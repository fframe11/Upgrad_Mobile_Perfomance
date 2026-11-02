# Ahead-Of-Time (AOT) ART Speed-Profile Code Compilation Module
param(
    [string]$AdbPath = "",
    [string]$DeviceId = "",
    [string[]]$CustomPackages = @()
)

$PSScriptRootCurrent = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$PSScriptRootCurrent\00-detect-environment.ps1"

if (-not $AdbPath) { $AdbPath = Get-AdbExecutable }
if (-not $DeviceId) { $DeviceId = Get-ConnectedDevice -AdbPath $AdbPath }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [6/7] AHEAD-OF-TIME (AOT) ART SPEED-PROFILE COMPILATION" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$defaultPackages = @(
    "com.sec.android.app.launcher",
    "com.samsung.android.honeyboard",
    "com.sec.android.gallery3d",
    "com.android.chrome",
    "com.facebook.orca",
    "com.instagram.android",
    "com.google.android.youtube"
)

$targetList = $defaultPackages + $CustomPackages | Select-Object -Unique

foreach ($pkg in $targetList) {
    $exists = & $AdbPath -s $DeviceId shell pm path $pkg 2>$null
    if ($exists) {
        Write-Host "Compiling package into native machine code: $pkg..." -NoNewline
        $res = & $AdbPath -s $DeviceId shell cmd package compile -m speed-profile -f $pkg 2>$null
        if ($res -match "Success") {
            Write-Host " [SUCCESS]" -ForegroundColor Green
        } else {
            Write-Host " [SKIPPED / $res]" -ForegroundColor DarkGray
        }
    }
}

Write-Host "`nAOT ART machine code compilation completed! Apps will launch faster with minimal JIT overhead." -ForegroundColor Green
