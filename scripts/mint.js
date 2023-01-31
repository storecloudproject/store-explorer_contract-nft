const { task } = require("hardhat/config");
const { getContract } = require("./helpers");
const fetch = require("node-fetch");

task("mintNFT", "Mints from the STORE_NFT_Marketplace contract")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract("STORE_NFT_Marketplace", hre);
    const price = hre.ethers.utils.parseUnits("0.0001", 'ether');
    const transactionResponse = await contract.
    mintNFT(
    'cloud',
    "bafkreihsrvrzscp7kp2br54kq73ys25d5g75k7vnfcrgpay3szc6nugfta",
    'storeId',
    'storeitUrl',
    1,
    price,
    {
      gasLimit: 500_000,
      value: price
    });
    console.log(`Transaction Hash:`,transactionResponse);
  });

  task("getAllMintedNFTs", "Get List of NFT List from STORE_NFT_Marketplace contract")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract("STORE_NFT_Marketplace", hre);
    const response = await contract.getAllMintedNFTs();
    console.log(`Response: ${response}`);
  });

  task("getMyMintedNFTs", "Get List of NFT List from STORE_NFT_Marketplace contract")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract("STORE_NFT_Marketplace", hre);
    const response = await contract.getMyMintedNFTs();
    console.log(`Response: ${response}`);
  });

task(
  "set-base-token-uri",
  "Sets the base token URI for the deployed smart contract"
)
  .addParam("baseUrl", "The base of the tokenURI endpoint to set")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract("STORE_NFT_Marketplace", hre);
    const transactionResponse = await contract.setBaseTokenURI(
      taskArguments.baseUrl,
      {
        gasLimit: 500_000,
      }
    );
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
  });

task("token-uri", "Fetches the token metadata for the given token ID")
  .addParam("tokenId", "The tokenID to fetch metadata for")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract("STORE_NFT_Marketplace", hre);
    const response = await contract.tokenURI(taskArguments.tokenId, {
      gasLimit: 500_000,
    });

    const metadata_url = response;
    console.log(`Metadata URL: ${metadata_url}`);

    const metadata = await fetch(metadata_url).then((res) => res.json());
    console.log(
      `Metadata fetch response: ${JSON.stringify(metadata, null, 2)}`
    );
  });

