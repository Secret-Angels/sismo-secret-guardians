// SPDX Licence Identifier : EPFL
pragma solidity ^0.8.17;

import "./SocialRecovery.sol";
import "./GnosisSafe.sol";


contract SocialRecoveryModule is SocialRecovery {
    
    GnosisSafe safe;

    constructor (
        bytes16 _appId,
        bytes16 _groupId,
        uint256 _minSignerCount ,
        address _newOwner,
        GnosisSafe _safe
    ) SocialRecovery(
        _appId,
        _groupId,
        _minSignerCount,
        _newOwner) 
        {
            safe = GnosisSafe(_safe);
        }
    

    function executeRecovery() override external threshold {
        
        require(msg.sender == newOwner, "not allowed");

    }


}
