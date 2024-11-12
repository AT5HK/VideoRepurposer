#!/bin/bash

# Check if the input video file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 input_video_file"
  exit 1
fi

# Input file name
input_video="$1"

# Function to generate random values for contrast, brightness, and saturation
generate_random_values() {
  # Generate random contrast between 0.9 and 1.1
  contrast=$(echo "scale=2; $RANDOM / 32767 * 0.2 + 0.9" | bc)  # Random between 0.9 and 1.1
  
  # Generate random brightness between -0.1 and 0.1
  brightness=$(echo "scale=2; $RANDOM / 32767 * 0.2 - 0.1" | bc)  # Random between -0.1 and 0.1
  
  # Generate random saturation between 0.5 and 1.5
  saturation=$(echo "scale=2; $RANDOM / 32767 + 0.5" | bc)  # Random between 0.5 and 1.5
}

# Create 3 different output videos with random adjustments
for i in {1..3}; do
  # Generate random values for contrast, brightness, and saturation
  generate_random_values

  # Output video file name
  output_video="output_${i}_$(basename "$input_video")"

  # Apply the adjustments and save the video with quiet logging
  ffmpeg -loglevel quiet -i "$input_video" -vf "eq=contrast=$contrast:brightness=$brightness:saturation=$saturation" -c:a copy "$output_video"

  # Output the applied settings
  echo "Generated Video $i with settings:"
  echo "Contrast: $contrast"
  echo "Brightness: $brightness"
  echo "Saturation: $saturation"
  echo "Output video: $output_video"
done
