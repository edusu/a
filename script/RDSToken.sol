// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RDSToken is ERC777, Ownable {
    constructor(
        address[] memory defaultOperators
    ) ERC777("RedSys Token", "RDS", defaultOperators) Ownable() {}

    function mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public onlyOwner {
        _mint(account, amount, userData, operatorData);
    }
}
