// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/CreateChildren.sol";

contract CreateTest is Test {

    address public xMEEB = 0x11Df658567e615f69D23289BE8A27a9C260cE297;
    address public xPUNK = 0x08765C76C758Da951DC73D3a8863B34752Dd76FB;

    CreateChildren cc;
    // address owner = 0x08908a69D3Ff4C42DcF5ddA856e25f3602e7f37A;

    function setUp() public {
        cc = new CreateChildren();
      
    }


    function testGetCode() public {
        // console.log("bytecode :");
        // bytes memory bytecode = cc.getBytecode();
        // console.logBytes(bytecode);
        // address childAddress = cc.getAddress(bytecode, 123);
        // console.log(childAddress);
        // deal(xMEEB,childAddress,2582605254356706947);
        // deal(xPUNK,childAddress,393390822776929879);
        // address childAddressa = cc.deploy(bytecode, 123);
        // console.log(childAddressa);
    }



}