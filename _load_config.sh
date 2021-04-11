#!/bin/bash
# Load variables from config.json
AWS_ACCOUNT_ID=$(
  cat ./config.json \
  | awk '{ gsub(/ /,""); print }' \
  | grep -Eo '"AWSAccountId":"(.*?)"' \
  | awk -F':' '{print substr($2, 2, length($2)-2)}'
)
AWS_REGION=$(
  cat ./config.json \
  | awk '{ gsub(/ /,""); print }' \
  | grep -Eo '"AWSRegion":"(.*?)"' \
  | awk -F':' '{print substr($2, 2, length($2)-2)}'
)
IMAGE_NAME=$(
  cat ./config.json \
  | awk '{ gsub(/ /,""); print }' \
  | grep -Eo '"ImageName":"(.*?)"' \
  | awk -F':' '{print substr($2, 2, length($2)-2)}'
)
IMAGE_TAG=$(
  cat ./config.json \
  | awk '{ gsub(/ /,""); print }' \
  | grep -Eo '"ImageTag":"(.*?)"' \
  | awk -F':' '{print substr($2, 2, length($2)-2)}'
)
FUNCTION_NAME=$(
  cat ./config.json \
  | awk '{ gsub(/ /,""); print }' \
  | grep -Eo '"FunctionName":"(.*?)"' \
  | awk -F':' '{print substr($2, 2, length($2)-2)}'
)
ROLE="arn:aws:iam::$AWS_ACCOUNT_ID:role/$( \
  cat ./config.json \
  | awk '{ gsub(/ /,""); print }' \
  | grep -Eo '"Role":"(.*?)"' \
  | awk -F':' '{print substr($2, 2, length($2)-2)}' \
)"
TIMEOUT=$(cat ./config.json | awk '{ gsub(/ /,""); print }' | grep -Po '"Timeout":\d*' | awk -F':' '{print $2}')
MEMORY_SIZE=$(cat ./config.json | awk '{ gsub(/ /,""); print }' | grep -Po '"MemorySize":\d*' | awk -F':' '{print $2}')
