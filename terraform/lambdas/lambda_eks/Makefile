PACKAGE ?= lambda_eks
HANDLER ?= main
GO=docker run --rm -it -v $(PWD):/usr/src/myapp -w /usr/src/myapp -e GOPATH=/go golang:1.12.1 go



build:
	@echo "Building..."
	$(GO) get -v
	$(GO) build -ldflags='-w -s' -o $(HANDLER)

pack:
	@echo "Packing binary..."
	@zip $(PACKAGE).zip $(HANDLER)