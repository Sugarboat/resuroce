#!/bin/bash
# Enhanced Benchmarking Script with Resource Monitoring (CPU/RAM)
# Specifically designed for Occlum TEE environments.

INSTANCE_DIR="./occlum_instance"
LOG_FILE="benchmark_resource_log.csv"

echo "Timestamp,Memory_Usage(MB),CPU_Usage(%)" > $LOG_FILE

# 后台监控函数
monitor_resources() {
    while true; do
        # 捕捉 Occlum 进程的内存占用
        MEM=$(ps -o rss= -p $1 | awk '{print $1/1024}') 
        CPU=$(ps -o %cpu= -p $1)
        echo "$(date +%H:%M:%S),$MEM,$CPU" >> $LOG_FILE
        sleep 1
    done
}

echo "Building Occlum instance with 4GB Limit..."
# 配置 Occlum 的内存限制
# jq '.resource_limits.user_space_size = "4100MB"' Occlum.json > tmp.json && mv tmp.json Occlum.json

occlum build --sgx-mode SIM

echo "Starting Inference Task..."
occlum run /bin/python3 /app/inference.py &
PID=$!

# 启动资源监控
monitor_resources $PID &
MONITOR_PID=$!

wait $PID
kill $MONITOR_PID


echo "Benchmark completed. Resource logs saved to $LOG_FILE."
