#!/usr/bin/env bash
set -e

DATA_DIR=/app/data
INIT_SCHEMA_DIR=/app/init/schemas
INIT_SCHEMA_FILE_PATTERN="$INIT_SCHEMA_DIR/*.json"
INIT_DATA_DIR=/app/init/data
INIT_DATA_FILE_PATTERN="$INIT_DATA_DIR/*.json"

# configure_aws AccessKeyID SecretAccessKey Region
function configure_aws() {
    [ -d ~/.aws ] && rm -rf ~/.aws
    mkdir ~/.aws
    {
      echo "[default]"
      echo "aws_access_key_id = $1"
      echo "aws_secret_access_key = $2"
    } >> ~/.aws/credentials

    {
      echo "[default]"
      echo "region = $3"
      echo "output = json"
    } >> ~/.aws/config
}

function start_server() {
    exec java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -dbPath /app/data
}

function create_table() {
    aws dynamodb --endpoint-url http://localhost:8000 --region="$AWS_REGION" create-table \
        --table-name "$DYNAMO_PREFIX$1" \
        --cli-input-json file://"$2"
}

function populate_data() {
    aws dynamodb --endpoint-url http://localhost:8000 --region="$AWS_REGION" put-item \
        --table-name "$DYNAMO_PREFIX$1" --item file://"$2"
}

function init_db() {
    # shellcheck disable=SC2086
    if [ -z "$(ls $INIT_SCHEMA_FILE_PATTERN 2> /dev/null)" ]; then
        echo "Cannot find schema files in $INIT_SCHEMA_DIR, skipping creating tables"
        return 0
    fi

    echo "Configuring aws cli for initial operations"
    configure_aws "$AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_REGION"
    echo "Aws cli configured"

    echo "Starting temporary server"
    start_server > /dev/null &
    echo "Temporary server started"

    echo "Creating DynamoDb tables"
    shopt -s nullglob
    for filename in $INIT_SCHEMA_FILE_PATTERN; do
        create_table "$(basename "$filename" .json)" "$filename"
    done
    echo "DynamoDb tables created"

    echo "Populating DynamoDb tables"
    for filename in $INIT_DATA_FILE_PATTERN; do
        populate_data "$(basename "$filename" .json)" "$filename"
    done
    echo "DynamoDb tables populated"

    echo "Stopping temporary server"
    kill -s SIGTERM "$(pidof java)"
    echo "Temporary server stopped"
}

if [ ! -f $DATA_DIR/shared-local-instance.db ]; then
    echo "Database volume is empty, creating from provided resources"

    echo "Initializing database"
    init_db
    echo "Database initialization completed"

else
    echo "Database already initialized; clear the database volume to reinitialize with updated resources"
fi

start_server
