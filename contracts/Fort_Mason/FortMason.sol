// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155Tradable.sol";

/**
 * @title FortMason
 * FortMason - a contract for my non-fungible nfts.
 */
contract FortMason is ERC1155Tradable {
    constructor()
        ERC1155Tradable(
            "FortMason Marketplace",
            "FMM_v0.0.1-beta",
            "http://localhost:8080/{id}")
    {}

    function contractURI() public pure returns (string memory) {
        return "http://localhost:4200/";
    }
}
