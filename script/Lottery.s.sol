// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {COMToken} from "../src/COMToken.sol";
import {RDSToken} from "../src/RDSToken.sol";

contract LotteryScript is Script {
    Lottery public lottery;
    COMToken public comToken;
    RDSToken public rdsToken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        rdsToken = new RDSToken();
        comToken = new COMToken();
        lottery = new Lottery(address(rdsToken), address(comToken), 10, 10000);
        // counter = new Counter();
        console.logAddress(address(rdsToken));
        console.logAddress(address(comToken));

        vm.stopBroadcast();
    }
}
