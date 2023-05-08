// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDiamondERC20 {
  function initERC20(string memory name, string memory symbol, uint256 maxSupply) external;
  function nameERC20() external view returns (string memory);
  function symbolERC20() external view returns (string memory);
  function approveERC20(address spender, uint256 amount) external;
  function allowanceERC20(address owner, address spender) external view returns (uint256);
  function balanceOfERC20(address account) external view returns (uint256);
  function transferERC20(address to, uint256 amount) external returns (bool);
  function transferFromERC20(address from, address to, uint256 amount) external returns (bool);
  function mintERC20(address to, uint256 amount) external;
  function burnERC20(uint256 amount) external;
}