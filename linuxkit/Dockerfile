FROM docker:stable-git
WORKDIR /go/src/github.com/linuxkit
RUN apk add --no-cache make go && \
    go get -u golang.org/x/lint/golint && \
    go get -u github.com/gordonklaus/ineffassign && \
    git clone https://github.com/linuxkit/linuxkit.git
WORKDIR /go/src/github.com/linuxkit/linuxkit
RUN make local

FROM docker:stable
COPY --from=0 /go/src/github.com/linuxkit/linuxkit/bin/linuxkit /bin/linuxkit
