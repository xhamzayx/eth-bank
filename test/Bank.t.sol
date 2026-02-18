// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "forge-std/Test.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank public bank;
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);

    

    function setUp() external {
        bank = new Bank();
    }

    function testDeposit() external {
        vm.prank(user1);
        vm.deal(user1, 10 ether);

        bank.deposit{value : 1 ether}();
        assertEq(bank.getBalance(user1), 1 ether);
        assertEq(address(bank).balance, 1 ether);
    }

    function testFuzz_Deposit(uint256 amount) external {
    vm.assume(amount > 0 && amount <= 10 ether);

    vm.deal(user1, amount);
    vm.prank(user1);

    bank.deposit{value: amount}();

    assertEq(bank.getBalance(user1), amount);
    assertEq(address(bank).balance, amount);
}


    function testDepositViaReceive() external{
        vm.prank(user1);
        vm.deal(user1, 5 ether);
        (bool success , ) = address(bank).call{value: 3 ether}("");
        assertTrue(success);
        assertEq(bank.getBalance(user1), 3 ether);
        assertEq(address(bank).balance, 3 ether);
    }

    function testRevert_When_DepositZero() external {
        vm.prank(user2);
        vm.deal(user2, 5 ether);
        vm.expectRevert();
        bank.deposit{value : 0 ether}();
    }
    
    function testWithDraw() external {
        vm.startPrank(user1);
        vm.deal(user1, 5 ether);
        bank.deposit{value: 3 ether}();
        assertEq(user1.balance, 2 ether);
        assertEq(address(bank).balance, 3 ether);
        assertEq(bank.getBalance(user1), 3 ether);
        bank.withDraw(2 ether);
        assertEq(bank.getBalance(user1), 1 ether);
        assertEq(user1.balance, 4 ether);
        assertEq(address(bank).balance, 1 ether);
        vm.stopPrank();
    }

    function testFuzz_Withdraw(uint256 depositAmount, uint256 withdrawAmount) external {
    vm.assume(depositAmount > 0 && depositAmount <= 10 ether);
    vm.assume(withdrawAmount > 0 && withdrawAmount <= depositAmount);

    vm.deal(user1, depositAmount);
    vm.startPrank(user1);

    bank.deposit{value: depositAmount}();
    bank.withDraw(withdrawAmount);

    assertEq(
        bank.getBalance(user1),
        depositAmount - withdrawAmount
    );

    vm.stopPrank();
}


    function testRevert_WhenWithDrawZeroETH() external {
        vm.prank(user2);
        vm.deal(user2, 5 ether);
        bank.deposit{value: 3 ether}();
        vm.expectRevert();
        bank.withDraw(0);
    }

     function testWithdrawFullBalance() external {
        vm.startPrank(user1);
        vm.deal(user1, 5 ether);
        bank.deposit{value: 2 ether}();
        bank.withDraw(2 ether);
        assertEq(bank.getBalance(user1), 0);
        assertEq(user1.balance, 5 ether);
        vm.stopPrank();
    }

    function testRevert_When_WithdrawZero() external {
        vm.prank(user2);
        vm.deal(user2, 5 ether);
        bank.deposit{value: 3 ether}();
        vm.expectRevert();
        bank.withDraw(0);
    }

    function testRevert_When_WithdrawwithZeroBal() external {
        vm.prank(user1);
        vm.expectRevert();
        bank.withDraw(2 ether);
    }

    function testRevert_When_withdrawETHMoreThanBal() external{
        vm.prank(user3);
        vm.deal(user3, 5 ether);
        bank.deposit{value: 2 ether}();
        vm.expectRevert();
        bank.withDraw(4 ether);
    }

    function testMultipleUserBalancesIndependent() external {
        vm.prank(user1);
        vm.deal(user1, 5 ether);
        bank.deposit{value: 2 ether}();
        vm.prank(user2);
        vm.deal(user2, 5 ether);
        bank.deposit{value: 3 ether}();
        assertEq(bank.getBalance(user1), 2 ether);
        assertEq(bank.getBalance(user2), 3 ether);
        assertEq(address(bank).balance, 5 ether);
    }

    function testRevert_When_ReentrancyAttacks() external {
        ReentrantAttacker attacker = new ReentrantAttacker(bank);
        vm.deal(address(attacker), 5 ether);
        attacker.deposit{value: 3 ether}();
        vm.expectRevert();
        attacker.attack();
    }


}

 contract ReentrantAttacker {
        Bank public bank;
        bool public attackInProgress;

        constructor(Bank _bank) {
            bank = _bank;
        }

        function deposit() external payable {
            bank.deposit{value: msg.value}();
        }

        function attack() external {
            attackInProgress = true;
            bank.withDraw(1 ether);
        }

        receive() external payable {
            if (attackInProgress) {
                bank.withDraw(1 ether);
            }
        }
    }