FROM alpine:3.8

# configure alpine and install packages
RUN apk update
RUN apk add --no-cache \
        build-base \
        libffi-dev \
        ruby \
        ruby-dev \
        ruby-bundler \
        ruby-webrick
        
RUN  apk add libatomic readline readline-dev libxml2 libxml2-dev \
        ncurses-terminfo-base ncurses-terminfo \
        libxslt libxslt-dev zlib-dev zlib \
        yaml yaml-dev \
        ruby-io-console ruby-irb ruby-json ruby-rake ruby-rdoc ruby-bigdecimal

# configure gem
RUN gem sources -c

# create working directory
WORKDIR /build
# copy gemfile
COPY Gemfile /build/Gemfile
COPY launch-script.sh /build/launch-script.sh

# install gems
RUN gem install bundler -v 1.17.3
RUN bundle install

# in case you wish to run site locally
EXPOSE 4000

# Needs to mount /build/repo
ENTRYPOINT [ "./launch-script.sh" ]
