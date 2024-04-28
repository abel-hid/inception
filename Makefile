.PHONY: all build up down clean re



all: build

init: all
	@mkdir -p /home/abel-hid/data/wordpress
	@mkdir -p /home/abel-hid/data/mariadb

build: clean
	@echo "Building images..."
	@cd srcs && docker compose up --build

up:
	@cd srcs && docker compose up

down:
	@cd srcs && docker compose down

clean:
	@echo "Cleaning images..."
	@cd srcs && docker compose down --rmi all --volumes --remove-orphans
	@docker system prune -af
	@rm -rf /home/abel-hid/data

re: clean all