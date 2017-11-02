
# I doubt this work ;-)
run:
	sudo docker build -t riccseptober .
	sudo docker run --name riccardo-septober -d riccseptober

run-v1:
	sudo docker run -it -p 3002:3000 --name=septober-v1-p3002 palladius/septober:v1 bash -c -- 'cd /home/riccardo/git/septober/ && make run'

build:
	sudo docker build -t=septober-ng .

debug:
	sudo docker run -it -P --name septober-unico-$(VER) palladius/septober:$(VER) bash

push2dockerhub-v2.0:
	@echo "Assuming you tag is: 7d27ead4236d. TODO(ricc): make it smarter"
	sudo docker tag 7d27ead4236d palladius/septober:autopush
	sudo docker push palladius/septober:autopush
