FROM golang:1.10.3-alpine3.7 as builder
RUN \
    cd / && \
    apk update && \
    apk add --no-cache git ca-certificates make tzdata && \
    git clone https://github.com/vortland/prometheus_bot && \
    cd prometheus_bot && \
    go get -d -v && \
    CGO_ENABLED=0 GOOS=linux go build -v -a -installsuffix cgo -o prometheus_bot 


FROM alpine:3.9
COPY --from=builder /prometheus_bot/prometheus_bot /
RUN apk add --no-cache ca-certificates tzdata tini

USER nobody
EXPOSE 9087

ENV PROXY_URL=
ENV PROXY_USERNAME=
ENV PROXY_PASSWORD=
ENV CONFIG_PATH=/config/config.yaml
ENV TEMPLATE_PATH=/config/default.tmpl

ENTRYPOINT /sbin/tini -- /prometheus_bot -c=$CONFIG_PATH -t=$TEMPLATE_PATH
