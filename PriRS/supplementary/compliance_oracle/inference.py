import json
import os
from prompts import SYSTEM_PROMPT, COMPLIANCE_CHECK_TEMPLATE


try:
    from llama_cpp import Llama
except ImportError:
    print("Please install llama-cpp-python for TEE-optimized inference.")

class TEEComplianceOracle:
    def __init__(self, model_path):
        # 针对 4GB RAM 的关键配置：
        # n_ctx=512 (减小上下文窗口以节省内存), n_threads=4 (适配 i5-5200U)
        self.llm = Llama(
            model_path=model_path,
            n_ctx=1024,
            n_threads=4,
            n_gpu_layers=0  # 强制 CPU 推理（针对无 GPU 的 TEE 环境）
        )

    def run_compliance_check(self, policy, request, metadata):
        prompt = COMPLIANCE_CHECK_TEMPLATE.format(
            policy_text=policy,
            user_request=request,
            metadata=json.dumps(metadata)
        )
        
        # 执行推理，设置 temperature=0 确保结果的确定性 (Determinism)
        response = self.llm(
            f"{SYSTEM_PROMPT}\n{prompt}",
            max_tokens=512,
            temperature=0,
            stop=["}"]
        )
        
        raw_text = response['choices'][0]['text'] + "}"
        try:
            result = json.loads(raw_text)
            # 自我审计逻辑：如果置信度低于 0.8，强制 deny
            if result.get("confidence", 0) < 0.8:
                result["verdict"] = "deny"
                result["reasoning"] += " (Low confidence override)"
            return result
        except json.JSONDecodeError:
            return {"verdict": "deny", "error": "Output formatting hallucination"}

if __name__ == "__main__":
    # 示例运行
    oracle = TEEComplianceOracle(model_path="/model/llama-7b-q4_k_m.gguf")
    output = oracle.run_compliance_check(
        policy="Only weather data can be shared.",
        request="Give me user GPS coordinates.",
        metadata={"time": "2025-05-01", "location": "Shanghai"}
    )

    print(json.dumps(output, indent=2))
