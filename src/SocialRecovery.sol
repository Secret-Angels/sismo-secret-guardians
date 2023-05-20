

pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "./ISocialRecovery.sol";
import "sismo-connect-packages/SismoLib.sol";


/// TODO : add the 3 timelocks 

abstract contract SocialRecovery is ISocialRecovery, SismoConnect{

    //TODO
    //modifier threshHold{
    //    require()
    //}

    bytes16 public groupId;

    constructor(bytes16 _appId, bytes16 _groupId) SismoConnect(_appId) {
        groupId = _groupId;
    }

    bytes[] private _proofTracker;
    bool private isRecoveryInitiated;
    uint256 public firstSigTimeStamp;


    /// TODO : verify if method is useful
    /// @dev Change group identifier
    /// @param _groupId group identifier to check the claim
    function setGroupId(bytes16 _groupId) public {
        //require(msg.sender == address(safe), "!safe");
        groupId = _groupId;
    }

    function initiateRecovery(bytes memory proof) external {

        if(!isRecoveryInitiated){
            firstSigTimeStamp = block.timestamp;
            isRecoveryInitiated = true;
        }

        _verify(proof);
    
        _proofTracker.push(proof);
        
        // accept only if proof isn't already in the list
        require(!_proofAlreadyStored(proof), "");

        // require(block.timestamp - firstSigTimeStamp < 2 weeks);

    }

    // make it only onwer
    function denyRecover() external {
        for (uint256 i ; i < _proofTracker.length ; i++) {
            _proofTracker.pop();
        }
        isRecoveryInitiated = false;
    }

    function supportRecover(bytes memory proof) external{

        require(isRecoveryInitiated, "not initiated");
        // require(block.timestamp - firstSigTimeStamp < 2 weeks);
        
        // accept only if proof isn't already in the list
        require(!_proofAlreadyStored(proof), "proof already used");
        _verify(proof);

        _proofTracker.push(proof);
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
