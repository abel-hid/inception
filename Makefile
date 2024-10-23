.PHONY: all build up down clean re



all: build

init:
	@mkdir -p /home/abel-hid/data/wordpress
	@mkdir -p /home/abel-hid/data/mariadb

build: clean init
	@cd srcs && docker compose up --build

up:
	@cd srcs && docker compose up

down:
	@cd srcs && docker compose down

clean:
	@cd srcs && docker compose down --rmi all --volumes --remove-orphans
	@docker system prune -af
	@rm -rf /home/abel-hid/data

re: clean all