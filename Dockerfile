FROM ruby:3.1.0-alpine3.15

ENV RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    RACK_TIMEOUT_SERVICE_TIMEOUT=60 \
    BUNDLE_BUILD__SASSC=--disable-march-tune-native

RUN mkdir /app
WORKDIR /app

EXPOSE 3000
ENTRYPOINT [ "/app/docker-entrypoint.sh"]
CMD ["-m", "--frontend" ]

ARG SHA
RUN echo "sha-${SHA}" > /etc/school-experience-sha

# remove upgrade zlib-dev & busybox when ruby:3.1.0-alpine3.15 base image is updated to address snyk vuln https://snyk.io/vuln/SNYK-ALPINE315-ZLIB-2434420
# also https://security.snyk.io/vuln/SNYK-ALPINE315-NCURSES-2952568
# hadolint ignore=DL3018
RUN apk update && apk add -Uu --no-cache zlib-dev busybox ncurses

# hadolint ignore=DL3018
RUN apk add -U --no-cache bash build-base git tzdata libxml2 libxml2-dev \
			postgresql-libs postgresql-dev\
            chromium=99.0.4844.84-r0 chromium-chromedriver=99.0.4844.84-r0

# Install Node.js 18
RUN apk add --no-cache nodejs~=18 npm~=18

# Install Yarn
RUN npm install -g yarn@1.22.17

# Remove once base image ruby:3.1.0-alpine3.15 has been updated
RUN apk add --no-cache gmp=6.2.1-r1 libretls=3.3.4-r3

# Copy Entrypoint script
COPY script/docker-entrypoint.sh .
RUN chmod +x /app/docker-entrypoint.sh

# install NPM packages removign artifacts
COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean

# Install Gems removing artifacts
COPY .ruby-version Gemfile Gemfile.lock ./
# hadolint ignore=SC2046
RUN gem install bundler --version='~> 2.3.10' && \
    bundle install --jobs=$(nproc --all) && \
    rm -rf /root/.bundle/cache && \
    rm -rf /usr/local/bundle/cache

# Add code and compile assets
COPY . .
RUN bundle exec rake assets:precompile SECRET_KEY_BASE=stubbed SKIP_REDIS=true

# Create symlinks for CSS files without digest hashes for use in error pages
RUN bundle exec rake assets:symlink_non_digested SECRET_KEY_BASE=stubbed SKIP_REDIS=true
