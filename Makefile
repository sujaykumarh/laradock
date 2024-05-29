.PHONY: help

help:
	@echo ""
	@echo "TODO Help."
	@echo ""

build-docker:
	docker build -t laravel:latest .

buildx-docker:
	docker buildx build -t laravel:latest .

buildx-docker-local:
	docker buildx build --build-arg LARAVEL_UID=${UID} --build-arg LARAVEL_GID=${GID} -t laravel:local .