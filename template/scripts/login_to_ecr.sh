#!/bin/bash
aws ecr get-login-password --region $(aws.region) \
  | docker login \
  --username AWS \
  --password-stdin \
  $(aws.account_id).dkr.ecr.$(aws.region).amazonaws.com/$(image.name)
