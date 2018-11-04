.PHONY: generate data setup

install: setup data generate
	go get ./...
	go install

release: setup-release
	@: $(if ${GITHUB_TOKEN},,$(error GITHUB_TOKEN must be defined))
	git tag -a $(VERSION) -m "$(VERSION)"
	git push origin $(VERSION)
	goreleaser --rm-dist --parallelism 1 || (git tag -d $(VERSION) && git push --delete origin $(VERSION))

autorelease: install
	@: $(if ${GITHUB_TOKEN},,$(error GITHUB_TOKEN must be defined))
	git add . && git diff --cached --exit-code || \
		( \
			echo 'New data files found, updating...' \
			&& git commit -m "Update data files" \
			&& git push origin master \
			&& GITHUB_TOKEN="${GITHUB_TOKEN}" $(MAKE) release VERSION=v1.0.$$(date +%s)\
		)

data:
	rm -fr data
	mkdir data
	curl -sSL https://github.com/tldr-pages/tldr/raw/master/LICENSE.md -o LICENSE-tldr-pages
	curl -sSL https://github.com/tldr-pages/tldr/archive/master.tar.gz | \
		tar --transform 's/\.md//' -xz --directory data tldr-master/pages/ --strip-components=2
	cp -n data/common/* data/linux/
	cp -n data/common/* data/osx/
	cp -n data/common/* data/sunos/
	cp -n data/common/* data/windows/

generate:
	cd data/linux && embedfiles -out ../../data_linux.go .
	cd data/osx && embedfiles -out ../../data_darwin.go .
	cd data/sunos && embedfiles -out ../../data_solaris.go .
	cd data/windows && embedfiles -out ../../data_windows.go .

setup:
	go get 4d63.com/embedfiles

setup-release:
	go get github.com/goreleaser/goreleaser
