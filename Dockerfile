FROM "docker.io/ruby:4.0-alpine"

ARG UID=1000
ARG GID=1000

RUN addgroup -g "$GID" -S 'app' \
      && adduser -u "$UID" -G 'app' -S 'app'

WORKDIR /home/app

COPY --chown=app:app . .

RUN apk add --no-cache --update alpine-sdk yaml-dev \
      && bundle install \
      && chown -R app:app /usr/local/bundle

ENTRYPOINT /bin/sh
USER app
