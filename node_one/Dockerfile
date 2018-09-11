FROM elixir:1.7.2-slim

RUN mkdir /node_one
WORKDIR /node_one

ARG ENV=prod

ENV MIX_ENV $ENV
ENV NODE_ENV production

ENV TELEGRAM_BOT_TOKEN $TELEGRAM_BOT_TOKEN
ENV TELEGRAM_CHANNEL_ID $TELEGRAM_CHANNEL_ID

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix* /node_one/
RUN mix deps.get
COPY config/config.exs /node_one/config/
RUN mix deps.compile

COPY . /node_one

RUN mix compile

CMD mix run --no-halt
