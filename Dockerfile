FROM alpine:edge
ENV CF_Token="" \
    CF_Account_ID=""
ENV ENV="/etc/profile"
RUN apk update && \
    apk add --no-cache  ca-certificates curl unzip caddy socat acme.sh wget tor
ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
