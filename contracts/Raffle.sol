// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Raffle {

    event EnoughParticipants( uint participantNumber );
    event WinnerChosen( address winner, uint amount );

    uint256 internal ticketPrice;
    uint256 internal requiredParticipants;
    address internal immutable admin;
    address [] internal participants;
    bool public isActive = true;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the contract admin can call this function.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function start(uint256 _ticketPrice, uint256 _requiredParticipants) public onlyAdmin {
        ticketPrice = _ticketPrice;
        requiredParticipants = _requiredParticipants;
        isActive = true;
    }

    function buyTicket() payable external {
        require(msg.value >= ticketPrice, "Insufficient funds!");
        require(isActive, "Raffle is currently inactive!");
        
        // If sender is trying to buy more tickets than current raffle allows
        uint256 numberOfTickets = msg.value / ticketPrice;
        if((numberOfTickets + participants.length) > requiredParticipants) {
            numberOfTickets = requiredParticipants - participants.length;
        }
        uint256 totalCost = numberOfTickets * ticketPrice;
        uint256 change = msg.value - totalCost;
        
        if (change > 0) {
            payable(msg.sender).transfer(change);
        }

        for (uint256 i = 0; i < numberOfTickets; i++) {
            participants.push(msg.sender);
        }

        if (participants.length == requiredParticipants) {
            selectWinner();
        }
    }

    function selectWinner() internal {
        isActive = false;
        address payable winner = payable(participants[0]);
        uint256 prizeAmount = address(this).balance;
        participants = new address[](0);

        winner.transfer(prizeAmount);
        emit WinnerChosen(winner, prizeAmount);
    }
} 