FROM ruby:2.7.0
MAINTAINER Abdulrahman Dimashki <idimsh@gmail.com>

############################
## Terminal enhancements
############################
RUN cd /root && \
    git clone https://gist.github.com/1980f616aef1d17106df06304d993d56.git && \
    mv 1980f616aef1d17106df06304d993d56/bash-aliases.sh /opt/bash-aliases && \
    rm -rf 1980f616aef1d17106df06304d993d56 && \
    /bin/echo -e "\n\n## idimsh bash aliases ####\n. /opt/bash-aliases\n\n" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    true

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get update --fix-missing
RUN apt-get install -y --no-install-recommends locales
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8

# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen


RUN gem install bundler jekyll

COPY Gemfile /tmp/Gemfile
RUN bundle install --gemfile /tmp/Gemfile && \
    rm -f /tmp/Gemfile* Gemfile*

WORKDIR /srv/jekyll
VOLUME  /srv/jekyll

EXPOSE 4000 80


CMD bundle exec jekyll serve -d ./_site --watch --force_polling -H 0.0.0.0 -P 4000
