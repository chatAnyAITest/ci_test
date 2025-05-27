# API build stage
FROM golang:1.21.0-alpine3.17 AS go-builder
ARG GOPROXY=goproxy.cn
ARG MY_GITHUB_TOKEN

ENV GOPROXY=https://${GOPROXY},direct
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add --no-cache make bash git tzdata
RUN git config --global url."https://allentatakai:${MY_GITHUB_TOKEN}@github.com".insteadOf "https://github.com"
RUN go env -w GOPRIVATE=github.com/ragzone/ragpdf
WORKDIR /chatanyai
COPY . .
RUN ls -rtl pkg/router/ui/build/
RUN make build
RUN strings ./bin/chatanyai | grep "index.html"

# Fianl running stage
FROM chatanyai/alpine3.17plus:latest
LABEL maintainer="support@chatanyai.com"

WORKDIR /chatanyai

COPY --from=go-builder /chatanyai/bin/chatanyai ./bin/
COPY --from=go-builder /chatanyai/config ./config
COPY --from=go-builder /chatanyai/examples ./examples
COPY --from=go-builder /chatanyai/scripts/build/entrypoint.sh /entrypoint.sh

EXPOSE 9088

RUN apk add --no-cache tzdata

CMD ["sh", "-c", "./bin/chatanyai server"]