#!/bin/bash
# TripTalk App Store Screenshot Capture Script
# Usage: ./scripts/capture_screenshots.sh
#
# Prerequisites:
# 1. Simulator must be running with TripTalk installed
# 2. Run from TripTalk project root
#
# This script resets app state and captures each onboarding screen.
# For in-app screens (catalog, detail, etc.), it sets up state and
# prompts you to navigate manually, then captures on keypress.

set -e

DEVICE="FDCD17A2-22FF-486B-ACBA-75BF27E261AA"  # iPhone 15 Pro Max
OUTDIR="$HOME/Desktop/lilly_output/screenshots"
BUNDLE="com.triptalk.app"

mkdir -p "$OUTDIR"

echo "📱 TripTalk Screenshot Capture"
echo "================================"
echo ""

# Helper functions
screenshot() {
    local name=$1
    xcrun simctl io "$DEVICE" screenshot "$OUTDIR/$name.png" 2>/dev/null
    echo "  ✅ Captured: $name.png"
}

set_defaults() {
    for kv in "$@"; do
        local key="${kv%%=*}"
        local val="${kv#*=}"
        if [ "$val" = "true" ] || [ "$val" = "false" ]; then
            xcrun simctl spawn "$DEVICE" defaults write "$BUNDLE" "$key" -bool "$val"
        else
            xcrun simctl spawn "$DEVICE" defaults write "$BUNDLE" "$key" "$val"
        fi
    done
}

relaunch() {
    xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
    sleep 1
    xcrun simctl launch "$DEVICE" "$BUNDLE"
    sleep 3
}

wait_for_user() {
    echo ""
    echo "  👉 $1"
    echo "  Press ENTER when ready to capture..."
    read -r
}

# ==========================================
# Auto-capture: Screens controllable via state
# ==========================================

echo "🔄 Capturing state-controlled screens..."

# 1. Age Gate
echo ""
echo "1/8: Age Gate"
set_defaults "ageVerified=false" "hasSeenOnboarding=false" "guest_mode=false"
relaunch
screenshot "01_age_gate"

# 2. Onboarding Page 1
echo "2/8: Onboarding"
set_defaults "ageVerified=true" "hasSeenOnboarding=false" "guest_mode=false"
relaunch
screenshot "02_onboarding"

# 3. Sign In
echo "3/8: Sign In"
set_defaults "ageVerified=true" "hasSeenOnboarding=true" "guest_mode=false"
relaunch
screenshot "03_sign_in"

# 4. Home
echo "4/8: Home"
set_defaults "ageVerified=true" "hasSeenOnboarding=true" "guest_mode=true"
relaunch
screenshot "04_home"

# ==========================================
# Manual-assist: Navigate then capture
# ==========================================

echo ""
echo "🖐  Manual navigation needed for remaining screens."
echo "  The app is on the Home screen. Navigate using the simulator."
echo ""

# 5. Catalog
wait_for_user "Tap the CATALOG tab (book icon, 3rd tab)"
screenshot "05_catalog"

# 6. Strain Detail
wait_for_user "Tap any strain (e.g., Golden Teachers) to open its detail page"
screenshot "06_strain_detail"

# 7. Explore
wait_for_user "Go back, then tap the EXPLORE tab (safari icon, 2nd tab)"
screenshot "07_explore"

# 8. Services
wait_for_user "Tap the SERVICES tab (building icon, 5th tab)"
screenshot "08_services"

# 9. Profile (bonus)
wait_for_user "Tap the PROFILE tab (person icon, 6th tab) and scroll to Crisis Resources"
screenshot "09_profile_crisis"

echo ""
echo "================================"
echo "✅ All screenshots saved to: $OUTDIR"
echo ""
ls -la "$OUTDIR"/*.png 2>/dev/null | awk '{print "  " $NF}'
echo ""
echo "📐 These are 6.7\" iPhone 15 Pro Max (1290x2796) screenshots."
echo "   Ready for App Store Connect upload."
