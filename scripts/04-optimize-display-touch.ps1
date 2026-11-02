# Display & Touchscreen Optimization Module
param(
    [string]$AdbPath = "",
    [string]$DeviceId = "",
    [switch]$Lock60Hz = $false
)

$PSScriptRootCurrent = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRootCurrent\00-detect-environment.ps1"

if (-not $AdbPath) { $AdbPath = Get-AdbExecutable }
if (-not $DeviceId) { $DeviceId = Get-ConnectedDevice -AdbPath $AdbPath }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [4/7] DISPLAY, GESTURE LATENCY & TOUCHSCREEN STABILIZATION" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Fix Samsung One UI Gesture Stutter (Setting to 0.5x prevents touch pipeline freeze)
Write-Host "1. Setting Window/Transition/Animator scales to 0.5x..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global window_animation_scale 0.5
& $AdbPath -s $DeviceId shell settings put global transition_animation_scale 0.5
& $AdbPath -s $DeviceId shell settings put global animator_duration_scale 0.5
Write-Host " [OK]" -ForegroundColor Green

# 2. Disable Real-time GPU Window Blurs (Saves Mali GPU from severe frame drops)
Write-Host "2. Disabling Real-time GPU Window Blurs & Reducing Transparency..." -NoNewline
& $AdbPath -s $DeviceId shell settings put global disable_window_blurs 1
& $AdbPath -s $DeviceId shell settings put secure accessibility_reduce_transparency 1
Write-Host " [OK]" -ForegroundColor Green

# 3. Touch Screen Stabilization (Essential for aftermarket / non-original replacement screens)
if ($Lock60Hz) {
    Write-Host "3. Locking Display Refresh Rate to 60Hz (Prevents Digitizer Ghost Touch)..." -NoNewline
    & $AdbPath -s $DeviceId shell settings put system refresh_rate_mode 0
    & $AdbPath -s $DeviceId shell settings put system peak_refresh_rate 60.0
    & $AdbPath -s $DeviceId shell settings put system min_refresh_rate 60.0
    & $AdbPath -s $DeviceId shell settings put system touch_sensitivity 0
    & $AdbPath -s $DeviceId shell settings put system accidental_touch_prevention 1
    Write-Host " [OK - 60Hz LOCKED]" -ForegroundColor Yellow
} else {
    Write-Host "3. Normalizing Touch Sensitivity & Accidental Touch Protection..." -NoNewline
    & $AdbPath -s $DeviceId shell settings put system touch_sensitivity 0
    & $AdbPath -s $DeviceId shell settings put system accidental_touch_prevention 1
    Write-Host " [OK]" -ForegroundColor Green
}

Write-Host "`nDisplay & Gesture Touch optimizations applied successfully!" -ForegroundColor Green
