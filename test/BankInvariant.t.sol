// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "../test/BankHandler.t.sol";

contract BankInvariantTest is Test {
    Bank public bank;
    BankHandler public handler;

    function setUp() external {
        bank = new Bank();
        handler = new BankHandler(bank);

        targetContract(address(handler));
    }

    /*//////////////////////////////////////////////////////////////
                            INVARIANTS
    //////////////////////////////////////////////////////////////*/

    function invariant_ContractBalanceMatchesInternalBalances() external {
        uint256 totalBalances;

        for (uint256 i = 0; i < 5; i++) {
            address user = address(uint160(i + 1));
            totalBalances += bank.getBalance(user);
        }

        assertEq(address(bank).balance, totalBalances);
    }

    function invariant_NoNegativeBalances() external {
        for (uint256 i = 0; i < 5; i++) {
            address user = address(uint160(i + 1));
            assertGe(bank.getBalance(user), 0);
        }
    }
}
