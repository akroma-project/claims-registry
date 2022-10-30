/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IBaseClaimsRegistry.sol";

/// @title Claims Registry - A repository storing claims issued
///        from any account to any other account.
abstract contract BaseClaimsRegistry is IBaseClaimsRegistry {
  uint256 public cost;
  string private _name;
  string private _url;

  mapping(address => mapping(address => mapping(bytes32 => bytes32))) public registry;

  constructor(string memory name_, string memory url_, uint256 cost_) {
        _name = name_;
        _url = url_;
        cost = cost_;
    }


  /// @dev Create or update a claim
  /// @param subject The address the claim is being issued to
  /// @param key The key used to identify the claim
  /// @param value The data associated with the claim
  function setClaim(
    address subject,
    bytes32 key,
    bytes32 value
  ) public payable virtual {
    registry[msg.sender][subject][key] = value;
    emit ClaimSet(msg.sender, subject, key, value, block.timestamp);
  }

  /// @dev Create or update a claim about yourself
  /// @param key The key used to identify the claim
  /// @param value The data associated with the claim
  function setSelfClaim(bytes32 key, bytes32 value) public payable virtual {
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
  ) public view returns (bytes32) {
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
    require(registry[issuer][subject][key] != 0);
    delete registry[issuer][subject][key];
    emit ClaimRemoved(msg.sender, subject, key, block.timestamp);
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function url() public view virtual override returns (string memory) {
    return _url;
  }
}
