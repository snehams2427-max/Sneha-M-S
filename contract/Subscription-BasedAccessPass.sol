
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Subscription-Based Access Pass
 * @notice A minimal subscription model where users pay to activate access.
 */
contract Project {
    address public owner;
    uint256 public subscriptionPrice = 0.01 ether;       // default price
    uint256 public subscriptionDuration = 30 days;       // default duration

    mapping(address => uint256) public subscriptions; // user => expiry timestamp

    event Subscribed(address indexed user, uint256 expiry);
    event SubscriptionPriceUpdated(uint256 newPrice);
    event SubscriptionDurationUpdated(uint256 newDuration);

    constructor() {
        owner = msg.sender; // no input fields required
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    /**
     * @notice Users subscribe by sending ETH equal to the subscription price.
     */
    function subscribe() external payable {
        require(msg.value == subscriptionPrice, "Incorrect subscription fee");

        uint256 currentExpiry = subscriptions[msg.sender];
        uint256 newExpiry = block.timestamp > currentExpiry
            ? block.timestamp + subscriptionDuration
            : currentExpiry + subscriptionDuration;

        subscriptions[msg.sender] = newExpiry;

        emit Subscribed(msg.sender, newExpiry);
    }

    /**
     * @notice Check if the user currently has access.
     */
    function hasActiveSubscription(address user) external view returns (bool) {
        return subscriptions[user] >= block.timestamp;
    }

    /**
     * @notice Update the subscription price (owner only).
     */
    function updateSubscriptionPrice(uint256 newPrice) external onlyOwner {
        subscriptionPrice = newPrice;
        emit SubscriptionPriceUpdated(newPrice);
    }

    /**
     * @notice Update subscription duration (owner only).
     */
    function updateSubscriptionDuration(uint256 newDuration) external onlyOwner {
        subscriptionDuration = newDuration;
        emit SubscriptionDurationUpdated(newDuration);
    }
}
