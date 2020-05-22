FROM ruby:2.6.6-alpine3.11

ENV RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    RACK_TIMEOUT_SERVICE_TIMEOUT=60 \
    BUNDLE_BUILD__SASSC=--disable-march-tune-native

RUN mkdir /app
WORKDIR /app

EXPOSE 3000
ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "server" ]

RUN apk add --no-cache build-base git tzdata libxml2 libxml2-dev \
                        postgresql-libs postgresql-dev nodejs yarn

# install NPM packages removign artifacts
COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean

# Install Gems removing artifacts
COPY .ruby-version Gemfile Gemfile.lock ./
RUN gem install bundler --version='~> 2.1.4' && \
    bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java && \
    bundle config set without 'development' && \
    bundle install --jobs=$(nproc --all) && \
    rm -rf /root/.bundle/cache && \
    rm -rf /usr/local/bundle/cache

# Add code and compile assets
COPY . .
RUN bundle exec rake assets:precompile SECRET_KEY_BASE=stubbed SKIP_REDIS=true

# Create symlinks for CSS files without digest hashes for use in error pages
RUN bundle exec rake assets:symlink_non_digested SECRET_KEY_BASE=stubbed SKIP_REDIS=true
