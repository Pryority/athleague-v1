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

    // // Property-based test for checkpoint completion consistency
    // function testFuzz_CheckpointCompletionConsistency(uint96 amount) public {
    //     // Initialize your contract state and checkpoints here
    //     ch.addCheckpoint(-404040404, 808080808, 0x48656c6c6f2c20576f726c6421);
    //     // Use 'amount' or other parameters as input data
    //     // Perform actions on the contract, e.g., adding checkpoints, marking as completed, etc.
    //     // Check the property you defined, e.g., consistency in checkpoint completion
    //     // Use 'assert' or other validation mechanisms to check the property
    // }
    // Property-based test for checkpoint completion consistency
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
