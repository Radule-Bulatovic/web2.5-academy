// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract Raffle is ERC721 {

    event WinnerChosen( address winner, uint256 randomTicketID, uint amount );

    uint8 constant PRIZE_PERCENT = 80;
    uint256 internal ticketPrice;
    uint256 internal totalTickets = 0;
    uint256 internal remainingTickets;
    address internal immutable admin;
    uint256  startingTokenIndex = 0;
    bool public isActive = false;

    modifier isAdmin() {
        require(msg.sender == admin, "Only the contract admin can call this function.");
        _;
    }

    constructor() ERC721("RaffleTicket", "TCKT"){
        admin = msg.sender;
    }

    function newRaffle(uint256 _ticketPrice, uint256 _totalTickets) external isAdmin {
        require(!isActive, "Raffle is already active!");

        startingTokenIndex = startingTokenIndex + totalTickets;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
        remainingTickets = _totalTickets;
        isActive = true;
    }

    function buyTicket() payable external {
        require(msg.value >= ticketPrice , "Insufficient funds!");
        require(isActive, "Raffle is currently inactive!");
        require(remainingTickets > 0, "There are no tickets le1ft!");

        // If sender is trying to buy more tickets than current raffle allows
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
            uint ticketId = startingTokenIndex + (totalTickets - remainingTickets) + i;
            _mint(msg.sender, ticketId);
        }
        remainingTickets -= numberOfTickets;

        if (remainingTickets == 0) {
            selectWinner();
        }
    }

    function selectWinner() internal {
        isActive = false;

        uint256 randomTicketID = random();

        address payable winner = payable(ownerOf(randomTicketID));
        uint256 prizeAmount = (address(this).balance * PRIZE_PERCENT) / 100;

        winner.transfer(prizeAmount);
        payable(admin).transfer(address(this).balance);

        emit WinnerChosen(winner, randomTicketID, prizeAmount);
    }

    function giftTicket(uint256 tokenId, address to) external {
        require (msg.sender == ownerOf(tokenId), "You need to be owner in order to gift ticket");
        safeTransferFrom(msg.sender, to, tokenId);
    }

    function random() internal view returns(uint){
       uint256 randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, uint(5))));
       return (randomNumber % totalTickets) + startingTokenIndex;
    }
} 