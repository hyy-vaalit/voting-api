# Development and tests run via compose (target: dev, see compose.yaml).
# The default target is the production image:
#   docker build -t voting-api .
# All production config (SECRET_KEY_BASE, SAML certs, ...) comes from the
# deploy environment; dotenv is a development/test-only gem.
FROM ruby:4.0.5-slim AS base

WORKDIR /app

# Runtime libs: libpq5 (pg), libyaml-0-2 (psych), liblzma5 (nokogiri).
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libpq5 libyaml-0-2 liblzma5 && \
    rm -rf /var/lib/apt/lists/*

FROM base AS build

# nokogiri, pg and psych build from source (Gemfile.lock PLATFORMS is "ruby" only).
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential patch zlib1g-dev liblzma-dev libpq-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
# Production gems by default; compose overrides with "" for dev/test.
ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}
# Bundler version matches BUNDLED WITH in Gemfile.lock.
RUN gem install bundler -v 4.0.10 && bundle install

FROM build AS dev

COPY . .

# Haka-test example certs, referenced as $(cat cert/haka-test/...) in .env / .env.test
RUN [ -d cert/haka-test ] || { mkdir -p cert && cp -r doc/examples/haka-test cert/; }

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

FROM base AS production

ENV RAILS_ENV=production
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY . .

RUN useradd rails --home /app --shell /usr/sbin/nologin && chown -R rails:rails /app
USER rails

EXPOSE 3000
# The delayed_job worker runs the same image with:
#   bundle exec rake jobs:work
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
