// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Bank is ReentrancyGuard {
    error ZeroAmount();
    error InsufficientBalance();
    error TransferFailed();

    event Deposited (address indexed User , uint Amount);
    event Withdrawn (address indexed user , uint Amount);

    mapping (address => uint) private Balances;
    
    function deposit () public payable {
        require(msg.value > 0, ZeroAmount());
        Balances[msg.sender] += msg.value ;
        emit Deposited(msg.sender, msg.value);
    }

    function withDraw(uint _amount) external nonReentrant {
        if (_amount == 0) revert ZeroAmount();
        require(Balances[msg.sender]!=0, InsufficientBalance());
        require(Balances[msg.sender] >= _amount , InsufficientBalance());

        Balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, TransferFailed());
        emit Withdrawn(msg.sender, _amount);
    }

    function getBalance(address user) external view returns(uint) {
        return Balances[user];
    }

    function SeeContractBalance() external view returns(uint) {
        return address(this).balance;
    }

    receive() external payable {
        Balances[msg.sender] += msg.value ;
        emit Deposited(msg.sender, msg.value);
    }

    fallback() external payable {
        revert("Invalid function call");
    }
    

}