- Instalei as dependências
- Compila o projeto

----- > Tive alguns problemas na hora de compilar no Dcoker, erros com a versão do Elixir no DockerFile, tive diversos problemas, acredito que no docs/erros > Vai estar alguns problemas que enfrentei

> executa a release
> roda em prod

```dockerfile
# ---------- BUILD ----------
FROM elixir:1.17

RUN apt-get update && apt-get install -y build-essential git

WORKDIR /app

# instala hex/rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# deps
COPY mix.exs mix.lock ./
RUN mix deps.get

# código
COPY . .

# compila deps e app
RUN MIX_ENV=prod mix deps.compile
RUN MIX_ENV=prod mix compile

# gera release
RUN MIX_ENV=prod mix release


# ---------- RUNTIME ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y openssl libstdc++6

WORKDIR /app

COPY --from=0 /app/_build/prod/rel/w_core ./

ENV HOME=/app

CMD ["bin/w_core", "start"]


Persistência de dados 

> O SQLite fica armazenado em /app/data



FLUXO DE DADOS FINAL 

[Eventos]
   ↓
Ingestor (GenServer)
   ↓
ETS (memória - ultra rápido)
   ↓
WriteBehind (batch async)
   ↓
SQLite (persistência)
   ↓
Dashboard (LiveView)




