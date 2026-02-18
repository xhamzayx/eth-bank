// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "../src/Bank.sol";
import "forge-std/Test.sol";

contract BankHandler is Test {
    Bank public bank;

    address[] public users;

    constructor(Bank _bank) {
        bank = _bank;

        // create fake users
        for (uint256 i = 0; i < 5; i++) {
            address user = address(uint160(i + 1));
            users.push(user);
            vm.deal(user, 100 ether);
        }
    }

    function deposit(uint256 userIndex, uint256 amount) external {
        address user = users[userIndex % users.length];

        amount = bound(amount, 1 wei, 10 ether);

        vm.prank(user);
        bank.deposit{value: amount}();
    }

    function withdraw(uint256 userIndex, uint256 amount) external {
        address user = users[userIndex % users.length];
        uint256 balance = bank.getBalance(user);

        if (balance == 0) return;

        amount = bound(amount, 1 wei, balance);

        vm.prank(user);
        bank.withDraw(amount);
    }
}
