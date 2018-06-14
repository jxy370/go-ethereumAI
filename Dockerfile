# Build Geai in a stock Go builder container
FROM golang:1.10-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers

ADD . /go-ethereumai
RUN cd /go-ethereumai && make geai

# Pull Geai into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereumai/build/bin/geai /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geai"]
