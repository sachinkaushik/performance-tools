#!/bin/bash
#
# Copyright (C) 2024 Intel Corporation.
#
# SPDX-License-Identifier: Apache-2.0
#

# up to 3 bottles and human hand
./format_avc_mp4.sh coca-cola-4465029.mp4 https://www.pexels.com/download/video/4465029 "$1" "$2" "$3"
./format_avc_mp4.sh vehicle-bike.mp4 https://www.pexels.com/download/video/853908 "$1" "$2" "$3"
./format_avc_mp4.sh group-of-friends-smiling-3248275.mp4 https://www.pexels.com/download/video/3248275 "$1" "$2" "$3"
#./format_avc_mp4.sh grocery-items-on-the-kitchen-shelf-4983686.mp4 https://www.pexels.com/video/4983686/download/ $1 $2 $3
./format_avc_mp4.sh video_of_people_walking_855564.mp4 https://www.pexels.com/download/video/855564 "$1" "$2" "$3"
./format_avc_mp4.sh barcode.mp4 https://github.com/antoniomtz/sample-clips/raw/main/barcode.mp4 "$1" "$2" "$3"

echo "######## Downloaded and formatted sample videos for benchmarking #######"

CONFIG_JSON="${1:-../../configs/camera_to_workload.json}"

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

# Extract all video entries from camera_to_workload.json
jq -c '.. | objects | select(has("fileSrc")) | {fileSrc, width, height, fps}' "$CONFIG_JSON" | while read -r entry; do
    fileSrc=$(echo "$entry" | jq -r '.fileSrc')
    width=$(echo "$entry" | jq -r '.width // empty')
    height=$(echo "$entry" | jq -r '.height // empty')
    fps=$(echo "$entry" | jq -r '.fps // empty')

    # Parse fileSrc: either "name|url" or just "url"
    if [[ "$fileSrc" == *"|"* ]]; then
        filename="${fileSrc%%|*}"
        url="${fileSrc#*|}"
    else
        url="$fileSrc"
        filename=$(basename "$url")
    fi
    filename="${filename%.mp4}.mp4" # Ensure .mp4 extension

    echo "Processing: $filename from $url (width=$width, height=$height, fps=$fps)"
    ./format_avc_mp4.sh "$filename" "$url" "$width" "$height" "$fps"
done