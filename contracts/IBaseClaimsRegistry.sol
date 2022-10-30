/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

interface IBaseClaimsRegistry {
  function name() external view returns (string memory);

  function url() external view returns (string memory);

  event ClaimSet(address indexed issuer, address indexed subject, bytes32 indexed key, bytes32 value, uint256 updatedAt);

  event ClaimRemoved(address indexed issuer, address indexed subject, bytes32 indexed key, uint256 removedAt);

  function setClaim(
    address subject,
    bytes32 key,
    bytes32 value
  ) external payable;

  function setSelfClaim(bytes32 key, bytes32 value) external payable;

  function getClaim(
    address issuer,
    address subject,
    bytes32 key
  ) external view returns (bytes32);

  function removeClaim(
    address issuer,
    address subject,
    bytes32 key
  ) external payable;

  function setCost(uint256 cost_) external;
}
