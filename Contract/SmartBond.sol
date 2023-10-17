// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract SmartBond {
    address public issuer;
    uint256 public constant PRINCIPAL_AMOUNT = 100 ether; // Using "ether" for simplicity, but represents principal units.
    uint256 public constant COUPON_RATE = 2; // Represented as a percentage.
    uint256 public constant MATURITY_PERIOD = 3 years;
   uint256 public constant PAYMENT_FREQUENCY = 1 years;
    uint256 public bondBoughtDate;
    bool public bondFullySubscribed = false;
 
    mapping(address => uint256) public bondholders;
    uint256 public totalInvested;
 
    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer can call this function");
        _;
    }
 
    modifier notFullySubscribed() {
        require(!bondFullySubscribed, "Bond is already fully subscribed");
        _;
    }
 
    constructor() {
        issuer = msg.sender;
    }
 
    function buyBond() external payable notFullySubscribed {
        require(totalInvested + msg.value <= PRINCIPAL_AMOUNT, "Cannot invest more than the principal amount");
 
        bondholders[msg.sender] += msg.value;
        totalInvested += msg.value;
 
        if (totalInvested == PRINCIPAL_AMOUNT) {
            bondFullySubscribed = true;
            bondBoughtDate = block.timestamp;
        }
    }
 
    function payCoupon() external onlyIssuer {
        require(bondFullySubscribed, "Bond not fully subscribed yet");
        require(block.timestamp >= bondBoughtDate + PAYMENT_FREQUENCY, "Coupon payment not due yet");
 
        for (address bondholder : bondholders) {
            uint256 couponPayment = (bondholders[bondholder] * COUPON_RATE) / 100;
            payable(bondholder).transfer(couponPayment);
        }
 
        bondBoughtDate += PAYMENT_FREQUENCY; // Reset the bond bought date for the next payment cycle.
    }
 
    function redeemBond() external {
        require(bondFullySubscribed, "Bond not fully subscribed yet");
        require(block.timestamp >= bondBoughtDate + MATURITY_PERIOD, "Bond not matured yet");
 
        uint256 principalAmount = bondholders[msg.sender];
        bondholders[msg.sender] = 0; // Reset the bondholder's balance to avoid re-entrancy.
        payable(msg.sender).transfer(principalAmount);
    }
}
