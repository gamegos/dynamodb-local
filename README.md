# DynamoDb Local Image for Development Environment

This image includes both DynamoDb Local and AWS Commandline Interface applications with some setup scripts to make
DynamoDb Local version ready for use in a local development environment.

The main purpose of this bundle is to create DynamoDb tables for a project before running the DynamoDb Local server.

## Usage

Basic Usage Example:

```shell
docker run -it -p 8000:8000 \
  -v $(pwd)/data/dynamodb/table-schemas:/app/init/schemas \
  -v $(pwd)/data/dynamodb/table-data:/app/init/data \
  -v dynamodb-local-data:/app/data \
  -e DYNAMO_PREFIX=test. \
  gamegoscom/dynamodb-local
```

### Volumes

Mount the container these volumes:
* `/app/init/schemas` location of table schema (.json) files
* `/app/init/data` location of exemplary data (.json) files that will be inserted in initiation
* `/app/data` to persist DynamoDb data

### Environment Variables

* **DYNAMO_PREFIX**: Table name prefix
  * Default value: "dev."
  * Table name pattern: "PREFIX.TABLE_NAME"
* **AWS_ACCESS_KEY_ID***: To override the default dummy access key ID ("DummyAccessKeyId")
* **AWS_SECRET_ACCESS_KEY***: To override the default dummy secret access key ("DummySecretAccessKey")
* **AWS_REGION***: To override the default dummy region ("DummyRegion")

*_Values are used for client initialization, ignored by DynamoDB Local server._

### Docker Compose

```yaml
version: "3.5"
  dynamodb:
    container_name: my-app-dynamodb
    image: gamegoscom/dynamodb-local
    ports:
      - 8000:8000
    volumes:
      - dynamodb-data:/app/data
      - ./docs/dynamodb_tables:/app/init/schemas
      - ./docs/dynamodb_data:/app/init/data
    environment:
      DYNAMO_PREFIX: test.
volumes:
  dynamodb-data:
```
