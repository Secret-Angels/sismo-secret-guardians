// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/SecretAngelModule.sol";

contract Deploy is Script {
    bytes16 _appId = 0x233d8ed9e8c2c89ccc3bccdece915115;
    bytes16 _groupId = 0x3497b46c5dcd30bf8ee001fe3fdd0acd;
    address _safe = 0xe23B2067877E013434bE22BE0357B176bcC00174; 

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
    }

    function run() public {
        vm.broadcast();
        SecretAngelModule secretAngelMod = new SecretAngelModule(_appId, _groupId, _safe, 1,0 , 4 seconds, 2 weeks);
        vm.stopBroadcast();
    }
}
