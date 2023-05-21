pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "./ISecretAngel.sol";
import "sismo-connect-packages/SismoLib.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";


abstract contract SecretAngel is ISecretAngel, SismoConnect, Owned {


    bytes16 public groupId;
    uint256 public epoch;
    uint256 public maxDuration;
    uint256 public minSignerCount;

    bytes[] private _proofTracker;
    bool public isRecoveryInitiated;
    uint256 public firstSigTimeStamp;

    event RecoveryDenied(uint256 timestamp);
    event ProofVerifiedAndAdded(uint256 timestamp, bytes proof);

    constructor(bytes16 _appId, bytes16 _groupId, uint256 _minSignerCount) SismoConnect(_appId) Owned(msg.sender) {
        groupId = _groupId;
        minSignerCount = _minSignerCount;
    }


    modifier threshold() {
        console.log("threshold: ", _proofTracker.length, " over ", minSignerCount);
        console.log(_proofTracker.length);
        console.log(minSignerCount);
        require(_proofTracker.length >= minSignerCount, "threshold not met");
        _;
    }


    function supportRecovery(bytes memory proof, address newOwner) external {

        if (block.timestamp - firstSigTimeStamp > maxDuration) {
            epoch += 1;
            return;
        }
        if (!isRecoveryInitiated) {
            firstSigTimeStamp = block.timestamp;
            isRecoveryInitiated = true;
        }
        console.log("after if");
        _verify(proof, newOwner);
    
        
        // accept only if proof isn't already in the list

        require(!_proofAlreadyStored(proof), "already deployed");

        _proofTracker.push(proof);
    }


    function denyRecovery() external onlyOwner {
        for (uint256 i; i < _proofTracker.length; i++) {
            _proofTracker.pop();
        }

        isRecoveryInitiated = false;
        epoch += 1;
        emit RecoveryDenied(block.timestamp);
    }

    function executeRecovery(address newOwner) external virtual returns(bool);
    

    function _proofAlreadyStored(bytes memory proof) private returns (bool) {
        for(uint i; i < _proofTracker.length; i++){
            console.log("proofs are equal");
            if(keccak256(abi.encode(_proofTracker[i])) == keccak256(abi.encode(proof))){
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

