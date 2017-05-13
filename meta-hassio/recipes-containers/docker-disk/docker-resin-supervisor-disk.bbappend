
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SUPERVISOR_REPOSITORY_armv5 = "homeassistant/armhf-hassio-supervisor"
SUPERVISOR_REPOSITORY_armv6 = "homeassistant/armhf-hassio-supervisor"
SUPERVISOR_REPOSITORY_armv7a = "homeassistant/armhf-hassio-supervisor"
SUPERVISOR_REPOSITORY_armv7ve = "homeassistant/armhf-hassio-supervisor"
SUPERVISOR_REPOSITORY_aarch64 = "homeassistant/aarch64-hassio-supervisor"
SUPERVISOR_REPOSITORY_x86 = "homeassistant/i386-hassio-supervisor"
SUPERVISOR_REPOSITORY_x86-64 = "homeassistant/amd64-hassio-supervisor"

SUPERVISOR_TAG = "${HASSIO_SUPERVISOR_TAG}"
TARGET_REPOSITORY = "${SUPERVISOR_REPOSITORY}"
TARGET_TAG = "${SUPERVISOR_TAG}"

SYSTEMD_AUTO_ENABLE = "enable"

SYSTEMD_SERVICE_${PN}_remove = "update-resin-supervisor.timer"
SYSTEMD_SERVICE_${PN}_remove = "update-resin-supervisor.service"

do_install_append () {
    install -d ${D}${sysconfdir}/resin-supervisor
    sed -i -e 's:@HOMEASSISTANT_REPOSITORY@:${HOMEASSISTANT_REPOSITORY}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf
    sed -i -e 's:@MACHINE@:${HASSIO_MACHINE}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf
    sed -i -e 's:@RESINOS_HASSIO_VERSION@:${RESINOS_HASSIO_VERSION}:g' ${D}${sysconfdir}/resin-supervisor/supervisor.conf

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        rm -f ${D}${systemd_unitdir}/system/update-resin-supervisor.timer
        rm -f ${D}${systemd_unitdir}/system/update-resin-supervisor.service
    fi
}
