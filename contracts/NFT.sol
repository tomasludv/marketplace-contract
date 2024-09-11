// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    constructor() ERC721("Test NFT", "TESTNFT") {}

    function mint(uint256 id)public {
        _mint(msg.sender,id);
    }
}
