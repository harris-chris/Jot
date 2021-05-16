#!/bin/bash
aws ecr get-login-password --region ap-northeast-1 \
  | docker login \
  --username AWS \
  --password-stdin \
  513118378795.dkr.ecr.ap-northeast-1.amazonaws.com/vzlf3wgr25-julia-lambda
