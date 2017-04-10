.PHONY: all
all: deploy

# getting and updating sources
graal-jvmci-8:
	hg clone http://hg.openjdk.java.net/graal/graal-jvmci-8

source: graal-jvmci-8
	git submodule update --init --recursive

mx: source
truffle: source
graal-core: source

update: source
	cd graal-jvmci-8; hg pull -u
	cd mx; git pull origin master
	cd graal-core; git pull origin master; ../mx/mx sforceimport
	git add graal-core
	git add truffle
	git add mx
	git commit -m "Updated to graal-core ref $(shell git rev-parse HEAD graal-core/ | head -1)" || true

# cleaning
clean_jvmci: graal-jvmci-8
	cd graal-jvmci-8; hg purge --all

clean_truffle: truffle
	cd truffle; git clean -fdx

clean_graal: graal-core
	cd graal-core; git clean -fdx

clean: clean_truffle clean_graal clean_jvmci

# building

# Ugh, the first time this build fails, the second time works?
jvmci: mx graal-jvmci-8
	cd graal-jvmci-8; echo "n" | ../mx/mx build || echo "n" | ../mx/mx build

java_home: jvmci
	$(eval JAVA_HOME = $(shell cd graal-jvmci-8; ../mx/mx jdkhome))
	@echo "JAVA_HOME is at $(JAVA_HOME)"

graal: mx graal-core java_home
	export JAVA_HOME=$(JAVA_HOME); cd graal-core; ../mx/mx build

deploy: java_home graal
	cd graal-core; cp mxbuild/dists/graal.jar $(JAVA_HOME)/jre/lib/jvmci/
