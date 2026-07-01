// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Sharden is ERC20 {

    address private immutable deployer;

    address public minter;

    bool public initialized;

    constructor() ERC20("Sharden", "SHARDEN") {
        deployer = msg.sender;
    }

    function initializeMinter(address _minter) external {
        require(msg.sender == deployer, "not deployer");
        require(!initialized, "already initialized");

        initialized = true;
        minter = _minter;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == minter, "not minter");
        _mint(to, amount);
    }
}