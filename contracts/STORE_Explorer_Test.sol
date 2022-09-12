// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/// @custom:security-contact sohaibahsan007@live.com
contract STORE_Explorer_Test is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    // Constants
    uint256 public constant TOTAL_SUPPLY = 100000;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private currentTokenId;

    constructor() ERC721("STORE_Explorer_Test", "STR") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/";
    }

    function safeMint(address to, string memory uri)
        public
        payable
        returns (uint256)
    {
        uint256 tokenId = currentTokenId.current();
        require(tokenId < TOTAL_SUPPLY, "Max supply reached");

        currentTokenId.increment();

        uint256 newItemId = currentTokenId.current();

        _safeMint(to, newItemId);
        _setTokenURI(newItemId, uri);
        return newItemId;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
