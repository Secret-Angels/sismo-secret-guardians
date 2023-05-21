
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "./ISocialRecovery.sol";
import "sismo-connect-packages/SismoLib.sol";


/// TODO : add the 3 timelocks 

abstract contract SocialRecovery is ISocialRecovery, SismoConnect{


    uint256 public maxDuration;
    uint256 public minSignerCount;//TODO: constructor
    bytes16 public groupId;


    constructor(
        bytes16 _appId,
        bytes16 _groupId,
        uint256 _minSignerCount ) SismoConnect(_appId) {

            groupId = _groupId;
            minSignerCount = _minSignerCount;

    }


    bytes[] private _proofTracker;
    bool public isRecoveryInitiated;
    uint256 public firstSigTimeStamp;
    
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

        require (block.timestamp - firstSigTimeStart <= maxDuration);

        if(!isRecoveryInitiated){
            firstSigTimeStamp = block.timestamp;
            isRecoveryInitiated = true;
        }

        _verify(proof);
    
        _proofTracker.push(proof);
        
        // accept only if proof isn't already in the list

        require(!_proofAlreadyStored(proof), "");


    }

    // make it only onwer
    function denyRecover() external {
        for (uint256 i ; i < _proofTracker.length ; i++) {
            _proofTracker.pop();
        }
        isRecoveryInitiated = false;
    }


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
            signature: buildSignature({message: abi.encode(msg.sender)})
        });

        _proofTracker.push(proof);

    }
}
