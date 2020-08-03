# FROM docker:19.03.12
# WORKDIR /go/src/github.com/linuxkit
# RUN apk add --no-cache git make go && \
#     git clone https://github.com/linuxkit/linuxkit.git
# WORKDIR /go/src/github.com/linuxkit/linuxkit
# RUN make

FROM docker:19.03.12
# COPY --from=0 /go/src/github.com/linuxkit/linuxkit/bin/linuxkit /bin/linuxkit
COPY ./linuxkit /bin/linuxkit
