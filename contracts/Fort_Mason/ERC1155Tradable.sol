// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./common/meta-transactions/ContentMixin.sol";
import "./common/meta-transactions/NativeMetaTransaction.sol";

contract OwnableDelegateProxy {}

/**
 * @title ERC1155Tradable
 * ERC1155Tradable - ERC1155 contract that whitelists an operator address, has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract ERC1155Tradable is
    ContextMixin,
    ERC1155,
    NativeMetaTransaction,
    Ownable
{
    using Strings for string;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    mapping (uint256 => uint256) public tokenSupply;
    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId for minted NFTs
    mapping(uint256 => MintedNFT) private idsToMintedNFT;
    // Contract name
    string public name;
    // Contract symbol
    string public symbol;

    // list of minted NFTs
    Counters.Counter private _mintedNFTs;

    //_tokenIds variable has the most recent minted tokenId
    Counters.Counter private _tokenIds;

    //The structure to store info about a listed token
    struct MintedNFT {
        uint256 tokenId;
        address payable owner;
        string ipfsId;
        string storeId;
        string cloud;
        uint256 supply;
    }

        // event for succefull minted nft
    event MintedNFTSuccess (
        uint256 indexed tokenId,
        address owner,
        string ipfsId,
        string storeId,
        string cloud,
        uint256 supply
    );
    /**
     * @dev Require _msgSender() to own more than 0 of the token id
     */
    modifier ownersOnly(uint256 _id) {
        require(
            balanceOf(_msgSender(), _id) > 0,
            "ERC1155Tradable#ownersOnly: ONLY_OWNERS_ALLOWED"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155(_uri) {
        name = _name;
        symbol = _symbol;
        _initializeEIP712(name);
    }

    function uri(uint256 _id) public view override returns (string memory) {
        require(_exists(_id), "ERC1155Tradable#uri: NONEXISTENT_TOKEN");

        return super.uri(_id);
    }

    /**
     * @dev Returns the total quantity for a token ID
     * @param _id uint256 ID of the token to query
     * @return amount of token in existence
     */
    function totalSupplyById(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

      /**
    * @dev Returns whether the specified token exists by checking to see if it has a creator
    * @param _id uint256 ID of the token to query the existence of
    * @return bool whether the token exists
    */
    function _exists(
      uint256 _id
    ) internal view returns (bool) {
      if (idsToMintedNFT[_id].tokenId == _id) return true;
        else return false;
    }

    function exists(
      uint256 _id
    ) external view returns (bool) {
      return _exists(_id);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     * @param _newURI New URI for all tokens
     */
    function setURI(string memory _newURI) public onlyOwner {
        _setURI(_newURI);
    }

    /**
     * @dev Creates a new token type and assigns _initialSupply to an address
     * NOTE: remove onlyOwner if you want third parties to create new tokens on
     *       your contract (which may change your IDs)
     * NOTE: The token id must be passed. This allows lazy creation of tokens or
     *       creating NFTs by setting the id's high bits with the method
     *       described in ERC1155 or to use ids representing values other than
     *       successive small integers. If you wish to create ids as successive
     *       small integers you can either subclass this class to count onchain
     *       or maintain the offchain cache of identifiers recommended in
     *       ERC1155 and calculate successive ids from that.
     * @param CLOUD Forever Stored On value
     * @param IPFSID Optional URI for this token type
     * @param STOREID Asset id in Store Database
     * @param SUPPLY amount to supply the first owner
     * @return The newly created token ID
     */
    function mintNFT(
      string memory CLOUD,
        string memory IPFSID,
        string memory STOREID,
        uint256 SUPPLY
    ) public payable returns (uint256) {

        require(msg.value >  0, "Hopefully sending the correct price");

        //Increment the tokenId counter, which is keeping track of the number of minted NFTs
        _tokenIds.increment();

        uint256 _id = _tokenIds.current();

        if (bytes(IPFSID).length > 0) {
            emit URI(IPFSID, _id);
        }

        _mint(msg.sender, _id, SUPPLY, "0x00");

        tokenSupply[_id] = SUPPLY;

        // add nft into mintedf list
        idsToMintedNFT[_id] = MintedNFT(
            _id,
            payable(msg.sender),
            CLOUD,
            IPFSID,
            STOREID,
            SUPPLY
            );

         //Transfer the platform fee to the marketplace creator
        payable(owner()).transfer(msg.value);

         //Emit the event for successful transfer. The frontend parses this message and updates the end user
        emit MintedNFTSuccess(
             _id,
            msg.sender,
            CLOUD,
            IPFSID,
            STOREID,
            SUPPLY);

        return _id;
    }

    /**
     * @dev Mints some amount of tokens to an address
     * @param _to          Address of the future owner of the token
     * @param _quantity    Amount of tokens to mint
     * @param _data        Data to pass if receiver is contract
     */
    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity,
        bytes memory _data
    ) public virtual {
        _mint(_to, _id, _quantity, _data);
        tokenSupply[_id] = tokenSupply[_id].add(_quantity);
    }

    /**
     * Override isApprovedForAll to whitelist user's FortMason proxy accounts to enable gas-free listings.
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view override returns (bool isOperator) {
        // Whitelist FortMason proxy contract for easy trading.
        // ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        // if (address(proxyRegistry.proxies(_owner)) == _operator) {
        //   return true;
        // }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by FortMason.
     */
    function _msgSender() internal view override returns (address sender) {
        return ContextMixin.msgSender();
    }

        function getLatestIdToMintedNFT() public view returns (MintedNFT memory) {
        uint256 currentNFTId = _tokenIds.current();
        return idsToMintedNFT[currentNFTId];
    }

    function getListedMintedNFTForId(uint256 tokenId) public view returns (MintedNFT memory) {
        return idsToMintedNFT[tokenId];
    }

    function getCurrentNFT() public view returns (uint256) {
        return _tokenIds.current();
    }

         //This will return all the NFTs currently listed to be sold on the marketplace
    function getAllMintedNFTs() public view returns (MintedNFT[] memory) {
        uint nftCount = _tokenIds.current();
        MintedNFT[] memory tokens = new MintedNFT[](nftCount);
        uint currentIndex = 0;
        uint currentId;
        //at the moment currentlyListed is true for all, if it becomes false in the future we will
        //filter out currentlyListed == false over here
        for(uint i=0;i<nftCount;i++)
        {
            currentId = i + 1;
            MintedNFT storage currentItem = idsToMintedNFT[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        //the array 'tokens' has the list of all NFTs in the marketplace
        return tokens;
    }

    //Returns all the NFTs that the current user is owner or seller in
    function getMyMintedNFTs() public view returns (MintedNFT[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        uint currentId;
        //Important to get a count of all the NFTs that belong to the user before we can make an array for them
        for(uint i=0; i < totalItemCount; i++)
        {
            if(idsToMintedNFT[i+1].owner == msg.sender){
                itemCount += 1;
            }
        }

        //Once you have the count of relevant NFTs, create an array then store all the NFTs in it
        MintedNFT[] memory nfts = new MintedNFT[](itemCount);
        for(uint i=0; i < totalItemCount; i++) {
            if(idsToMintedNFT[i+1].owner == msg.sender) {
                currentId = i+1;
                MintedNFT storage currentItem = idsToMintedNFT[currentId];
                nfts[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return nfts;
    }
}
