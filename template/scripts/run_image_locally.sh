#!/bin/bash
docker run \
  -p 9000:8080 \
  -it $(image.full_image_string)
