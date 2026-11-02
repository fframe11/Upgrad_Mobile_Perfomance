# System Diagnostics Module
param(
    [string]$AdbPath = "",
    [string]$DeviceId = ""
)

$PSScriptRootCurrent = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRootCurrent\00-detect-environment.ps1"

if (-not $AdbPath) { $AdbPath = Get-AdbExecutable }
if (-not $DeviceId) { $DeviceId = Get-ConnectedDevice -AdbPath $AdbPath }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [1/7] ANDROID / SAMSUNG HARDWARE & PLATFORM DIAGNOSTICS" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Target Device: $DeviceId"

$brand       = & $AdbPath -s $DeviceId shell getprop ro.product.brand
$model       = & $AdbPath -s $DeviceId shell getprop ro.product.model
$board       = & $AdbPath -s $DeviceId shell getprop ro.board.platform
$hardware    = & $AdbPath -s $DeviceId shell getprop ro.hardware
$androidVer  = & $AdbPath -s $DeviceId shell getprop ro.build.version.release
$oneUiVer    = & $AdbPath -s $DeviceId shell getprop ro.build.version.oneui
$socModel    = & $AdbPath -s $DeviceId shell getprop ro.soc.model
$uptime      = & $AdbPath -s $DeviceId shell uptime

Write-Host "Device Model      : $brand $model"
Write-Host "SoC / Board       : $socModel ($board, $hardware)"
Write-Host "Android Version   : $androidVer (One UI: $oneUiVer)"
Write-Host "Kernel Uptime     : $uptime"

Write-Host "`n--- THERMAL & BATTERY METRICS ---" -ForegroundColor Yellow
$battery = & $AdbPath -s $DeviceId shell dumpsys battery
$tempMatch = ($battery | Select-String "temperature:\s*(\d+)").Matches.Groups[1].Value
$maxTempMatch = ($battery | Select-String "mSavedBatteryMaxTemp:\s*(\d+)").Matches.Groups[1].Value
if ($tempMatch) {
    $curTemp = [double]$tempMatch / 10.0
    Write-Host "Current Battery Temp : $curTemp C"
}
if ($maxTempMatch) {
    $histMax = [double]$maxTempMatch / 10.0
    Write-Host "Historical Max Temp  : $histMax C"
}

Write-Host "`n--- RAM & ZRAM PRESSURE ---" -ForegroundColor Yellow
$mem = & $AdbPath -s $DeviceId shell dumpsys meminfo
$mem | Select-String -Pattern "Total RAM:", "Free RAM:", "Used RAM:", "ZRAM:"

Write-Host "`n--- STORAGE STATUS ---" -ForegroundColor Yellow
& $AdbPath -s $DeviceId shell df -h /data

Write-Host "`n--- CURRENT TOP 10 CPU CONSUMERS ---" -ForegroundColor Yellow
& $AdbPath -s $DeviceId shell top -b -n 1 -m 10
