
ifndef BUILDBASE
	export BUILDBASE=$(GOPATH)/src/github.com/crunchydata/crunchy-watch
endif

versiontest:
	if test -z "$$CCP_PGVERSION"; then echo "CCP_PGVERSION undefined"; exit 1;fi;
	if test -z "$$CCP_BASEOS"; then echo "CCP_BASEOS undefined"; exit 1;fi;
	if test -z "$$CCP_VERSION"; then echo "CCP_VERSION undefined"; exit 1;fi;
gendeps:
	godep save \
	github.com/crunchydata/crunchy-watch/watchapi 

docbuild:
	cd docs && ./build-docs.sh
watchserver:
	cp `which oc` bin/watch
	cp `which kubectl` bin/watch
	docker build -t crunchy-watch -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.watch.$(CCP_BASEOS) .
	docker tag crunchy-watch crunchydata/crunchy-watch:$(CCP_BASEOS)-$(CCP_PGVERSION)-$(CCP_VERSION)
version:
	docker build -t crunchy-version -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.version.$(CCP_BASEOS) .
	docker tag crunchy-version crunchydata/crunchy-version:$(CCP_BASEOS)-$(CCP_PGVERSION)-$(CCP_VERSION)
backrest:
	make versiontest
watchserver:
	cp `which oc` bin/watch
	cp `which kubectl` bin/watch
	cd watch && godep go install watchserver.go
	cp $(GOBIN)/watchserver bin/watch
	docker build -t crunchy-watch -f $(CCP_BASEOS)/$(CCP_PGVERSION)/Dockerfile.watch.$(CCP_BASEOS) .
	docker tag crunchy-watch crunchydata/crunchy-watch:$(CCP_BASEOS)-$(CCP_PGVERSION)-$(CCP_VERSION)

all:
	make versiontest
	make watch
push:
	./bin/push-to-dockerhub.sh
default:
	all
test:
	./tests/standalone/test-watch.sh; /usr/bin/test "$$?" -eq 0
