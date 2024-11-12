#!/bin/bash

# Check if the input video file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 input_video_file"
  exit 1
fi

# Input file name
input_video="$1"

# Function to generate random values
generate_random_values() {
  contrast=$(echo "scale=2; $RANDOM % 20 + 50" | bc)  # Random between 50 and 70
  brightness=$(echo "scale=2; $RANDOM % 40 - 20" | bc)  # Random between -20 and 20
  saturation=$(echo "scale=2; $RANDOM % 40 + 50" | bc)  # Random between 50 and 90
}

# Create 3 different output videos
for i in {1..3}; do
  # Generate random values for contrast, brightness, and saturation
  generate_random_values

  # Output video file name
  output_video="output_${i}_$(basename "$input_video")"

  # Apply the adjustments and save the video
  ffmpeg -i "$input_video" -vf "eq=contrast=$contrast:brightness=$brightness:saturation=$saturation" -c:a copy "$output_video"

  # Output the applied settings
  echo "Generated Video $i with settings:"
  echo "Contrast: $contrast"
  echo "Brightness: $brightness"
  echo "Saturation: $saturation"
  echo "Output video: $output_video"
done
