/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./BaseClaimsRegistry.sol";

contract AkromaClaimsRegistry is BaseClaimsRegistry, Ownable, AccessControl {
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  constructor(
    string memory _name,
    string memory _url,
    uint256 _cost
  ) BaseClaimsRegistry(_name, _url, _cost) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADMIN_ROLE, msg.sender);
  }

  // Access Control
  function isAdmin(address account) public view virtual returns (bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, account);
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender), "AccessControl: Restricted to admins!");
    _;
  }

  function addAdmin(address account) public virtual onlyAdmin {
    grantRole(DEFAULT_ADMIN_ROLE, account);
  }

  /**
   * @dev Removes address from DEFAULT_ADMIN_ROLE. If all admins are removed it will not be possible to call
   * `onlyAdmin` functions anymore. including: addAdmin
   */
  function removeAdmin(address account) public virtual onlyAdmin {
    revokeRole(DEFAULT_ADMIN_ROLE, account);
  }

  // Access Control End

  function setCost(uint256 cost_) public onlyAdmin {
    cost = cost_;
  }

  modifier priceCompliance() {
    require(msg.value >= cost, "Not enough AKA sent to set claim, check cost");
    _;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl) returns (bool) {
    return interfaceId == type(IBaseClaimsRegistry).interfaceId || interfaceId == type(AccessControl).interfaceId || super.supportsInterface(interfaceId);
  }

  function setClaim(
    address subject,
    bytes32 key,
    bytes32 value
  ) public payable override {
    require(msg.value >= cost, "Not enough AKA sent to set claim, check cost");
    super.setClaim(subject, key, value);
  }
}
