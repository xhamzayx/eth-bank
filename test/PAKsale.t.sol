// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "forge-std/Test.sol";
import "../src/PAK.sol";
import '../src/PAKsale.sol';


contract PAKsaleTest is Test {
    PAK public pak;
    PAKsale public paksale;

    address public owner = address(1);
    address public buyer = address(2);

    uint constant tokenspereth = 10;
    uint constant initialsupply = 1000 * 1e18;


    function setUp() public {
        // deploy PAK token as Owner
        vm.prank(owner);
        pak = new PAK();

        // deploy PAKsale as owner
        vm.prank(owner);
        paksale = new PAKsale(address(pak) , tokenspereth);

        // transfer some PAK tokens to PAKsale contract
        // vm.prank(owner);
        // pak.transfer(address(paksale) , 500*1e18);

        // give buyer some ETH
        vm.deal(buyer , 10 ether);
    }

    function testInitialTokensinContract() external {
        assertEq(pak.balanceOf(address(paksale)), 0*1e18);
    }

    function testTokenBalanceAfterDepositingInCOntract() external {
        address contractAddress = address(paksale); 
        uint ownerBalanceBefore = pak.balanceOf(owner); 
        vm.prank(owner);
        pak.transfer(contractAddress , ownerBalanceBefore);

        assertEq(pak.balanceOf(contractAddress), ownerBalanceBefore);
        assertEq(pak.balanceOf(contractAddress), 1000*1e18);  // for confirming value
        assertEq(pak.balanceOf(owner), 0*1e18);
    }

    function testBuyTokens() external {
        address saleCAs = address(paksale);
        uint ownerBalance = pak.balanceOf(owner);
        vm.prank(owner);
        pak.transfer(saleCAs , ownerBalance);
        assertEq(pak.balanceOf(saleCAs), ownerBalance);

        vm.deal(buyer, 10 ether);
        uint ethvalue = 0.5 ether;
        uint expectedTokenAmount = ethvalue*tokenspereth;
        vm.prank(buyer);
        paksale.buyTokens{value: ethvalue}();


        assertEq(pak.balanceOf(buyer), expectedTokenAmount);

        assertEq(pak.balanceOf(saleCAs), 1000*1e18 - expectedTokenAmount);

    }

    function test_RevertWhen_buywithzeroETH() external {
        vm.prank(buyer);

        vm.expectRevert("ADD some ETH to buy PAK TOkens");
        paksale.buyTokens();
    }

    function test_RevertWhen_zeroTokensInContract() external {
        vm.prank(buyer);
        vm.deal(buyer, 10 ether);

        vm.expectRevert("Not enough tokens left in Contract");
        paksale.buyTokens{value: 0.5 ether}();
    }
    
    function test_RevertWhen_buyMoretokensthanbalance() external {
        address saleAddress = address(paksale);
        uint ownerBalance = pak.balanceOf(owner);
        vm.prank(owner);
        pak.transfer(saleAddress , ownerBalance);
        assertEq(pak.balanceOf(saleAddress), ownerBalance);
        // buyer buys tokens
        vm.deal(buyer, 100000 ether);

        vm.prank(buyer);
        vm.expectRevert("Not enough tokens left in Contract");
        paksale.buyTokens{value :100000 ether}();

    }

    function testOwnerCanWithDrawETH() external {
        address saleCAs = address(paksale);
        uint ownerBalance = pak.balanceOf(owner);
        vm.prank(owner);
        pak.transfer(saleCAs , ownerBalance);
        assertEq(pak.balanceOf(saleCAs), ownerBalance);
        uint saleCAsETHBalanceBefore = saleCAs.balance;
        vm.prank(buyer);
        vm.deal(buyer, 10 ether);
        paksale.buyTokens{value: 0.5 ether}();
        uint saleCAsETHBalanceAfter = saleCAs.balance;
        assertEq(saleCAs.balance, saleCAsETHBalanceBefore+saleCAsETHBalanceAfter);

        uint ownerETHBalanceBefore = owner.balance;

        vm.prank(owner);

        paksale.withdrawETH();
        uint ownerETHBalanceAfter = owner.balance;

        assertEq(owner.balance, ownerETHBalanceBefore+saleCAsETHBalanceAfter);

    }

     function test_RevertWhen_NotownerWithdrawsETH() external {
        vm.prank(buyer);
        vm.expectRevert();

        paksale.withdrawETH();

    }

    function test_RevertWhen_withdrawWithZeroETH() external {
        vm.prank(owner);
        vm.expectRevert("NO ETHs in the contract");

        paksale.withdrawETH();

    }

    function testCheckTokensBalanceInCOntract() external {
        address saleCOntractAddress = address(paksale);

        vm.prank(owner);
        pak.transfer(saleCOntractAddress , 500*1e18);

        uint contractTokenBalance = paksale.tokenBalanceInContract();
        assertEq(contractTokenBalance, 500*1e18);
    }


}