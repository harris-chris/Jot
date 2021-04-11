#!/bin/bash
# Load variables from config.json
source ./_load_config.sh

aws ecr get-login-password --region $AWS_REGION \
  | docker login \
  --username AWS \
  --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME
