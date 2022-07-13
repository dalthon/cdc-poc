#!/bin/bash

status=000

configureDebezium () {
  response_code=$(curl --write-out '%{http_code}' --silent --output /dev/null -XPOST localhost:8083/connectors/ -H "content-type: application/json" -d @scripts/connectors/debezium.json);

  echo "$response_code"
}

while [ "$status" != 201 ] | [ "$status" != 409 ];
  do
    echo "Trying to configure debezium"
    status=$(configureDebezium)
    sleep 5
  done

echo "debezium configured"
