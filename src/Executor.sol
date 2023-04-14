// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Executor {

    address internal owner;
    address internal executor;

    modifier onlyOwner {
        require(msg.sender == owner, "caller is not the owner...");
        _;
    }

    modifier onlyExecutor() {
        require(msg.sender == executor, "caller is not the executor...");
        _;
    }

    constructor (address _executor) {
        owner = msg.sender;
        executor = _executor;
    }

    function setExecutor (address _executor) external onlyOwner returns (bool){
        executor = _executor;
        return true;
    }

    function setOwner (address _owner) external onlyOwner returns (bool){
        owner = _owner;
        return true;
    }

    function getExecutor () external  view returns (address){
        return executor;
    }

    function getOwner () external view returns (address){
        return owner;
    }
}