#!/bin/bash

input_video=$1

# Generate a random number between 10 and 50
random_crop=$((10 + RANDOM % 41))

# Apply the crop filter using the random number for all sides
ffmpeg -i $input_video -vf "crop=iw-$(($random_crop*2)):ih-$(($random_crop*2)):$(($random_crop)):$(($random_crop))" croppedVideo.mp4


echo "cropped by $random_crop"
