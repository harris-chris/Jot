#!/bin/bash
eval login_to_ecr.sh >/dev/null 2>&1
if [ $? -eq 0 ];
then
  echo "YEAH"
else
  echo "NAY"
fi
