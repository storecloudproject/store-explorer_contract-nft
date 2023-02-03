const { task } = require("hardhat/config");
const { getContract } = require("./helpers");
const fetch = require("node-fetch");
require('dotenv').config();

const { CONTRACT_OWNER } = process.env;

task("mintNFT", "Mints from the FortMason contract").setAction(async function (
  taskArguments,
  hre
) {
  const contract = await getContract("FortMason", hre);
  const price = hre.ethers.utils.parseUnits("0.0001", "ether");
  const transactionResponse = await contract.mintNFT(
    "cloud",
    "bafkreihsrvrzscp7kp2br54kq73ys25d5g75k7vnfcrgpay3szc6nugfta",
    "storeId",
    1,
    "0x00",
    {
      value: price,
    }
  );
  console.log(`Transaction Hash:`, transactionResponse);
});

task("totalSupply", "Total Token Supply from the FortMason contract").setAction(async function (
  taskArguments,
  hre
) {
  const contract = await getContract("FortMason", hre);
  const transactionResponse = await contract.totalSupply();
  console.log(`Transaction Hash:`, transactionResponse);
});

task("safeTransferFrom", "safeTransferFrom from the FortMason contract").setAction(async function (
  taskArguments,
  hre
) {
  const contract = await getContract("FortMason", hre);
  const transactionResponse = await contract.safeTransferFrom(
    CONTRACT_OWNER,
    "0xc7cA31A8398dc5247FCe496B26B61a5eA4Ee2366",
    1,
    5,
    "0x00000000000000000000000031e7f9b72383c5ff7d91b62c361299b47348074400000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000005af3107a40000000000000000000000000000000000000000000000000000000000000000005636c6f7564000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b6261666b72656968737276727a736370376b7032627235346b7137337973323564356737356b37766e6663726770617933737a63366e75676674610000000000000000000000000000000000000000000000000000000000000000000000000773746f7265496400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a73746f7265697455726c00000000000000000000000000000000000000000000"
  );
  console.log(`Transaction Hash:`, transactionResponse);
});

task("balanceOf", "balanceOf from the FortMason contract").setAction(async function (
  taskArguments,
  hre
) {
  const contract = await getContract("FortMason", hre);
  const transactionResponse = await contract.balanceOf(
    CONTRACT_OWNER,
    1
  );
  console.log(`Transaction Hash:`, transactionResponse);
});

task("uri", "uri from the FortMason contract").setAction(async function (
  taskArguments,
  hre
) {
  const contract = await getContract("FortMason", hre);
  const transactionResponse = await contract.uri(
    1
  );
  console.log(`Transaction Hash:`, transactionResponse);
});

task(
  "getAllMintedNFTs",
  "Get List of NFT List from FortMason contract"
).setAction(async function (taskArguments, hre) {
  const contract = await getContract("FortMason", hre);
  const response = await contract.getAllMintedNFTs();
  console.log(`Response: ${response}`);
});

task(
  "getMyMintedNFTs",
  "Get List of NFT List from FortMason contract"
).setAction(async function (taskArguments, hre) {
  const contract = await getContract("FortMason", hre);
  const response = await contract.getMyMintedNFTs();
  console.log(`Response: ${response}`);
});

task(
  "set-base-token-uri",
  "Sets the base token URI for the deployed smart contract"
)
  .addParam("baseUrl", "The base of the tokenURI endpoint to set")
  .setAction(async function (taskArguments, hre) {
    const contract = await getContract("FortMason", hre);
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
    const contract = await getContract("FortMason", hre);
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
