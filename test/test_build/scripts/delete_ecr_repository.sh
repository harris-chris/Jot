#!/bin/bash
aws ecr describe-repositories | grep '"repositoryArn": "arn:aws:ecr:ap-northeast-1:513118378795:repository/glero5hpyq-julia-function"' >/dev/null
if [ $? -eq 0 ];
then
  aws ecr delete-repository \
    --force \
    --repository-name glero5hpyq-julia-lambda \
    </dev/null
  echo "Deleted repository glero5hpyq-julia-lambda"
else
  echo "Unable to delete repository glero5hpyq-julia-lambda; does not exist"
fi
