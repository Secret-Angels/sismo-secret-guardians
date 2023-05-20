// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "sismo-connect-packages/SismoLib.sol";
import "./GnosisSafe.sol";

contract SecretAngelModule is SismoConnect {
    bytes16 public groupId;
    GnosisSafe public safe;

    constructor(address _safe, bytes16 _appId, bytes16 _groupId) SismoConnect(_appId) {
        safe = GnosisSafe(_safe);
        groupId = _groupId;
    }

    function _verifyRecoverProof(bytes memory proof) internal {
        verify({
            responseBytes: proof,
            auth: buildAuth({authType: AuthType.VAULT}),
            claim: buildClaim({groupId: groupId}),
            signature: buildSignature({message: abi.encode(msg.sender)})
        });
    }

    function helpRecover(address newOwner, bytes memory proof) external {
        _verifyRecoverProof(proof);
        // GnosisSafe(safe).addOwnerWithThreshold(newOwner, 1);
    }
}
