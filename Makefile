N_WORKERS=2

init:
	docker swarm init

build:
	docker rmi grid_search_elixir_worker -f
	docker rmi grid_search_elixir_manager -f
	docker build -t grid_search_elixir_worker ./src/ -f ./src/worker/Dockerfile
	docker build -t grid_search_elixir_manager ./src/ -f ./src/manager/Dockerfile

setup: init build

remove:
	docker stack rm gs_elixir

deploy:
	mkdir -p graphite
	N_WORKERS=${N_WORKERS} docker compose -f=docker-compose-deploy-local.yml up --build

deploy_remote:
	mkdir -p graphite
	N_WORKERS=${N_WORKERS} docker stack deploy -c docker-compose-deploy.yml gs_elixir

down_graphite:
	if docker stack ls | grep -q graphite; then \
		docker stack rm graphite; \
		docker stack rm grafana; \
		docker stack rm cadvisor; \
	fi
.PHONY: down_graphite

run_worker_local:
	cd ./src/worker && LOCAL=local elixir --sname worker@localhost -S mix run

run_manager_local:
	cd ./src/manager && LOCAL=local elixir --sname manager@localhost -S mix run

install_deps_worker_local:
	cd ./src/worker && LOCAL=local mix deps.get

install_deps_manager_local:
	cd ./src/manager && LOCAL=local mix deps.get

format:
	cd ./src/worker && mix format
	cd ./src/manager && mix format
	cd ./src/common && mix format

test_manager:
	cd ./src/manager && mix test