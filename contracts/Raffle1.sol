// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Raffle is ERC721 {

    address internal immutable admin;
    uint256 internal ticketPrice;
    uint256 internal totalTickets;
    uint256 internal remainingTickets;
    bool internal isActive;

    modifier isAdmin() {
        require(msg.sender == admin, "Only admin is allowed following action!");
        _;
    }

    constructor() ERC721("RaffleTicket", "TCKT") { 
        admin = msg.sender;        
    }

    function start(uint256 _ticketPrice, uint _totalTickets) external isAdmin {
        require(!isActive, "Raffle is already active!");
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        remainingTickets = _totalTickets;
        isActive = true;
    }

    function buyTicket() external payable {
        require(msg.value >= ticketPrice, "Insufficient funds!");
        require(isActive, "Raffle is not active!");
        require(remainingTickets > 0, "There are no tickets left!");
        
        uint256 numberOfTickets = msg.value / ticketPrice;
        if(numberOfTickets > remainingTickets) {
            numberOfTickets = remainingTickets;
        }
        uint256 totalCost = numberOfTickets * ticketPrice;
        uint256 change = msg.value - totalCost;
        
        if (change > 0) {
            payable(msg.sender).transfer(change);
        }

        for (uint256 i = 0; i < numberOfTickets; i++) {
            _safeMint(msg.sender, totalTickets - remainingTickets);
            participants.push(msg.sender);
        }
        remainingTickets -= numberOfTickets;

    }

    function transferTicket() external {}

    function pickWinner() external {}

    function resetRaffle() external {}
} 