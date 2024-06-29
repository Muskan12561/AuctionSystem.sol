// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionSystem {
    address public owner;
    uint public highestBid;
    address public highestBidder;
    bool public auctionFinalized;
    mapping(address => uint) public bids;

    event NewBid(address indexed bidder, uint amount);
    event AuctionFinalized(address winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier notOwner() {
        require(msg.sender != owner, "Owner cannot bid in the auction");
        _;
    }

    modifier auctionNotFinalized() {
        require(!auctionFinalized, "Auction has already been finalized");
        _;
    }

    constructor() {
        owner = msg.sender;
        highestBid = 0;
        highestBidder = address(0);
        auctionFinalized = false;
    }

    function placeBid() public payable notOwner auctionNotFinalized {
        require(msg.value > 0, "Bid amount must be greater than zero");
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");

        if (bids[msg.sender] > 0) {
            // Refund the previous bid
            payable(msg.sender).transfer(bids[msg.sender]);
        }

        bids[msg.sender] = msg.value;
        highestBid = msg.value;
        highestBidder = msg.sender;

        emit NewBid(msg.sender, msg.value);
    }

    function finalizeAuction() public onlyOwner auctionNotFinalized {
        require(highestBidder != address(0), "No bids placed");

        auctionFinalized = true;

        // Transfer the highest bid to the owner
        payable(owner).transfer(highestBid);

        emit AuctionFinalized(highestBidder, highestBid);

        // Ensure the auction is marked as finalized
        assert(auctionFinalized == true);
    }

    function withdrawBid() public auctionNotFinalized {
        uint bidAmount = bids[msg.sender];
        require(bidAmount > 0, "No bid to withdraw");

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bidAmount);
    }
}
