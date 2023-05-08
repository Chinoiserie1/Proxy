// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/Diamond/upgradeInitializers/DiamondInit.sol";
import "../src/Diamond/Diamond.sol";
import "../src/Diamond/facets/DiamondCutFacet.sol";
import "../src/Diamond/facets/DiamondLoupeFacet.sol";
import "../src/Diamond/facets/OwnershipFacet.sol";
import "../src/Diamond/facets/ERC20Facet.sol";

import { IDiamond } from "../src/Diamond/interfaces/IDiamond.sol";
import { IDiamondERC20 } from "../src/Diamond/interfaces/IDiamondERC20.sol";
import { IDiamondCut } from "../src/Diamond/interfaces/IDiamondCut.sol";

contract DiamondProxyTest is Test {
  DiamondInit public initDiamond;
  OwnershipFacet public facetOwnership;
  DiamondLoupeFacet public facetDiamondLoupe;
  DiamondCutFacet public facetDiamondCut;
  Diamond public diamond;
  ERC20Facet public erc20;

  uint256 internal ownerPrivateKey;
  address internal owner;
  uint256 internal user1PrivateKey;
  address internal user1;

  IDiamond.FacetCutAction public action;

  function initOwnershipFacet(address facetAddress) public pure returns (IDiamond.FacetCut memory initFacet) {
    initFacet.facetAddress = facetAddress;
    initFacet.action = IDiamond.FacetCutAction.Add;
    initFacet.functionSelectors = new bytes4[](2);
    bytes4 sig = bytes4(keccak256("owner()"));
    initFacet.functionSelectors[0] = sig;
    sig = bytes4(keccak256("transferOwnership(address)"));
    initFacet.functionSelectors[1] = sig;
  }

  function initLoupeFacet(address facetAddress) public pure returns (IDiamond.FacetCut memory initFacet) {
    initFacet.facetAddress = facetAddress;
    initFacet.action = IDiamond.FacetCutAction.Add;
    initFacet.functionSelectors = new bytes4[](4);
    bytes4 sig = bytes4(keccak256("facets()"));
    initFacet.functionSelectors[0] = sig;
    sig = bytes4(keccak256("facetFunctionSelectors(address)"));
    initFacet.functionSelectors[1] = sig;
    sig = bytes4(keccak256("facetAddresses()"));
    initFacet.functionSelectors[2] = sig;
    sig = bytes4(keccak256("facetAddress(bytes4)"));
    initFacet.functionSelectors[3] = sig;
  }

  function initCutFacet(address facetAddress) public pure returns (IDiamond.FacetCut memory initFacet) {
    initFacet.facetAddress = facetAddress;
    initFacet.action = IDiamond.FacetCutAction.Add;
    initFacet.functionSelectors = new bytes4[](1);
    bytes4 sig = 0x1f931c1c;
    initFacet.functionSelectors[0] = sig;
  }

  function initDiamondERC20(address facetAddress) public view returns (IDiamond.FacetCut memory initFacet) {
    initFacet.facetAddress = facetAddress;
    initFacet.action = IDiamond.FacetCutAction.Add;
    initFacet.functionSelectors = new bytes4[](10);
    bytes4 sig = bytes4(keccak256("nameERC20()"));
    initFacet.functionSelectors[0] = sig;
    sig = bytes4(keccak256("symbolERC20()"));
    initFacet.functionSelectors[1] = sig;
    sig = bytes4(keccak256("approveERC20(address,uint256)"));
    initFacet.functionSelectors[2] = sig;
    sig = bytes4(keccak256("allowanceERC20(address, address)"));
    initFacet.functionSelectors[3] = sig;
    sig = bytes4(keccak256("balanceOfERC20(address)"));
    initFacet.functionSelectors[4] = sig;
    sig = bytes4(keccak256("transferERC20(address,uint256)"));
    initFacet.functionSelectors[5] = sig;
    sig = bytes4(keccak256("transferFromERC20(address,address,uint255)"));
    initFacet.functionSelectors[6] = sig;
    sig = bytes4(keccak256("mintERC20(address,uint256)"));
    initFacet.functionSelectors[7] = sig;
    sig = bytes4(keccak256("burnERC20(uint256 amount)"));
    initFacet.functionSelectors[8] = sig;
    sig = bytes4(keccak256("initERC20(string,string,uint256)"));
    initFacet.functionSelectors[9] = sig;
  }

  function setUp() public {
    ownerPrivateKey = 0xA11CE;
    owner = vm.addr(ownerPrivateKey);
    user1PrivateKey = 0xB0B;
    user1 = vm.addr(user1PrivateKey);
    vm.startPrank(owner);

    initDiamond = new DiamondInit();

    IDiamond.FacetCut[] memory faceCut = new IDiamond.FacetCut[](3);
    DiamondArgs memory args;

    args.owner = address(owner);
    args.init = address(initDiamond);
    args.initCalldata = abi.encode(bytes4(keccak256("init()")));

    facetOwnership = new OwnershipFacet();
    IDiamond.FacetCut memory ownerShipFacet = initOwnershipFacet(address(facetOwnership));
    faceCut[0] = ownerShipFacet;
    facetDiamondLoupe = new DiamondLoupeFacet();
    IDiamond.FacetCut memory loupeFacet = initLoupeFacet(address(facetDiamondLoupe));
    faceCut[1] = loupeFacet;
    facetDiamondCut = new DiamondCutFacet();
    IDiamond.FacetCut memory cutFacet = initCutFacet(address(facetDiamondCut));
    faceCut[2] = cutFacet;
    diamond = new Diamond(faceCut, args);
    erc20 = new ERC20Facet();
  }

  function testInit() view public {
    address diamondOwner = IERC173(address(diamond)).owner();
    require(diamondOwner == owner, "fail set owner");
  }

  function addDiamondERC20Facet() internal {
    IDiamond.FacetCut[] memory erc20Facet = new IDiamond.FacetCut[](1);
    erc20Facet[0] = initDiamondERC20(address(erc20));
    IDiamondCut(
      address(diamond)).diamondCut(erc20Facet, address(erc20),
      abi.encodeWithSelector(erc20Facet[0].functionSelectors[9], "DiamondERC20", "DERC20", 100000 ether)
    );
  }

  function testAddERC20Facet() public {
    addDiamondERC20Facet();
  }

  function testDiamondERC20Mint() public {
    addDiamondERC20Facet();
    IDiamondERC20(address(diamond)).mintERC20(user1, 1 ether);
    uint256 balanceAfter = IDiamondERC20(address(diamond)).balanceOfERC20(user1);
    require(balanceAfter == 1 ether);
  }
}