FROM ruby:2.5

ENV XRAILS_ENV=production \
    XRAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# Install node, leaving as few artifacts as possible
RUN apt-get update && apt-get install apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update && \
    apt-get install -y -o Dpkg::Options::="--force-confold" --no-install-recommends yarn nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log

RUN mkdir /app
WORKDIR /app

# install NPM packages removign artifacts
COPY package.json yarn.lock /app/package.json
RUN yarn install && yarn cache clean

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

EXPOSE 3000
ENTRYPOINT ["bundle", "exec"]

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]

HEALTHCHECK CMD curl --fail http://localhost:3000/ || exit 1

# Install Gems removing artifacts
#COPY .ruby-version Gemfile Gemfile.lock ./
#RUN bundle install --without development --jobs=$(nproc --all) && \
#    rm -rf /root/.bundle/cache && \
#    rm -rf /usr/local/bundle/cache

# Add code and compile assets
#COPY . .
#RUN bundle exec rake assets:precompile SECRET_KEY_BASE=stubbed
