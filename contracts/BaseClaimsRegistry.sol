/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IBaseClaimsRegistry.sol";

/// @title Claims Registry - A repository storing claims issued
///        from any account to any other account.
abstract contract BaseClaimsRegistry is IBaseClaimsRegistry, AccessControl {
  uint256 public cost;
  bool public paused;
  string private _name;
  string private _url;

  mapping(address => mapping(address => mapping(bytes32 => string))) public registry;

  constructor(
    string memory name_,
    string memory url_,
    uint256 cost_
  ) {
    _name = name_;
    _url = url_;
    cost = cost_;
  }

  modifier priceCompliance() {
    require(msg.value >= cost, "Not enough AKA sent to set claim, check cost");
    _;
  }

  modifier notPaused() {
    require(!paused, "Paused: the contract is paused, no claims can be set");
    _;
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

  /// @dev Create or update a claim
  /// @param subject The address the claim is being issued to
  /// @param key The key used to identify the claim
  /// @param value The data associated with the claim
  function setClaim(
    address subject,
    bytes32 key,
    string memory value
  ) public payable virtual priceCompliance notPaused {
    require(bytes(value).length  != 0, "Claim value cannot be empty");
    require(bytes(value).length  <= 1000, "Claim value cannot be longer than 1000 characters");
    registry[msg.sender][subject][key] = value;
    emit ClaimSet(msg.sender, subject, key, value, block.timestamp);
  }

  /// @dev Create or update a claim about yourself
  /// @param key The key used to identify the claim
  /// @param value The data associated with the claim
  function setSelfClaim(bytes32 key, string memory value) public payable virtual {
    setClaim(msg.sender, key, value);
  }

  /// @dev Allows to retrieve claims from other contracts as well as other off-chain interfaces
  /// @param issuer The address of the issuer of the claim
  /// @param subject The address to which the claim was issued to
  /// @param key The key used to identify the claim
  function getClaim(
    address issuer,
    address subject,
    bytes32 key
  ) public view returns (string memory) {
    return registry[issuer][subject][key];
  }

  /// @dev Allows to remove a claims from the registry.
  ///      This can only be done by the issuer or the subject of the claim.
  /// @param issuer The address of the issuer of the claim
  /// @param subject The address to which the claim was issued to
  /// @param key The key used to identify the claim
  function removeClaim(
    address issuer,
    address subject,
    bytes32 key
  ) public payable virtual {
    require(msg.sender == issuer || msg.sender == subject);
    require(bytes(registry[issuer][subject][key]).length  != 0, "Claim does not exist");
    delete registry[issuer][subject][key];
    emit ClaimRemoved(msg.sender, subject, key, block.timestamp);
  }

  function setCost(uint256 cost_) public onlyAdmin {
    cost = cost_;
  }

  function setPaused(bool _state) public onlyAdmin {
    paused = _state;
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function url() public view virtual override returns (string memory) {
    return _url;
  }

  function id() public view virtual returns (bytes4) {
    return type(IBaseClaimsRegistry).interfaceId;
  }
}