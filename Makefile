
install:
	sudo apt-get install sqlite libsqlite3-dev

configure:
	rake db:migrate
	rake db:seed

docker-run:
	sudo docker build -t riccseptober .
	sudo docker run --name riccardo-septober -d riccseptober
