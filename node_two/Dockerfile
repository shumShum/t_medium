FROM elixir:1.7.2-slim

RUN apt-get update && apt-get install -y \
      build-essential \
      curl \
      inotify-tools && \
    apt-get install -y --no-install-recommends apt-utils && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /node_two
WORKDIR /node_two

ARG ENV=prod

ENV MIX_ENV $ENV
ENV NODE_ENV production

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix* /node_two/
RUN mix deps.get
COPY config/config.exs /node_two/config/
COPY config/$ENV*.exs /node_two/config/
RUN mix deps.compile

COPY assets/package.json /node_two/assets/
RUN cd assets && npm install --production=false && cd ..

COPY . /node_two

RUN mix compile && \
    cd assets && \
    node_modules/brunch/bin/brunch build --production && \
    npm prune --production && \
    cd .. && \
    mix phx.digest

CMD mix ecto.create && mix ecto.migrate && mix phx.server
