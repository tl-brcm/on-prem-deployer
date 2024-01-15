#!/bin/bash

# Set default container tool to docker
containerTool="docker"

# Check if a file path parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-image-list-file> [container-tool]"
    exit 1
fi

# Path to the image list file
imageListFile="$1"

# Check if an optional second argument (container tool) is provided
if [ $# -eq 2 ]; then
    containerTool="$2"
fi

# Check if the image list file exists
if [ ! -f "$imageListFile" ]; then
    echo "Image list file not found: $imageListFile"
    exit 1
fi

# Read each line from the file and pull the corresponding image using the specified tool
while IFS= read -r image; do
    echo "Pulling image with $containerTool: $image"
    $containerTool pull "$image"
done < <(cat "$imageListFile"; echo)
