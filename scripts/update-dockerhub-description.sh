#!/bin/bash

# Script to update Docker Hub repository descriptions using the API
# Requires DOCKERHUB_USERNAME and DOCKERHUB_TOKEN environment variables

set -e

# Check required environment variables
if [[ -z "$DOCKERHUB_USERNAME" || -z "$DOCKERHUB_TOKEN" ]]; then
    echo "Error: DOCKERHUB_USERNAME and DOCKERHUB_TOKEN environment variables are required"
    exit 1
fi

# Function to update repository description
update_description() {
    local repo_name="$1"
    local readme_file="$2"
    
    if [[ ! -f "$readme_file" ]]; then
        echo "Error: README file $readme_file not found"
        return 1
    fi
    
    echo "Updating description for $repo_name..."
    
    # Read README content and escape for JSON
    local description=$(cat "$readme_file" | jq -Rs .)
    
    # Get JWT token
    local token=$(curl -s -H "Content-Type: application/json" \
        -X POST \
        -d "{\"username\": \"$DOCKERHUB_USERNAME\", \"password\": \"$DOCKERHUB_TOKEN\"}" \
        https://hub.docker.com/v2/users/login/ | jq -r .token)
    
    if [[ "$token" == "null" || -z "$token" ]]; then
        echo "Error: Failed to authenticate with Docker Hub"
        return 1
    fi
    
    # Update repository description
    local response=$(curl -s -w "%{http_code}" -o /tmp/response.json \
        -H "Authorization: JWT $token" \
        -H "Content-Type: application/json" \
        -X PATCH \
        -d "{\"full_description\": $description}" \
        "https://hub.docker.com/v2/repositories/$DOCKERHUB_USERNAME/$repo_name/")
    
    if [[ "$response" == "200" ]]; then
        echo "Successfully updated description for $repo_name"
    else
        echo "Error: Failed to update $repo_name (HTTP $response)"
        cat /tmp/response.json
        return 1
    fi
}

# Update both repositories
echo "Starting Docker Hub description updates..."

update_description "anonymous-ftp-proftpd" "README.proftpd.md"
update_description "anonymous-ftp-vsftpd" "README.vsftpd.md"

echo "All descriptions updated successfully!"