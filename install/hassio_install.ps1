#requires -version 4.0
#requires -runasadministrator

param (
    [string]
    $DataSharePath = "/usr/share/hassio",

    [string]
    $BinaryLocation = "$($env:ALLUSERSPROFILE)\hassio",

    [string]
    $HassIoSourceUrlRoot = "https://raw.githubusercontent.com/home-assistant/hassio-build",

    [string]
    $HassIoSourceBranch = "master",

    [Switch]
    $Torch
)

# Setup Variables
$URL_VERSION="https://raw.githubusercontent.com/home-assistant/hassio/master/version.json"
$URL_HASSIO_SERVICE="$HassIoSourceUrlRoot/$HassIoSourceBranch/install/service/hassio_supervisor.ps1"

$DOCKER_REPO="homeassistant"
$HOMEASSISTANT_DOCKER="$DOCKER_REPO/qemux86-64-homeassistant"
$HASSIO_DOCKER="$DOCKER_REPO/amd64-hassio-supervisor"



Write-Host "`n------------------------------------------" -ForegroundColor White
Write-Host "-  Hass.io Installer for Windows         -" -ForegroundColor White
Write-Host "-  This will install a hass.io system    -" -ForegroundColor White
Write-Host "-  on Docker in a Windows environemnt.   -" -ForegroundColor White
Write-Host "------------------------------------------" -ForegroundColor White

# Read infos retrieved from the web
$HASSIO_VERSION= (ConvertFrom-Json  (Invoke-WebRequest -Uri $URL_VERSION).Content).hassio
$GENERIC_HC_VERSION= (ConvertFrom-Json  (Invoke-WebRequest -Uri $URL_VERSION).Content).generic

Write-Host "`n[INFO] Version Information"
Write-Host "HASSIO_VERSION = $HASSIO_VERSION"
Write-Host "GENERIC_HC_VERSION = $GENERIC_HC_VERSION"


if($Torch) {
    Write-Host "Warning. This will torch all areas before installation starts. You WILL lose data..."
    Write-Host " -- The Docker containers hassio_supervisor and homeassistant will be completly deleted. -- "
    Read-Host -Prompt "LAST CHANCE. Press CTRL-C to about this now!!!"
    
    if((Test-Path -Path $BinaryLocation)) {
        & $BinaryLocation\hassio_supervisor.ps1 -Remove
        Remove-Item -Path $BinaryLocation -Recurse -Force
    }    
    docker rm hassio_supervisor -f
    docker rmi "$($HASSIO_DOCKER)"
    docker rm homeassistant -f
    docker rmi "$($HOMEASSISTANT_DOCKER)"
}

if(!(Test-Path -Path $BinaryLocation)) {
    Write-Host "[INFO] Creating the binary location @ $BinaryLocation"
    New-Item -Path $BinaryLocation -ItemType Directory | Out-Null
}

$hassIoConfiguration = Join-Path $BinaryLocation 'configuration.json'

##
# Install supervisor
Write-Host "[INFO] Install supervisor docker"
docker pull "$($HASSIO_DOCKER):$($HASSIO_VERSION)"
docker tag "$($HASSIO_DOCKER):$($HASSIO_VERSION)" "$($HASSIO_DOCKER):latest" 

##
# Download service script
Write-Host "[INFO] Downloading service script to $BinaryLocation\hassio_supervisor.ps1"
(Invoke-WebRequest -Uri "$URL_HASSIO_SERVICE").Content | Set-Content -Path "$BinaryLocation\hassio_supervisor.ps1" -Encoding UTF8

##
# Generate runtime configuration
Write-Host "[INFO] Generating configuration: $hassIoConfiguration"
$defaultConfiguration = "{
    `"datapath`":`"$DataSharePath`", 
    `"home_assistant_docker`":`"$HOMEASSISTANT_DOCKER`",
    `"hassio_supervisor_docker`":`"$HASSIO_DOCKER`"
}"
Write-Host "[INFO] ... $defaultConfiguration "
$defaultConfiguration | Set-Content -Path $hassIoConfiguration -Encoding UTF8

##
# Installing Service
Write-Host "[INFO] Installing service."
$status = & $BinaryLocation\hassio_supervisor.ps1 -status
Write-Host "[INFO] Service Current Status: $status"
if($status -ne "Not Installed") {
    Write-Host "[INFO] Removing existing service."
    & $BinaryLocation\hassio_supervisor.ps1 -Remove
}

& $BinaryLocation\hassio_supervisor.ps1 -Setup


##
# Starting Service
Write-Host "[INFO] Starting hass.io Service"
& $BinaryLocation\hassio_supervisor.ps1 -Start

