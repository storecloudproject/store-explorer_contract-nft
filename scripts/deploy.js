const { task } = require("hardhat/config");
const { getAccount } = require("./helpers");
const fs = require("fs");


task("deploy", "Deploys the STORE_NFT_Marketplace.sol contract").setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory("STORE_NFT_Marketplace", getAccount());
    const nft = await nftContractFactory.deploy();
    console.log(`Contract deployed to address: ${nft.address}`);

    const data = {
      address: nft.address,
      abi: JSON.parse(nft.interface.format('json'))
    }

    //This writes the ABI and address to the mktplace.json
    fs.writeFileSync('./abi/STORE_NFT_Marketplace.json', JSON.stringify(data))
});
