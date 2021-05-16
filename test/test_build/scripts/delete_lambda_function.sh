#!/bin/bash
# Check if the lambda function exists
aws lambda list-functions \
  | grep '"FunctionArn": "$(image.function_arn_string)"' \
  >/dev/null

if [ $? -eq 0 ];
then
  echo "Found existing function; deleting it"
  aws lambda delete-function \
    --function-name=$(lambda_function.name) >/dev/null
else
  echo "Unable to delete function $(lambda_function.name); does not exist"
fi
