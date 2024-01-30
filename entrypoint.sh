#!/bin/bash

set -euo pipefail

image=$1
report=$2
patched_tag=$3
timeout=$4
output_file=$5
format=$6

# parse image into image name
image_no_tag=$(echo "$image" | cut -d':' -f1)

# check if output_file has been set
if [ -z "$output_file" ]
then
    output=""
else
    output="--format $format --output ./data/"$output_file""
fi

# run copa to patch image
if copa patch -i "$image" -r ./data/"$report" -t "$patched_tag" --addr tcp://127.0.0.1:8888 --timeout $timeout $output;
then
    patched_image="$image_no_tag:$patched_tag"
    echo "patched-image=$patched_image" >> "$GITHUB_OUTPUT"
else
    echo "Error patching image $image with copa"
    exit 1
fi

# due to docker, file permissions are set as 400
# set output file permissions so user can read it
if [ ! -z "$output_file" ]
then
    chmod 444 ./data/"$output_file"
fi
