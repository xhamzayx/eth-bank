// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";


contract PAKsale is Ownable , ReentrancyGuard {

    IERC20 public immutable paktoken;
    uint public immutable tokenspereth;

    event TokensPurchased(address indexed buyer , string _hasbought , uint _tokensAmount , string _of , uint _ethvalue);
    event ETHWtihdrawn(address indexed _owner , uint _amount);
    constructor
    (address _paktoken , uint _tokenspereth)
    Ownable(msg.sender) {
        require(_paktoken != address(0) , "Enter valid token address");
        require(_tokenspereth > 0 , "enter some value of token");

        paktoken = IERC20(_paktoken);
        tokenspereth = _tokenspereth;
    }

    function buyTokens() external payable nonReentrant {
        require(msg.value > 0 ,"ADD some ETH to buy PAK TOkens");

        uint tokenAmount = msg.value * tokenspereth;

        require(paktoken.balanceOf(address(this)) >= tokenAmount  , "Not enough tokens left in Contract");

        paktoken.transfer(msg.sender , tokenAmount);

        emit TokensPurchased(msg.sender , "Has bought" , tokenAmount , "of" , msg.value);


    }

    function withdrawETH() external onlyOwner {
        uint balance = address(this).balance;

        require (balance > 0 , "NO ETHs in the contract");
        (bool success , ) = owner().call{value: balance}("");
        require(success , "ETH transfer failed");

        emit ETHWtihdrawn(owner() , balance);
    }

    function tokenBalanceInContract() external view returns(uint) {
        return(paktoken.balanceOf(address(this)));
    }

}


