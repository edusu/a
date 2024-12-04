// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    constructor() Ownable() {}

    function buyTicket() public payable {
        require(msg.value == 1 ether, "Lottery: ticket price is 1 ether");
    }
}
