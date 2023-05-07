// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { UUPSProxiable } from "./UUPSProxiable.sol";

error alreadyInitialized();
error amountExceedBalance();
error addressZero();
error insufficientAllowance();
error callerNotOwner();

contract MyERC20Proxy is UUPSProxiable {
  bool public initialized = false;

  address private owner_;

  string private name_;
  string private symbol_;

  uint256 public maxSupply;
  uint256 private currentSupply;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event TransferOwnership(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    if (msg.sender != owner_) revert callerNotOwner();
    _;
  }

  function transferOwnership(address newOwner) external {
    address previousOwner = owner_;
    owner_ = newOwner;
    emit TransferOwnership(previousOwner, newOwner);
  }

  function owner() public view returns (address) {
    return owner_;
  }

  // use a function because all data are store in proxy contract
  function initialize(string calldata _name, string calldata _symbol, uint256 _maxSupply) external {
    if (initialized) revert alreadyInitialized();
    name_ = _name;
    symbol_ = _symbol;
    owner_ = msg.sender;
    maxSupply = _maxSupply;
    initialized = true;
  }

  function updateCode(address newCode) external onlyOwner {
    updateCodeAddress(newCode);
  }

  function name() public view returns (string memory) {
    return name_;
  }

  function symbol() public view returns (string memory) {
    return symbol_;
  }

  function totalSupply() public view returns (uint256) {
    return currentSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }

  function transfer(address to, uint256 amount) external returns (bool) {
    if (msg.sender == address(0)) revert addressZero();
    if (to == address(0)) revert addressZero();
    if (_balances[msg.sender] < amount) revert amountExceedBalance();
    unchecked { _balances[msg.sender] -= amount; }
    _balances[to] += amount;
    emit Transfer(address(0), to, amount);
    return true;
  }

  function transferFrom(address from, address to, uint256 amount) external returns (bool) {
    if (from == address(0)) revert addressZero();
    if (to == address(0)) revert addressZero();
    if (_allowances[from][msg.sender] < amount) revert insufficientAllowance();
    if (_balances[from] < amount) revert amountExceedBalance();
    unchecked {
      _balances[from] -= amount;
      _allowances[from][msg.sender] -= amount;
    }
    _balances[to] += amount;
    emit Transfer(from, to, amount);
    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    if (spender == address(0)) revert addressZero();
    if (msg.sender == address(0)) revert addressZero();
    _allowances[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }
}