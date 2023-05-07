// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IMyERC20Proxy {
  function transferOwnership(address newOwner) external;
  function owner() external view returns (address);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function initialize(string calldata _name, string calldata _symbol, uint256 _maxSupply) external;
  function updateCode(address newCode) external;
  function totalSupply() external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function mint(address to, uint256 amount) external;
}