FROM ruby:2.7.0
MAINTAINER Abdulrahman Dimashki <idimsh@gmail.com>

ENV BUNDLE_HOME=/usr/local/bundle
ENV GEM_HOME=/usr/gem

############################
## Terminal enhancements
############################
RUN cd /root && \
    git clone https://gist.github.com/1980f616aef1d17106df06304d993d56.git && \
    mv 1980f616aef1d17106df06304d993d56/bash-aliases.sh /opt/bash-aliases && \
    rm -rf 1980f616aef1d17106df06304d993d56 && \
    /bin/echo -e "\n\n## idimsh bash aliases ####\n. /opt/bash-aliases\n\n" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    true

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends nodejs && \
    gem install bundler

RUN apt-get install -y --no-install-recommends \
  zlib1g-dev \
  build-essential \
  libxml2-dev \
  libxslt-dev \
  libreadline-dev \
  libffi-dev \
  libyaml-dev \
  libffi-dev


# --
# Gems
# Update
# --
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN unset GEM_HOME && unset GEM_BIN && \
  yes | gem update --system

# --
# Gems
# Main
# --
# Work around a nonsense RubyGem permission bug.
RUN unset GEM_HOME && unset GEM_BIN && yes | gem install --force bundler
RUN gem install jekyll -- --use-system-libraries

RUN echo 'source "https://rubygems.org"\n\
gem "github-pages", group: :jekyll_plugins\n\
gem "jekyll-github-metadata"\n\
gem "jekyll-octicons"\n\
gem "jemoji"\n'\
> /tmp/Gemfile

RUN printf "\nBuilding required Ruby gems. Please wait...\n\n" && \
    bundle install --gemfile /tmp/Gemfile && \
    rm -f /tmp/Gemfile

RUN apt-get -y purge \
    zlib1g-dev \
    build-essential \
    libxml2-dev \
    libxslt-dev \
    libreadline-dev \
    libffi-dev \
    libyaml-dev \
    libffi-dev

RUN for i in /usr/gem/bin/*; do ln -s $i /usr/local/bin/`basename $i`; done

RUN rm -rf /root/.gem
RUN rm -rf /home/jekyll/.gem
RUN rm -rf $BUNDLE_HOME/cache
RUN rm -rf $GEM_HOME/cache

WORKDIR /srv/jekyll
VOLUME  /srv/jekyll

EXPOSE 4000 80


CMD bundle exec jekyll serve -d /_site --watch --force_polling -H 0.0.0.0 -P 4000
