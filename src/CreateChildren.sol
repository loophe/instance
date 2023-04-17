// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./Child1.sol";

contract CreateChildren {

    function getBytecode() internal pure returns (bytes memory) {
        bytes memory bytecode = type(Child1).creationCode;
        return bytecode;
    }

    function getAddress(
        bytes memory bytecode,
        uint _salt
    ) internal view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );
        return address (uint160(uint(hash)));
    }

    function deploy(bytes memory bytecode, uint _salt) internal returns (address){
        address addr;

        assembly {
            addr := create2(
                callvalue(),
                add(bytecode, 0x20),
                mload(bytecode),
                _salt
            )

            if iszero(extcodesize(addr)) {
                revert(0,0)
            }
        }
        return addr;
    }

}