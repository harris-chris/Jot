if [ $# -eq 0 ]
  then
    echo "Please supply an argument to use as the invocation payload"
fi
curl -XPOST \
  "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d "$1"
