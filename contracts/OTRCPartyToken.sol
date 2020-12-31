// SPDX-License-Identifier: GNU GPL v.3

pragma solidity ^0.6.2;

import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "./MoneyMailer.sol";

contract OTRCPartyToken {
    using SafeMath for uint256;

    string public name = "OTRCPartyToken";
    string public symbol = "OTRCPT";
    uint8 public decimals = 5;
    uint256
        public totalSupply_ = 85000000700000000000000000000000000000000000000000;
    uint256 totalDividendPoints = 0;
    uint256 unclaimedDividends = 0;
    uint256 pointMultiplier = 1000000000;
    address payable owner = 0x751a2016D88040b43Dc623e662FF2b7693d9a35a ;

    struct account {
        uint256 balance;
        uint256 lastDividendPoints;
    }

    mapping(address => account) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier onlyOwner() {
        _;
    }
    modifier updateDividend(address investor) {
        uint256 owing = dividendsOwing(investor);
        if (owing > 0) {
            unclaimedDividends = unclaimedDividends.sub(owing);
            balanceOf[investor].balance = balanceOf[investor].balance.add(
                owing
            );
            balanceOf[investor].lastDividendPoints = totalDividendPoints;
        }
        _;
    }

    constructor() public {
        // Initially assign all tokens to the contract's creator.
        balanceOf[msg.sender].balance = totalSupply_;
        owner = payable(address(0x751a2016D88040b43Dc623e662FF2b7693d9a35a));
        emit Transfer(address(0), owner, totalSupply_);
    }

    /**
     new dividend = totalDividendPoints - investor's lastDividnedPoint
     ( balance * new dividend ) / points multiplier

    **/
    function dividendsOwing(address investor)
        public
        updateDividend(msg.sender)
        returns (uint256)
    {
        uint256 newDividendPoints = totalDividendPoints.sub(
            balanceOf[investor].lastDividendPoints
        );
        return
            (balanceOf[investor].balance.mul(newDividendPoints)).div(
                pointMultiplier
            );
    }

    /**

    **/
    function disburse(uint256 amount) public onlyOwner {
        totalDividendPoints = totalDividendPoints.add(
            (amount.mul(pointMultiplier)).div(totalSupply_)
        );
        totalSupply_ = totalSupply_.add(amount);
        unclaimedDividends = unclaimedDividends.add(amount);
    }

    function transfer(address _to, uint256 _value)
        public
        updateDividend(msg.sender)
        updateDividend(_to)
        returns (bool)
    {
        if (msg.sender != _to)
            if (_to != address(0))
                if (_value <= balanceOf[msg.sender].balance)
                    balanceOf[msg.sender].balance = (
                        balanceOf[msg.sender].balance
                    )
                        .sub(_value);
        balanceOf[_to].balance = (balanceOf[_to].balance).add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    mapping(address => mapping(address => account)) internal allowed;

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public updateDividend(_from) updateDividend(_to) returns (bool) {
        balanceOf[_from].balance = (balanceOf[_from].balance).sub(_value);
        balanceOf[_to].balance = (balanceOf[_to].balance).add(_value);
        (allowed[_from][msg.sender]).balance = (allowed[_from][msg.sender])
            .balance
            .sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        (allowed[msg.sender][_spender]).balance = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return (allowed[_owner][_spender]).balance;
    }
   function withdraw(uint256 amount) public {
    if(msg.sender==owner){
         owner.transfer(amount);
    }
}
   

}
