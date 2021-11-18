FROM alpine:edge
ADD configure.sh /configure.sh
RUN apk update \
    && apk add --no-cache --virtual .build-deps ca-certificates curl \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps \
    && chmod +x /configure.sh
ENTRYPOINT ["sh", "-c", "/configure.sh"]
