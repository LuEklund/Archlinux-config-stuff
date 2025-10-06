#!/bin/bash
# record_gif.sh — record a region with wf-recorder, then convert it to a GIF

# === CONFIG ===
BASE_DIR=~/Videos
MP4_DIR="$BASE_DIR/quickGif_mp4"
GIF_DIR="$BASE_DIR/quickGif_gif"
mkdir -p "$MP4_DIR" "$GIF_DIR"

# Timestamp for filenames
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# File paths
MP4_FILE="$MP4_DIR/recording_$DATE.mp4"
GIF_FILE="$GIF_DIR/recording_$DATE.gif"

# === RECORD ===
echo "🎥 Select region to record..."
GEOM=$(slurp)
echo "Recording... (press Ctrl+C to stop)"
wf-recorder -g "$GEOM" -f "$MP4_FILE"

if [[ ! -f "$MP4_FILE" ]]; then
    notify-send "❌ Recording failed — no MP4 file created!"
    echo "Error: MP4 file not found, aborting GIF conversion."
    exit 1
fi

# === CONVERT ===
echo "🎞 Converting to GIF..."
# Create an optimized palette and apply it for smooth colors
ffmpeg -y -i "$MP4_FILE" -vf "fps=15,scale=640:-1:flags=lanczos,palettegen" /tmp/palette.png
ffmpeg -y -i "$MP4_FILE" -i /tmp/palette.png -filter_complex "fps=15,scale=640:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" "$GIF_FILE"
rm /tmp/palette.png

# === DONE ===
notify-send "✅ GIF saved!" "$GIF_FILE"
echo "GIF saved to: $GIF_FILE"

