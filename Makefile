N_WORKERS=2
WORKER_REPLICAS ?=2
SECRET ?= secret

init:
	docker swarm init

build:
	docker rmi grid_search_elixir_worker -f
	docker rmi grid_search_elixir_manager -f
	docker build -t grid_search_elixir_worker ./src/ -f ./src/worker/Dockerfile
	docker build -t grid_search_elixir_manager ./src/ -f ./src/manager/Dockerfile

_setup: init build

remove:
	docker stack rm gs_elixir

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

#Commands from Nico's version
_script_permisions:
	chmod -R +x ./scripts

_common_folders:
	mkdir -p configs/graphite
	mkdir -p configs/grafana_config
.PHONY: _common_folders

setup: _script_permisions _common_folders

deploy_local:
	WORKER_REPLICAS=$(WORKER_REPLICAS) \
	SECRET=$(SECRET) \
	docker stack deploy \
	-c docker/monitor.yml \
	-c docker/service.yml \
	gs_elixir

remove_local:
	docker stack rm ip_elixir

remove_local_containers:
	-docker service rm $(shell docker service ls -q -f name=gs_elixir) || echo "No services to remove"

clean_local_deploy: setup
	make remove_local_containers
	make deploy_local
	@echo "Waiting for services to start..."
	@while [ $$(docker service ls --filter name=gs_elixir --format "{{.Replicas}}" | grep -v "0/0" | awk -F/ '{if ($$1!=$$2) print $$0}' | wc -l) -gt 0 ]; do sleep 1; done
	@echo "Waiting for setup to complete..."
		@for container in $$(docker ps -qf "name=gs_elixir" -f "status=running"); do \
			if echo $$container | grep -q -e "worker" -e "manager"; then \
				container_name=$$(docker inspect --format '{{.Name}}' $$container); \
				echo "> Waiting for setup to complete for $$container $$container_name"; \
				while docker inspect --format '{{.State.Running}}' $$container | grep -q "true" && ! docker logs $$container 2>&1 | grep -q "Setup complete"; do \
					sleep 1; \
				done; \
			fi \
		done
	@echo "All services are up and running."

iex:
	make clean_local_deploy
	make manager_iex

run:
	make clean_local_deploy
	make manager_run_gs

full_remove_local:
	docker stack rm gs_elixir

worker_iex:
	@if [ -z "$(num)" ]; then \
		echo "Opening shell for worker.1"; \
		docker exec -it $(shell docker ps -q -f name=gs_elixir_worker.1) iex --sname worker --cookie $(SECRET) -S mix; \
	else \
		echo "Opening shell for worker.$(num)"; \
		docker exec -it $(shell docker ps -q -f name=gs_elixir_worker.$(num)) iex --sname worker --cookie $(SECRET) -S mix; \
	fi

worker_shell:
	@if [ -z "$(num)" ]; then \
		echo "Opening shell for worker.1"; \
		docker exec -it $(shell docker ps -q -f name=gs_elixir_worker.1) sh; \
	else \
		echo "Opening shell for worker.$(num)"; \
		docker exec -it $(shell docker ps -q -f name=gs_elixir_worker.$(num)) sh; \
	fi

manager_iex:
	docker exec -it $(shell docker ps -q -f name=gs_elixir_manager) iex --sname manager --cookie $(SECRET) -S mix

manager_shell:
	docker exec -it $(shell docker ps -q -f name=gs_elixir_manager) sh

manager_run_gs:
	docker exec -it $(shell docker ps -q -f name=gs_elixir_manager) iex --sname manager --cookie $(SECRET) -S mix run -e "DistributedPipeline.main()"

manager_profile_gs:
	docker exec -it $(shell docker ps -q -f name=gs_elixir_manager) iex --sname manager --cookie $(SECRET) -S mix profile.eprof -e "DistributedPipeline.main()"

manager_logs:
	docker service logs -f $(shell docker service ls -q -f name=gs_elixir_manager) --raw

worker_logs:
	./docker/logs.sh

worker1_logs:
	docker service logs -f $(shell docker service ls -q -f name=gs_elixir_worker.1) --raw