IMAGE_NAME ?= local/headless-vnc

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -ti --rm -p 6901:6901 -p 5901:5901 $(IMAGE_NAME)

run-debug:
	docker run -ti --rm -p 6901:6901 -p 5901:5901 $(IMAGE_NAME) --debug
