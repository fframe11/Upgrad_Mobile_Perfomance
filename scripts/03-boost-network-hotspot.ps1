# Network, Cellular & Wi-Fi Hotspot Boost
param(
    [string]$AdbPath = "",
    [string]$DeviceId = ""
)

$PSScriptRootCurrent = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRootCurrent\00-detect-environment.ps1"

if (-not $AdbPath) { $AdbPath = Get-AdbExecutable }
if (-not $DeviceId) { $DeviceId = Get-ConnectedDevice -AdbPath $AdbPath }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [3/7] BOOSTING CELLULAR, DNS & HOTSPOT HARDWARE OFFLOAD" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Hardware Tethering Offload (Bypasses CPU kernel routing)
Write-Host "1. Enabling Hardware Tethering Acceleration (Offload)..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global tether_offload_disabled 0
Write-Host " [OK]" -ForegroundColor Green

# 2. Lock Hotspot Band to 5 GHz (802.11ac high bandwidth, cuts 2.4GHz interference)
Write-Host "2. Configuring Hotspot Band to 5 GHz (802.11ac)..." -NoNewline
& $AdbPath -s $DeviceId shell settings put secure wifi_ap_band 1
& $AdbPath -s $DeviceId shell settings put global wifi_ap_band 1
Write-Host " [OK]" -ForegroundColor Green

# 3. Configure Native Cloudflare Private DNS (one.one.one.one)
Write-Host "3. Activating Native Cloudflare Private DNS over TLS (one.one.one.one)..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global private_dns_mode hostname
& $AdbPath -s $DeviceId shell settings put global private_dns_specifier one.one.one.one
Write-Host " [OK]" -ForegroundColor Green

Write-Host "`nNetwork, Hotspot Hardware Offload, and Cloudflare DNS configured successfully!" -ForegroundColor Green
