// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Lottery} from "../src/Lottery.sol";
import {RDSToken} from "../src/RDSToken.sol";
import {COMToken} from "../src/COMToken.sol";

contract LotteryTest is Test {
    Lottery public lottery;
    RDSToken public rdsToken;
    COMToken public comToken;
    address owner;
    address user1;
    address user2;

    // Eventos para testear
    event TicketPurchased(address indexed buyer, uint256 indexed ticketNumber);
    event WinnerNumber(address indexed winner, uint256 indexed ticketNumber);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        rdsToken = new RDSToken();
        comToken = new COMToken();
        lottery = new Lottery(address(rdsToken), address(comToken), 10, 1000);

        // Mintear tokens para testing
        rdsToken.mint(user1, 100);
        rdsToken.mint(user2, 100);
        comToken.mint(address(lottery), 10000);

        // Aprobar tokens para la lotería
        vm.prank(user1);
        rdsToken.approve(address(lottery), type(uint256).max);
        vm.prank(user2);
        rdsToken.approve(address(lottery), type(uint256).max);
    }

    function testInitialState() public {
        assertEq(address(lottery.rdsTokenContract()), address(rdsToken));
        assertEq(address(lottery.comTokenContract()), address(comToken));
        assertEq(lottery.ticketPrice(), 10);
        assertEq(lottery.winnerPrice(), 1000);
        assertEq(uint(lottery.state()), uint(Lottery.LotteryState.Open));
    }

    function testBuyTicket() public {
        vm.prank(user1);
        lottery.buyTicket(1);

        assertEq(lottery.getTicketOwner(1), user1);
        assertEq(rdsToken.balanceOf(user1), 90);
        assertEq(rdsToken.balanceOf(address(lottery)), 10);
    }

    function testCannotBuyDuplicateTicket() public {
        vm.prank(user1);
        lottery.buyTicket(1);

        vm.prank(user2);
        vm.expectRevert("Ticket no disponible");
        lottery.buyTicket(1);
    }

    function testCannotBuyTicketWhenClosed() public {
        lottery.closeLottery();

        vm.prank(user1);
        vm.expectRevert("Operacion no permitida en el estado actual");
        lottery.buyTicket(1);
    }

    function testSetWinnerNumber() public {
        // Preparar escenario
        vm.prank(user1);
        lottery.buyTicket(1);
        vm.prank(user2);
        lottery.buyTicket(2);

        // Cerrar lotería
        lottery.closeLottery();

        // Verificar evento
        vm.expectEmit(true, true, false, true);
        emit WinnerNumber(user1, 1);

        // Seleccionar ganador
        lottery.setWinnerNumber(1);

        // Verificar premio
        assertEq(comToken.balanceOf(user1), 1000);
        // Verificar que la lotería se reabre
        assertEq(uint(lottery.state()), uint(Lottery.LotteryState.Open));
    }

    function testCancelLottery() public {
        uint256 initialBalance1 = rdsToken.balanceOf(user1);
        uint256 initialBalance2 = rdsToken.balanceOf(user2);

        // Comprar tickets
        vm.prank(user1);
        lottery.buyTicket(1);
        vm.prank(user2);
        lottery.buyTicket(2);

        lottery.cancelLottery();

        // Verificar reembolsos
        assertEq(rdsToken.balanceOf(user1), initialBalance1);
        assertEq(rdsToken.balanceOf(user2), initialBalance2);
        assertEq(lottery.getTicketOwner(1), address(0));
        assertEq(lottery.getTicketOwner(2), address(0));
    }

    function testAdminFunctions() public {
        lottery.setTicketPrice(20);
        assertEq(lottery.ticketPrice(), 20);

        lottery.setWinnerPrice(2000);
        assertEq(lottery.winnerPrice(), 2000);

        lottery.closeLottery();
        assertEq(uint(lottery.state()), uint(Lottery.LotteryState.Closed));

        lottery.openLottery();
        assertEq(uint(lottery.state()), uint(Lottery.LotteryState.Open));
    }

    function testFuzzBuyTickets(uint256 ticketNumber) public {
        vm.assume(ticketNumber > 0);
        vm.prank(user1);
        lottery.buyTicket(ticketNumber);
        assertEq(lottery.getTicketOwner(ticketNumber), user1);
    }
}
