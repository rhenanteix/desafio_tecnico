# ---------- BUILD ----------
    FROM elixir:1.16 AS build

    RUN apt-get update && apt-get install -y build-essential git
    
    WORKDIR /app
    
    RUN mix local.hex --force && \
        mix local.rebar --force
    
    COPY mix.exs mix.lock ./
    RUN mix deps.get
    RUN mix deps.compile
    
    COPY . .
    
    RUN MIX_ENV=prod mix deps.compile
    RUN MIX_ENV=prod mix compile
    
    RUN MIX_ENV=prod mix release
    
    
    # ---------- RUNTIME ----------
    FROM debian:bookworm-slim
    
    RUN apt-get update && apt-get install -y openssl libstdc++6
    
    WORKDIR /app
    
    COPY --from=build /app/_build/prod/rel/w_core ./
    
    ENV HOME=/app
    
    CMD ["bin/w_core", "start"]