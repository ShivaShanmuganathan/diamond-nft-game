require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require('solidity-coverage')
require("hardhat-gas-reporter");
require("hardhat-diamond-abi");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
  
});

function filterDuplicateFunctions(abiElement, index, fullAbi, fullyQualifiedName) {

  
  if(abiElement.type !== "event") {
    return false
  }

  if(abiElement.name !== "approve") {
    return false
  }
  
  return true;

}

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: '0.8.1',
  diamondAbi: {
    // (required) The name of your Diamond ABI
    name: "dynamicGame",
    filter: function (abiElement, index, fullAbi, fullyQualifiedName) {

      if(abiElement.name === "Approval"){
        return false;
      }

      if(abiElement.name === "ApprovalForAll"){
        return false;
      }

      if(abiElement.name === "Transfer"){
        return false;
      }

      if(abiElement.name === "approve"){
        return false;
      }

      if(abiElement.name === "getApproved"){
        return false;
      }

      if(abiElement.name === "isApprovedForAll"){
        return false;
      }

      if(abiElement.name === "setApprovalForAll"){
        return false;
      }

      if(abiElement.name === "supportsInterface"){
        return false;
      }

      if(abiElement.name === "balanceOf"){
        return false;
      }

      if(abiElement.name === "ownerOf"){
        return false;
      }

      if(abiElement.name === "safeTransferFrom"){
        return false;
      }

      if(abiElement.name === "transferFrom"){
        return false;
      }

      if(abiElement.name === "name"){
        return false;
      }

      if(abiElement.name === "symbol"){
        return false;
      }

      if(abiElement.name === "tokenURI"){
        return false;
      }

      console.log(abiElement);

      return true;
      
    },
    
  },
  networks: {
    // rinkeby: {
    //   url: process.env.STAGING_ALCHEMY_KEY,
    //   accounts: [process.env.PRIVATE_KEY],
    // }
    localhost: {
      chainId: 31337
    }
    
  },
};
