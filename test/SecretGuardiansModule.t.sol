// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/SecretAngelModule.sol";

contract zkConnectDummyModuleTest is Test {
    error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
    error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);
    error VersionMismatch(bytes32 requestVersion, bytes32 responseVersion);
    error SignatureMessageMismatch(bytes requestMessageSignature, bytes responseMessageSignature);
    address newOwner = makeAddr("newOwner");

    function setUp() public {
        //vm.createSelectFork("https://goerli.blockpi.network/v1/rpc/public");
        vm.createSelectFork("https://eth-goerli.g.alchemy.com/v2/qIhUbBSJG9G78ZP1lMbz3PLlz6OaH9L4", 9037645);
    }

    function testSimpleAttachment(address[] memory addresses) public {
        vm.assume(addresses.length > 2 && addresses.length < 15);
        //address[] storage addresses = [0x3c337dE4847adB31b57559c14eDfF1E0Ee59F988, 0x000000000000000000000000000000000000000000000000000000000000122b, 0x0000000000000000000000000000000000000000000000000000000000000add, 0x0000000000000000000000000000000000000000000000000000000000000ded];
        address _safe = 0xe23B2067877E013434bE22BE0357B176bcC00174;
        bytes16 _appId = 0x233d8ed9e8c2c89ccc3bccdece915115;
        bytes16 _groupId = 0x3497b46c5dcd30bf8ee001fe3fdd0acd;
        //use these args for tests: (_appId, _groupId, _safe, 0, 0, 0, 2 weeks)
        SecretAngelModule angelModule = new SecretAngelModule(_appId, _groupId, _safe, 0, 0, 0, 2 weeks);
        vm.startPrank(_safe);
        GnosisSafe safe = GnosisSafe(_safe);

        safe.enableModule(address(angelModule));
        vm.stopPrank();
        
        for(uint256 user_id; user_id<addresses.length; ++user_id){
            vm.startPrank(addresses[user_id]);
            angelModule.supportRecovery(abi.encodePacked(user_id+1), newOwner);
            vm.stopPrank();
        }

        vm.startPrank(newOwner);
        angelModule.executeRecovery(newOwner);
        vm.stopPrank();

        assertTrue(safe.isOwner(newOwner));
    }

}
