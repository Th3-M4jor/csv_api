FROM elixir:1.13-alpine

WORKDIR /usr/src/app

COPY . .

# Install build-base for building sqlite3
RUN apk add --update-cache build-base && \
    # Install hex for buidling Elixir dependencies
    mix local.hex --force && \
    # Install rebar for building Erlang dependencies
    mix local.rebar --force && \
    # fetch all dependencies
    mix deps.get && \
    # build
    mix compile && \
    # clean alpine's apk cache
    rm -rf /var/cache/apk/* && \
    # run DB migrations
    mix ecto.migrate
    
# App listens on port 5000
EXPOSE 5000 

CMD ["mix", "phx.server"]