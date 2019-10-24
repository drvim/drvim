me:
	docker build . -t drvim --build-arg username=$(shell whoami) --build-arg user_id=$(shell id -u) --build-arg group_id=$(shell id -g)

build:
	docker build . -t drvim 

run: build
	docker run -it --rm -h drvim

all: build run

.DEFAULT_GOAL := all
