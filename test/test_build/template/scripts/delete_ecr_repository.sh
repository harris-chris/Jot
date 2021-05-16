#!/bin/bash
aws ecr describe-repositories | grep '"repositoryArn": "$(image.ecr_arn_string)"' >/dev/null
if [ $? -eq 0 ];
then
  aws ecr delete-repository \
    --force \
    --repository-name $(image.name) \
    </dev/null
  echo "Deleted repository $(image.name)"
else
  echo "Unable to delete repository $(image.name); does not exist"
fi
