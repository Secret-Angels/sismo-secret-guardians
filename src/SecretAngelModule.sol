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
        address _safe
    ) SecretAngel(_appId, _groupId, _minSignerCount) {
        safe = GnosisSafe(_safe);
        minLockTime = _minLockTime;
    }

    function executeRecovery(address newOwner) external override threshold returns(bool){
        require(block.timestamp - firstSigTimeStamp >= minLockTime, "timestamp 2");
        require(msg.sender == newOwner, "not newOwner");
        //GnosisSafe(safe).addOwnerWithThreshold(newOwner, 1);
        bytes memory data = abi.encodeWithSignature("addOwnerWithThreshold(address,uint256)", newOwner, 1);
        require(safe.execTransactionFromModule(address(safe), 0, data, Enum.Operation.Call), "Module transaction failed");

        return true;

    }
}
