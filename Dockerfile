FROM debian:bullseye-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget openjdk-11-jre-headless awscli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN wget https://s3.eu-central-1.amazonaws.com/dynamodb-local-frankfurt/dynamodb_local_latest.tar.gz \
    && tar -xf dynamodb_local_latest.tar.gz -C . \
    && rm dynamodb_local_latest.tar.gz

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 8000

VOLUME /app/data /app/init/schemas /app/init/data

ENV AWS_ACCESS_KEY_ID=DummyAccessKeyId
ENV AWS_SECRET_ACCESS_KEY=DummySecretAccessKey
ENV AWS_REGION=DummyRegion
ENV DYNAMO_PREFIX=""
