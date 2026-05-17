# resuroce
# PriRS: AI-Driven Privacy & Reliability Framework
Cyber-Physical-Social Systems (CPSS) impose stringent requirements for data sharing security and regulatory compliance. However, existing solutions fail to bridge the gap between rigid smart contracts and flexible social regulations. The core research question is: how can we enforce complex, human-readable regulatory policies within rigid blockchain transactions without creating scalability bottlenecks? To address this, we propose PriRS, an AI-driven privacy and reliability framework. First, we utilize an LLM-based Compliance Oracle within a Trusted Execution Environment (TEE). This agent intelligently analyzes regulations to ensure strict compliance before data authorization. Second, we introduce a "Majority Voting Group Data Sharing" mechanism. By combining Shamir's Secret Sharing with Conditional Proxy Re-encryption, we move heavy coordination off-chain. This ensures fairness and significantly improves throughput. Experimental results on the Sepolia testnet demonstrate that PriRS reduces on-chain Gas consumption by 92.3% compared to state-of-the-art schemes. Furthermore, the AI-driven oracle achieves 96.0\% accuracy and 98.0% precision on policy violation detection, while maintaining 100% deterministic consistency across repeated runs in the TEE.


## 🚀 Quick Start

### Prerequisites
* Python 3.8+
* Occlum (for TEE simulation)
* Web3.py


```bash
python3 evaluation/run_benchmark.py

Volume 14 - 2026 | https://doi.org/10.3389/fphy.2026.1743945
作者单位:暨南大学网络空间安全学院
