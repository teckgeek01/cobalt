FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app
RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk
RUN --mount=type=cache,id=s/5d6ce327-caa7-4554-b165-5e008e15bd5e-/pnpm/store,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app
RUN apk add --no-cache git
COPY --from=build --chown=node:node /prod/api /app
COPY --chown=node:node cookies.json /app/cookies.json
RUN git init -q \
 && git config user.email "build@local" \
 && git config user.name "build" \
 && git remote add origin https://github.com/teckgeek01/cobalt.git \
 && git add -A \
 && git commit -qm "railway build" \
 && chown -R node:node /app/.git
USER node
EXPOSE 9000
CMD [ "node", "src/cobalt" ]
