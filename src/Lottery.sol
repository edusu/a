// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Lottery is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public rdsTokenContract;
    IERC20 public comTokenContract;
    uint256 public ticketPrice;
    uint256 public winnerPrice;
    mapping(uint256 => address) private ticketOwners;
    // Guardamos las keys en un array cuando asignamos tickets
    uint256[] private _activeTickets;
    event TicketPurchased(address indexed buyer, uint256 indexed ticketNumber);
    event WinnerNumber(address indexed winner, uint256 indexed ticketNumber);

    enum LotteryState {
        Open,
        Closed
    }
    LotteryState public state;

    modifier inState(LotteryState _state) {
        require(state == _state, "Operacion no permitida en el estado actual");
        _;
    }

    constructor(
        address _rdsTokenContract,
        address _comTokenContract,
        uint256 _ticketPrice,
        uint256 _winnerPrice
    ) Ownable(msg.sender) {
        rdsTokenContract = IERC20(_rdsTokenContract);
        comTokenContract = IERC20(_comTokenContract);
        ticketPrice = _ticketPrice;
        winnerPrice = _winnerPrice;
    }

    function buyTicket(
        uint256 ticketNumber
    ) external nonReentrant inState(LotteryState.Open) {
        // El ticket debe ser menor que 100000
        require(ticketNumber < 100000, "Numero de ticket invalido");
        // El ticket debe estar disponible
        require(
            ticketOwners[ticketNumber] == address(0),
            "Ticket no disponible"
        );
        // Transfiere tokens del usuario al contrato
        rdsTokenContract.transferFrom(msg.sender, address(this), ticketPrice);

        // Asigna el ticket al usuario
        _assignTicket(msg.sender, ticketNumber);

        // Emite un evento si es necesario
        emit TicketPurchased(msg.sender, ticketNumber);
    }

    function _assignTicket(address buyer, uint256 ticketNumber) internal {
        ticketOwners[ticketNumber] = buyer;
        _activeTickets.push(ticketNumber);
    }

    function setTicketPrice(uint256 _ticketPrice) external onlyOwner {
        ticketPrice = _ticketPrice;
    }

    function setWinnerPrice(uint256 _winnerPrice) external onlyOwner {
        winnerPrice = _winnerPrice;
    }

    function openLottery() external onlyOwner {
        state = LotteryState.Open;
    }

    function closeLottery() external onlyOwner {
        state = LotteryState.Closed;
    }

    function setWinnerNumber(
        uint256 ticketNumber
    ) external onlyOwner inState(LotteryState.Closed) {
        // El ticket debe estar disponible
        if (ticketOwners[ticketNumber] != address(0)) {
            // Dar el premio
            comTokenContract.transfer(ticketOwners[ticketNumber], winnerPrice);
        }
        emit WinnerNumber(ticketOwners[ticketNumber], ticketNumber);
        // Limpiar el mapping
        _clearTickets();
        // Cambia el estado de la loteria
        state = LotteryState.Open;
    }

    // Limpiamos usando el array de keys
    function _clearTickets() internal {
        for (uint i = 0; i < _activeTickets.length; i++) {
            delete ticketOwners[_activeTickets[i]];
        }
        delete _activeTickets; // Limpia el array
    }

    function cancelLottery() external onlyOwner {
        // Devuelve los tokens a los usuarios
        for (uint i = 0; i < _activeTickets.length; i++) {
            rdsTokenContract.transfer(
                ticketOwners[_activeTickets[i]],
                ticketPrice
            );
            delete ticketOwners[_activeTickets[i]];
        }
        // Limpiar el mapping
        _clearTickets();
        delete _activeTickets; // Limpia el array
        // Cambia el estado de la loteria
        state = LotteryState.Open;
    }

    function getTicketOwner(
        uint256 ticketNumber
    ) external view returns (address) {
        return ticketOwners[ticketNumber];
    }
}
