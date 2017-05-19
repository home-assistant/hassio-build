
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://resinhup"

do_install_append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/resinhup ${D}${bindir}

    sed -i -e 's:@MACHINE@:${HASSIO_MACHINE}:g' ${D}${bindir}/resinhup
    sed -i -e 's:@RESINOS_HASSIO_VERSION@:${RESINOS_HASSIO_VERSION}:g' ${D}${bindir}/resinhup
}
