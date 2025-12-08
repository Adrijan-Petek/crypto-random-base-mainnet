// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title RandomVRFGame
 * @notice Example contract that uses Chainlink VRF v2 to request secure on-chain randomness.
 * @dev This example is configured for the Base mainnet network. Always verify VRF
 *      coordinator, keyHash, and subscription settings against the official Chainlink docs
 *      before deploying to production.
 */

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/VRFCoordinatorV2Interface.sol";

contract RandomVRFGame is VRFConsumerBaseV2 {
    /// @notice Emitted when a new randomness request is sent to the VRF coordinator
    event RandomWordsRequested(uint256 indexed requestId, address indexed requester);

    /// @notice Emitted when random words have been fulfilled and stored
    event RandomWordsFulfilled(uint256 indexed requestId, uint256[] randomWords);

    /// @notice Emitted when a random number in a given range is generated
    event RandomInRangeGenerated(uint256 indexed requestId, uint256 indexed result, uint256 maxExclusive);

    VRFCoordinatorV2Interface public immutable COORDINATOR;

    // VRF configuration (these values MUST be verified and possibly updated)
    uint64 public subscriptionId;       // Chainlink VRF subscription ID
    bytes32 public keyHash;            // Gas lane key hash
    uint16 public requestConfirmations = 3;
    uint32 public callbackGasLimit = 200_000;
    uint32 public numWords = 1;

    // last request data
    uint256 public lastRequestId;
    mapping(uint256 => uint256[]) public requestIdToRandomWords;
    mapping(uint256 => address) public requestIdToRequester;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        require(_vrfCoordinator != address(0), "Invalid coordinator");
        owner = msg.sender;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    /**
     * @notice Request a new set of random words from Chainlink VRF.
     * @dev Anyone can call this in this simple example, but many apps will restrict this.
     */
    function requestRandomWords() external returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        lastRequestId = requestId;
        requestIdToRequester[requestId] = msg.sender;

        emit RandomWordsRequested(requestId, msg.sender);
    }

    /**
     * @dev VRF callback function. The VRF coordinator calls this after the random
     *      words have been generated. Never call this manually.
     */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        requestIdToRandomWords[_requestId] = _randomWords;
        emit RandomWordsFulfilled(_requestId, _randomWords);
    }

    /**
     * @notice Returns a pseudo-random number in [0, maxExclusive) using a fulfilled request.
     * @dev This does not make a new VRF request. It uses the stored random word.
     */
    function getRandomInRange(uint256 requestId, uint256 maxExclusive) external returns (uint256) {
        require(maxExclusive > 0, "maxExclusive must be > 0");
        uint256[] memory words = requestIdToRandomWords[requestId];
        require(words.length > 0, "Random words not ready");

        uint256 result = words[0] % maxExclusive;
        emit RandomInRangeGenerated(requestId, result, maxExclusive);
        return result;
    }

    // --------- Admin config ---------

    function setSubscriptionId(uint64 _subscriptionId) external onlyOwner {
        subscriptionId = _subscriptionId;
    }

    function setKeyHash(bytes32 _keyHash) external onlyOwner {
        keyHash = _keyHash;
    }

    function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
        callbackGasLimit = _callbackGasLimit;
    }

    function setNumWords(uint32 _numWords) external onlyOwner {
        require(_numWords > 0 && _numWords <= 10, "Invalid numWords");
        numWords = _numWords;
    }

    function setRequestConfirmations(uint16 _confirmations) external onlyOwner {
        require(_confirmations >= 3 && _confirmations <= 200, "Invalid confirmations");
        requestConfirmations = _confirmations;
    }
}
