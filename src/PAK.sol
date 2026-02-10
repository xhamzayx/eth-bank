// SPDX-License-Identifier: MIT
pragma solidity ^0.8.32;

import"lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import"lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import"lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
 
 contract PAK is ERC20 , Ownable , ERC20Burnable {

    constructor () ERC20("Pakistan" , "PAK") Ownable(msg.sender) {
        _mint(msg.sender, 1000*10**decimals());
        
    }

    // function mintMore() public onlyOwner {
    //     // we can use it if needed

    // }

 }