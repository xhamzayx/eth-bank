// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/PAK.sol";

contract PAKScript is Script {
    function setUp() external{}

    function run() external {
        uint devPrivateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(devPrivateKey);
        console.log("Deployer address is " , account);

        vm.startBroadcast(devPrivateKey);
        PAK pak = new PAK();
        console.log("Contract Address is" , address(pak));
        vm.stopBroadcast();
    }
    
}
