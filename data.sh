#! /usr/bin/env sh

cwd="$PWD"

rm -fr data
mkdir data
curl -sSL https://github.com/tldr-pages/tldr/raw/master/LICENSE.md -o LICENSE-tldr-pages
curl -sSL https://github.com/tldr-pages/tldr/archive/master.tar.gz | tar --transform 's/\.md//' -xz --directory data tldr-master/pages/ --strip-components=2
cd "$cwd"/data/common && go run 4d63.com/embedfiles -out ../../data_common.go -file-names-var commonFileNames -files-var commonFiles .
cd "$cwd"/data/linux && go run 4d63.com/embedfiles -out ../../data_linux.go .
cd "$cwd"/data/osx && go run 4d63.com/embedfiles -out ../../data_darwin.go .
cd "$cwd"/data/windows && go run 4d63.com/embedfiles -out ../../data_windows.go .
