// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

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

    // storeit URl
    mapping(uint256 => string) private _storeitURLs;

    /// @dev Base token URI used as a prefix by tokenURI().
    string public baseTokenURI;

    constructor() ERC721("STORE_Explorer_Test", "STR") {
       baseTokenURI = "";
    }

    function safeMint(address to, string memory uri,string memory storeiturl)
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
        _setStoreit(newItemId, storeiturl);
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
      /// @dev Returns an URI for a given token ID
      function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
      }

      /// @dev Sets the base token URI prefix.
      function setBaseTokenURI(string memory _baseTokenURI) public {
        baseTokenURI = _baseTokenURI;
    }

    function _setStoreit(uint256 tokenId, string memory _storeitURL) internal virtual {
        require(_exists(tokenId), "STOREITStorage: URI set of nonexistent token");
        _storeitURLs[tokenId] = _storeitURL;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function storeitURL(uint256 tokenId) public view virtual returns (string memory) {
        _requireMinted(tokenId);
        string memory __storeitURL = _storeitURLs[tokenId];
        return __storeitURL;
    }
}
