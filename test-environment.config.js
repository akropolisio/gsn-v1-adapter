const { utils, GSNDevProvider } = require("@openzeppelin/gsn-provider");
const { accounts, web3 } = require("@openzeppelin/test-environment");

const approveFunction = async ({
  from,
  to,
  encodedFunctionCall,
  txFee,
  gasPrice,
  gas,
  nonce,
  relayerAddress,
  relayHubAddress,
}) => {
  const hash = web3.utils.soliditySha3(
    from,
    to,
    encodedFunctionCall,
    txFee,
    gasPrice,
    gas,
    nonce,
    relayerAddress,
    relayHubAddress,
  );
  const signature = await web3.eth.sign(hash, signer);
  return utils.fixSignature(signature); // this takes care of removing signature malleability attacks
};

module.exports = {
  accounts: {
    ether: 1e6,
  },

  contracts: {
    type: "truffle",
  },

  setupProvider: (baseProvider) => {
    return new GSNDevProvider(baseProvider, {
      txfee: 70,
      useGSN: false,
      ownerAddress: accounts[8],
      relayerAddress: accounts[9],
      approveFunction,
    });
  },
};
