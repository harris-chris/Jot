#!/bin/bash
# Push the image to ECR
docker push $(image.full_image_string)
# Delete lambda function if it already exists
aws lambda delete-function \
  --function-name=$(lambda_function.name)
# Create a function based on the ECR image 
aws lambda create-function \
  --function-name=$(lambda_function.name) \
  --code ImageUri=$(image.full_image_string) \
  --role=arn:aws:iam::$(aws.account_id):role/$(aws.role) \
  --package-type Image \
  --timeout=$(lambda_function.timeout) \
  --memory-size=$(lambda_function.memory_size)
