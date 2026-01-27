// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ComplianceManager {
    address public admin;
    
    struct ComplianceRecord {
        bytes32 requestId;
        string verdict;      // "allow" or "deny"
        string reasonHash;   // 判定理由的IPFS哈希或简述
        uint256 timestamp;
        address oracleNode;
    }

    mapping(bytes32 => ComplianceRecord) public records;

    event ComplianceVerified(bytes32 indexed requestId, string verdict, address oracle);

    constructor() {
        admin = msg.sender;
    }

    // 由运行在 TEE 中的 Oracle 调用
    function submitVerdict(bytes32 _requestId, string memory _verdict, string memory _reasonHash) public {
        records[_requestId] = ComplianceRecord({
            requestId: _requestId,
            verdict: _verdict,
            reasonHash: _reasonHash,
            timestamp: block.timestamp,
            oracleNode: msg.sender
        });
        emit ComplianceVerified(_requestId, _verdict, msg.sender);
    }
}