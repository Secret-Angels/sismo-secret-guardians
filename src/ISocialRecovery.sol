
pragma solidity 0.8.17;

interface ISocialRecovery {

    function initiateRecovery(bytes memory proof) external;
    // make it only onwer
    function denyRecover() external;

    function supportRecover() external;

    function executeRecovery() external;

}
