FROM ruby:3.1-alpine

ARG SHOPIFY_API_KEY
ENV SHOPIFY_API_KEY=$SHOPIFY_API_KEY

# Install necessary dependencies including PostgreSQL client libraries
RUN apk update && apk add --no-cache \
  nodejs \
  npm \
  git \
  build-base \
  sqlite-dev \
  gcompat \
  bash \
  openssl-dev \
  postgresql-dev

WORKDIR /app

COPY web .

RUN cd frontend && npm install
RUN bundle install

RUN cd frontend && npm run build
RUN rake build:all

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]
