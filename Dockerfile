FROM alpine:edge
RUN apk update && \
    apk add --no-cache  ca-certificates curl unzip nginx wget tor
COPY wwwroot.tar.gz /wwwroot/wwwroot.tar.gz
COPY /etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
