FROM golang:1.21.6-bullseye as dependencies
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

FROM golang:1.21.6-bullseye as builder
WORKDIR /app
COPY --from=dependencies /go/pkg /go/pkg
COPY . ./
RUN GOOS=linux go build -v -o voter_server

FROM debian:bullseye-20240110-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
ENV ENVIRONMENT=production
COPY --from=builder /app/voter_server /voter_server
CMD ["/voter_server"]
