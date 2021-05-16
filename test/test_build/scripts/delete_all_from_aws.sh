#!/bin/bash

# Get the current path
THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

bash $THIS_DIR/delete_ecr_repository.sh
bash $THIS_DIR/delete_lambda_function.sh
bash $THIS_DIR/delete_lambda_user_role.sh
