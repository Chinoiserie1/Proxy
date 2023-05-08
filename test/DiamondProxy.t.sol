// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/Diamond/upgradeInitializers/DiamondInit.sol";
import "../src/Diamond/Diamond.sol";
import "../src/Diamond/facets/DiamondCutFacet.sol";
import "../src/Diamond/facets/DiamondLoupeFacet.sol";
import "../src/Diamond/facets/OwnershipFacet.sol";

import { IDiamond } from "../src/Diamond/interfaces/IDiamond.sol";

contract DiamondProxyTest is Test {
  DiamondInit public initDiamond;
  OwnershipFacet public facetOwnership;
  DiamondLoupeFacet public facetDiamondLoupe;
  DiamondCutFacet public facetDiamondCut;
  Diamond public diamond;

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
    // console.log();
    diamond = new Diamond(faceCut, args);
  }

  function testInit() public {
    console.log("ok");
  }
}