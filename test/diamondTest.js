/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai')



const transformCharacterData = (characterData) => {
  return {
    name: characterData.name,
    imageURI: characterData.imageURI,
    hp: characterData.hp.toNumber(),
    maxHp: characterData.maxHp.toNumber(),
    attackDamage: characterData.attackDamage.toNumber(),
    
  };
};

describe('DiamondTest', async function () {
  let diamondAddress
  let diamondCutFacet
  let diamondLoupeFacet
  let ownershipFacet
  let tx
  let receipt
  let result
  const addresses = []
  let owner, addr1, addr2;

  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    diamondAddress = await deployDiamond()
    diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)
    ownershipFacet = await ethers.getContractAt('OwnershipFacet', diamondAddress)
  })

  it('should have three facets -- call to facetAddresses function', async () => {
    for (const address of await diamondLoupeFacet.facetAddresses()) {
      addresses.push(address)
    }

    assert.equal(addresses.length, 3)
  })

  it('facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
    let selectors = getSelectors(diamondCutFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(diamondLoupeFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[1])
    assert.sameMembers(result, selectors)
    selectors = getSelectors(ownershipFacet)
    result = await diamondLoupeFacet.facetFunctionSelectors(addresses[2])
    assert.sameMembers(result, selectors)
  })

  it('selectors should be associated to facets correctly -- multiple calls to facetAddress function', async () => {
    assert.equal(
      addresses[0],
      await diamondLoupeFacet.facetAddress('0x1f931c1c')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0xcdffacc6')
    )
    assert.equal(
      addresses[1],
      await diamondLoupeFacet.facetAddress('0x01ffc9a7')
    )
    assert.equal(
      addresses[2],
      await diamondLoupeFacet.facetAddress('0xf2fde38b')
    )
  })

  describe('Deploy DynamicGameFacet & Test Constructor Args()', function () { 

    it('should add dynamic game facet', async () => {

      const DynamicGameFacet = await ethers.getContractFactory('DynamicGameFacet')
      const dynamicGameFacet = await DynamicGameFacet.deploy()
  
      // let facetB = await FacetB.deployed();
      let selectors = getSelectors(dynamicGameFacet);
      selectors = selectors.remove(['supportsInterface'])
      let addresses = [];
      addresses.push(dynamicGameFacet.address);
      
      await diamondCutFacet.diamondCut([[dynamicGameFacet.address, FacetCutAction.Add, selectors]], ethers.constants.AddressZero, '0x');
  
      // let diamondLoupeFacet = await DiamondLoupeFacet.at(diamond.address);
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0]);
      assert.sameMembers(result, selectors)
  
    })
  
    it('should check dynamic game facet constructor args', async () => { 
  
      const dynamicGameFacet = await ethers.getContractAt('DynamicGameFacet', diamondAddress)
      let bossTxn = await dynamicGameFacet.getBigBoss();
      let result = transformCharacterData(bossTxn);
  
      expect(result.name).to.equal("Thanos: The Mad Titan");
      expect((result.hp).toString()).to.equal("10000");
      expect((result.maxHp).toString()).to.equal("10000");
      expect((result.attackDamage).toString()).to.equal("50");
  
      const charactersTxn = await dynamicGameFacet.getAllDefaultCharacters();
      const characters = charactersTxn.map((characterData) => transformCharacterData(characterData));
      characters.forEach((character, index) => {
      
        if(index == 0){
            expect(character.name).to.equal("Raze");
            expect((character.hp).toString()).to.equal("100");
            expect((character.maxHp).toString()).to.equal("100");
            expect((character.attackDamage).toString()).to.equal("100");
        }
        
        else if(index == 1){
            expect(character.name).to.equal("Phoenix");
            expect((character.hp).toString()).to.equal("200");
            expect((character.maxHp).toString()).to.equal("200");
            expect((character.attackDamage).toString()).to.equal("50");
        }
  
        else if(index == 2){
            expect(character.name).to.equal("Sage");
            expect((character.hp).toString()).to.equal("400");
            expect((character.maxHp).toString()).to.equal("400");
            expect((character.attackDamage).toString()).to.equal("25");
        }
      });
  
      
  
    })



  });

  describe('mintCharacterNFT()', function () { 

    // Fetch dynamicGameFacet
    it('Should Fetch DynamicGameFacet', async function () {

      dynamicGameFacet = await ethers.getContractAt('DynamicGameFacet', diamondAddress)

    });

    

    // Minting Characters
    it('Should Mint Characters', async function () {
        
        for (let i = 0; i < 3; i++) {
          await expect(dynamicGameFacet.connect(owner).mintCharacterNFT(i, {value: ethers.utils.parseEther("0.01")})).to.not.be.reverted; 
        }

    });

    it('Should Fail To Mint If Amount Is Not Exact', async function () {
      
      await expect(dynamicGameFacet.connect(addr1).mintCharacterNFT(0, {value: ethers.utils.parseEther("0.005")})).to.be.reverted; 
      await expect(dynamicGameFacet.connect(addr1).mintCharacterNFT(0, {value: ethers.utils.parseEther("0.002")})).to.be.reverted; 

    });


  });
  

  describe('updateFee()', function () { 

    // Fetch dynamicGameFacet
    it('Should Fetch DynamicGameFacet', async function () {

      dynamicGameFacet = await ethers.getContractAt('DynamicGameFacet', diamondAddress)

    });

    // updateFee function can be used only by contract owner
    it('should fail since fee can only be updated by owner', async function() {
        
        await expect(dynamicGameFacet.connect(addr1).updateFee(ethers.utils.parseEther("0.2"))).to.be.reverted;

    });

    it('should allow only the owner to update fee', async function() {
      
        await expect(dynamicGameFacet.connect(owner).updateFee(ethers.utils.parseEther("0.2"))).to.not.be.reverted;

    });

  });

  
  





  


})
