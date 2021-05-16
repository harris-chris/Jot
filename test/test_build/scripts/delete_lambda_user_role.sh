#!/bin/bash
# See if the role already exists
aws iam list-roles | grep '"Arn": "arn:aws:iam::513118378795:role/vzlf3wgr25-LambdaExecutionRole"' >/dev/null 
if [ $? -eq 1 ];
then
  # It doesn't exist, so we can create it
  echo "Unable to delete User role vzlf3wgr25-LambdaExecutionRole; does not exist"
else
  # The role does exist; delete it
  aws iam delete-role --role-name vzlf3wgr25-LambdaExecutionRole
  echo "Deleted user role vzlf3wgr25-LambdaExecutionRole"
fi
