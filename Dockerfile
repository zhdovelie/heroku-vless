FROM windows:20H2-KB5005033-amd64
RUN apk update && \
    apk add --no-cache  ca-certificates curl unzip caddy wget tor
ENTRYPOINT ["mysql"]
ENV XDG_CONFIG_HOME /etc/caddy
ENV XDG_DATA_HOME /usr/share/caddy
ENV HOME /usr/share/caddy
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
