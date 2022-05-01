FROM alpine:edge
COPY ./setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh && sh -ec /tmp/setup.sh && rm -vf /tmp/setup.sh
