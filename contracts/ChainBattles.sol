//SPDX-License-Identifier: unliencense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    uint256 constant MAX_SUPPLY = 1000;

    struct ChainAttributes {
        uint256 level;  // 0
        uint256 health;  // 1
        uint256 speed;  // 2
        uint256 attack;  // 3
    }
    mapping(uint256 => ChainAttributes) public tokenIdToAttributes;
    Counters.Counter private _tokenIds;

    constructor() ERC721 ("Chain Battles", "CBTLS"){

    }


    function generateCharacter(uint256 tokenId) public view returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base{fill:#2D42FF;font-family:serif;font-size:18px;font-weight:bold}</style>',
            '<style>.attrib{fill:#2D42FF;font-family:serif;font-size:14px;font-weight:bold}</style>',
            '<style>.uid{fill:#2D42FF;font-family:serif;font-size:18px;font-weight:bold}</style>',
            '<rect width="100%" height="100%" fill="#FFD7CB"/>',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle"><tspan class="uid"> #', tokenId.toString(), '</tspan> level ', getAttributes(tokenId, 0),'</text>',
            '<text x="50%" y="50%" class="attrib" dominant-baseline="middle" text-anchor="middle">', "health: ",getAttributes(tokenId, 1),'</text>',
            '<text x="50%" y="60%" class="attrib" dominant-baseline="middle" text-anchor="middle">', "speed: ",getAttributes(tokenId, 2),'</text>',
            '<text x="50%" y="70%" class="attrib" dominant-baseline="middle" text-anchor="middle">', "attack: ",getAttributes(tokenId, 3),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getAttributes(uint256 tokenId, uint8 attribute) public view returns (string memory){
        require(attribute <= 4, "unknown attribute");
        string memory returnValue;
        ChainAttributes memory attributes = tokenIdToAttributes[tokenId];
        if(attribute == 1){returnValue = attributes.health.toString();}
        else if(attribute == 2){returnValue = attributes.speed.toString();}
        else if(attribute == 3){returnValue = attributes.attack.toString();}
        else{returnValue = attributes.level.toString();} // ==level

        return returnValue;
    }


    function getTokenURI(uint256 tokenId)public returns(string memory){
        bytes memory dataURI = abi.encodePacked(
           '{',
              '"name": "Chain Battles #', tokenId.toString(), '",',
              '"description": "Battles on chain ",',
              '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
            );
    }
    function randomness(uint rng, uint scale) private view returns(uint){
        uint random_keccak = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        return (random_keccak % rng) * scale;
    }
    function mint() public{
        //require max minted
        require(_tokenIds.current() <= MAX_SUPPLY, "maxmimum nft minted, sorry");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToAttributes[newItemId].level = randomness(1000,1);
        tokenIdToAttributes[newItemId].health = randomness(1000,1);
        tokenIdToAttributes[newItemId].speed = randomness(1000,1);
        tokenIdToAttributes[newItemId].attack = randomness(1000,1);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public{
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        uint256 currentLevel = tokenIdToAttributes[tokenId].level;
        uint256 currentHealth = tokenIdToAttributes[tokenId].health;
        uint256 currentSpeed = tokenIdToAttributes[tokenId].speed;
        uint256 currentAttack = tokenIdToAttributes[tokenId].attack;

        tokenIdToAttributes[tokenId].level = currentLevel - randomness(10,5) + randomness(100,1);
        tokenIdToAttributes[tokenId].health = currentHealth - randomness(10,2) + randomness(100,1);
        tokenIdToAttributes[tokenId].speed = currentSpeed - randomness(9,1) + randomness(10,1);
        tokenIdToAttributes[tokenId].attack = currentAttack - randomness(8,5) + randomness(100,1);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }



}
