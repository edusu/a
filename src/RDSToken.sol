// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RDSToken is ERC20, Ownable {
    constructor() ERC20("RedSys Token", "RDS") Ownable(msg.sender) {}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}
