#!/bin/bash

# Check if the input video file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 input_video_file"
  exit 1
fi

# Input video file
input_video="$1"

# Generate a random brightness value between -1.0 and 1.0
brightness=$(echo "scale=2; $RANDOM / 32767 * 2 - 1" | bc)

# Output video file name
output_video="random${brightness//./}_$(basename "$input_video")"

# Apply the random brightness using FFmpeg
ffmpeg -i "$input_video" -vf "eq=brightness=$brightness" -c:a copy "$output_video"

# Output the applied settings
echo "Random brightness value applied: $brightness"
echo "Output video: $output_video"
