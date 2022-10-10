// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';

contract BonusToken is ERC20 {
    event Mint(address user, uint new_balance);
    event Burn(address user, uint new_balance);
    event AnnualClearing(string message);
    event SetUserStatus(address, UserStatus);

    enum UserStatus{ ORDINARY, VIP, PREMIUM}

    address private _owner;
    address[] private _users;
    mapping(address => UserStatus) private _userStatus;
    mapping(address => bool) private _isUser;
    mapping(address => uint) public _spendedBonusTokens;

    constructor() ERC20("Bonus Token", "BT") {
       _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function setStatus(address user, UserStatus status) public onlyOwner {
        _userStatus[user] = status;
        emit SetUserStatus(user, status);
    }

    function mintBT(address user, uint amount) external onlyOwner {
        if (_isUser[user] == false) {
            _isUser[user] = true;
            _users.push(user);
        }
        uint multiplier = 1;
        if (_userStatus[user] == UserStatus.VIP) {
            multiplier = 5;
        } else if(_userStatus[user] == UserStatus.PREMIUM) {
            multiplier = 2;
        }
        _mint(user, multiplier * amount);
        emit Mint(user, balanceOf(user));
    }

    function burnBT(address user, uint amount) external onlyOwner {
        _burn(user, amount);
        _spendedBonusTokens[user] += amount;
        emit Burn(user, balanceOf(user));
    }

    function annualPointsClearing() external onlyOwner {
        for(uint i = 0; i < _users.length; ++i) {
            _burn(_users[i], balanceOf(_users[i]));
        }
        emit AnnualClearing("Done");
    }

    function getMySpendedPoints() external view virtual returns(uint) {
        return _spendedBonusTokens[msg.sender];
    }

    function getOwner() external view returns(address) {
        return _owner;
    }
}