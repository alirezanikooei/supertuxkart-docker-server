FROM alpine:3.24

RUN apk add --no-cache \
    supertuxkart-server \
    bash \
    ca-certificates \
    libxml2-utils

ENV HOME=/home/stkserver
RUN adduser -D -u 1000 stkserver \
    && mkdir -p /home/stkserver/.config/supertuxkart/config-0.10 \
    && chown -R stkserver:stkserver /home/stkserver
COPY --chmod=0755 entrypoint.sh /usr/local/bin/stk-entrypoint
COPY server_config.example.xml /usr/local/share/stk/server_config.example.xml

USER stkserver
WORKDIR /home/stkserver

EXPOSE 2757/udp 2759/udp
ENTRYPOINT ["/usr/local/bin/stk-entrypoint"]
