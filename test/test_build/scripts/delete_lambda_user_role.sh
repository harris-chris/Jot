#!/bin/bash
# See if the role already exists
aws iam list-roles | grep '"Arn": "arn:aws:iam::513118378795:role/glero5hpyq-LambdaExecutionRole"' >/dev/null 
if [ $? -eq 1 ];
then
  # It doesn't exist, so we can create it
  echo "Unable to delete User role glero5hpyq-LambdaExecutionRole; does not exist"
else
  # The role does exist; delete it
  aws iam delete-role --role-name glero5hpyq-LambdaExecutionRole
  echo "Deleted user role glero5hpyq-LambdaExecutionRole"
fi
