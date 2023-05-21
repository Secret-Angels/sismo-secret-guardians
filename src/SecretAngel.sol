// SPDX Licence Identifier : EPFL


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

    uint256 public freezeRecoveryDuration;
    uint256 public inactivityTimestamp;
    uint256 public firstSigTimeStamp;
    mapping(address => uint256) newOwnerVote;
    address[] potentialNewOwner;

    // EVENTS

    event RecoveryDenied(uint256 timestamp);
    event ProofVerifiedAndAdded(uint256 timestamp, bytes proof);

    
    /// @param _appId application identifier as given by Sismo
    /// @param _groupId group identifier as given by Sismo
    /// @param _minSignerCount minimal number of distinct signatures required for recovery 
    /// @param _freezeRecoveryDuration timelock offset before which no recovery is possible
    /// @param _maxDuration after the first signature, maximal time frame during which we require at least _minSignerCount signatures to issue recovery



    constructor(
        bytes16 _appId,
        bytes16 _groupId,
        uint256 _minSignerCount,
        uint256 _freezeRecoveryDuration,
        uint256 _maxDuration) SismoConnect(_appId) {

            groupId = _groupId;
            minSignerCount = _minSignerCount;
            freezeRecoveryDuration = _freezeRecoveryDuration;
            maxDuration = _maxDuration;
    }




    modifier threshold(address newOwner) {
        console.log("threshold: ", _proofTracker.length, " over ", minSignerCount);
        console.log(_proofTracker.length);
        console.log(minSignerCount);
        require(newOwnerVote[newOwner] >= minSignerCount, "threshold not met");
        _;
    }


    ///@notice queries proof of activity from safe

    function challengeOwner() external {
        require(inactivityTimestamp == 0, "already challenged");
        inactivityTimestamp = block.timestamp;
    }

    ///@notice deny the inactivity query issued by the guardians. Proves the wallet is active 
    function denyChallenge() external virtual;


    ///@notice method called by the guardians to sign recovery issuance
    ///@param proof proof of guardianhood
    ///@param newOwner new address chosen by guardians, in which funds will be deposited if recovery succeeds. 

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
        console.log("after if");
        _verify(proof, newOwner);
        require(!_proofAlreadyStored(proof), "proof already in the list");
        _proofTracker.push(proof);
        if (newOwnerVote[newOwner] > 0) {
            newOwnerVote[newOwner]++;
        } else {
            potentialNewOwner.push(newOwner);
            newOwnerVote[newOwner] = 1;
        }

        emit ProofVerifiedAndAdded(block.timestamp, proof);
    }


    /// @notice denies recovery
    /// TODO : terminate mapping and array


    function _denyRecovery() internal {
    
        for (uint256 i; i < _proofTracker.length; i++) {
            _proofTracker.pop();
        }
        for(uint256 i; i < potentialNewOwner.length; i++){
            address _deletedOwner = potentialNewOwner[potentialNewOwner.length-1];
            newOwnerVote[_deletedOwner] = 0;
            potentialNewOwner.pop();
        }

        isRecoveryInitiated = false;
        epoch += 1;
        emit RecoveryDenied(block.timestamp);
    }

    /// @notice execute the recovery of the safe

    function executeRecovery(address newOwner) external virtual returns(bool);

    /// @notice verifies if the proof is already stored
    

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

