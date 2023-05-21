// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

interface ISecretAngel {
    // make it only onwer
    function denyRecovery() external;

    function supportRecovery(bytes memory proof, address newOwner) external;

    function executeRecovery(address newOwner) external returns(bool);

}
