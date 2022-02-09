FROM elixir:1.13-alpine

WORKDIR /usr/src/app

COPY . .

RUN apk add --update-cache build-base && \
    mix local.hex --force && \
    mix deps.get && \
    mix compile && \
    rm -rf /var/cache/apk/* && \
    mix ecto.migrate
    

EXPOSE 5000 

CMD ["mix", "phx.server"]