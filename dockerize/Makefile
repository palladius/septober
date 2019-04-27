
# I doubt this work ;-)
run:
	docker build -t riccseptober .
	docker run --name riccardo-septober -d riccseptober

run-v1:
	docker run -it -p 3002:3000 --name=septober-v1-p3002 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'

build:
	docker build -t=septober-ng .

run-latest-build: build
	docker run -it septober-ng:latest bash -c -- 'cd /home/riccardo/git/septober/ && PORT=8080 make run-prod'

debug:
	docker run -it -P --name septober-unico-$(VER) palladius/septober:$(VER) bash

push2dockerhub-v2.0:
	@echo "Assuming you tag is: 7d27ead4236d. TODO(ricc): make it smarter"
	docker tag 7d27ead4236d palladius/septober:autopush
	docker push palladius/septober:autopush
