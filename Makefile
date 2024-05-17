.PHONY: all build up down clean re



all: build

init:
	@mkdir -p /Users/abel-hid/goinfre/data/wordpress
	@mkdir -p /Users/abel-hid/goinfre/data/mariadb

build: clean init
	@cd srcs && docker compose up --build

up:
	@cd srcs && docker compose up

down:
	@cd srcs && docker compose down

clean:
	@echo "Cleaning images..."
	@cd srcs && docker compose down --rmi all --volumes --remove-orphans
	@docker system prune -af
	@rm -rf /Users/abel-hid/goinfre/data

re: clean all