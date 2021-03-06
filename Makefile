TEST?=./...
VETARGS?=-asmdecl -atomic -bool -buildtags -copylocks -methods \
         -nilfunc -printf -rangeloops -shift -structtags -unsafeptr

default: test

bin:
	@XC_OS=linux XC_ARCH=amd64 sh -c "$(CURDIR)/scripts/build.sh"

dev:
	@TF_DEV=1 sh -c "$(CURDIR)/scripts/build.sh"

zip:
	@mkdir built
	@cd /home/travis/gopath/bin/; zip packer_0.80_linux_amd64.zip *; cd -; mv /home/travis/gopath/bin/packer_0.80_linux_amd64.zip built/

test:
	go test $(TEST) $(TESTARGS) -timeout=10s
	@$(MAKE) vet

testrace:
	go test -race $(TEST) $(TESTARGS)

updatedeps:
	go get -d -v -p 2 ./...

vet:
	@go tool vet 2>/dev/null ; if [ $$? -eq 3 ]; then \
		go get golang.org/x/tools/cmd/vet; \
	fi
	@go tool vet $(VETARGS) . ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for reviewal."; \
	fi

.PHONY: bin default test updatedeps vet
