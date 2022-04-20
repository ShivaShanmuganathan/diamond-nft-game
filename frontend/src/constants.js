const CONTRACT_ADDRESS = '0x9989fEc3F6aa8D9Bf7d215FB50F67812BBfb80dd';

const transformCharacterData = (characterData) => {
  return {
    name: characterData.name,
    imageURI: characterData.imageURI,
    hp: characterData.hp.toNumber(),
    maxHp: characterData.maxHp.toNumber(),
    attackDamage: characterData.attackDamage.toNumber(),
    
  };
};

export { CONTRACT_ADDRESS, transformCharacterData};

export const DIAMOND_ABI = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_contractOwner",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_diamondCutFacet",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "constructor"
  },
  {
    "stateMutability": "payable",
    "type": "fallback"
  },
  {
    "stateMutability": "payable",
    "type": "receive"
  }
]
