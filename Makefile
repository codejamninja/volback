# Volback v2.0.0 (https://camptocamp.github.io/volback)
# Copyright (c) 2019 Camptocamp
# Licensed under Apache-2.0 (https://raw.githubusercontent.com/camptocamp/volback/master/LICENSE)
# Modifications copyright (c) 2019 Jam Risser <jam@codejam.ninja>

DEPS = $(wildcard */*/*/*.go)
VERSION = $(shell git describe --always --dirty)

all: lint vet test volback

volback: main.go $(DEPS)
	CGO_ENABLED=0 GOOS=linux \
	  go build -a \
		  -ldflags="-s -X main.version=$(VERSION)" \
	    -installsuffix cgo -o $@ $<
	strip $@

lint:
	@ go get -v github.com/golang/lint/golint
	@for file in $$(go list ./... | grep -v '_workspace/' | grep -v 'vendor'); do \
		export output="$$(golint $${file} | grep -v 'type name will be used as docker.DockerInfo')"; \
		[ -n "$${output}" ] && echo "$${output}" && export status=1; \
	done; \
	exit $${status:-0}

vet: main.go
	@go vet $<

imports: main.go
	@dep ensure
	@goimports -d $<

clean:
	@rm -f volback

test:
	@go test -cover -coverprofile=coverage -v ./...

link:
	@rm -rf $$GOPATH/src/github.com/codejamninja/volback
	@mkdir -p $$GOPATH/src/github.com/codejamninja
	@ln -s $(shell pwd) $$GOPATH/src/github.com/codejamninja/volback

.PHONY: all imports lint vet clean test
