// SPDX-License-Identifier: GNU GPL v.3

pragma solidity 0.6.12;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract OTRCPartyToken is ERC20Upgradeable {
    using SafeMath for uint256;
    uint256 totalDividendPoints = 0;
    uint256 unclaimedDividends = 0;
    uint256 pointMultiplier = 1000000000;
    address payable public owner = 0x751a2016D88040b43Dc623e662FF2b7693d9a35a;

    struct account {
        uint256 balance;
        uint256 lastDividendPoints;
    }
    modifier onlyOwner() {
        require(owner == owner);
        _;
    }
    modifier updateDividend(address investor) {
        uint256 owing = dividendsOwing(investor);
        if (owing > 0) {
            unclaimedDividends = unclaimedDividends.sub(owing);
            balanceOf(investor).balance = balanceOf(investor).balance.add(
                owing
            );
            balanceOf(investor).lastDividendPoints = totalDividendPoints;
        }
        _;
    }

 constructor() __ERC20_init("OTRCPartyToken","OTRCPT") public {
    _mint(msg.sender, 8.5000001e19);
     emit Transfer(address(0), owner, 8.5000001e19);
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
            balanceOf(investor).lastDividendPoints
        );
        return
            (balanceOf(investor).balance.mul(newDividendPoints)).div(
                pointMultiplier
            );
    }
    // function disburse(uint256 amount) public onlyOwner {
    //     totalDividendPoints = totalDividendPoints.add(
    //         (amount.mul(pointMultiplier)).div(totalSupply_)
    //     );
    //     totalSupply_ = totalSupply_.add(amount);
    //     unclaimedDividends = unclaimedDividends.add(amount);
    // }
   function withdraw(uint256 amount) public {
    require(msg.sender == owner);
        owner.call{value: amount}('');
    }
}