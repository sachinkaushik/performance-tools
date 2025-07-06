#!/bin/bash
#
# Copyright (C) 2024 Intel Corporation.
#
# SPDX-License-Identifier: Apache-2.0
#

./format_avc_mp4.sh coca-cola-4465029.mp4 https://www.pexels.com/download/video/4465029 "$1" "$2" "$3"
./format_avc_mp4.sh vehicle-bike.mp4 https://www.pexels.com/download/video/853908 "$1" "$2" "$3"
./format_avc_mp4.sh group-of-friends-smiling-3248275.mp4 https://www.pexels.com/download/video/3248275 "$1" "$2" "$3"
#./format_avc_mp4.sh grocery-items-on-the-kitchen-shelf-4983686.mp4 https://www.pexels.com/video/4983686/download/ $1 $2 $3
./format_avc_mp4.sh video_of_people_walking_855564.mp4 https://www.pexels.com/download/video/855564 "$1" "$2" "$3"
./format_avc_mp4.sh barcode.mp4 https://github.com/antoniomtz/sample-clips/raw/main/barcode.mp4 "$1" "$2" "$3"

# Path to the camera configuration JSON file
CAMERA_CONFIG="../../configs/camera_to_workload.json"

# Check if the config file exists
if [ ! -f "$CAMERA_CONFIG" ]; then
    echo "Error: Camera configuration file not found at $CAMERA_CONFIG"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq."
    exit 1
fi

# Read camera configurations and process each camera
jq -r '.lane_config.cameras[] | @base64' "$CAMERA_CONFIG" | while read -r camera_data; do
    # Decode the base64 encoded camera data
    camera_json=$(echo "$camera_data" | base64 --decode)
    
    # Extract fileSrc (mandatory)
    fileSrc=$(echo "$camera_json" | jq -r '.fileSrc')
    
    if [ "$fileSrc" = "null" ] || [ -z "$fileSrc" ]; then
        echo "Warning: Skipping camera with missing fileSrc"
        continue
    fi
    
    # Split fileSrc by '|' to get filename and URL
    filename=$(echo "$fileSrc" | cut -d'|' -f1)
    url=$(echo "$fileSrc" | cut -d'|' -f2)
    
    # Extract optional parameters
    width=$(echo "$camera_json" | jq -r '.width // empty')
    height=$(echo "$camera_json" | jq -r '.height // empty')
    fps=$(echo "$camera_json" | jq -r '.fps // empty')
    
    # Build the command arguments
    cmd_args=""
    if [ -n "$width" ] && [ -n "$height" ] && [ -n "$fps" ]; then
        cmd_args="\"$width\" \"$height\" \"$fps\""
    elif [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
        cmd_args="\"$1\" \"$2\" \"$3\""
    fi
    
    # Execute the format command
    echo "Processing: $filename from $url"
    if [ -n "$cmd_args" ]; then
        eval "./format_avc_mp4.sh \"$filename\" \"$url\" $cmd_args"
    else
        ./format_avc_mp4.sh "$filename" "$url"
    fi
done

echo "All camera videos processed."