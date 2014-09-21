
install:
	sudo apt-get install sqlite libsqlite3-dev
	touch install

configure: install
	bundle install
	rake db:migrate
	rake db:seed
	touch configure

docker-run:
	sudo docker build -t riccseptober .
	sudo docker run --name riccardo-septober -d riccseptober

run: configure
	rake db:migrate
	rails server
