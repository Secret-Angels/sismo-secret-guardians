
pragma solidity ^0.8.17;

import "solmate/auth/Owned.sol";
import "./ISecretAngel.sol";
import "sismo-connect-packages/SismoLib.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";


/// TODO : add the 3 timelocks 

abstract contract SecretAngel is ISecretAngel, SismoConnect, Test{


    bytes16 public groupId;
    uint256 public maxDuration;
    uint256 public minSignerCount;//TODO: constructor
    address public newOwner;


    constructor(
        bytes16 _appId,
        bytes16 _groupId,
        uint256 _minSignerCount ,
        address _newOwner) SismoConnect(_appId) {

            groupId = _groupId;
            minSignerCount = _minSignerCount;
            newOwner = _newOwner;

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

        //require (block.timestamp - firstSigTimeStamp <= maxDuration, "timeStamp!");
        console.log("before if");
        if(!isRecoveryInitiated){
            firstSigTimeStamp = block.timestamp;
            isRecoveryInitiated = true;
        }
        console.log("after if");
        _verify(proof);
        console.log("verified");
        require(!_proofAlreadyStored(proof), "proof already stored");
        console.log("perfect");
        // accept only if proof isn't already in the list
        _proofTracker.push(proof);
    }

    // make it only onwer
    function denyRecovery() external {
        for (uint256 i ; i < _proofTracker.length ; i++) {
            _proofTracker.pop();
        }
        isRecoveryInitiated = false;
    }

    function executeRecovery() external virtual returns(bool);
    

    function _proofAlreadyStored(bytes memory proof) private returns (bool) {
        for(uint i; i < _proofTracker.length; i++){
            //console.log(keccak256(abi.encode(_proofTracker[i])));
            //console.log(keccak256(abi.encode(proof)));
            assertNotEq(keccak256(abi.encode(_proofTracker[i])), keccak256(abi.encode(proof)));
            console.log("proofs are equal");
            if(keccak256(abi.encode(_proofTracker[i])) == keccak256(abi.encode(proof))){
                return true;
            }
        }
        return false;
    }
    

    function _verify(bytes memory proof) private {
        /*verify ({ 
            responseBytes: proof,
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({groupId: groupId}),
            signature: buildSignature({message: abi.encode(msg.sender)})
        });*/

    }
}
