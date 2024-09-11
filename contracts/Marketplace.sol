// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NotOwner();
error NotApprovedForMarketplace();
error PriceMustBeAboveZero();

event ItemListed(
    address indexed seller,
    address indexed nft,
    uint256 indexed id,
    uint256 price,
    address token
);

event ItemCanceled(
    address indexed seller,
    address indexed nft,
    uint256 indexed id
);

event ItemBought(
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

    function listItem(
        address nft,
        uint256 id,
        uint256 price,
        address token
    ) external {
        if (price == 0) {
            revert PriceMustBeAboveZero();
        }
        if (msg.sender != IERC721(nft).ownerOf(id)) {
            revert NotOwner();
        }
        if (listings[nft][id].price > 0) {
            revert AlreadyListed(nft, id);
        }
        if (IERC721(nft).getApproved(id) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        listings[nft][id] = Listing(msg.sender, price, token);
        emit ItemListed(msg.sender, nft, id, price, token);
    }

    function updateListing(
        address nft,
        uint256 id,
        uint256 price,
        address token
    ) external {
        if (price == 0) {
            revert PriceMustBeAboveZero();
        }
        if (msg.sender != IERC721(nft).ownerOf(id)) {
            revert NotOwner();
        }
        if (listings[nft][id].price == 0) {
            revert NotListed(nft, id);
        }
        Listing storage listing = listings[nft][id];
        listing.price = price;
        listing.token = token;
        emit ItemListed(msg.sender, nft, id, price, token);
    }

    function buyItem(address nft, uint256 id) external {
        if (listings[nft][id].price == 0) {
            revert NotListed(nft, id);
        }
        Listing memory listing = listings[nft][id];
        IERC20(listing.token).transferFrom(
            msg.sender,
            listing.seller,
            listing.price
        );
        IERC721(nft).safeTransferFrom(listing.seller, msg.sender, id);
        delete (listings[nft][id]);
        emit ItemBought(msg.sender, nft, id, listing.price, listing.token);
    }

    function getListing(address nft, uint256 id)
        external
        view
        returns (Listing memory)
    {
        return listings[nft][id];
    }
}
