

pragma solidity ^0.8.17;

import "./ISocialRecovery.sol";


abstract contract SocialRecovery is ISocialRecovery{


    address owner;
    uint256 private firstSigTimeStamp;

    function initiateRecovery(address proposedNewAddress) external {
        firstSigTimeStamp = block.timestamp;
        

    }
    // make it only onwer
    function denyRecover() external {

    }

    function supportRecover() external{}


}