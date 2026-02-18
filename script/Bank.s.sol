// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;


import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Bank.sol";

contract BankScript is Script {

    function run() external {
        uint devPrivateKey = vm.envUint("DEV_PRIVATE_KEY");
        address account = vm.addr(devPrivateKey);
        console.log("Deployer address is" , account);
        vm.startBroadcast(devPrivateKey);
        Bank bank = new Bank();
        console.log("Contract Address is" , address(bank));
        vm.stopBroadcast();
    }

}