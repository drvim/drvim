me:
	docker build . -t drvim --build-arg username=$(shell whoami) --build-arg user_id=$(shell id -u) --build-arg group_id=$(shell id -g)

base:
	docker build ./drvim-base -t drvim-base

jupyter: base
	docker build ./drvim-jupyter -t drvim-jupyter

build:
	docker build . -t drvim 

run: build
	docker run -it --rm -h drvim drvim

all: build run

.DEFAULT_GOAL := all
