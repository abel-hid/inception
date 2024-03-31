.PHONY: all build up down clean re

all: build

build: clean
	@echo "Building images..."
	@cd srcs && docker-compose up --build

up:
	@cd srcs && docker compose up

down:
	@cd srcs && docker-compose down

clean:
	@echo "Cleaning images..."
	@cd srcs && docker-compose down --rmi all --volumes --remove-orphans
	@docker system prune -af

re: clean all