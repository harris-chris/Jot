#!/bin/bash

# Get the current path
THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Delete lambda function if it already exists
bash $THIS_DIR/delete_lambda_function.sh

# Create a function based on the ECR image 
read RESULT < <(aws lambda create-function \
  --function-name=vzlf3wgr25-julia-function \
  --code ImageUri=513118378795.dkr.ecr.ap-northeast-1.amazonaws.com/vzlf3wgr25-julia-lambda:latest \
  --role arn:aws:iam::513118378795:role/vzlf3wgr25-LambdaExecutionRole \
  --package-type Image \
  --timeout=30 \
  --memory-size=1000)

if [ $? -eq 0 ];
then
  echo "Successfully created function vzlf3wgr25-julia-function"
else
  echo $RESULT
fi



