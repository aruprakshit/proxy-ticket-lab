FROM ruby:4.0.6-slim

# Native gems such as json and Puma's dependencies need a C compiler
# and related build tools during bundle install.
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Require the lockfile to match the declared dependencies.
ENV BUNDLE_FROZEN=true

# Cache dependency installation separately from application changes.
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY app.rb config.ru ./

# Listen on the container's network interfaces, not only its loopback.
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:4567", "config.ru"]
