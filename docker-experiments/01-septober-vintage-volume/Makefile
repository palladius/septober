
APPNAME = septober-vintage-volume
VERSION = $(shell cat DOCKERIZE_VERSION )


clone: septober-github-copy
	@echo Its 63MB I can still tolerate a dupe..

septober-github-copy:
	git clone git@github.com:palladius/septober.git septober-github-copy/
	ln -sf septober-github-copy/Dockerfile ./Dockerfile-copy 

docker-build: clone
	docker build -t $(APPNAME):v$(VERSION) septober-github-copy/
	#docker run
	echo Built $(APPNAME):v$(VERSION) my dear.

# this works!
docker-run-oldway-WORKS:
	echo Camomile yourself: this works.
	docker run -it -p 8080:8080 $(APPNAME):v$(VERSION) ./entrypoint-8080.sh

docker-run-volume: docker-build
	#docker run -it -p 8080:8080 $(APPNAME):v$(VERSION) bash
	#@echo Also exposing 3306 from outside to inside for mysql tests..
	@yellow Riccardo Remember to switch to another non default dir: /var/www-public/septober-vintage-volume/
	docker run -it -p 8080:8080  \
	    -v /home/riccardo/git/gcp-metarepo/septober/docker-experiments/septober-vintage-volume/septober-github-copy/:/var/www-public/septober-vintage-volume/ \
	 	$(APPNAME):v$(VERSION) \
	 	bash

