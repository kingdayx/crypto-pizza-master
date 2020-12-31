// SPDX-License-Identifier: GNU GPL v.3

pragma solidity ^0.6.2;

/**
 * @title FiatContractInterface
 * @notice Interface for third-party contract FiatContract (see: https://fiatcontract.com/)
 */
interface FiatContractInterface {
    function ETH(uint256 _id) external view returns (uint256);

    function USD(uint256 _id) external view returns (uint256);

    function EUR(uint256 _id) external view returns (uint256);

    function GBP(uint256 _id) external view returns (uint256);

    function updatedAt(uint256 _id) external view returns (uint256);
}
