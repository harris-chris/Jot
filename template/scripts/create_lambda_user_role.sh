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
aws iam list-roles | grep '"Arn": "$(aws.role_arn_string)"' >/dev/null 
if [ $? -eq 1 ];
then
  # It doesn't exist, so we can create it
  read RESULT < <(aws iam create-role \
    --role-name $(aws.role) \
    --assume-role-policy-document "$TRUST_POLICY")
  if [ $? -eq 0 ];
  then
    echo "Successfully created role $(aws.role)"
  else
    echo $RESULT
  fi
else
  # The role does exist; just use that
  echo "User role already found for $(aws.role)"
fi




