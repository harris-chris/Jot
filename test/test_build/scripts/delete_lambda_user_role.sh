#!/bin/bash
# See if the role already exists
aws iam list-roles | grep '"Arn": "$(aws.role_arn_string)"' >/dev/null 
if [ $? -eq 1 ];
then
  # It doesn't exist, so we can create it
  echo "Unable to delete User role $(aws.role); does not exist"
else
  # The role does exist; delete it
  aws iam delete-role --role-name $(aws.role)
  echo "Deleted user role $(aws.role)"
fi
