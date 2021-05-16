#!/bin/bash
docker run \
  -p 9000:8080 \
  -it $(image.image_uri_string)
