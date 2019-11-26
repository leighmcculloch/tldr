generate:
	go generate

build:
	go build

release:
	go run github.com/goreleaser/goreleaser --rm-dist
