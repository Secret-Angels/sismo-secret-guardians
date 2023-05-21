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
        //vm.createSelectFork("https://rpc.ankr.com/eth_goerli");
    }

    function testSimpleAttachment(address[] memory addresses) public {
        vm.assume(addresses.length > 1 && addresses.length < 15);
        //address[] storage addresses = [0x3c337dE4847adB31b57559c14eDfF1E0Ee59F988, 0x000000000000000000000000000000000000000000000000000000000000122b, 0x0000000000000000000000000000000000000000000000000000000000000add, 0x0000000000000000000000000000000000000000000000000000000000000ded];
        address _safe = 0xe23B2067877E013434bE22BE0357B176bcC00174;
        bytes16 _appId = 0x233d8ed9e8c2c89ccc3bccdece915115;
        bytes16 _groupId = 0x3497b46c5dcd30bf8ee001fe3fdd0acd;

        SecretAngelModule angelModule = new SecretAngelModule(_appId, _groupId, addresses.length, newOwner, _safe);
        vm.startPrank(_safe);
        GnosisSafe safe = GnosisSafe(_safe);

        safe.enableModule(address(angelModule));
        vm.stopPrank();

        bytes memory proof =
            hex"0000000000000000000000000000000000000000000000000000000000000020233d8ed9e8c2c89ccc3bccdece91511500000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000200000000000000000000000004f5c9a72905896bb157be8ff8d3fd62b21b882b40000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012fb480f34746dc7479140126b6713a9a6077a240a10c9e5e8848321a6867b8f500000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c001daf9216fd64f6b4e8668392ab763ee033020cc6e4f1c94e53a08a630215daa07a41413749454ea347af4d55066ca781565113def3843d4bf195d2652093cd60cc0343d9023499f77d5781fa896b1350a8a54252d433688abb722c38f66bd342ee533deaa44276adb3aed5f9551cd707701df061dd9213e47f281399b8cbd7705b67be76cfa70be6242f6f7fec95a25198d2b2b249e2864fe0170a65394580a03eeae1044448266ee6f5467162d6c169ff22c2a2c24463c302931e56a5e3c62083b76fec2a8250361739a891115faa15e484d392894f80dd810571b070023d3032113acf4fd2a2125db8cee29d3436e67d41695ffd40a17a046db6a7dcc188d000000000000000000000000000000000000000000000000000000000000000030467a527fd22b1e2f994f9baaece57c5a36bfd07cd8aea14833b5095742a8c92ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002fb480f34746dc7479140126b6713a9a6077a240a10c9e5e8848321a6867b8f5255736de257bc5d01c05a141d8f3a26f8e5c08e3b418bd698ecfcdb233c00cfc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        
        for(uint256 user_id; user_id<addresses.length; ++user_id){
            vm.startPrank(addresses[user_id]);
            angelModule.supportRecovery(abi.encodePacked(user_id+1));
            vm.stopPrank();
        }

        vm.startPrank(newOwner);
        angelModule.executeRecovery();
        vm.stopPrank();

        assertTrue(safe.isOwner(newOwner));
    }
}
