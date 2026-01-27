from web3 import Web3
import os

# 审稿人要求的 Sepolia 测试网
RPC_URL = "https://sepolia.infura.io/v3/YOUR_PROJECT_ID"
w3 = Web3(Web3.HTTPProvider(RPC_URL))

def deploy():
    # 这里的私钥应从环境变量读取
    account = w3.eth.account.from_key(os.getenv("PRIVATE_KEY"))
    
    # 此处省略合约编译生成的 ABI 和 Bytecode
    ComplianceContract = w3.eth.contract(abi=ABI, bytecode=BYTECODE)
    
    tx = ComplianceContract.constructor().build_transaction({
        'from': account.address,
        'nonce': w3.eth.get_transaction_count(account.address),
        'gas': 2000000,
        'gasPrice': w3.to_wei('20', 'gwei')
    })
    
    signed_tx = w3.eth.account.sign_transaction(tx, account.key)
    tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
    print(f"Contract Deployed! Address: {w3.eth.wait_for_transaction_receipt(tx_hash).contractAddress}")
    print(f"Transaction Hash: {tx_hash.hex()}")

if __name__ == "__main__":
    deploy()