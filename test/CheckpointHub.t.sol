// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {CheckpointHub} from "../src/CheckpointHub.sol";

contract CheckpointTest is Test {
    CheckpointHub public ch;
    address owner;
    address bob;

    function setUp() public {
        ch = new CheckpointHub();
        owner = msg.sender;
        bob = makeAddr("B0B");
    }

    // Property-based test for checkpoint completion consistency
    function testFuzz_CheckpointCompletionConsistency(
        int32 lat,
        int32 long,
        uint128 data,
        address racer
    ) public {
        // Initialize your contract state and checkpoints here
        vm.assume(lat >= -90);
        require(lat >= -90);
        vm.assume(lat <= 90);
        require(lat <= 90);
        vm.assume(long >= -90);
        require(long >= -90);
        vm.assume(long <= 90);
        require(long <= 90);
        ch.addCheckpoint(lat, long, data);

        vm.startPrank(racer);
        vm.assume(racer != owner);
        ch.completeCheckpoint(0);
        vm.expectRevert("Only the owner can add checkpoints.");
        ch.addCheckpoint(lat, long, data);
        vm.stopPrank();
    }

    // Property-based test for adding a checkpoint
    function testFuzz_AddCheckpoint(
        int32 lat,
        int32 long,
        uint128 data
    ) public {
        // Initialize your contract state and checkpoints here
        vm.assume(lat >= -90);
        require(lat >= -90);
        vm.assume(lat <= 90);
        require(lat <= 90);
        vm.assume(long >= -90);
        require(long >= -90);
        vm.assume(long <= 90);
        require(long <= 90);
        ch.addCheckpoint(lat, long, data);
    }
}
