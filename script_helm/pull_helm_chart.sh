#!/bin/bash

# Check if at least the repository URL, chart name, and version are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <repo-url> <chart-name> <chart-version> [username] [password]"
    echo "Example: $0 https://helm.elastic.co/elastic eck-operator 1.2.3 admin password"
    exit 1
fi

# Assign parameters to variables
repoUrl="$1"
chartName="$2"
chartVersion="$3"
username="$4"
password="$5"

# Determine the base directory of the script
scriptBase=$(dirname "$0")

# Create the helm_charts directory if it doesn't exist
chartsDir="$scriptBase/../helm_charts"
mkdir -p "$chartsDir"

# Extract the last part of the URL to use as an alias
repoAlias=$(basename $repoUrl)

# Add the Helm repository with or without authentication
if [ -n "$username" ] && [ -n "$password" ]; then
    helm repo add "$repoAlias" "$repoUrl" --username "$username" --password "$password"
else
    helm repo add "$repoAlias" "$repoUrl"
fi

# Update the Helm repositories
helm repo update

# Pull the chart and save it to the specified directory
helm pull "$repoAlias/$chartName" --version "$chartVersion" --untar=false --destination "$chartsDir"

echo "Downloaded $chartName version $chartVersion from $repoUrl to $chartsDir/"
