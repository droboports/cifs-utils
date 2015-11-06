CPPFLAGS="${CPPFLAGS:-} -I${PWD}/src/include"
CFLAGS="${CFLAGS:-} -ffunction-sections -fdata-sections"
LDFLAGS="-L${DEST}/lib -L${DEPS}/lib -Wl,--gc-sections"

### LIBCAP ###
_build_libcap() {
local VERSION="2.24"
local FOLDER="libcap-${VERSION}"
local FILE="${FOLDER}.tar.xz"
local URL="https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/${FILE}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_xz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
make install prefix="${DEPS}" \
  BUILD_CC="${CC}" CC="${CC}" CFLAGS="${CFLAGS} ${CPPFLAGS}" \
  PAM_CAP=no LIBATTR=no
rm -vf "${DEPS}/lib/libcap.so"*
popd
}

### CIFS-UTILS ###
_build_cifs_utils() {
local VERSION="6.4"
local FOLDER="cifs-utils-${VERSION}"
local FILE="${FOLDER}.tar.bz2"
local URL="https://download.samba.org/pub/linux-cifs/cifs-utils/${FILE}"

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="/" \
  --disable-pam --disable-systemd \
  ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
make
make install DESTDIR="${DEST}"
"${STRIP}" -s -R .comment -R .note -R .note.ABI-tag "${DEST}/sbin/mount.cifs"
popd
}

_build() {
  _build_libcap
  _build_cifs_utils
  _package
}
