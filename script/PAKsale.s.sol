// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/PAK.sol";
import "../src/PAKsale.sol";

contract PAKsaleScript is Script {

    function run() external{
        uint deployerPrivateKey = vm.envUint("DEV_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        console.log("Deployer Address is " , deployerAddress);

        address pakTokenAddress = vm.envAddress("PAK_TOKEN_CONTRACT_ADDRESS");
        uint tokensPerEth = vm.envUint("TOKENS_PER_ETH");
        vm.startBroadcast(deployerPrivateKey);
        PAKsale paksale = new PAKsale(pakTokenAddress, tokensPerEth);
        console.log("PAK Sale Contract Address is " , address(paksale));
        console.log("PAK Token Contract Address is " , pakTokenAddress);
        vm.stopBroadcast();
    }
}
