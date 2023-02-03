//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.8;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Fort_Mason_Marketplace is ERC721URIStorage {

    using Counters for Counters.Counter;
    //_tokenIds variable has the most recent minted tokenId
    Counters.Counter private _tokenIds;
    // //Keeps track of the number of nfts sold on the marketplace
    // Counters.Counter private _nftsSold;

    //Keeps track of the number of nfts sold on the marketplace
    Counters.Counter private _mintedNFTs;
    //owner is the contract address that created the smart contract
    address payable owner;

        //The structure to store info about a listed token
    struct MintedNFT {
        uint256 tokenId;
        address payable owner;
        string cloud;
        string ipfsId;
        string storeId;
        string storeitUrl;
        uint256 supply;
        uint256 price;
    }

    // //The structure to store info about a listed token
    // struct NFTForSale {
    //     uint256 tokenId;
    //     address payable owner;
    //     address payable seller;
    //     uint256 price;
    //     bool currentlyListed;
    // }

    // //the event emitted when a token is successfully listed
    // event NFTForSaleSuccess (
    //     uint256 indexed tokenId,
    //     address owner,
    //     address seller,
    //     uint256 price,
    //     bool currentlyListed
    // );

    // event for succefull minted nft
    event MintedNFTSuccess (
        uint256 indexed tokenId,
        address owner,
        string ipfsId,
        string storeId,
        string cloud,
        string storeitUrl,
        uint256 supply,
        uint256 price
    );

    // //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId
    // mapping(uint256 => NFTForSale) private idsToNFTForSale;

    //This mapping maps tokenId to token info and is helpful when retrieving details about a tokenId for minted NFTs
    mapping(uint256 => MintedNFT) private idsToMintedNFT;

    constructor() ERC721("Fort_Mason_Marketplace_v0.0.1-beta", "STRMPv0.0.1-beta") {
        owner = payable(msg.sender);
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

    // mint NFT here.
    // use transaction value to transfer to the contract owner.
    function mintNFT(string memory cloud, string memory ipfsId,string memory storeId, string memory storeitUrl,uint256 supply,uint256 price) public payable returns (uint) {

        require(msg.value >  0, "Hopefully sending the correct price");
        //Increment the tokenId counter, which is keeping track of the number of minted NFTs
        _tokenIds.increment();

        uint256 newNFTId = _tokenIds.current();

        //Mint the NFT with tokenId newNFTId to the address who called mintNFT
        _safeMint(msg.sender, newNFTId);

        //Map the tokenId to the tokenURI (which is an IPFS URL with the NFT metadata)
        _setTokenURI(newNFTId, ipfsId);

        //Transfer the platform fee to the marketplace creator
        payable(owner).transfer(msg.value);

        // add nft into mintedf list
        idsToMintedNFT[newNFTId] = MintedNFT(
            newNFTId,
            payable(msg.sender),
            cloud,
            ipfsId,
            storeId,
            storeitUrl,
            supply,
            price);

        //Emit the event for successful transfer. The frontend parses this message and updates the end user
        emit MintedNFTSuccess(
            newNFTId,
            msg.sender,
            cloud,
            ipfsId,
            storeId,
            storeitUrl,
            supply,
            price);

        return newNFTId;
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

    // function getLatestIdToListedForSaleNFT() public view returns (NFTForSale memory) {
    //     uint256 currentNFTId = _tokenIds.current();
    //     return idsToNFTForSale[currentNFTId];
    // }

    // function getListedForSaleNFTForId(uint256 tokenId) public view returns (NFTForSale memory) {
    //     return idsToNFTForSale[tokenId];
    // }
    // // this will list token/nft for sale.
    // function createListedForSaleNFT(uint256 tokenId, uint256 price) private {
    //     //Make sure the sender sent enough ETH to pay for listing
    //     require(msg.value == fee, "Hopefully sending the correct price");
    //     //Just sanity check
    //     require(price > 0, "Make sure the price isn't negative");

    //     //Update the mapping of tokenId's to NFT details, useful for retrieval functions
    //     idsToNFTForSale[tokenId] = NFTForSale(
    //         tokenId,
    //         payable(address(this)),
    //         payable(msg.sender),
    //         price,
    //         true
    //     );

    //     _transfer(msg.sender, address(this), tokenId);
    //     //Emit the event for successful transfer. The frontend parses this message and updates the end user
    //     emit NFTForSaleSuccess(
    //         tokenId,
    //         address(this),
    //         msg.sender,
    //         price,
    //         true
    //     );
    // }

    // //This will return all the NFTs currently listed to be sold on the marketplace
    // function getAllNFTs() public view returns (NFTForSale[] memory) {
    //     uint nftCount = _tokenIds.current();
    //     NFTForSale[] memory tokens = new NFTForSale[](nftCount);
    //     uint currentIndex = 0;
    //     uint currentId;
    //     //at the moment currentlyListed is true for all, if it becomes false in the future we will
    //     //filter out currentlyListed == false over here
    //     for(uint i=0;i<nftCount;i++)
    //     {
    //         currentId = i + 1;
    //         NFTForSale storage currentItem = idsToNFTForSale[currentId];
    //         tokens[currentIndex] = currentItem;
    //         currentIndex += 1;
    //     }
    //     //the array 'tokens' has the list of all NFTs in the marketplace
    //     return tokens;
    // }

    // //Returns all the NFTs that the current user is owner or seller in
    // function getMyNFTs() public view returns (NFTForSale[] memory) {
    //     uint totalItemCount = _tokenIds.current();
    //     uint itemCount = 0;
    //     uint currentIndex = 0;
    //     uint currentId;
    //     //Important to get a count of all the NFTs that belong to the user before we can make an array for them
    //     for(uint i=0; i < totalItemCount; i++)
    //     {
    //         if(idsToNFTForSale[i+1].owner == msg.sender || idsToNFTForSale[i+1].seller == msg.sender){
    //             itemCount += 1;
    //         }
    //     }

    //     //Once you have the count of relevant NFTs, create an array then store all the NFTs in it
    //     NFTForSale[] memory nfts = new NFTForSale[](itemCount);
    //     for(uint i=0; i < totalItemCount; i++) {
    //         if(idsToNFTForSale[i+1].owner == msg.sender || idsToNFTForSale[i+1].seller == msg.sender) {
    //             currentId = i+1;
    //             NFTForSale storage currentItem = idsToNFTForSale[currentId];
    //             nfts[currentIndex] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }
    //     return nfts;
    // }

    // function executeSale(uint256 tokenId) public payable {
    //     uint price = idsToNFTForSale[tokenId].price;
    //     address seller = idsToNFTForSale[tokenId].seller;
    //     require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    //     //update the details of the token
    //     idsToNFTForSale[tokenId].currentlyListed = true;
    //     idsToNFTForSale[tokenId].seller = payable(msg.sender);
    //     _nftsSold.increment();

    //     //Actually transfer the token to the new owner
    //     _transfer(address(this), msg.sender, tokenId);
    //     //approve the marketplace to sell NFTs on your behalf
    //     approve(address(this), tokenId);

    //     //Transfer the listing fee to the marketplace creator
    //     payable(owner).transfer(fee);
    //     //Transfer the proceeds from the sale to the seller of the NFT
    //     payable(seller).transfer(msg.value);
    // }

    //We might add a resell token function in the future
    //In that case, tokens won't be listed by default but users can send a request to actually list a token
    //Currently NFTs are listed by default
}
