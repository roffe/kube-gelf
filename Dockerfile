FROM debian:stretch-slim
LABEL maintainer "TAGOMORI Satoshi <tagomoris@gmail.com> , Tweaked by Joakim Karlsson <joakim@roffe.nu>"
LABEL Description="Fluentd docker image" Vendor="roffe.nu" Version="1.1"

ARG DEBIAN_FRONTEND=noninteractive

ENV DUMB_INIT_SETSID 0
ENV DUMB_INIT_VERSION=1.2.0

ENV FLUENTD_CONF="fluent.conf"
ENV FLUENTD_OPT=""

RUN mkdir -p /fluentd/etc /fluentd/plugins /fluentd/log

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
            ca-certificates \
            ruby \
 && buildDeps=" \
      make gcc g++ libc-dev \
      ruby-dev \
      wget bzip2 gnupg dirmngr \
    " \
 && apt-get install -y --no-install-recommends $buildDeps \
 && update-ca-certificates \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 2.18.3 \
 && gem install json -v 2.1.0 \
 && gem install fluentd -v 1.0.2 \
 && gem install fluent-plugin-kubernetes_metadata_filter -v 1.0.0 \
 && gem install fluent-plugin-systemd -v 0.3.1 \
 && gem install fluent-plugin-graylog -v 1.0.2 \
 && gem install gelf -v 3.0.0 \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_$dpkgArch \
 && wget https://raw.githubusercontent.com/bedag/fluent-plugin-gelf/master/lib/fluent/plugin/out_gelf.rb -O /fluentd/plugins/out_gelf.rb \
 && chmod +x /usr/bin/dumb-init \
 && wget -O /tmp/jemalloc-4.4.0.tar.bz2 https://github.com/jemalloc/jemalloc/releases/download/4.4.0/jemalloc-4.4.0.tar.bz2 \
 && cd /tmp && tar -xjf jemalloc-4.4.0.tar.bz2 && cd jemalloc-4.4.0/ \
 && ./configure && make \
 && mv lib/libjemalloc.so.2 /usr/lib \
 && apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"

# EXPOSE 24224 5140

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins $FLUENTD_OPT