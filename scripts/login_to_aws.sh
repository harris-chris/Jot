#!/bin/bash
aws ecr get-login-password --region ap-northeast-1 \
  | docker login \
  --username AWS \
  --password-stdin \
  111111111111.dkr.ecr.ap-northeast-1.amazonaws.com/julia-lambda
