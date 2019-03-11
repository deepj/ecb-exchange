FROM ruby:2.6.1-alpine

WORKDIR /app

COPY . .

RUN apk add --no-cache --virtual .build-deps build-base && \
    apk add --no-cache postgresql-dev && \
    bundle install --jobs $(nproc) --without development:test && \
    apk del .build-deps && \
    rm -rf /usr/local/bundle/cache
