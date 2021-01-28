FROM elixir:1.7.3-alpine as asset-builder-mix-getter

RUN apk add --no-cache \
        git

ENV HOME=/opt/app
WORKDIR $HOME

RUN mix do local.hex --force, local.rebar --force

COPY config/ ./config/
COPY mix.exs mix.lock ./

RUN mix deps.get

############################################################
FROM bitwalker/alpine-elixir-phoenix:latest

RUN apk add --no-cache \
        git

ENV HOME=/opt/app
ENV PORT=4040
WORKDIR $HOME

RUN mix do local.hex --force, local.rebar --force

COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/

COPY lib/ ./lib

COPY priv/ ./priv

ENV MIX_ENV=prod

RUN mix do deps.get --only $MIX_ENV, deps.compile, compile

RUN mix phx.digest

CMD ["mix", "phx.server"]
