generate:
	go generate

build: generate
	go build

release: generate
	git diff --cached --exit-code
	git add . && git diff --cached --exit-code
	go run github.com/goreleaser/goreleaser --rm-dist
