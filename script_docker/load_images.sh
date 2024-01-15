#!/bin/bash

# Function to load image and get its name
load_image() {
    local imageFile=$1
    local containerTool=$2
    local imageListFile=$3

    # Load image and capture the output
    local loadOutput
    if [[ "$imageFile" == *.tar.gz ]]; then
        loadOutput=$(gunzip -c "$imageFile" | $containerTool load)
    else
        loadOutput=$($containerTool load < "$imageFile")
    fi

    # Try to extract image name from the load output
    local imageName=$(echo "$loadOutput" | grep -oP '(?<=Loaded image: )[^ ]+' | head -n 1)

    # If image name extraction failed, use a placeholder
    if [ -z "$imageName" ]; then
        imageName="Unknown-Image-Loaded"
    fi

    # Append the image name to the list
    echo "$imageName" >> "$imageListFile"
}

# Check if parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <path-to-image-folder> <docker|podman>"
    echo "Example: $0 /path/to/images docker"
    exit 1
fi

# Assign parameters to variables
imageFolder="$1"
containerTool="$2"

# Validate container tool parameter
if [ "$containerTool" != "docker" ] && [ "$containerTool" != "podman" ]; then
    echo "Invalid container tool. Please choose 'docker' or 'podman'."
    exit 1
fi

# Check if the specified directory exists
if [ ! -d "$imageFolder" ]; then
    echo "Image folder not found: $imageFolder"
    exit 1
fi

# File to store the list of loaded images
loadedImagesList="loaded_images_list"
> "$loadedImagesList" # Clear the file content

# Loop through each file in the image folder
for imageFile in "$imageFolder"/*.{tar,tar.gz}; do
    if [ -f "$imageFile" ]; then
        load_image "$imageFile" "$containerTool" "$loadedImagesList"
    fi
done

echo "Loading complete. List of loaded images and versions:"
cat "$loadedImagesList"
