/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./BaseClaimsRegistry.sol";

contract AkromaClaimsRegistry is BaseClaimsRegistry, Ownable {
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  constructor(
    string memory _name,
    string memory _url,
    uint256 _cost
  ) BaseClaimsRegistry(_name, _url, _cost) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADMIN_ROLE, msg.sender);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl) returns (bool) {
    return interfaceId == type(IBaseClaimsRegistry).interfaceId || interfaceId == type(AccessControl).interfaceId || super.supportsInterface(interfaceId);
  }
}
