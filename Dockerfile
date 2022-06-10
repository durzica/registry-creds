FROM eu.gcr.io/tradeshift-base/tradeshift-golang:18 as builder

ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG Version
ARG GitCommit

WORKDIR /workspace

COPY go.mod go.mod
COPY go.sum go.sum

RUN go mod download

# Copy the go source
COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/

# Build
RUN echo flags=${Version} ${GitCommit}
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
  GO111MODULE=on go build -ldflags "-s -w -X main.Release=${Version} -X main.SHA=${GitCommit}" -a -o /usr/bin/controller

# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /usr/bin/controller .
USER nonroot:nonroot

ENTRYPOINT ["/controller"]
