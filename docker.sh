#!/bin/bash

# Variables
REPO_DIR="/var/www/html/practics"
IMAGE_NAME="practics"
CONTAINER_NAME="nodejsapp"

# Pull the latest code
echo "Pulling the latest code from the repository..."
cd $REPO_DIR || { echo "Repository directory not found! Exiting."; exit 1; }

# Stash any local changes
git stash

# Pull the latest code
git pull origin master || { echo "Failed to pull the latest code. Exiting."; exit 1; }

# Apply stashed changes
git stash pop

# Get the latest commit ID
COMMIT_ID=$(git rev-parse --short HEAD)
if [ -z "$COMMIT_ID" ]; then
  echo "Failed to get the latest commit ID. Exiting."
  exit 1
fi
echo "Latest commit ID: $COMMIT_ID"

# Build the new Docker image with the commit ID as the tag
echo "Building the Docker image..."
docker build --no-cache -t $IMAGE_NAME:$COMMIT_ID . || { echo "Docker build failed. Exiting."; exit 1; }

# Stop and remove the current running container
echo "Stopping and removing the current container..."
docker stop $CONTAINER_NAME || echo "No such container: $CONTAINER_NAME"
docker rm $CONTAINER_NAME || echo "No such container: $CONTAINER_NAME"

# Run a new container with the updated image
echo "Running a new container with the updated image..."
docker run -d -p 3000:3000 --name $CONTAINER_NAME $IMAGE_NAME:$COMMIT_ID || { echo "Failed to run the new container. Exiting."; exit 1; }

echo "Deployment completed successfully!"
