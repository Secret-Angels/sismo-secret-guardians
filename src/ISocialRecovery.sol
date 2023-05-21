
pragma solidity 0.8.17;

interface ISocialRecovery {

    // make it only onwer
    function denyRecover() external;

    function supportRecover(bytes memory proof) external;

    function executeRecovery() external;

}
