// SPDX Licence Identifier : EPFL
pragma solidity ^0.8.17;

import "./SecretAngel.sol";
import "./GnosisSafe.sol";

contract SecretAngelModule is SecretAngel {
    uint256 minLockTime;
    GnosisSafe safe;

    constructor(
        bytes16 _appId,
        bytes16 _groupId,
        uint256 _minSignerCount,
        uint256 _minLockTime,
        address _newOwner,
        address _safe
    ) SecretAngel(_appId, _groupId, _minSignerCount, _newOwner) {
        safe = GnosisSafe(_safe);
        minLockTime = _minLockTime;
    }

    function executeRecovery() external override threshold {
        require(block.timestamp - firstSigTimeStamp >= minLockTime);
        require(msg.sender == newOwner, "not allowed");
        GnosisSafe(safe).addOwnerWithThreshold(newOwner, 1);
    }
}
