#!/bin/bash
# /root/demos/python/python_glibc/python3.10-multiprocessing/run_weather_min_bench.sh
set -euo pipefail

BLUE='\033[1;34m'; NC='\033[0m'
script_dir="/root/demos/python/python_glibc/python3.10-multiprocessing"
instance_dir="$script_dir/occlum_instance"
bom_file="$script_dir/python3.10.yaml"
app_src="$script_dir/weather_filter_min.py"
app_dst_rel="/app/weather_filter_min.py"

# 预设正确答案（按上面的数据库，唯一 weather 的 id 是 2）
EXPECTED_OUTPUT="[2]"
RUNS="${RUNS_PER_GROUP:-20}"

echo -e "${BLUE}[1/4] 初始化 Occlum 实例并拷贝运行时${NC}"
rm -rf "$instance_dir" && occlum new "$instance_dir"
cd "$instance_dir" && rm -rf image
copy_bom -f "$bom_file" --root image --include-dir /opt/occlum/etc/template

echo -e "${BLUE}[2/4] 放入脚本 & 基础网络文件（DNS/CA）${NC}"
mkdir -p image/app image/etc/ssl/certs
cp "$app_src" "image$app_dst_rel"
# DNS（简单稳妥；你已能联网的话保留即可）
cat > image/etc/resolv.conf <<'EOF'
nameserver 8.8.8.8
nameserver 1.1.1.1
options use-vc
options timeout:2 attempts:2
EOF
# CA 证书（HTTPS）
[ -f /etc/ssl/certs/ca-certificates.crt ] && cp /etc/ssl/certs/ca-certificates.crt image/etc/ssl/certs/

# 允许从宿主透传必要环境变量（Key/Model/代理）
new_json="$(jq '.env.untrusted += [
  "OPENROUTER_API_KEY","OPENROUTER_MODEL",
  "http_proxy","https_proxy","HTTP_PROXY","HTTPS_PROXY","NO_PROXY","no_proxy"
] | .env.default += ["PYTHONHOME=/opt/python-occlum","PATH=/bin"] |
    .resource_limits.user_space_size = "1000MB" |
    .resource_limits.kernel_space_heap_size = "300MB" |
    .feature.enable_posix_shm = true' Occlum.json)"
echo "$new_json" > Occlum.json

echo -e "${BLUE}[3/4] 构建镜像（SIM）${NC}"
occlum build --sgx-mode SIM -f

echo -e "${BLUE}[4/4] 循环 ${RUNS} 次：跑模型 → 抓输出 → 对比预期 → 计时${NC}"
declare -a LATS=()
correct=0
for ((i=1;i<=RUNS;i++)); do
  start_ns=$(date +%s%N)
  out="$(occlum run /bin/python3.10 "$app_dst_rel" || true)"
  end_ns=$(date +%s%N)
  # 去掉行尾空白
  out="${out%"${out##*[![:space:]]}"}"

  elapsed_ms=$(( (end_ns - start_ns)/1000000 ))
  LATS+=("$elapsed_ms")

  if [[ "$out" == "$EXPECTED_OUTPUT" ]]; then
    correct=$((correct+1))
    echo "[$i/$RUNS] OK  (${elapsed_ms} ms)  -> $out"
  else
    echo "[$i/$RUNS] NG  (${elapsed_ms} ms)  -> $out"
  fi
done

# ---- 汇总性能（min / avg / p50 / p90 / max）----
# 排序
IFS=$'\n' read -r -d '' -a SORTED < <(printf "%s\n" "${LATS[@]}" | sort -n && printf '\0')
n="${#SORTED[@]}"

min="${SORTED[0]}"
max="${SORTED[$((n-1))]}"

# 平均
sum=0
for v in "${LATS[@]}"; do sum=$((sum+v)); done
avg=$(( sum / (n>0?n:1) ))

# p50（四舍五入到最近索引）
p50_idx=$(( (n+1)/2 - 1 ))
(( p50_idx<0 )) && p50_idx=0
p50="${SORTED[$p50_idx]}"

# p90（向上取整）
p90_rank=$(( (90*n + 99)/100 ))
(( p90_rank<1 )) && p90_rank=1
(( p90_rank>n )) && p90_rank=$n
p90="${SORTED[$((p90_rank-1))]}"

echo
echo "========== SUMMARY =========="
echo "runs           : $n"
echo "correct        : $correct"
echo "accuracy       : $(( 100*correct/(n>0?n:1) ))%"
echo "lat_ms  min    : $min"
echo "lat_ms  avg    : $avg"
echo "lat_ms  p50    : $p50"
echo "lat_ms  p90    : $p90"
echo "lat_ms  max    : $max"
echo "============================="