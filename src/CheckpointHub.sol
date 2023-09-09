// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Structure to hold a checkpoint's completion information as a bitset
struct CheckpointBitset {
    uint256 data; // Bitset data
}

contract CheckpointHub {
    // Structure to represent a checkpoint
    struct Checkpoint {
        uint128 info; // Additional data reserved for each checkpoint
        uint96 packedCoordinates; // Encoded coordinate data (X, Y, sign information)
        uint16 sequence; // Sequence number of the checkpoint
        CheckpointBitset completionBitset; // Bitset for recording checkpoint completion
        bool initialized; // Flag to check if the checkpoint is initialized
    }

    // Array to store all checkpoints
    Checkpoint[] public checkpoints;

    // Owner of the contract
    address public owner;

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
    }

    // Function to add a new checkpoint
    function addCheckpoint(int32 lat, int32 long, uint128 data) public {
        require(msg.sender == owner, "Only the owner can add checkpoints.");

        // Ensure that latitude and longitude values are within the valid range
        require(lat >= -90 && lat <= 90, "Latitude out of range.");
        require(long >= -90 && long <= 90, "Longitude out of range.");

        // Create a new checkpoint with the provided parameters and initialize it
        Checkpoint memory newCheckpoint = Checkpoint({
            packedCoordinates: packCoordinates(lat, long),
            sequence: uint16(checkpoints.length),
            info: data,
            completionBitset: CheckpointBitset(0), // Initialize the completion bitset with all bits set to 0
            initialized: true
        });

        checkpoints.push(newCheckpoint); // Add the new checkpoint to the array
    }

    // Function to mark a checkpoint as completed for a racer
    function completeCheckpoint(uint256 checkpointIndex) public {
        require(
            checkpointIndex < checkpoints.length,
            "Checkpoint does not exist."
        );
        Checkpoint storage checkpoint = checkpoints[checkpointIndex];

        // Ensure that the checkpoint is initialized before marking it as completed
        require(checkpoint.initialized, "Checkpoint is not initialized.");

        // Mark the checkpoint as completed for the racer (you can replace `true` with `false` to mark it as not completed)
        setCompletionStatus(checkpoint, msg.sender, true);
    }

    // Function to get the data of a checkpoint
    function getCheckpointData(
        uint256 index
    ) public view returns (int32 lat, int32 long, uint128 data) {
        require(index < checkpoints.length, "Checkpoint does not exist.");
        (lat, long) = unpackCoordinates(checkpoints[index].packedCoordinates);
        data = checkpoints[index].info;
    }

    // Function to check if a racer has completed a checkpoint
    function hasCompletedCheckpoint(
        uint256 checkpointIndex,
        address racer
    ) public view returns (bool) {
        require(
            checkpointIndex < checkpoints.length,
            "Checkpoint does not exist."
        );
        Checkpoint storage checkpoint = checkpoints[checkpointIndex];

        // Ensure that the checkpoint is initialized before querying its completion status
        require(checkpoint.initialized, "Checkpoint is not initialized.");

        return getCompletionStatus(checkpoint, racer);
    }

    // Function to pack coordinate data into a compact format
    function packCoordinates(
        int32 lat,
        int32 long
    ) internal pure returns (uint96 packed) {
        uint32 latValue = uint32(lat);
        uint32 longValue = uint32(long);
        bool latSign = lat < 0;
        bool longSign = long < 0;

        packed = uint96(latValue);
        packed |= uint96(longValue) << 14;
        if (latSign) packed |= uint96(1) << 108; // Set the latitude sign bit
        if (longSign) packed |= uint96(1) << 109; // Set the longitude sign bit
    }

    // Function to unpack coordinate data from the compact format
    function unpackCoordinates(
        uint96 packed
    ) internal pure returns (int32 lat, int32 long) {
        uint32 latValue = uint32(packed & 0x3FFF); // Extract latitude data
        uint32 longValue = uint32((packed >> 14) & 0x3FFF); // Extract longitude data
        bool latSign = (packed >> 108) & 1 == 1; // Check the latitude sign bit
        bool longSign = (packed >> 109) & 1 == 1; // Check the longitude sign bit

        lat = int32(latSign ? -int32(latValue) : int32(latValue)); // Convert latitude back to its original value
        long = int32(longSign ? -int32(longValue) : int32(longValue)); // Convert longitude back to its original value
    }

    // Function to set the completion status for a racer at a checkpoint
    function setCompletionStatus(
        Checkpoint storage checkpoint,
        address racer,
        bool completed
    ) internal {
        require(
            checkpoint.initialized,
            "Checkpoint bitset is not initialized."
        );

        uint256 bitPosition = uint256(uint160(racer)) % 256; // Calculate the bit position based on the racer's address
        uint256 mask = uint256(1) << bitPosition; // Create a mask with the bit set to 1 at the calculated position

        if (completed) {
            checkpoint.completionBitset.data |= mask; // Set the bit to 1 (completed)
        } else {
            checkpoint.completionBitset.data &= ~mask; // Set the bit to 0 (not completed)
        }
    }

    // Function to query the completion status for a racer at a checkpoint
    function getCompletionStatus(
        Checkpoint storage checkpoint,
        address racer
    ) internal view returns (bool) {
        require(
            checkpoint.initialized,
            "Checkpoint bitset is not initialized."
        );

        uint256 bitPosition = uint256(uint160(racer)) % 256; // Calculate the bit position based on the racer's address
        uint256 mask = uint256(1) << bitPosition; // Create a mask with the bit set to 1 at the calculated position

        return (checkpoint.completionBitset.data & mask) != 0; // Check if the bit is 1 (completed)
    }
}
