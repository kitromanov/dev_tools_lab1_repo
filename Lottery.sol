// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Lottery {
    uint currentRound;
    uint constant minValue = 1 ether;
    uint immutable i_initialTicketsSupply;
    uint immutable i_startTime;
    uint immutable i_lotteryDuration;

    mapping(address => uint) balance;
    mapping(address => mapping(uint => uint[])) ticketsList;
    mapping(uint => address) ticketsOwner;

    modifier isCorrectValue {
         require(msg.value >= minValue, "Insufficient funds");
        _;
    }

    modifier checkTime {
        require(block.timestamp - i_startTime <= i_lotteryDuration, "The lottery has already ended");
        _;
    }

    constructor(uint _startTime, uint _lotteryDuration, uint _initialTicketsSupply) {
        i_startTime = block.timestamp;
        i_lotteryDuration = _lotteryDuration;
        i_initialTicketsSupply = _initialTicketsSupply;
    }

    function buyTickets(uint ticketsAmount) external {
        for (uint i = 1; i <= ticketsAmount; ++i) {
            ticketsList[msg.sender][currentRound].push(i_initialTicketsSupply + i);
            ticketsOwner[i_initialTicketsSupply + i] = msg.sender;
        }
    }

    function transfer(address to, uint amount) external payable isCorrectValue {
        balance[msg.sender] -= amount;
        balance[to] += amount;
    }
}