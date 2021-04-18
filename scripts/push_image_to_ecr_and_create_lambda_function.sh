#!/bin/bash
# Push the image to ECR
docker push 513118378795.dkr.ecr.ap-northeast-1.amazonaws.com/julia-lambda:latest
# Delete lambda function if it already exists
aws lambda delete-function \
  --function-name=julia-lambda
# Create a function based on the ECR image 
aws lambda create-function \
  --function-name=julia-lambda \
  --code ImageUri=513118378795.dkr.ecr.ap-northeast-1.amazonaws.com/julia-lambda:latest \
  --role=arn:aws:iam::513118378795:role/lambda-test-user \
  --package-type Image \
  --timeout=20 \
  --memory-size=600
