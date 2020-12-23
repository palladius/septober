
APPNAME = septober-vintage-volume
VERSION = 0.1


clone: septober-github-copy
	echo Its 63MB I can still tolerate a dupe..

septober-github-copy:
	git clone git@github.com:palladius/septober.git septober-github-copy/
	ln -sf septober-github-copy/Dockerfile ./Dockerfile-copy 

docker-build: clone
	docker build -t $(APPNAME):v$(VERSION) septober-github-copy/
	docker run

# this works!
docker-run-oldway-WORKS:
	echo Camomile yourself: this works.
	docker run -it -p 8080:8080 $(APPNAME):v$(VERSION) ./entrypoint-8080.sh

docker-run-volume:
	#docker run -it -p 8080:8080 $(APPNAME):v$(VERSION) bash
	docker run -it -p 8080:8080 \
	    -v /home/riccardo/git/gcp-metarepo/septober/docker-experiments/septober-vintage-volume/septober-github-copy/:/var/www-public/septober-vintage-volume/ \
	 	$(APPNAME):v$(VERSION) \
	 	bash


--volume: