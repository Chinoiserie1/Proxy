// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/UUPS/UUPSProxy.sol";
import "../src/UUPS/MyERC20Proxy.sol";
import { MyERC20ProxyUpgraded } from "../src/UUPS/MyERC20ProxyUpgraded.sol";
import "../src/UUPS/Interfaces/IMyERC20Proxy.sol";

contract UUPSProxyTest is Test {
  MyERC20Proxy public myERC20Proxy;
  MyERC20ProxyUpgraded public myERC20ProxyUpgraded;
  UUPSProxy public proxy;

  uint256 internal ownerPrivateKey;
  address internal owner;
  uint256 internal user1PrivateKey;
  address internal user1;

  function setUp() public {
    ownerPrivateKey = 0xA11CE;
    owner = vm.addr(ownerPrivateKey);
    user1PrivateKey = 0xB0B;
    user1 = vm.addr(user1PrivateKey);
    vm.startPrank(owner);

    myERC20Proxy = new MyERC20Proxy();
    proxy = new UUPSProxy("", address(myERC20Proxy));
  }

  function testInit() public {
    IMyERC20Proxy(address(proxy)).initialize("TestProxy", "TProxy", 1000 ether);
    address _owner = IMyERC20Proxy(address(proxy)).owner();
    require(_owner == owner, "fail init proxy");
    IMyERC20Proxy(address(proxy)).name();
    IMyERC20Proxy(address(proxy)).symbol();
    uint256 currentSupply = IMyERC20Proxy(address(proxy)).totalSupply();
    require(currentSupply == 0, "fail get current supply");
  }

  function testUpgrade() public {
    IMyERC20Proxy(address(proxy)).initialize("TestProxy", "TProxy", 1000 ether);
    vm.expectRevert();
    IMyERC20Proxy(address(proxy)).mint(user1, 10 ether);
    myERC20ProxyUpgraded = new MyERC20ProxyUpgraded();
    IMyERC20Proxy(address(proxy)).updateCode(address(myERC20ProxyUpgraded));
    IMyERC20Proxy(address(proxy)).mint(user1, 10 ether);
  }

}
