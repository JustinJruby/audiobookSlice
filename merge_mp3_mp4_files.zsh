#!/bin/zsh

#
# for file in *; do
#   new_filename="5-${file}"
#   mv -- "$file" "$new_filename"
# done
#

input_dir="."   # Set the input directory to the local directory
output_dir="output"
output_file="$output_dir/merged.m4a"

# Create the "output" directory if it's missing
if [[ ! -d "$output_dir" ]]; then
  mkdir "$output_dir"
fi

for mp3file in "$input_dir"/*.mp3; do
  filename=$(basename "$mp3file")
  output_file="$output_dir/merged.m4a"
  ffmpeg -i "$mp3file" -c:a aac -strict experimental -y "$output_file"
  echo "Converted $filename to $output_file"
done


# Create a text file listing the input files (sorted)
find "$input_dir" -type f -name "*.m4a" -exec echo "file '{}'" \; | sort > filelist.txt

# Check if the filelist.txt is empty
if [[ -s filelist.txt ]]; then
  # Use ffmpeg to concatenate the files listed in the text file
  ffmpeg -f concat -safe 0 -i filelist.txt -c:a aac -strict experimental -y "$output_file"
  echo "Merged all files into $output_file"
else
  echo "No valid files found for merging."
fi

ffmpeg -i "$output_file" -map 0 -f segment -segment_time 422.4 -b:a 100k -reset_timestamps 1 -c:a aac output_%03d.m4a
