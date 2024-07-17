#!/bin/bash

# Set a log file
LOG_FILE="/var/log/update-agent.log"

# Redirect stdout and stderr to the log file with timestamps
exec > >(while IFS= read -r line; do echo "$(date +'%Y-%m-%d %H:%M:%S') $line"; done >> $LOG_FILE) 2>&1



# Update Management API URL
UPDATE_API_URL="http://localhost:5000/api/latest-versions"
# Docker Compose file location
DOCKER_COMPOSE_FILE="/usr/local/bin/docker-compose.yaml"
DOCKER_COMPOSE="/usr/local/bin/docker-compose"

# Function to fetch image tag used by the container
fetch_container_image_tag() {
    local CONTAINER_NAME=$1

    # Check if container name is provided
    if [ -z "$CONTAINER_NAME" ]; then
        echo "Error: Container name must be provided"
        return 1
    fi

    # Get the Image ID used by the container
    local IMAGE_ID=$(docker inspect --format='{{.Image}}' $CONTAINER_NAME)
    if [ $? -ne 0 ]; then
        echo "Error: Unable to get image ID for container $CONTAINER_NAME"
        return 1
    fi

    # Find the full image reference associated with the Image ID
    local FULL_TAG=$(docker images --digests --no-trunc | grep $IMAGE_ID | awk '{print $1":"$2}')
    if [ $? -ne 0 ] || [ -z "$FULL_TAG" ]; then
        echo "Error: Unable to find full tag for image ID $IMAGE_ID"
        return 1
    fi

    # Extract the tag part from the full image reference
    local TAG=$(echo $FULL_TAG | awk -F':' '{print $2}')
    echo "$TAG"
}

# Function to check for updates
check_for_updates() {
    echo "Checking for updates..."
    response=$(curl -s $UPDATE_API_URL)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch updates from get updated api running on $UPDATE_API_URL"
        exit 1
    fi

    echo 
    echo "Response from get latest version for update :- "
    echo 

    echo $response

    status=$(echo $response | jq -r '.status')
    if [ "$status" != "success" ]; then
        echo "Error: Failed to fetch the latest versions. Status: $status"
        exit 1
    fi

    latest_frontend_version=$(echo $response | jq -r '.data.frontend')
    latest_backend_version=$(echo $response | jq -r '.data.backend')

    FRONTEND_CONTAINER_NAME="frontend-switchboard"
    FRONTEND_TAG=$(fetch_container_image_tag $FRONTEND_CONTAINER_NAME)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get tag for container $FRONTEND_CONTAINER_NAME"
        exit 1
    fi

    BACKEND_CONTAINER_NAME="backend-switchboard"
    BACKEND_TAG=$(fetch_container_image_tag $BACKEND_CONTAINER_NAME)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get tag for container $BACKEND_CONTAINER_NAME"
        exit 1
    fi

    current_frontend_version=$FRONTEND_TAG
    current_backend_version=$BACKEND_TAG

    echo "Current frontend version: $current_frontend_version"
    echo "Current backend version: $current_backend_version"

    echo 

    echo "Latest frontend version: $latest_frontend_version"
    echo "Latest backend version: $latest_backend_version"



    frontend_update_needed=false
    backend_update_needed=false

    if [[ "$latest_frontend_version" != "$current_frontend_version" ]]; then
        frontend_update_needed=true
    fi

    if [[ "$latest_backend_version" != "$current_backend_version" ]]; then
        backend_update_needed=true
    fi

    echo "Update required for frontend: $frontend_update_needed"
    echo "Update required for backend: $backend_update_needed"

    if [ "$frontend_update_needed" = true ]; then
        update_image "frontend-switchboard" "hs60/switchboard-frontend" "$latest_frontend_version"
    else
        echo 
        echo "------------------------------------------------------------------"
        echo "No updates available for frontend."
        echo "------------------------------------------------------------------"
        echo
    fi

    if [ "$backend_update_needed" = true ]; then
        update_image "backend-switchboard" "hs60/switchboard-backend" "$latest_backend_version"
    else
        echo 
        echo "------------------------------------------------------------------"
        echo "No updates available for backend."
        echo "------------------------------------------------------------------"
        echo 
    fi
}

# Function to update a specific Docker image and redeploy container
update_image() {
    container_name=$1
    image_name=$2
    latest_version=$3

    echo "Pulling updated Docker image: $image_name:$latest_version..."
    docker pull $image_name:$latest_version
    if [ $? -ne 0 ]; then
        echo "Error: Failed to pull image $image_name:$latest_version"
        exit 1
    fi

    new_image_sha=$(docker inspect --format='{{.Id}}' $image_name:$latest_version)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get SHA of image $image_name:$latest_version"
        exit 1
    fi

    current_image_sha=$(docker inspect --format='{{.Image}}' $container_name)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get current image SHA for container $container_name"
        exit 1
    fi

        echo 
        echo "========================================================================================="
        echo "New image hash for $container_name :- $new_image_sha"
        echo "========================================================================================="
        echo 


        echo 
        echo "========================================================================================="
        echo "current image hash $$container_name :- $current_image_sha"
        echo "========================================================================================="
        echo 


    if [[ "$new_image_sha" != "$current_image_sha" ]]; then
        echo "SHA256 hash mismatch. Updating $container_name to $image_name:$latest_version..."


        echo "Updating compose file with the latest version..."
        tmp_file=$(mktemp)
        cp $DOCKER_COMPOSE_FILE $DOCKER_COMPOSE_FILE-previous
        sed "s|$image_name:.*|$image_name:$latest_version|g" $DOCKER_COMPOSE_FILE > $tmp_file
        if [ $? -ne 0 ]; then
            echo "Error: Failed to update compose file"
            exit 1
        fi

        cat $tmp_file > $DOCKER_COMPOSE_FILE
        rm $tmp_file

        echo "NEW COMPOSE FILE"
        cat $DOCKER_COMPOSE_FILE



        echo "Stopping running container: $container_name..."
        set -x
        docker stop $container_name
        if [ $? -ne 0 ]; then
            echo "Error: Failed to stop container $container_name"
            exit 1
        fi

        docker rm $container_name
        if [ $? -ne 0 ]; then
            echo "Error: Failed to remove container $container_name"
            exit 1
        fi
        set +x

        sleep 10

        echo "Starting container with updated image:- $container_name..."
        set -x
        $DOCKER_COMPOSE -f $DOCKER_COMPOSE_FILE up -d $container_name
        if [ $? -ne 0 ]; then
              echo
              echo "--------------------------------------------------------------------"
              echo "Error: Failed to start container $container_name with updated image"
              echo "--------------------------------------------------------------------"
              echo 
              echo "--------------------------------------------------------------------"
              echo "Running old version of app again"
              echo "--------------------------------------------------------------------"
              cat $DOCKER_COMPOSE_FILE-previous > $DOCKER_COMPOSE_FILE
               if [ $? -ne 0 ]; then
                  echo "Error: creating old docker-compose file"
                  exit 1
              fi
              $DOCKER_COMPOSE -f $DOCKER_COMPOSE_FILE up -d $container_name
               if [ $? -ne 0 ]; then
                  echo "Error: running old verison app again "
                  exit 1
              fi
              echo "--------------------------------------------------------------------"
              echo "old version of $container_name running SUCCESSFULLY"
              echo "--------------------------------------------------------------------"
            exit 1
        fi
        set +x

        echo "--------------------------------------------------------------------"
        echo "$container_name UPDATED SUCCESSFULLY"
        echo "--------------------------------------------------------------------"
    else
        echo "No update needed for $container_name."
    fi
}

# Run the update check
check_for_updates
