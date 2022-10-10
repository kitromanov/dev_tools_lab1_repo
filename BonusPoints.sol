// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

contract BonusPoints {
    event Mint(address user, uint new_balance);
    event Burn(address user, uint new_balance);
    event AnnualClearing(string message);
    address public owner;
    mapping(address => uint) public balances;
    mapping(address => uint) public spended_points;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _is_user;
    address[] private _users;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function mint(address user, uint amount) external onlyOwner {
        if (_is_user[user] == false) {
            _is_user[user] = true;
            _users.push(user);
        }
        balances[user] += amount;
        emit Mint(user, balances[user]);
    }

    function burn(address user, uint amount) external onlyOwner {
        balances[user] -= amount;
        emit Burn(user, balances[user]);
    }

    function withdraw(address user, uint amount) external onlyOwner {
        balances[user] -= amount;
        emit Burn(user, balances[user]);
    }

    function allow(address from, address to, uint amount) external {
        require(from == msg.sender);
        _allowances[from][to] += amount;
    }

    function transfer(address from, uint amount) external {
        require(_allowances[from][msg.sender] >= amount);
        _allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[msg.sender] += amount;
        emit Mint(msg.sender, balances[msg.sender]);
        emit Burn(from, balances[from]);
    }

    function annualPointsClearing() external onlyOwner {
        for(uint i = 0; i < _users.length; ++i) {
            balances[_users[i]] = 0;
        }
        emit AnnualClearing("All scores were burn");
    }

    function getMyBonusPoints() external view virtual returns(uint) {
        return balances[msg.sender];
    }

    function getMySpendedPoints() external view virtual returns(uint) {
        return spended_points[msg.sender];
    }
}