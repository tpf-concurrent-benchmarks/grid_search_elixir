# Benchmarks

## Measurements

### FaMAF Server

| Measurement         | 4 Nodes              | 8 Nodes             | 16 Nodes            |
|---------------------|----------------------|---------------------|---------------------|
| Worker Throughput   | 0.25 Results/Second  | 0.24 Results/Second | 0.23 Results/Second |
| Combined Throughput | 0.991 Results/Second | 1.90 Results/Second | 3.74 Results/Second |
| Work-time Variation | 3.05%                | 0.659%              | 2.37%               |
| Memory Usage        | 83-95 MB/Worker      | 84-96/Worker        | 84 MB/Worker        |
| Network Usage (Tx)  | 376 B/(s * Worker)   | 399 B/(s * Worker)  | 469 B/(s * Worker)  |
| Network Usage (Rx)  | 266 B/(s * Worker)   | 296 B/(s * Worker)  | 367 B/(s * Worker)  |
| CPU Usage           | 100%/Worker          | 100%/Worker         | 100%/Worker         |
| Completion Time     | 403.2 Minutes        | 209.4 Minutes       | 106.8 Minutes       |

### Cloud (GCP)

| Measurement         | 4 Nodes            | 8 Nodes        | 16 Nodes       |
|---------------------|--------------------|----------------|----------------|
| Worker Throughput   | Results/Second     | Results/Second | Results/Second |
| Combined Throughput | Results/Second     | Results/Second | Results/Second |
| Work-time Variation | %                  | %              | %              |
| Memory Usage        | MB/Worker          | MB/Worker      | MB/Worker      |
| Network Usage (Tx)  | B/(s * Worker)     | B/(s * Worker) | B/(s * Worker) |
| Network Usage (Rx)  | B/(s * Worker)     | B/(s * Worker) | B/(s * Worker) |
| CPU Usage           | %/Worker           | %/Worker       | %/Worker       |
| Completion Time     | Minutes            | Minutes        | Minutes        |

Average measurements using the [specified configuration](measurements/README.md)

## Subjective analysis

TODO