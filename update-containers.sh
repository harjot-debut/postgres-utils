#!/bin/bash

# Set the image names
FRONTEND_IMAGE="hs60/switchboard-frontend:latest"
BACKEND_IMAGE="hs60/switchboard-backend:latest"

# Get the IDs of the currently available images
CURRENT_FRONTEND_ID=$(docker images -q $FRONTEND_IMAGE)
CURRENT_BACKEND_ID=$(docker images -q $BACKEND_IMAGE)

echo "1111111111111111111111111111111111111111111"
echo 
echo "Current Frontend Image ID: $CURRENT_FRONTEND_ID"
echo 
echo "Current Backend Image ID: $CURRENT_BACKEND_ID"
echo

# Pull the latest images
docker pull $FRONTEND_IMAGE
docker pull $BACKEND_IMAGE

# Get the IDs of the newly pulled images (using `docker images -q` for consistency)
NEW_FRONTEND_ID=$(docker images -q $FRONTEND_IMAGE)
NEW_BACKEND_ID=$(docker images -q $BACKEND_IMAGE)

echo "2222222222222222222222222222222222"
echo
echo "New Frontend Image ID: $NEW_FRONTEND_ID"
echo
echo "New Backend Image ID: $NEW_BACKEND_ID"
echo

# Compare current and new image IDs
if [ "$CURRENT_FRONTEND_ID" != "$NEW_FRONTEND_ID" ] || [ "$CURRENT_BACKEND_ID" != "$NEW_BACKEND_ID" ]; then
  echo "New image found. Updating containers..."
else
  echo "No update found"
fi


# # Check if the images have been updated
# if [ "$CURRENT_FRONTEND_ID" != "$NEW_FRONTEND_ID" ] || [ "$CURRENT_BACKEND_ID" != "$NEW_BACKEND_ID" ]; then
#   echo "New image found. Updating containers..."

#   # Restart containers with new images
#   docker-compose down
#   docker-compose up -d

#   echo "Containers updated."
# else
#   echo "No new image updates found."
# fi
