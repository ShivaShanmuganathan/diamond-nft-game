// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// IERC721 Interface Contract 📃 to inherit from.
import {LibERC721} from "../libraries/LibERC721.sol";

// NFT contract to inherit from.
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper we wrote to encode in Base64
import "../libraries/Base64.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../tokens/ERC721Diamond.sol";
import "../libraries/LibDiamond.sol";
import {CharacterAttributes, BigBoss} from "../libraries/LibAppStorage.sol";

// Makes Debugging Easy
import "hardhat/console.sol";




// @title NFT Based Mini Game
/// @author Shiva Shanmuganathan
/// @notice You can use this contract for implementing a simple NFT based game to change NFT Metadata
/// @dev All function calls are currently implemented without side effects
contract DynamicGameFacet is ERC721Diamond {


  // Events to show that a Minting & Attacking action has been completed 
  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackComplete(uint newBossHp, uint newPlayerHp);


  // Data is passed in to the contract when it's first created initializing the characters.
  // We're going to actually pass these values in from from run.js.
    function init(
      string[] memory characterNames,
      string[] memory characterImageURIs,
      uint[] memory characterHp,
      uint[] memory characterAttackDmg,
      string memory bossName, 
      string memory bossImageURI,
      uint bossHp,
      uint bossAttackDamage
    ) external {
        LibDiamond.enforceIsContractOwner();
        s._name = "Heroes";
        s._symbol = "HERO";

        s.bigBoss = BigBoss({
          name: bossName,
          imageURI: bossImageURI,
          hp: bossHp,
          maxHp: bossHp,
          attackDamage: bossAttackDamage
        });

        for(uint i = 0; i < characterNames.length; i += 1) {

          s.defaultCharacters.push(CharacterAttributes({
            characterIndex: i,
            name: characterNames[i],
            imageURI: characterImageURIs[i],
            hp: characterHp[i],
            maxHp: characterHp[i],
            attackDamage: characterAttackDmg[i]
          }));

        }

        s._tokenIds += 1;
        s.fee = 0.01 ether;

    }


  
//     /// @notice Update Fee to mint the NFTs
//     /// @dev Only the contract owner will be able to update the minting fee
//     /// @param _fee The updated fee is passed by contract owner
//     /// Ownable is used to verify the contract owner

    function updateFee(uint256 _fee) external {

        LibDiamond.enforceIsContractOwner();
        s.fee = _fee;

    }


  /// @notice Mints the NFT of the selected character
  /// @dev The payable function requires users to pay the fee amount to mint the NFT. 
  /// @param _characterIndex The index of the character the user chooses to Mint
  
//   function mintCharacterNFT(uint _characterIndex) external payable{
//     require(msg.value == fee);
//     uint256 newItemId = _tokenIds.current();

//     _safeMint(msg.sender, newItemId);

//     nftHolderAttributes[newItemId] = CharacterAttributes({
      
//       characterIndex: _characterIndex,
//       name: defaultCharacters[_characterIndex].name,
//       imageURI: defaultCharacters[_characterIndex].imageURI,
//       hp: defaultCharacters[_characterIndex].hp,
//       maxHp: defaultCharacters[_characterIndex].hp,
//       attackDamage: defaultCharacters[_characterIndex].attackDamage
      
//     });

//     console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);  

//     nftHolders[msg.sender] = newItemId;
//     totalTokens = newItemId;

//     _tokenIds.increment();
    
//     emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);

//   }


}
