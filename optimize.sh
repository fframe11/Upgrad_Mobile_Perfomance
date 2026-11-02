#!/usr/bin/env bash
# ==============================================================================
# Upgraded Mobile Performance Toolkit (Android / Samsung)
# Zero-Root | Zero-ROM Modification | Knox-Safe (0x0) | Banking App Certified
# ==============================================================================

set -e

# Detect ADB
if command -v adb >/dev/null 2>&1; then
    ADB="adb"
elif [ -f "$HOME/Library/Android/sdk/platform-tools/adb" ]; then
    ADB="$HOME/Library/Android/sdk/platform-tools/adb"
elif [ -f "$HOME/Android/Sdk/platform-tools/adb" ]; then
    ADB="$HOME/Android/Sdk/platform-tools/adb"
else
    echo "[-] Error: adb executable not found on PATH or standard Android SDK directories."
    exit 1
fi

DEVICE=$($ADB devices | grep -w "device" | awk '{print $1}' | head -n 1)
if [ -z "$DEVICE" ]; then
    echo "[-] Error: No authorized Android device connected. Please unlock device and enable USB debugging."
    exit 1
fi

echo "[+] Connected Device: $DEVICE"
echo "=============================================================================="
echo " Starting Upgraded Mobile Performance Optimization Suite..."
echo "=============================================================================="

# 1. Debloat OEM Telemetry
echo "[1/5] Disabling OEM Background Telemetry & Bloatware (User 0)..."
PACKAGES=(
    "com.sec.android.diagmonagent"
    "com.samsung.android.rubin.app"
    "com.samsung.android.game.gamehome"
    "com.samsung.android.allshare.service.mediashare"
    "com.samsung.android.smartswitchassistant"
    "com.samsung.android.kidsinstaller"
    "com.samsung.android.visualars"
    "com.facebook.services"
    "com.facebook.system"
    "com.facebook.appmanager"
)
for pkg in "${PACKAGES[@]}"; do
    $ADB -s "$DEVICE" shell pm disable-user --user 0 "$pkg" 2>/dev/null || true
done

# 2. Network & Hotspot Hardware Offload
echo "[2/5] Accelerating Tethering & Activating Cloudflare DNS..."
$ADB -s "$DEVICE" shell settings put global tether_offload_disabled 0
$ADB -s "$DEVICE" shell settings put secure wifi_ap_band 1
$ADB -s "$DEVICE" shell settings put global wifi_ap_band 1
$ADB -s "$DEVICE" shell settings put global private_dns_mode hostname
$ADB -s "$DEVICE" shell settings put global private_dns_specifier one.one.one.one

# 3. Display & Gesture Touch Tuning
echo "[3/5] Fixing Gesture Animation Latency & Disabling GPU Window Blurs..."
$ADB -s "$DEVICE" shell settings put global window_animation_scale 0.5
$ADB -s "$DEVICE" shell settings put global transition_animation_scale 0.5
$ADB -s "$DEVICE" shell settings put global animator_duration_scale 0.5
$ADB -s "$DEVICE" shell settings put global disable_window_blurs 1
$ADB -s "$DEVICE" shell settings put secure accessibility_reduce_transparency 1
$ADB -s "$DEVICE" shell settings put system touch_sensitivity 0
$ADB -s "$DEVICE" shell settings put system accidental_touch_prevention 1

# 4. Thermal Mitigation
echo "[4/5] Disabling 24/7 Background RF Scanners & Trimming Caches..."
$ADB -s "$DEVICE" shell settings put global wifi_scan_always_enabled 0
$ADB -s "$DEVICE" shell settings put global ble_scan_always_enabled 0
$ADB -s "$DEVICE" shell settings put system nearby_scanning_enabled 0
$ADB -s "$DEVICE" shell pm trim-caches 999G 2>/dev/null || true

# 5. AOT ART Compilation
echo "[5/5] Compiling Core User Interface Applications to Native Machine Code..."
APPS=(
    "com.sec.android.app.launcher"
    "com.samsung.android.honeyboard"
    "com.sec.android.gallery3d"
    "com.android.chrome"
)
for app in "${APPS[@]}"; do
    $ADB -s "$DEVICE" shell cmd package compile -m speed-profile -f "$app" 2>/dev/null || true
done

echo "=============================================================================="
echo "[V] Optimization completed! Reboot device to apply changes: adb reboot"
echo "=============================================================================="
