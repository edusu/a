// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract COMToken is ERC777, Ownable {
    constructor(
        address[] memory defaultOperators
    ) ERC777("Cash Out Money Token", COM, defaultOperators) Ownable() {}

    function mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public onlyOwner {
        _mint(account, amount, userData, operatorData);
    }
}
