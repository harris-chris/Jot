#!/bin/bash

TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

# See if the role already exists
aws iam list-roles | grep '"Arn": "arn:aws:iam::513118378795:role/vzlf3wgr25-LambdaExecutionRole"' >/dev/null 
if [ $? -eq 1 ];
then
  # It doesn't exist, so we can create it
  read RESULT < <(aws iam create-role \
    --role-name vzlf3wgr25-LambdaExecutionRole \
    --assume-role-policy-document "$TRUST_POLICY")
  if [ $? -eq 0 ];
  then
    echo "Successfully created role vzlf3wgr25-LambdaExecutionRole"
  else
    echo $RESULT
  fi
else
  # The role does exist; just use that
  echo "User role already found for vzlf3wgr25-LambdaExecutionRole"
fi




