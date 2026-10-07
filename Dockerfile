FROM ruby:4.0.7-alpine3.23

ENV RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    RACK_TIMEOUT_SERVICE_TIMEOUT=60 \
    BUNDLE_BUILD__SASSC=--disable-march-tune-native

RUN mkdir -p /app/tmp /app/out /app/log
WORKDIR /app

# Create non-root user and group
RUN addgroup -S appgroup -g 20001 && adduser -S appuser -G appgroup -u 10001


# zlib is a transitive dependency (Ruby's zlib ext + nodejs/chromium/libxml2), so it can't be
# removed, only patched. Alpine 3.23 ships zlib 1.3.2-r0, still vulnerable to CVE-2026-85091 (High),
# so pin the patched build: https://security.snyk.io/vuln/SNYK-ALPINE323-ZLIB-20541565
# hadolint ignore=DL3018
RUN apk add -U --no-cache "zlib>=1.3.2-r1" \
    bash build-base git tzdata libxml2 libxml2-dev \
    libffi-dev yaml-dev gcompat gcc postgresql-libs postgresql-dev nodejs npm yarn \
    chromium chromium-chromedriver

# Copy Entrypoint script
COPY script/docker-entrypoint.sh .
RUN chmod +x /app/docker-entrypoint.sh

# install NPM packages removign artifacts
COPY package.json yarn.lock .yarnrc.yml ./
RUN npm install -g corepack@0.35.0  \
    && corepack enable  \
    && yarn install --immutable  \
    && yarn cache clean

# Install Gems removing artifacts
COPY .ruby-version Gemfile Gemfile.lock ./
# hadolint ignore=SC2046
RUN gem install bundler --version='~> 2.6.8' && \
    bundle install --jobs=$(nproc --all) && \
    rm -rf /root/.bundle/cache && \
    rm -rf /usr/local/bundle/cache

# Add code and compile assets (Propshaft digests the esbuild/Dart Sass builds)
COPY . .
RUN bundle exec rake assets:precompile SECRET_KEY_BASE=stubbed SKIP_REDIS=true

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}
RUN echo "sha-${SHA}" > /etc/school-experience-sha

# Create writable directories and set proper permissions for non-root user
RUN mkdir -p /app/tmp /app/out /app/log /app/coverage /tmp /tmp/prometheus/ && \
    chown -R appuser:appgroup /app/tmp /app/out /app/log /app/coverage /tmp /tmp/prometheus/ &&\
    chmod -R u+rwX /app/tmp /app/out /app/log /app/coverage /tmp /tmp/prometheus/

# Use non-root user
USER 10001

EXPOSE 3000
ENTRYPOINT [ "/app/docker-entrypoint.sh"]
CMD ["-m", "--frontend" ]
