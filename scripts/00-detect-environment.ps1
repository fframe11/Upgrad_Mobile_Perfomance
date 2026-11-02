# Helper module for detecting ADB and connected target Android device
function Get-AdbExecutable {
    param([string]$ExplicitPath)
    if ($ExplicitPath -and (Test-Path $ExplicitPath)) {
        return $ExplicitPath
    }
    $cmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }
    $candidates = @(
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:ProgramFiles\Android\platform-tools\adb.exe",
        "$env:ProgramFiles(x86)\Android\android-sdk\platform-tools\adb.exe",
        "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) {
            return $path
        }
    }
    throw "ADB executable not found. Please ensure Android SDK platform-tools is installed or ADB is in your PATH."
}

function Get-ConnectedDevice {
    param([string]$AdbPath)
    $output = & $AdbPath devices -l
    $lines = $output | Where-Object { $_ -match "\bdevice\b" -and $_ -notmatch "List of devices" }
    if (-not $lines) {
        $unauthorized = $output | Where-Object { $_ -match "unauthorized" }
        if ($unauthorized) {
            throw "Device detected but UNAUTHORIZED. Please unlock your device and tap 'Allow USB debugging'."
        }
        throw "No connected Android devices detected via ADB. Check USB cable and ensure USB debugging is enabled."
    }
    # Return first device id
    $firstLine = $lines[0].Trim()
    $devId = ($firstLine -split "\s+")[0]
    return $devId
}

Export-ModuleMember -Function Get-AdbExecutable, Get-ConnectedDevice -ErrorAction SilentlyContinue
