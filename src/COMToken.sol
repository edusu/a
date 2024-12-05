// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract COMToken is ERC20, Ownable {
    constructor() ERC20("Cash Out Money Token", "COM") Ownable(msg.sender) {}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}
