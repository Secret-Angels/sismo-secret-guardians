// SPDX Licence Identifier : EPFL
pragma solidity ^0.8.17;

import "./SecretAngel.sol";
import "./GnosisSafe.sol";


contract SecretAngelModule is SecretAngel {
    
    GnosisSafe safe;

    constructor (
        bytes16 _appId,
        bytes16 _groupId,
        uint256 _minSignerCount,
        address _newOwner,
        address _safe
    ) SecretAngel(
        _appId,
        _groupId,
        _minSignerCount,
        _newOwner) 
        {
            safe = GnosisSafe(_safe);
        }
    

    function executeRecovery() override external threshold returns(bool) {
        
        require(msg.sender == newOwner, "not allowed");
        //GnosisSafe(safe).addOwnerWithThreshold(newOwner, 1);
        bytes memory data = abi.encodeWithSignature("addOwnerWithThreshold(address,uint256)", newOwner, 1);
        require(safe.execTransactionFromModule(address(safe), 0, data, Enum.Operation.Call), "Module transaction failed");

        return true;

    }


}
