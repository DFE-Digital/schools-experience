FROM nginx

HEALTHCHECK CMD curl --fail http://localhost:3000/ || exit 1

# Install node, leaving as few artifacts as possible
#RUN apt-get update && apt-get install apt-transport-https && \
#    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
#    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
#    apt-get update && \
#    apt-get install -y -o Dpkg::Options::="--force-confold" --no-install-recommends yarn nodejs && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/dpkg.log
#
## install NPM packages removign artifacts
#COPY package.json yarn.lock ./
#RUN yarn install && yarn cache clean
#
## Install Gems removing artifacts
#COPY .ruby-version Gemfile Gemfile.lock ./
#RUN bundle install --without development --jobs=$(nproc --all) && \
#    rm -rf /root/.bundle/cache && \
#    rm -rf /usr/local/bundle/cache
#
# Add code and compile assets
#COPY . .
#RUN bundle exec rake assets:precompile SECRET_KEY_BASE=stubbed
