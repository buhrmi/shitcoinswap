# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=4.0.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Copy Bun runtime binary into base so it is available in all stages
COPY --from=oven/bun:1 /usr/local/bin/bun /usr/local/bin/bun

# Install base runtime dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y curl ffmpeg libpq5 libjemalloc2 libvips && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"


# --- STAGE 1: Download external binaries ---
FROM base AS tools
RUN curl -fsSL https://github.com/DarthSim/hivemind/releases/download/v1.1.0/hivemind-v1.1.0-linux-amd64.gz | gzip -d > /usr/local/bin/hivemind && \
    chmod +x /usr/local/bin/hivemind


# --- STAGE 2: Common Build Environment (Deduplicates Apt Installs) ---
FROM base AS build-base
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives


# --- STAGE 3: Install Ruby Gems ---
FROM build-base AS gems-builder

COPY --link vendor* ./vendor/
COPY --link Gemfile Gemfile.lock ./

RUN --mount=type=cache,target=/root/.bundle/cache,sharing=locked \
    bundle install && \
    rm -rf "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    find "${BUNDLE_PATH}"/ruby/*/gems/ -name "*.o" -o -name "*.c" -delete && \
    bundle exec bootsnap precompile --gemfile


# --- STAGE 4: Build JS Assets ---
FROM base AS assets-builder
COPY --link package.json bun.lock ./
RUN --mount=type=cache,target=/root/.bun,sharing=locked \
    bun install --frozen-lockfile

COPY --link . .
RUN bun run build

# Ensure output directories exist so COPY commands won't fail
RUN mkdir -p app/assets/builds public/assets


# --- STAGE 5: Final App Compilation Stage ---
FROM build-base AS build

# Pull prebuilt gems and compiled JS assets
COPY --from=gems-builder "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --link . .
COPY --from=assets-builder /rails/public ./public

COPY --from=assets-builder /rails/node_modules ./node_modules

# Precompile Bootsnap using all CPU cores
RUN bundle exec bootsnap precompile app/ lib/


# --- STAGE 6: Production Runtime ---
FROM base

COPY --from=tools /usr/local/bin/hivemind /usr/local/bin/hivemind

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

COPY --chown=rails:rails --from=gems-builder "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails