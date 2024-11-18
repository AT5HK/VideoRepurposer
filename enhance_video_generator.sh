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


# Function to generate a random string of 6 characters
generate_random_string() {
  # Generates a random string of 6 characters (letters and numbers)
  mktemp -u XXXXXX
}

# Get the original file extension of the input video
input_extension="${input_video##*.}"

# Create the output videos with random adjustments
for i in $(seq 1 $num_videos); do


  # Generate a random name for the output video (6 alphanumeric characters)
  random_name=$(generate_random_string)

  # Output video file name using the random string, keeping the original extension
  output_video="${random_name}.${input_extension}"

# Random values for brightness, contrast, saturation, gamma, and sharpness
brightness=$(awk -v min=-0.3 -v max=0.3 'BEGIN{srand(); print min+rand()*(max-min)}')
contrast=$(awk -v min=0.8 -v max=1.5 'BEGIN{srand(); print min+rand()*(max-min)}')
saturation=$(awk -v min=1 -v max=2 'BEGIN{srand(); print min+rand()*(max-min)}')
gamma=$(awk -v min=0.8 -v max=1.5 'BEGIN{srand(); print min+rand()*(max-min)}')
sharpen_amount=$(awk -v min=0.5 -v max=2 'BEGIN{srand(); print min+rand()*(max-min)}')

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

# Print the random values for debugging/confirmation
echo "Random enhancement values:"
echo "Brightness: $brightness"
echo "Contrast: $contrast"
echo "Saturation: $saturation"
echo "Gamma: $gamma"
echo "Sharpness: $sharpen_amount"
echo "width: $new_width"

# Generate FFmpeg filter string with random values
filter="scale=$new_width:-2,eq=brightness=$brightness:contrast=$contrast:saturation=$saturation:gamma=$gamma,unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=$sharpen_amount"

# Apply FFmpeg filter to the video
ffmpeg -loglevel warning -i "$input_video" -vf "$filter" -c:v libx264 -crf 18 -preset fast "$output_video"

# Remove metadata
exiftool -all= -overwrite_original "$output_video"

echo "removed metadata"
echo "Enhanced video saved as $output_video"
echo "----------------------------"

done
