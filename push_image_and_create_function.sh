#!/bin/bash
# Load variables from config.json
source ./_load_config.sh

# Push the image to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG
# Delete function if it already exists
aws lambda delete-function \
  --function-name=$FUNCTION_NAME
# Create a function based on the ECR image 
aws lambda create-function \
  --function-name=$FUNCTION_NAME \
  --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG \
  --role=$ROLE \
  --package-type Image \
  --timeout=$TIMEOUT \
  --memory-size=$MEMORY_SIZE
