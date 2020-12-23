
# I doubt this work ;-)
run: build
#	docker build -t riccseptober .
#	docker run --name riccardo-septober -d riccseptober
	docker run -it -p 8080:8080 septober-ng ./entrypoint-8080.sh

run-v1:
	docker run -it -p 3002:3000 --name=septober-v1-p3002 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'

build:
	docker build -t=septober-ng .

# PORT=8080  DOESNT WORK :/
run-latest-build: build
	docker run -it -p 8080:3000 septober-ng:latest bash -c -- 'cd /home/riccardo/git/septober/ && make run-prod'

debug:
	docker run -it -P --name septober-unico-$(VER) palladius/septober:$(VER) bash

push2dockerhub-v2.0:
	@echo "Assuming you tag is: 7d27ead4236d. TODO(ricc): make it smarter"
	docker tag 7d27ead4236d palladius/septober:autopush
	docker push palladius/septober:autopush


#############################################
# 2020 effort to restore old amazing apps :)
# idea: https://rollout.io/blog/running-rails-development-environment-docker/

septober-volume:
	git clone git@github.com:palladius/septober.git septober-volume/
	touch !$/.septober-volume.touch 

docker-septvolume-build: septober-volume
	docker build -t septober-volume septober-volume/


docker-septvolume-run: septober-volume
	yellow TODO build docker-septvolume-build
	docker run -itP -p 3000:3000 -v `pwd`/septober-volume/:/var/www-public/septober septober-volume bash


