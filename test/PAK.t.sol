// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "forge-std/Test.sol";
import "../src/PAK.sol";

contract PAKTest is Test {
    PAK public pak;
    address public owner = address(this);
    address public user = address(1);
    address public hamza = address(2);

    function setUp() public {

        vm.prank(owner);
        pak = new PAK();

    }

    function testTokenName() public view {
        assertEq(pak.name(), "Pakistan");
    }

    function testSymbol() public view {
        assertEq(pak.symbol(), "PAK");
    }
    
    function testdecimals() public {
        assertEq(pak.decimals(), 18);
    }

    function testInitialSupplyMintedToOwner() public {
        uint expectedSupply = 1000*10**pak.decimals();
        assertEq(pak.totalSupply() , expectedSupply);
        assertEq(pak.balanceOf(owner) , expectedSupply);

    }

    function testOwnerIsCorrect() public {
        assertEq(pak.owner() , owner);
    }

    function test_RevertIfnotOwnerChangesOwner() public {

        vm.prank(user);
        // change owner trynow
        // expect revert is what we are getting from ownable.sol
        vm.expectRevert(bytes("OwnableUnauthorizedAccount(0x0000000000000000000000000000000000000001)"));
        pak.transferOwnership(address(123));

    }

    function testTransferTokens() public {
        uint amount = 10*10**pak.decimals();

        vm.prank(owner);

        pak.transfer(user , amount);

        assertEq(pak.balanceOf(user) , amount);

        assertEq(
            pak.balanceOf(owner) ,
            pak.totalSupply() - amount);

    }

    function testBurnTokens() public {
        uint totalSupplyBefore = pak.totalSupply();
        uint burnAmount = 200*10**pak.decimals();

        vm.prank(owner);

        pak.burn(burnAmount);
        uint totalSupplyAfter = pak.totalSupply();
        assertEq(pak.totalSupply() ,
        totalSupplyBefore - burnAmount);

        assertEq(pak.balanceOf(owner) ,
        totalSupplyAfter);
    }

    function test_RevertWhen_BurnMoreThanBalance() public {
        vm.prank(user);
        vm.expectRevert();
        pak.burn(100);
    }
       function test_RevertWhen_NotOwnerChangesOwner() public {
        vm.prank(user);
        vm.expectRevert();
        pak.transferOwnership(hamza);
    }
}
