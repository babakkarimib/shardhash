// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Sharden.sol";

contract Shardhash {

    Sharden public immutable token;

    mapping(uint256 => mapping(uint8 => bool)) public claimed;

    event Claimed(uint256 round, address miner, uint8 tier, uint256 reward);

    constructor(address tokenAddr) {
        token = Sharden(tokenAddr);
    }

    function claim(uint256 round, uint256 nonce) external {
        require(round == block.number - 1, "invalid round");

        bytes32 challenge = getChallenge(round);

        bytes32 candidate = keccak256(
            abi.encodePacked(challenge, round, msg.sender, nonce)
        );

        uint8 tier = matchSuffix(candidate, challenge);

        require(tier >= 10, "no reward");
        require(!claimed[round][tier], "already claimed");

        claimed[round][tier] = true;

        uint256 reward = rewardOf(tier);

        token.mint(msg.sender, reward);

        emit Claimed(round, msg.sender, tier, reward);
    }

    function getChallenge(uint256 round) internal view returns (bytes32) {
        bytes memory data = new bytes(512);

        for (uint256 i = 0; i < 16; ++i) {
            bytes32 h = blockhash(round - 1 - i);

            assembly {
                mstore(add(add(data, 32), mul(i, 32)), h)
            }
        }

        return keccak256(data);
    }

    function matchSuffix(bytes32 candidate, bytes32 challenge) internal pure returns (uint8) {
        uint256 c = uint256(candidate);
        uint256 h = uint256(challenge);

        uint8 count = 0;

        for (uint8 i = 0; i < 64; ++i) {
            if ((c & 0xF) != (h & 0xF)) {
                return count;
            }

            count++;
            c >>= 4;
            h >>= 4;
        }

        return count;
    }

    function rewardOf(uint8 n) internal pure returns (uint256) {
        uint256 reward = 1;

        for (uint8 i = 10; i < n; ++i) {
            reward *= 10;
        }

        return reward;
    }
}