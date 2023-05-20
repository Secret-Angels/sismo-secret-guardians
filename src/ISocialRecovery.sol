
pragma solidity 0.8.17;

interface ISocialRecovery {

    function initiateRecovery(address proposedNewAddress) external;
    // make it only onwer
    function denyRecover() external;

    function supportRecover() external;

}