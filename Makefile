TYPE := carbon-relay-ng
IMAGE_NAME := docker-${TYPE}

build:
	docker build --rm --tag=$(IMAGE_NAME) .

run:
	docker run \
		--detach \
		--interactive \
		--tty \
		--hostname=${TYPE} \
		--name=${TYPE} \
		$(IMAGE_NAME)

shell:
	docker run \
		--rm \
		--interactive \
		--tty \
		--hostname=${TYPE} \
		--name=${TYPE} \
		$(IMAGE_NAME) \
		/bin/sh

exec:
	docker exec \
		--interactive \
		--tty \
		${TYPE} \
		/bin/sh

stop:
	docker kill \
		${TYPE}
