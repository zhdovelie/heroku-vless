FROM alpine:edge
RUN apk update && \
    apk add --no-cache  ca-certificates curl unzip caddy wget tor
COPY /etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
