#!/bin/bash
aws ecr describe-repositories | grep '"repositoryArn": "arn:aws:ecr:ap-northeast-1:513118378795:repository/vzlf3wgr25-julia-function"' >/dev/null
if [ $? -eq 0 ];
then
  aws ecr delete-repository \
    --force \
    --repository-name vzlf3wgr25-julia-lambda \
    </dev/null
  echo "Deleted repository vzlf3wgr25-julia-lambda"
else
  echo "Unable to delete repository vzlf3wgr25-julia-lambda; does not exist"
fi
