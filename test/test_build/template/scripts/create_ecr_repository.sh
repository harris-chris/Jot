#!/bin/bash
aws ecr describe-repositories | grep '"repositoryArn": "$(image.ecr_arn_string)"' >/dev/null
if [ $? -eq 1 ];
then
  echo "Repository not found; creating"
  aws ecr create-repository \
    --repository-name $(lambda_function.name) \
    --image-scanning-configuration scanOnPush=true \
    --region $(aws.region)
fi
