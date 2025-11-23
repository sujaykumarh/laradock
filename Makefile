.PHONY: help

help:
	@echo ""
	@echo "TODO Help."
	@echo ""

build-docker:
	docker build -t laradock:latest .

build-docker-local:
	docker build --build-arg LARAVEL_UID=${UID} --build-arg LARAVEL_GID=${GID} -t laradock:local .

buildx-docker:
	docker buildx build -t laradock:latest .

buildx-docker-local:
	docker buildx build --build-arg LARAVEL_UID=${UID} --build-arg LARAVEL_GID=${GID} -t laradock:local .

buildx-docker-arm:
	docker buildx build --platform linux/arm64 -t laradock:arm64 .

buildx-docker-local-arm:
	docker buildx build --platform linux/arm64 --build-arg LARAVEL_UID=${UID} --build-arg LARAVEL_GID=${GID} -t laradock:local-arm64 .