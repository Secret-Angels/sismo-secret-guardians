

pragma solidity ^0.8.17;

import "./ISocialRecovery.sol";
import "sismo-connect-packages/SismoLib.sol";


/// TODO : add the 3 timelocks 

abstract contract SocialRecovery is ISocialRecovery, SismoConnect{

    
    bytes16 public groupId;

    constructor(bytes16 _appId, bytes16 _groupId) SismoConnect(_appId) {
        groupId = _groupId;
    }

    bytes[] private proofTracker;
    bool private isRecoveryInitiated;
    uint256 private firstSigTimeStamp;


    /// TODO : verify if method is useful
    /// @dev Change group identifier
    /// @param _groupId group identifier to check the claim
    function setGroupId(bytes16 _groupId) public {
        //require(msg.sender == address(safe), "!safe");
        groupId = _groupId;
    }

    function initiateRecovery(bytes memory proof) external {

        firstSigTimeStamp = block.timestamp;
        isRecoveryInitiated = true;

        verify ({ 
            responseBytes: proof,
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({groupId: groupId}),
            signature: buildSignature({message: abi.encode(msg.sender)})
        });
    
        proofTracker.push(proof);

    }
    // make it only onwer
    function denyRecover() external {
        for (uint256 i ; i < proofTracker.length ; i++) {
            proofTracker.pop();
        }
        isRecoveryInitiated = false;
    }

    function supportRecover(bytes memory proof) external{

        require(isRecoveryInitiated, "not initiated");
        // require(block.timestamp - firstSigTimeStamp < 2 weeks);

        verify ({ 
            responseBytes: proof,
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({groupId: groupId}),
            signature: buildSignature({message: abi.encode(msg.sender)})
        });

        

        proofTracker.push(proof);



    }

    
}
