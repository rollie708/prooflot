// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Anchors asset record identifiers and evidence digests. This contract
///         makes no claim about asset ownership, document authorship, or truth.
contract ProoflotRegistry {
    struct Anchor {
        address registrar;
        bytes32 evidenceDigest;
        uint64 anchoredAt;
    }

    mapping(bytes32 => Anchor) public anchors;
    event RecordAnchored(bytes32 indexed recordId, bytes32 indexed evidenceDigest, address indexed registrar, uint64 anchoredAt);

    error EmptyRecordId();
    error EmptyDigest();
    error AlreadyAnchored();

    function anchor(bytes32 recordId, bytes32 evidenceDigest) external {
        if (recordId == bytes32(0)) revert EmptyRecordId();
        if (evidenceDigest == bytes32(0)) revert EmptyDigest();
        if (anchors[recordId].anchoredAt != 0) revert AlreadyAnchored();
        uint64 timestamp = uint64(block.timestamp);
        anchors[recordId] = Anchor(msg.sender, evidenceDigest, timestamp);
        emit RecordAnchored(recordId, evidenceDigest, msg.sender, timestamp);
    }
}
