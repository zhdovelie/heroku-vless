FROM alpine:edge
ADD configure.sh /configure.sh
RUN apk update
RUN apk add --no-cache --virtual .build-deps ca-certificates iptables curl \
    && chmod +x /configure.sh
RUN rm -rf /var/cache/apk/*
RUN apk del .build-deps
ENTRYPOINT ["sh", "-c", "/configure.sh"]
