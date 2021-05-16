#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
docker build \
  --rm  \
  --tag 513118378795.dkr.ecr.ap-northeast-1.amazonaws.com/vzlf3wgr25-julia-lambda:latest \
  $DIR/.
