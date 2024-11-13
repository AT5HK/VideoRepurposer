#!/bin/bash

# Check if the input video file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 input_video_file"
  exit 1
fi

# Input file name
input_video="$1"

# Default number of videos to generate (if not specified)
num_videos=1

# Parse the "video=" argument if provided
for arg in "$@"; do
  case $arg in
    videos=*)
      num_videos="${arg#*=}"
      ;;
  esac
done

# Function to generate random values for contrast, brightness, saturation, and scaling
generate_random_values() {
  # Generate random contrast between 0.9 and 1.1
  contrast=$(echo "scale=2; $RANDOM / 32767 * 0.2 + 0.9" | bc)  # Random between 0.9 and 1.1
  
  # Generate random brightness between -0.1 and 0.1
  brightness=$(echo "scale=2; $RANDOM / 32767 * 0.2 - 0.1" | bc)  # Random between -0.1 and 0.1
  
  # Generate random saturation between 0.5 and 1.5
  saturation=$(echo "scale=2; $RANDOM / 32767 + 0.5" | bc)  # Random between 0.5 and 1.5
  
  # Generate a random scaling factor between -100 and +100 for the width
  scale_factor=$((RANDOM % 201 - 100))  # Random number between -100 and 100
  
  # Get the original width and height of the video
  original_width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$input_video")
  original_height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$input_video")
  
  # Calculate the new width by adding the scale factor
  new_width=$((original_width + scale_factor))
  
  # Ensure new width is divisible by 2 (if it's odd, subtract 1)
  if ((new_width % 2 != 0)); then
    new_width=$((new_width - 1))
  fi
  
  # Calculate the new height to maintain the original aspect ratio
  new_height=$(echo "scale=2; $new_width * $original_height / $original_width" | bc)
}

# Create 3 different output videos with random adjustments
for i in $(seq 1 $num_videos); do
  # Generate random values for contrast, brightness, saturation, and scaling
  generate_random_values

  # Output video file name
  output_video="output_${i}_$(basename "$input_video")"

  # Apply the adjustments and scaling, then save the video with quiet logging
  ffmpeg -loglevel warning -i "$input_video" -map_metadata -1 -vf "scale=$new_width:-2,eq=contrast=$contrast:brightness=$brightness:saturation=$saturation" -c:v libx264 -c:a copy "$output_video"

  # Output the applied settings
  echo "Generated Video $i with settings:"
  echo "Contrast: $contrast"
  echo "Brightness: $brightness"
  echo "Saturation: $saturation"
  echo "Width: $new_width, Height: $new_height"
  echo "Output video: $output_video"
  echo "---------------------------------------"
  echo \n
done
