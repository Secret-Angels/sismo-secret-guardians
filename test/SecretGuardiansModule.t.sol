// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "src/SecretGuardiansModule.sol";

contract zkConnectDummyModuleTest is Test {
    error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
    error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);
    error VersionMismatch(bytes32 requestVersion, bytes32 responseVersion);
    error SignatureMessageMismatch(bytes requestMessageSignature, bytes responseMessageSignature);

    function setUp() public {
        vm.createSelectFork("https://goerli.blockpi.network/v1/rpc/public");
    }

    function testSimpleAttachment() public {
        address _safe = 0xe23B2067877E013434bE22BE0357B176bcC00174;
        bytes16 _appId = 0x233d8ed9e8c2c89ccc3bccdece915115;
        bytes16 _groupId = 0x3497b46c5dcd30bf8ee001fe3fdd0acd;

        SecretAngelModule angelModule = new SecretAngelModule(_safe, _appId, _groupId);
        vm.startPrank(_safe);
        GnosisSafe safe = GnosisSafe(_safe);

        safe.enableModule(address(angelModule));
        vm.stopPrank();

        bytes memory proof = 
          hex"0000000000000000000000000000000000000000000000000000000000000020233d8ed9e8c2c89ccc3bccdece91511500000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000000004c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000003497b46c5dcd30bf8ee001fe3fdd0acd000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c0009bd3c294d1b6cc29ceac8707239581c190416fddff0224d13c8adb1a1f0665127a17bd41ea3a3ea1cb6e544968f7902760de04fe34fb965b17314a65bb527428fc7665f102f1450b898e0bd153da381b30eac224455ed62d06e3f56fd4ad3512d604f0ccd5a8f5e962c9d8c6358e1e1abf9cdf125de8607096af31579d817c303318c4f24048457fdab996cda23f8eefe3ccb4a6472130f95dcbc37197098a1b601fbe0a1d75fbdc295f57e9c9fa5b7cc431fed7dd9447ce866b1a23661a400d42bd6d90bcdd1cca4300fa3b8930d211a0340d75baa31fd1053aa59eb31df60d30c48c35168e627d9ce322492438c09874f94cb3427bf4884f7a0796a68ce6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db742b1ac5d0db3b54eb72dfe420aff7d464157794515831c7a58b4048564eaf798e1a1f90b6ef57949c4250de4e113f82a37daa0349d1bdb8217a52526a505d06801782f29da28f18548500f5c7d6316c8e3e4ad85b59323a05be0bc301650fe1880000000000000000000000000000000000000000000000000000000000000001043365f97c9b9095d68fbc47be5bb270442d8c1cf9ba8f6ebc1e0a6c0fffffff00000000000000000000000000000000000000000000000000000000000000002fb480f34746dc7479140126b6713a9a6077a240a10c9e5e8848321a6867b8f5255736de257bc5d01c05a141d8f3a26f8e5c08e3b418bd698ecfcdb233c00cfc00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012fb480f34746dc7479140126b6713a9a6077a240a10c9e5e8848321a6867b8f500000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c00efd787eaa65ec172cc7ceedbe5748919492c73b1b9b3a66806ec52164a0d3c427a854080b6346ce75ee5534057e4e7dacdd7539e2e838ae8f4b3d4625c38110007c519a21683a93f416486102ac140343df7749bd8db89a169eb93a7ff693912e09bd48e960fdce279e6001a924a29dd401664b3fd449f0002563851921ba3e171bf3fce0a798e228b130590addd5b394be23cfdc4d19279ec5ecab3d713b3d19665f385e72662337e1153264ee9984d122dfaf60684801747cade4fa80693e023448baec1885a2cd737423695920dbde8b78e1de057ed57d602a2af9d0a2b41e01be7fc0f4a88e16b63562888a350182566aff36b19beb156961732c540e81000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002fb480f34746dc7479140126b6713a9a6077a240a10c9e5e8848321a6867b8f5255736de257bc5d01c05a141d8f3a26f8e5c08e3b418bd698ecfcdb233c00cfc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        // hex"0000000000000000000000000000000000000000000000000000000000000020233d8ed9e8c2c89ccc3bccdece91511500000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000000004c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000003497b46c5dcd30bf8ee001fe3fdd0acd000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c0074792c93489f32d076cbf14d4c28a471c987162fe1b1cceb43f06abb28cbe8326f3a8903caf13f3033845ad1ec72e965ed53f9018a3b64bea5e138c4c5426d70a67a40ef9bf47f80a82061dbc0464c132a0ff94b47448dbfe7fec461ad634ca292f4c3bc2d3dc31e695fae4df90b4fe50605c2d771be7171ccdc8b055340c8425f1db43441a713bcf0f420f3575578788e4a2dddc1d274f310206b79ffbb33527f4c48b73d0021c95718a1f307e55451f1290ae24558a0abb149567886d684f038f138d93c83a987671edf35aa5058feac29a4340f263840e635210724f2db11d4a9f4ff3188f826edf356937fc82b89cf191d46530059cca7b5d4c635d7bd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa040858f11236890688ee7461f247850ebeb5e36b7ddf513592a9cda6cd3d97f01a1f90b6ef57949c4250de4e113f82a37daa0349d1bdb8217a52526a505d06801782f29da28f18548500f5c7d6316c8e3e4ad85b59323a05be0bc301650fe1880000000000000000000000000000000000000000000000000000000000000001043365f97c9b9095d68fbc47be5bb270442d8c1cf9ba8f6ebc1e0a6c0fffffff00000000000000000000000000000000000000000000000000000000000000000c867f7320246666e5ae0ba6767c0e5f6d2adce42ef74da788e165bbe981cce1255736de257bc5d01c05a141d8f3a26f8e5c08e3b418bd698ecfcdb233c00cfc00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010c867f7320246666e5ae0ba6767c0e5f6d2adce42ef74da788e165bbe981cce100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c00c9e1d89ab0214df0d1a11456956d83f4448b1733d6e7a673b61147d8505680c297ac2ffee1f3c6b1e4a07d976e7adad33a5a43ae107e92ffc7061957dc9e35a1e2c184ba667bd7bf6fd5c6ed07a6d8a19433367cae13d02188f71f36022e84d211fe26a11a6dd1203b172ec04b0050f8bdc99d27ded79d7da42d9a634cbe5a30086a2bfd4cffdfaa5c249521581b386a5147d253b19bd3bbea13c3dae8735c806a19f380bb9402f0d6cf552f43ddd9942df757e6e65aec508f992bee52220740269407ff8c7037983d78a0777c581afb4989f00e7a1a65ee58d532e3fda77ee239446382c446c70f2acde4158885d680d6f81def18f2e17d08bdcb691d60ea80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c867f7320246666e5ae0ba6767c0e5f6d2adce42ef74da788e165bbe981cce1255736de257bc5d01c05a141d8f3a26f8e5c08e3b418bd698ecfcdb233c00cfc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        

        vm.startPrank(0xA77aFBE129ae74869179df6cE9BA7b8d83Cbd4F1);
        angelModule.helpRecover(address(0x42), proof);
        vm.stopPrank();
    }
}
