
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "./ISecretAngel.sol";
import "sismo-connect-packages/SismoLib.sol";


/// TODO : add the 3 timelocks 

abstract contract SecretAngel is ISecretAngel, SismoConnect, Owned{



    bytes16 public groupId;
    uint256 public epoch;
    uint256 public maxDuration;
    uint256 public minSignerCount; 
    address public newOwner;



    constructor(
        bytes16 _appId,
        bytes16 _groupId,
        uint256 _minSignerCount ,
        address _newOwner) SismoConnect(_appId) {

            groupId = _groupId;
            minSignerCount = _minSignerCount;
            newOwner = _newOwner;
            epoch = 0;
    }


    bytes[] private _proofTracker;
    bool public isRecoveryInitiated;
    uint256 public firstSigTimeStamp;

    event FirstSignatureEmitted(uint256 timestamp, bytes proof);
    event SignatureEmitted(uint256 timestamp, bytes proof);
    event RecoveryDenied(uint256 timestamp);
    event ProofVerifiedAndAdded(uint256 timestamp, bytes proof);


    
    modifier threshold{
        require(_proofTracker.length >= minSignerCount);
        _;
    }

    /// TODO : verify if method is useful
    /// @dev Change group identifier
    /// @param _groupId group identifier to check the claim
    function setGroupId(bytes16 _groupId) public {
        //require(msg.sender == address(safe), "!safe");
        groupId = _groupId;
    }

    function supportRecovery(bytes memory proof) external {

        if (block.timestamp - firstSigTimeStamp > maxDuration) {
            epoch += 1;
            return;
        }
        if(!isRecoveryInitiated){
            firstSigTimeStamp = block.timestamp;
            isRecoveryInitiated = true;
            emit FirstSignatureEmitted(block.timestamp, proof);
        }

        _verify(proof);
        emit SignatureEmitted(block.timestamp, proof);
        _proofTracker.push(proof);
        emit ProofVerifiedAndAdded(timestamp, proof);

        require(!_proofAlreadyStored(proof), "proof already in the list");

    }

    function denyRecovery() external onlyOwner{
        for (uint256 i ; i < _proofTracker.length ; i++) {
            _proofTracker.pop();
        }

        isRecoveryInitiated = false;
        epoch += 1;
        emit RecoveryDenied(block.timestamp);
    }

    function executeRecovery() external virtual;
    

    function _proofAlreadyStored(bytes memory proof) private view returns (bool) {
        for(uint i; i < _proofTracker.length; i++){
            if(keccak256(abi.encode(_proofTracker[i])) == keccak256(abi.encode(proof))){
                return true;
            }
        }
        return false;
    }
    

    function _verify(bytes memory proof) private {
        verify ({ 
            responseBytes: proof,
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({groupId: groupId}),
            signature: buildSignature({message: abi.encodePacked(msg.sender, epoch)})
        });

        _proofTracker.push(proof);
        emit proofVerifiedAndAdded(block.timestamp, proof);
    }
}
