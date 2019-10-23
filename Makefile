build:
	docker build . -t drvim

run: build
	docker run -it --rm -h drvim drvim:latest

all: build run

.DEFAULT_GOAL := all
