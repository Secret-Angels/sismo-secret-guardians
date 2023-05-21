// SPDX-License-Identifier: MIT


pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "./ISecretAngel.sol";
import "sismo-connect-packages/SismoLib.sol";

/// TODO : add the 3 timelocks

abstract contract SecretAngel is ISecretAngel, SismoConnect, Owned {


    bytes16 public groupId;
    uint256 public epoch;
    uint256 public maxDuration;
    uint256 public minSignerCount;
    address public newOwner;

    bytes[] private _proofTracker;
    bool public isRecoveryInitiated;
    uint256 public firstSigTimeStamp;

    event RecoveryDenied(uint256 timestamp);
    event ProofVerifiedAndAdded(uint256 timestamp, bytes proof);

    constructor(bytes16 _appId, bytes16 _groupId, uint256 _minSignerCount, address _newOwner)
        SismoConnect(_appId)
        Owned(msg.sender)
    {
        groupId = _groupId;
        minSignerCount = _minSignerCount;
        newOwner = _newOwner;
    }

    modifier threshold() {
        require(_proofTracker.length >= minSignerCount);
        _;
    }

    function supportRecovery(bytes memory proof) external {
        if (block.timestamp - firstSigTimeStamp > maxDuration) {
            epoch += 1;
            return;
        }
        if (!isRecoveryInitiated) {
            firstSigTimeStamp = block.timestamp;
            isRecoveryInitiated = true;
        }

        _verify(proof);

        _proofTracker.push(proof);

        emit ProofVerifiedAndAdded(block.timestamp, proof);
        require(!_proofAlreadyStored(proof), "proof already in the list");
    }

    function denyRecovery() external onlyOwner {
        for (uint256 i; i < _proofTracker.length; i++) {
            _proofTracker.pop();
        }

        isRecoveryInitiated = false;
        epoch += 1;
        emit RecoveryDenied(block.timestamp);
    }

    function executeRecovery() external virtual;

    function _proofAlreadyStored(bytes memory proof) private view returns (bool) {
        for (uint256 i; i < _proofTracker.length; i++) {
            if (keccak256(abi.encode(_proofTracker[i])) == keccak256(abi.encode(proof))) {
                return true;
            }
        }
        return false;
    }

    function _verify(bytes memory proof) private {
        verify({
            responseBytes: proof,
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({groupId: groupId}),
            signature: buildSignature({message: abi.encodePacked(msg.sender, epoch)})
        });
    }
}
