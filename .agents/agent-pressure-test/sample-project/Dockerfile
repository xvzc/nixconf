FROM golang:1.25 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /out/ledger ./cmd/ledger \
 && CGO_ENABLED=0 go build -trimpath -o /out/ledgerctl ./cmd/ledgerctl

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/ledger /out/ledgerctl /usr/local/bin/
EXPOSE 8080
USER nonroot
ENTRYPOINT ["/usr/local/bin/ledger"]
