// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

contract MoneyMailer {
    uint8 private clientCount;
    mapping(address => uint256) private balances;
    address public owner;

    // Log the event about a deposit being made by an address and its amount
    event LogDepositMade(address indexed accountAddress, uint256 amount);

    // Constructor is "payable" so it can receive the initial funding of 30,
    // required to reward the first 3 clients
    constructor() public payable {
        require(msg.value == 0 ether, "0 ether initial funding required");
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
        clientCount = 0;
    }

    /// @notice Enroll a customer with the bank,
    /// giving the first 100 of them .5 ether as reward
    /// @return The balance of the user after enrolling
    function enroll() public returns (uint256) {
        if (clientCount < 100) {
            clientCount++;
            balances[msg.sender] = .05 ether;
        }
        return balances[msg.sender];
    }

    /// @notice Deposit ether into bank, requires method is "payable"
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint256) {
        balances[msg.sender] += msg.value;
        emit LogDepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    function withdraw(uint256 withdrawAmount)
        public
        returns (uint256 remainingBal)
    {
        balances[msg.sender] -= withdrawAmount;

        // this automatically throws on a failure, which means the updated balance is reverted
        msg.sender.transfer(withdrawAmount);

        return balances[msg.sender];
    }
}
