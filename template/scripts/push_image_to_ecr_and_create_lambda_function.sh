#!/bin/bash
# Get the current directory
THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
# Login to ecr
bash $THIS_DIR/login_to_ecr.sh
# Create user role
bash $THIS_DIR/create_lambda_user_role.sh
# Create the ECR repository, if it doesn't already exists
bash $THIS_DIR/create_ecr_repository.sh
# Push the image to ECR
docker push $(image.image_uri_string)
# Create the function
bash $THIS_DIR/create_lambda_function.sh
