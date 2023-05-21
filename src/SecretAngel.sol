pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "./ISecretAngel.sol";
import "sismo-connect-packages/SismoLib.sol";


abstract contract SecretAngel is ISecretAngel, SismoConnect, Owned {


    bytes16 public groupId;
    uint256 public epoch;
    uint256 public maxDuration;
    uint256 public minSignerCount;

    bytes[] private _proofTracker;
    bool public isRecoveryInitiated;
    bool public isWalletInactive;

    uint256 public freezeRecoveryDuration;
    uint256 public inactivityTimestamp;
    uint256 public firstSigTimeStamp;

    // EVENTS

    event RecoveryDenied(uint256 timestamp);
    event ProofVerifiedAndAdded(uint256 timestamp, bytes proof);

    constructor(bool _isWalletInactive, bytes16 _appId, bytes16 _groupId, uint256 _minSignerCount, uint256 _freezeRecoveryDuration) SismoConnect(_appId) Owned(msg.sender) {
        groupId = _groupId;
        minSignerCount = _minSignerCount;
        freezeRecoveryDuration = _freezeRecoveryDuration;
        _isWalletInactive = false;
    }



    modifier threshold() {
        require(_proofTracker.length >= minSignerCount);
        _;
    }

    function challengeOwner() external {
        isWalletInactive = true;
        inactivityTimestamp = block.timestamp;
    }

    function denyChallenge() external virtual onlyOwner;

    function supportRecovery(bytes memory proof, address newOwner) external {

        if (block.timestamp - firstSigTimeStamp > maxDuration) {
            epoch += 1;
            return;
        }

        if (block.timestamp - inactivityTimestamp <= freezeRecoveryDuration) {
            epoch += 1;
            return;
        }

        if (!isRecoveryInitiated) {
            firstSigTimeStamp = block.timestamp;
            isRecoveryInitiated = true;
        }

        _verify(proof, newOwner);
        
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

    function _verify(bytes memory proof, address newOwner) private {
        verify({
            responseBytes: proof,
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({groupId: groupId}),
            signature: buildSignature({message: abi.encode(msg.sender, epoch, newOwner)})
        });
    }

}

