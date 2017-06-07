param (
    [string]
    $DataSharePath = "f:\docker\hassio",

    [string]
    $BinaryLocation = "$($env:ALLUSERSPROFILE)/hass",

    [string]
    $HassIoSourceUrlRoot = "https://raw.githubusercontent.com/home-assistant/hassio-build",

    [string]
    $HassIoSourceBranch = "master"

)
# Setup Variables
$DOCKER_REPO="homeassistant"
$ARCH="amd64"
$URL_VERSION="https://raw.githubusercontent.com/home-assistant/hassio/master/version.json"
$URL_START_HASSIO="$HassIoSourceUrlRoot/$HassIoSourceBranch/install/misc/hassio-start"
$URL_GENERIC_HC="$HassIoSourceUrlRoot/$HassIoSourceBranch/generic-hc"
$URL_SERVICE_HASSIO="$HassIoSourceUrlRoot/$HassIoSourceBranch/install/systemd/hassio-supervisor.service"
$URL_SERVICE_HOSTCONTROLL="$HassIoSourceUrlRoot/$HassIoSourceBranch/install/systemd/hassio-hc.service"
$MACHINE=$ARCH
$HOMEASSISTANT_DOCKER="$DOCKER_REPO/$MACHINE-homeassistant"
$HASSIO_DOCKER="$DOCKER_REPO/i386-hassio-supervisor"


if(!(Test-Path -Path $DataSharePath)) {
    New-Item -Path $DataSharePath -ItemType Directory
}

if(!(Test-Path -Path $BinaryLocation)) {
    New-Item -Path $BinaryLocation -ItemType Directory
}

# Read infos from web
$HASSIO_VERSION= (ConvertFrom-Json  (Invoke-WebRequest -Uri $URL_VERSION).Content).hassio
$GENERIC_HC_VERSION= (ConvertFrom-Json  (Invoke-WebRequest -Uri $URL_VERSION).Content).generic

Write-Host "HASSIO_VERSION = $HASSIO_VERSION"
Write-Host "GENERIC_HC_VERSION = $GENERIC_HC_VERSION"


##
# Install supervisor
Write-Host "[INFO] Install supervisor docker"
docker pull "$($HASSIO_DOCKER):$($HASSIO_VERSION)"
docker tag "$($HASSIO_DOCKER):$($HASSIO_VERSION)" "$($HASSIO_DOCKER):latest" 

##
# install generic hostcontrol
Write-Host "[INFO] Install generic HostControl"
(Invoke-WebRequest -Uri "$URL_GENERIC_HC/$GENERIC_HC_VERSION.ps1").Content | Set-Content -Path "$BinaryLocation/hassio-hc.ps1" -Encoding UTF8

##
# install start-hassio
Write-Host "[INFO] Install startup scripts"
(Invoke-WebRequest -Uri "$URL_START_HASSIO.ps1").Content | Set-Content -Path "$BinaryLocation/hassio-start.ps1" -Encoding UTF8


sed -i "s|%%SUPERVISOR_IMAGE%%|$HASSIO_DOCKER|g" "$BIN_DIR/hassio-start"
sed -i "s|%%HOMEASSISTANT_IMAGE%%|$HOMEASSISTANT_DOCKER|g" "$BIN_DIR/hassio-start"
sed -i "s|%%DATA_SHARE%%|$DATA_SHARE|g" "$BIN_DIR/hassio-start"

chmod a+x "$BIN_DIR/hassio-start"
