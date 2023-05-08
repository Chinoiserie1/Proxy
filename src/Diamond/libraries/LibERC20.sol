// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error addressZero();
error amountZero();
error insufficientFunds();
error insufficientAllowance();
error maxSupplyReach();

library LibERC20 {
  bytes32 constant ERC20_STORAGE_POSITION = keccak256("facet.erc20.diamond.storage");

  struct Storage {
    string _name;
    string _symbol;
    uint256 _maxSupply;
    uint256 _totalSupply;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
  }

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function init(string memory _name, string memory _symbol, uint256 _maxSupply) internal {
    Storage storage ds = getStorage();
    ds._name = _name;
    ds._symbol = _symbol;
    ds._maxSupply = _maxSupply;
  }

  // access erc20 storage via:
  function getStorage() internal pure returns (Storage storage ds) {
    bytes32 position = ERC20_STORAGE_POSITION;
    assembly {
      ds.slot := position
    }
  }

  function _erc20Name() internal view returns (string memory) {
    Storage storage ds = getStorage();
    return ds._name;
  }

  function _erc20Symbol() internal view returns (string memory) {
    Storage storage ds = getStorage();
    return ds._symbol;
  }

  function _erc20Transfer(address sender, address to, uint256 amount) internal returns (bool) {
    _transfer(sender, to, amount);
    return true;
  }

  function _erc20TransferFrom(address sender, address from, address to, uint256 amount) internal returns (bool) {
    _erc20_spendAllowance(from, sender, amount);
    _transfer(from, to, amount);
    return true;
  }

  function _transfer(address from, address to, uint256 amount) internal {
    if (to == address(0)) revert addressZero();
    if (from == address(0)) revert addressZero();

    Storage storage ds = getStorage();

    uint256 fromBalance = ds._balances[from];
    if (fromBalance < amount) revert insufficientFunds();
    unchecked { ds._balances[from] -= amount; }
    ds._balances[to] += amount;
    emit Transfer(from, to, amount);
  }

  function _erc20BalanceOf(address account) internal view returns (uint256) {
    Storage storage ds = getStorage();
    return ds._balances[account];
  }

  function _erc20approve(address owner, address spender, uint256 amount) internal {
    if (owner == address(0)) revert addressZero();
    if (spender == address(0)) revert addressZero();
    Storage storage ds = getStorage();

    ds._allowances[owner][spender] = amount;

    emit Approval(owner, spender, amount);
  }

  function _erc20allowance(address owner, address spender) internal view returns (uint256) {
    Storage storage ds = getStorage();
    return ds._allowances[owner][spender];
  }

  function _erc20_spendAllowance(address owner, address spender, uint256 amount) internal {
    uint256 currentAllowance = _erc20allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
      if(currentAllowance < amount) revert insufficientAllowance();
      unchecked {
        _erc20approve(owner, spender, currentAllowance - amount);
      }
    }
  }

  function _erc20Mint(address to, uint256 amount) internal {
    if (to == address(0)) revert addressZero();
    if (amount == 0) revert amountZero();
    Storage storage ds = getStorage();
    if (ds._totalSupply + amount > ds._maxSupply) revert maxSupplyReach();
    ds._balances[to] += amount;
    ds._totalSupply += amount;
  }

  function _erc20Burn(address sender, uint256 amount) internal {
    Storage storage ds = getStorage();
    if (ds._balances[sender] < amount) revert insufficientFunds();
    unchecked {
      ds._balances[sender] -= amount;
      ds._totalSupply -= amount;
    }
    emit Transfer(sender, address(0), amount);
  }
}