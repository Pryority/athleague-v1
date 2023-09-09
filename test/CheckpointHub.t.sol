// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {CheckpointHub} from "../src/CheckpointHub.sol";

contract CheckpointTest is Test {
    CheckpointHub public ch;

    function setUp() public {
        ch = new CheckpointHub();
    }
}
