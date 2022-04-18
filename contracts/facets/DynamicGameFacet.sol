// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// IERC721 Interface Contract 📃 to inherit from.
// import {IERC721} from "../interfaces/IERC721.sol";

// NFT contract to inherit from.
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper we wrote to encode in Base64
import "../libraries/Base64.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Access Control Function
import "@openzeppelin/contracts/access/Ownable.sol";

// Makes Debugging Easy
import "hardhat/console.sol";


library DynamicGameStorage {

    // We'll hold our character's attributes in a struct.    
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;        
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // We create a struct to keep track of bigBoss's attributes
    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // This struct contains state variables we care about.
    struct DiamondStorage {
        // The tokenId is the NFTs unique identifier, it's just a number that goes
        // 0, 1, 2, 3, etc.
        uint256 totalTokens;
        uint256 _tokenIds;
        // This array help us hold the default data for our characters.
        // This will be helpful when we mint new characters and need to know things like their HP, AD, etc.
        CharacterAttributes[] defaultCharacters;  
        // We create a mapping from the nft's tokenId => that NFTs attributes.
        mapping(uint256 => CharacterAttributes) nftHolderAttributes;
        // bigBoss is the Bad Guy that our Heroes Fight against
        BigBoss bigBoss;
        // A mapping from an address => the NFTs tokenId. Gives me an ez way
        // to store the owner of the NFT and reference it later.
        mapping(address => uint256) nftHolders;
        // A fee to mint the Characterrs. 
        uint256 fee;
        
    }



    // Returns the struct from a specified position in contract storage
    // ds is short for DiamondStorage
    function diamondStorage() internal pure returns(DiamondStorage storage ds) {
        // Specifies a random position from a hash of a string
        bytes32 storagePosition = keccak256("Dynamic.NFT.Mini.Game.Diamond.Storage");
        // Set the position of our struct in contract storage
        assembly {
        ds.slot := storagePosition
        }
    }


}



// @title NFT Based Mini Game
/// @author Shiva Shanmuganathan
/// @notice You can use this contract for implementing a simple NFT based game to change NFT Metadata
/// @dev All function calls are currently implemented without side effects
contract DynamicGameFacet is Ownable{

    // We'll hold our character's attributes in a struct.    
    // struct CharacterAttributes {
    //     uint characterIndex;
    //     string name;
    //     string imageURI;        
    //     uint hp;
    //     uint maxHp;
    //     uint attackDamage;
    // }

    // We create a struct to keep track of bigBoss's attributes
    // struct BigBoss {
    //     string name;
    //     string imageURI;
    //     uint hp;
    //     uint maxHp;
    //     uint attackDamage;
    // }

  // Events to show that a Minting & Attacking action has been completed 
//   event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
//   event AttackComplete(uint newBossHp, uint newPlayerHp);


  // Data is passed in to the contract when it's first created initializing the characters.
  // We're going to actually pass these values in from from run.js.
  
  /// @notice initFacet function initializes the Boss & DefaultCharacter's Attributes
  /// @dev TokenId is incremented to 1, so that 0th Token can be assigned for users that sell their Token
  /// @param characterNames -> Gets All Default Character's Names as string array
  /// @param characterImageURIs -> Gets All Default Character's ImageURI as string array
  /// @param characterHp -> Gets All Default Character's Health as uint array. 
  /// @param characterAttackDmg-> Gets All Default Character's Attack Damage as uint array. 
  /// @param bossName -> Gets Boss name as string
  /// @param bossImageURI -> Gets Boss imageURI as string
  /// @param bossHp -> Gets Boss Hp as uint
  /// @param bossAttackDamage -> Gets Boss AttackDamage as uint
//   function initFacet(// These new variables would be passed in via run.js or deploy.js.
//     string[] memory characterNames,
//     string[] memory characterImageURIs,
//     uint[] memory characterHp,
//     uint[] memory characterAttackDmg,
//     string memory bossName, 
//     string memory bossImageURI,
//     uint bossHp,
//     uint bossAttackDamage,
//     uint _fee
//     ) external {
        
//         DynamicGameStorage.DiamondStorage storage ds = DynamicGameStorage.diamondStorage();
        
//         ds.owner = msg.sender;
//         require(!ds.initialized, "Already Initialize");

//         // Initialize the boss as our "bigBoss" state variable.
//         ds.bigBoss = BigBoss({
//             name: bossName,
//             imageURI: bossImageURI,
//             hp: bossHp,
//             maxHp: bossHp,
//             attackDamage: bossAttackDamage
//         });

//         // console.log("Done initializing BOSS %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

//         // Loop through all the characters, and save their values in our contract so
//         // we can use them later when we mint our NFTs.
//         for(uint i = 0; i < characterNames.length; i += 1) {

//             ds.defaultCharacters.push(CharacterAttributes({
//                 characterIndex: i,
//                 name: characterNames[i],
//                 imageURI: characterImageURIs[i],
//                 hp: characterHp[i],
//                 maxHp: characterHp[i],
//                 attackDamage: characterAttackDmg[i]
//             }));

//         }

//         ds._tokenIds += 1;
//         ds.fee = _fee;
//         ds.initialized = true;
//     }


  
//     /// @notice Update Fee to mint the NFTs
//     /// @dev Only the contract owner will be able to update the minting fee
//     /// @param _fee The updated fee is passed by contract owner
//     /// Ownable is used to verify the contract owner

//     function updateFee(uint256 _fee) external onlyOwner {

//         DynamicGameStorage.DiamondStorage storage ds = DynamicGameStorage.diamondStorage();
//         require(ds.owner == msg.sender, "Only Owner Can Update Fee");
//         ds.fee = _fee;

//     }


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
