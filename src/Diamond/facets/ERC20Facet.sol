// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { LibERC20 } from "../libraries/LibERC20.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract ERC20Facet {
  constructor(string memory _name, string memory _symbol, uint256 _maxSupply) {
    LibERC20.init(_name, _symbol, _maxSupply);
  }

  function nameERC20() external view returns (string memory) {
    return LibERC20._erc20Name();
  }

  function symbolERC20() external view returns (string memory) {
    return LibERC20._erc20Symbol();
  }

  function approveERC20(address spender, uint256 amount) external {
    LibERC20._erc20approve(msg.sender, spender, amount);
  }

  function allowanceERC20(address owner, address spender) external view returns (uint256) {
    return LibERC20._erc20allowance(owner, spender);
  }

  function balanceOfERC20(address account) external view returns (uint256) {
    return LibERC20._erc20BalanceOf(account);
  }

  function transferERC20(address to, uint256 amount) external returns (bool) {
    LibERC20._erc20Transfer(msg.sender, to, amount);
    return true;
  }

  function transferFromERC20(address from, address to, uint256 amount) external returns (bool) {
    LibERC20._erc20TransferFrom(msg.sender, from, to, amount);
    return true;
  }

  function mintERC20(address to, uint256 amount) external {
    LibDiamond.enforceIsContractOwner();
    LibERC20._erc20Mint(to, amount);
  }

  function burnERC20(uint256 amount) external {
    LibERC20._erc20Burn(msg.sender, amount);
  }
}