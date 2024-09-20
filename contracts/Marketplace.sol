// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NotListed(address nftAddress, uint256 tokenId);
error NotOwner();

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
    bool active;
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
        listings[nft][id] = Listing(true,msg.sender, price, token);
        IERC721(nft).transferFrom(msg.sender, address(this), id);
        emit ItemListed(msg.sender, nft, id, price, token);
    }

    function updateListing(
        address nft,
        uint256 id,
        uint256 price,
        address token
    ) external {
        Listing storage listing = listings[nft][id];
        if (listing.seller != msg.sender) {
            revert NotOwner();
        }
        if (listing.active == false) {
            revert NotListed(nft, id);
        }
        listing.price = price;
        listing.token = token;
        emit ItemListed(msg.sender, nft, id, price, token);
    }

    function buyItem(address nft, uint256 id) external {
        Listing memory listing = listings[nft][id];
        if (listings[nft][id].active == false) {
            revert NotListed(nft, id);
        }
        IERC20(listing.token).transferFrom(
            msg.sender,
            listing.seller,
            listing.price
        );
        IERC721(nft).transferFrom(address(this), msg.sender, id);
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
