#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "Please supply an argument to use as the invocation payload"
  else
    CONTAINER=$(docker run \
      -p 9000:8080 \
      -d \
      -i $(image.image_uri_string))
    curl -XPOST \
      "http://localhost:9000/2015-03-31/functions/function/invocations" \
      -d "$1"
    wait $!
    docker stop $CONTAINER
fi

