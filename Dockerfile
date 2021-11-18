FROM alpine:edge
ADD configure.sh /configure.sh
RUN apk update
RUN apk add --no-cache --virtual .build-deps ca-certificates curl \
    && chmod +x /configure.sh
RUN apk del .build-deps
ENTRYPOINT ["sh", "-c", "/configure.sh"]
