# /root/demos/python/python_glibc/python3.10-multiprocessing/weather_filter_min.py
import os, json, requests

API_URL = "https://openrouter.ai/api/v1/chat/completions"
API_KEY = os.getenv("OPENROUTER_API_KEY", ""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)
MODEL   = os.getenv("OPENROUTER_MODEL", "minimax/minimax-m2:free")

# 三块固定输入
DATABASE = [
    {"id": 0, "type": "sports",  "text": "Lakers beat Warriors 118-112 in OT."},
    {"id": 1, "type": "finance", "text": "USD/JPY touches 151.2 amid policy divergence."},
    {"id": 2, "type": "weather", "text": "Typhoon landing expected tonight with heavy rain and gusts up to 10."},
    {"id": 3, "type": "travel",  "text": "Shinkansen discount campaign starts next week."},
    {"id": 4, "type": "news",    "text": "Company releases Q3 earnings beating estimates."}
]

REQUIREMENTS = ["只保留所有 type=weather 的数据段"]

FINAL_OUTPUT_RULE = (
    "最终输出格式【严格要求】：只输出满足要求的 id 列表，"
    "格式必须是没有空格的 JSON 数组，例如：[2] 或 [0,3]。"
    "禁止输出除该数组以外的任何字符（包括解释、换行、标点、代码块等）。"
)

if not API_KEY:
    print("ERROR: OPENROUTER_API_KEY not set")
    raise SystemExit(2)

content = (
    "【数据库】:\n" + json.dumps(DATABASE, ensure_ascii=False) + "\n\n"
    "【要求】:\n" + json.dumps(REQUIREMENTS, ensure_ascii=False) + "\n\n"
    "【最终输出格式】:\n" + FINAL_OUTPUT_RULE
)

resp = requests.post(
    API_URL,
    headers={
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json",
    },
    json={
        "model": MODEL,
        "temperature": 0,
        "messages": [{"role": "user", "content": content}],
    },
    timeout=60,
)

# 只打印模型文本（外部脚本会读这一行做对比）
if resp.ok:
    data = resp.json()
    txt = data["choices"][0]["message"]["content"]
    # 去掉首尾空白，避免因末尾换行导致对比失败
    print(txt.strip())
else:
    # 失败时也只打印一个可读文本，外层会统计正确率
    print(f"ERROR_STATUS_{resp.status_code}")
