#requires -version 4.0
#requires -runasadministrator

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
$URL_VERSION="https://raw.githubusercontent.com/home-assistant/hassio/master/version.json"
$URL_HASSIO_SERVICE="$HassIoSourceUrlRoot/$HassIoSourceBranch/install/service/hassio_supervisor.ps1"

$DOCKER_REPO="homeassistant"
$HOMEASSISTANT_DOCKER="$DOCKER_REPO/qemux86-64-homeassistant"
$HASSIO_DOCKER="$DOCKER_REPO/amd64-hassio-supervisor"

if(!(Test-Path -Path $DataSharePath)) {
    New-Item -Path $DataSharePath -ItemType Directory | Out-Null
}

if(!(Test-Path -Path $BinaryLocation)) {
    New-Item -Path $BinaryLocation -ItemType Directory | Out-Null
}

Write-Host "`n------------------------------------------" -ForegroundColor White
Write-Host "- HASS.IO Installer for Windows          -" -ForegroundColor White
Write-Host "-  This will install the hass.io system  -" -ForegroundColor White
Write-Host "-  on docker in a windows environemnt.   -" -ForegroundColor White
Write-Host "------------------------------------------" -ForegroundColor White

# Read infos from web
$HASSIO_VERSION= (ConvertFrom-Json  (Invoke-WebRequest -Uri $URL_VERSION).Content).hassio
$GENERIC_HC_VERSION= (ConvertFrom-Json  (Invoke-WebRequest -Uri $URL_VERSION).Content).generic

Write-Host "`n[INFO] Version Information"
Write-Host "HASSIO_VERSION = $HASSIO_VERSION"
Write-Host "GENERIC_HC_VERSION = $GENERIC_HC_VERSION"

##
# Install supervisor
Write-Host "[INFO] Install supervisor docker"
docker pull "$($HASSIO_DOCKER):$($HASSIO_VERSION)"
docker tag "$($HASSIO_DOCKER):$($HASSIO_VERSION)" "$($HASSIO_DOCKER):latest" 

##
# Download service script
Write-Host "[INFO] Downloading service script"
(Invoke-WebRequest -Uri "$URL_HASSIO_SERVICE").Content | Set-Content -Path "$BinaryLocation\hassio_supervisor.ps1" -Encoding UTF8

##
# Generate runtime configuration
Write-Host "[INFO] Generating configuration: $(Join-Path $hassIoConfiguration 'configuration.json')"
$defaultConfiguration = "{
    'datapath':'$DataSharePath', 
    'home_assistant_docker':'$HOMEASSISTANT_DOCKER',
    'hassio_supervisor_docker':'$HASSIO_DOCKER'
}"
Write-Host "[INFO] ... $defaultConfiguration "
$defaultConfiguration | Set-Content -Path (Join-Path $hassIoConfiguration 'configuration.json') -Encoding UTF8

##
# Installing Service
Write-Host "[INFO] Installing service."
& $BinaryLocation\hassio_supervisor.ps1 -Setup

##
# Starting Service
Write-Host "[INFO] Starting hass.io Service"

