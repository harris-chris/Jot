#!/bin/bash

# Get the current path
THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Delete lambda function if it already exists
bash $THIS_DIR/delete_lambda_function.sh

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



