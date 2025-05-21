#!/bin/bash

# PATHS 
MAC_MUSIC="/Users/username/Music/Music/Media.localized/Music/" # replace username/change path
PHONE_MUSIC="/sdcard/Music/" # sdcard is a standard directory for android (doesn't mean you need an SD card)
PHONE_PHOTOS="/sdcard/DCIM/Camera/"
MAC_PHOTOS="/Users/username/Pictures/Phone DCIM" # replace username/change path

# CHECK ADB 
if ! command -v adb &> /dev/null; then
  echo "adb not found."
  exit 1
fi

adb devices | grep -q "device"
if [ $? -ne 0 ]; then
  echo "No device connected."
  exit 1
fi

# MUSIC SYNC
echo "Syncing music..."
adb push --sync "$MAC_MUSIC" "$PHONE_MUSIC" > /dev/null 2>&1
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://$PHONE_MUSIC > /dev/null 2>&1
echo "Music synced."

# PHOTOS SYNC
echo -n "Syncing photos..."
mkdir -p "$MAC_PHOTOS"
PHOTO_LIST=$(adb shell ls "$PHONE_PHOTOS" | tr -d '\r')

COUNT=0
for FILE in $PHOTO_LIST; do
  LOCAL="$MAC_PHOTOS/$FILE"
  if [ ! -f "$LOCAL" ]; then
    adb pull "$PHONE_PHOTOS/$FILE" "$MAC_PHOTOS" > /dev/null 2>&1
    MODTIME=$(adb shell stat -c %Y "$PHONE_PHOTOS/$FILE" 2>/dev/null | tr -d '\r')
    [ -n "$MODTIME" ] && touch -t "$(date -r $MODTIME +%Y%m%d%H%M.%S)" "$LOCAL"
    ((COUNT++))
    echo -n "."
  fi
done

echo "$COUNT new photos/videos synced."


