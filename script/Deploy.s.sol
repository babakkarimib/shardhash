// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import "../src/Sharden.sol";
import "../src/Shardhash.sol";

contract Deploy is Script {

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        Sharden token = new Sharden();

        Shardhash shardhash = new Shardhash(address(token));

        token.initializeMinter(address(shardhash));

        vm.stopBroadcast();

        console2.log("Sharden:", address(token));
        console2.log("Shardhash:", address(shardhash));
    }
}