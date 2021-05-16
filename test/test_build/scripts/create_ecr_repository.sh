#!/bin/bash
aws ecr describe-repositories | grep '"repositoryArn": "arn:aws:ecr:ap-northeast-1:513118378795:repository/glero5hpyq-julia-function"' >/dev/null
if [ $? -eq 1 ];
then
  echo "Repository not found; creating"
  aws ecr create-repository \
    --repository-name glero5hpyq-julia-function \
    --image-scanning-configuration scanOnPush=true \
    --region ap-northeast-1
fi
