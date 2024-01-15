#!/bin/bash

# Check if necessary parameters are provided
if [ $# -lt 4 ]; then
    echo "Usage: $0 <chart-file> <target-repo-url> <username> <password>"
    echo "Example: $0 helm_charts/eck-operator-2.10.0.tgz https://artifactory.k3s.demo/artifactory/brcm-helm/eck-operator-2.10.0.tgz admin password"
    exit 1
fi

# Assign parameters to variables
chartFile="$1"
targetRepoUrl="$2"
username="$3"
password="$4"

# Upload the chart to the target repository
# This assumes the repository supports basic auth and accepts .tar.gz chart packages
curl -u "$username:$password" -T "$chartFile" "$targetRepoUrl" -k

echo "Uploaded $chartFile to $targetRepoUrl"
