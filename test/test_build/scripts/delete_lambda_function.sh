#!/bin/bash
# Check if the lambda function exists
aws lambda list-functions \
  | grep '"FunctionArn": "arn:aws:lambda:ap-northeast-1:513118378795:function:glero5hpyq-julia-function"' \
  >/dev/null

if [ $? -eq 0 ];
then
  echo "Found existing function; deleting it"
  aws lambda delete-function \
    --function-name=glero5hpyq-julia-function >/dev/null
else
  echo "Unable to delete function glero5hpyq-julia-function; does not exist"
fi
