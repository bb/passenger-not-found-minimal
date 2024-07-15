FROM phusion/passenger-ruby33

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV TZ=Europe/Berlin
COPY railsapp/.ruby-version /root/.ruby-version
RUN \
    RUBY_VERSION=$(cat /root/.ruby-version) && \
    echo "Using Ruby defined in .ruby-version file: $RUBY_VERSION" && \
    bash -lc "rvm install $RUBY_VERSION && rvm --default use $RUBY_VERSION" && \
    bash -lc 'gem update --system --no-document --silent && gem update --no-document' && \
    rm -f /etc/service/nginx/down && \
    # Install dependencies
    apt-get update && \
    apt-get install -y sudo tzdata shared-mime-info --no-install-recommends && \
    apt upgrade -y -o Dpkg::Options::="--force-confold"  && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    # clean up
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo "Base Install DONE"
RUN \
    echo "Check binary versions" && \
    ruby -v

ENV HOME /root
ENV RAILS_ENV production

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

WORKDIR /home/app/webapp/

# Set up the webserver including using using compressed assets etc.
COPY docker/nginx.conf /etc/nginx/sites-enabled/default

# Make sure Nginx preserves the environment variables listed
COPY docker/rails-env.conf /etc/nginx/main.d/rails-env.conf

RUN chown app:app /home/app/webapp

# pre-install gems for faster building of code changes
COPY --chown=app:app railsapp/.ruby-version railsapp/Gemfile railsapp/Gemfile.lock /home/app/webapp/
# && bundle config set --local without "development test"'
RUN sudo -Hu app sh -c 'cd /home/app/webapp && bundle config set --local deployment "true" && bundle config set --local path vendor/ruby && bundle install'

COPY --chown=app:app railsapp/. .
