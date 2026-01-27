import json
import re

class ComplianceValidator:
    def __init__(self, llm_engine):
        self.llm = llm_engine

    def validate_with_reflection(self, policy, request, metadata):
        # 第一轮：初步判定
        initial_output = self.llm.generate(policy, request, metadata)
        
        # 第二轮：自我反思 (Self-Reflection) - 专门对付幻觉
        reflection_prompt = f"""
        Review your previous decision: {initial_output}
        Based on the policy: {policy}
        Does this decision violate the 'Data Minimization' principle? 
        Answer 'STRICT_YES' or 'STRICT_NO' and explain.
        """
        reflection_result = self.llm.raw_query(reflection_prompt)
        
        # 语义一致性检查
        if "STRICT_YES" in reflection_result and "allow" in initial_output:
            return self._finalize_json("deny", "Conflict detected during self-reflection.")
        
        return initial_output

    def _finalize_json(self, verdict, reasoning):
        return json.dumps({
            "verdict": verdict,
            "reasoning": reasoning,
            "confidence": 1.0
        })