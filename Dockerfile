FROM fluent/fluentd:v0.14-debian
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
 && gem install fluent-plugin-kubernetes_metadata_filter_v0.14 -v 0.24.1 \
 && gem install gelf -v 3.0.0 \
 && gem install fluent-plugin-systemd -v 0.3.0 \
 && apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY out_gelf.rb /fluentd/plugins/out_gelf.rb

ENTRYPOINT ["gosu"]

CMD ["root", "exec", "fluentd", "-c", "/fluentd/etc/fluent.conf", "-p", "/fluentd/plugins"]