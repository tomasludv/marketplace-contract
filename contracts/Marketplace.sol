// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NotListed(address nftAddress, uint256 tokenId);
error NotOwner();
error PriceMustBeAboveZero();

event ListingCreated(
    address indexed seller,
    address indexed nft,
    uint256 indexed id,
    uint256 price,
    address token
);

event ListingUpdated(
    address indexed seller,
    address indexed nft,
    uint256 indexed id,
    uint256 price,
    address token
);

event ListingCanceled(
    address indexed seller,
    address indexed nft,
    uint256 indexed id
);

event ListingBought(
    address indexed buyer,
    address indexed nft,
    uint256 indexed id,
    uint256 price,
    address token
);

struct Listing {
    address seller;
    uint256 price;
    address token;
}

contract Marketplace {
    mapping(address => mapping(uint256 => Listing)) private listings;

    function createListing(
        address nft,
        uint256 id,
        uint256 price,
        address token
    ) external {
        if (price == 0) {
            revert PriceMustBeAboveZero();
        }
        listings[nft][id] = Listing(msg.sender, price, token);
        IERC721(nft).transferFrom(msg.sender, address(this), id);
        emit ListingCreated(msg.sender, nft, id, price, token);
    }

    function updateListing(
        address nft,
        uint256 id,
        uint256 price,
        address token
    ) external {
        Listing storage listing = listings[nft][id];
        if (price == 0) {
            revert PriceMustBeAboveZero();
        }
        if (listing.price == 0) {
            revert NotListed(nft, id);
        }
        if (listing.seller != msg.sender) {
            revert NotOwner();
        }
        listing.price = price;
        listing.token = token;
        emit ListingUpdated(msg.sender, nft, id, price, token);
    }

    function cancelListing(address nft, uint256 id)external{
        Listing memory listing = listings[nft][id];
        if (listing.price == 0) {
            revert NotListed(nft, id);
        }
        if (listing.seller != msg.sender) {
            revert NotOwner();
        }
        IERC721(nft).transferFrom(address(this), listing.seller, id);
        delete listings[nft][id];
        emit ListingCanceled(msg.sender, nft, id);
}

    function buyListing(address nft, uint256 id) external {
        Listing memory listing = listings[nft][id];
        if (listing.price == 0) {
            revert NotListed(nft, id);
        }
        IERC20(listing.token).transferFrom(
            msg.sender,
            listing.seller,
            listing.price
        );
        IERC721(nft).transferFrom(address(this), msg.sender, id);
        delete (listings[nft][id]);
        emit ListingBought(msg.sender, nft, id, listing.price, listing.token);
    }

     function getListing(address nft, uint256 id)
        external
        view
        returns (uint256 price , address token)
    {
        Listing memory listing = listings[nft][id];
        return (listing.price,listing.token);
    }
}
