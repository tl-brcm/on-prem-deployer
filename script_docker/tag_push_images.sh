#!/bin/bash

# Check if the image list file path parameter is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <path-to-image-list-file> [repository-name] [container-tool]"
    exit 1
fi

# Path to the image list file
imageListFile="$1"

# Default repository name
defaultRepo="artifactory.k3s.demo/brcm-docker"

# Use the second argument as the repo name, or default if not provided
repoName=${2:-$defaultRepo}

# Choose the container tool: Docker or Podman. Default is Docker.
containerTool=${3:-docker}

# Check if the image list file exists
if [ ! -f "$imageListFile" ]; then
    echo "Image list file not found: $imageListFile"
    exit 1
fi

# Read each line from the file and retag and push the image
# Adding an extra newline to ensure the last line is processed
while IFS= read -r image || [ -n "$image" ]; do
    echo $image
    # Extract the image name and version/tag (assumes format: "name:version")
    imageName=$(echo "$image" | cut -d ":" -f 1)
    version=$(echo "$image" | cut -d ":" -f 2)

    # If no version is found, default to 'latest'
    if [ -z "$version" ]; then
        version="latest"
    fi

    # Construct new image name. Extract only the image name without the registry part
    imageNameOnly=$(basename "$imageName")

    newName="$repoName/$imageNameOnly:$version"

    # Retag the image
    echo "Retagging $image to $newName"
    $containerTool tag "$image" "$newName"

    # Push the image to the repository
    echo "Pushing $newName"
    $containerTool push "$newName"
done < <(cat "$imageListFile"; echo)
