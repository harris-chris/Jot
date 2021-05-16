#!/bin/bash
aws ecr describe-repositories | grep '"repositoryArn": "arn:aws:ecr:ap-northeast-1:513118378795:repository/vzlf3wgr25-julia-function"' >/dev/null
if [ $? -eq 1 ];
then
  echo "Repository not found; creating"
  aws ecr create-repository \
    --repository-name vzlf3wgr25-julia-function \
    --image-scanning-configuration scanOnPush=true \
    --region ap-northeast-1
fi
