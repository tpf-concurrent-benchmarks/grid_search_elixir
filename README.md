# Grid Search in Elixir

## Objective

This is an Elixir implementation of a system for performing a grid search under [common specifications](https://github.com/tpf-concurrent-benchmarks/docs/tree/main/grid_search) defined for multiple languages.

The objective of this project is to benchmark the language on a real-world distributed system.

## Deployment

### Requirements

- [Docker >3](https://www.docker.com/) (needs docker swarm)

### Configuration

- **Number of replicas:** `WORKER_REPLICAS` constant is defined in the `Makefile` file.
- **Data config:** in `distributed_pipeline/lib/resources/data.json` you can define (this config is built into the container):
  - `data`: Intervals for each parameter, in format: [start, end, step, precision]
  - `agg`: Aggregation function to be used: MIN | MAX | AVG
  - `maxItemsPerBatch`: Maximum number of items per batch (batches are sub-intervals)
  
### Commands

#### Startup

- `make init` starts docker swarm
- `make setup` creates necessary directories and gives execution permissions to scripts

#### Run

- `make clean_local_deploy` deploys the manager and worker services locally, alongside with Graphite, Grafana and cAdvisor.
- `make manager_run_gs` executes the grid search on the manager service.
- `make remove` removes all services created by the `deploy` command.

### Monitoring

- Grafana: [http://127.0.0.1:8081](http://127.0.0.1:8081)
- Graphite: [http://127.0.0.1:8080](http://127.0.0.1:8080)

## Used libraries

- [Jason](https://github.com/michalmuskala/jason): used to parse JSON.