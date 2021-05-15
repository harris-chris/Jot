#!/bin/bash

# Delete lambda function if it already exists
aws lambda list-functions \
  | grep '"FunctionArn": "$(image.function_arn_string)"' \
  >/dev/null

if [ $? -eq 0 ];
then
  echo "Found existing function; deleting it"
  aws lambda delete-function \
    --function-name=$(lambda_function.name)
fi

# Create a function based on the ECR image 
read RESULT < <(aws lambda create-function \
  --function-name=$(lambda_function.name) \
  --code ImageUri=$(image.image_uri_string) \
  --role $(aws.role_arn_string) \
  --package-type Image \
  --timeout=$(lambda_function.timeout) \
  --memory-size=$(lambda_function.memory_size))

if [ $? -eq 0 ];
then
  echo "Successfully created function $(lambda_function.name)"
else
  echo $RESULT
fi



