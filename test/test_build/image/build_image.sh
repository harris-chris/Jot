#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
docker build \
  --rm  \
  --tag 513118378795.dkr.ecr.ap-northeast-1.amazonaws.com/glero5hpyq-julia-lambda:latest \
  $DIR/.
