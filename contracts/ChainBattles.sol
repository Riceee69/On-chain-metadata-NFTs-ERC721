// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


contract ChainBattles is ERC721URIStorage, VRFConsumerBaseV2Plus{
    using Strings for uint256;//to use String library functions on any uint256
    uint256 public tokenID;
    uint256 s_subscriptionId;
    //Polygon Amoy Testnet
    address vrfCoordinator = 0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2;
    bytes32 s_keyHash = 0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  4;

    event AttributesAssigned(
        uint256 indexed tokenId, 
        uint256 level, 
        uint256 speed, 
        uint256 strength, 
        uint256 life
    );

    struct WarriorAttributes{
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }
    mapping(uint256 => WarriorAttributes) public tokenIdToAttributes;
    mapping(uint256 => uint256) private requestIdToTokens;

    constructor(uint256 subscriptionId) ERC721("ChainBattles", "CB") VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_subscriptionId = subscriptionId;
    }

    function safeMint() public returns (uint256 requestId){
        _safeMint(msg.sender, tokenID);

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with POL instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        requestIdToTokens[requestId] = tokenID;
        tokenID++;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 tokenId = requestIdToTokens[requestId];

        WarriorAttributes storage attributes = tokenIdToAttributes[tokenId];
        attributes.level = (randomWords[0] % 20) + 1;
        attributes.speed = (randomWords[1] % 50) + 1;
        attributes.strength = (randomWords[2] % 50) + 1;
        attributes.life = (randomWords[3] % 20) + 1;

        _setTokenURI(tokenId, generateTokenURI(tokenId));

        emit AttributesAssigned(
            tokenId,
            tokenIdToAttributes[tokenId].level, 
            tokenIdToAttributes[tokenId].speed, 
            tokenIdToAttributes[tokenId].strength, 
            tokenIdToAttributes[tokenId].life
        );
    }

    function generateTokenURI(uint256 tokenId) private view returns(string memory){
        //toString() is used as abi.encodePacked() only concatenates and encodes strings!!!
        bytes memory dataURI  = abi.encodePacked(
            '{',
                '"description": "A dynamic on-chain metadata NFT",',
                '"image": "', generateCharacter(tokenId), '",',
                '"name": "ChainBattles#', tokenId.toString(), '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function generateCharacter(uint256 tokenId) private view returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="38%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior: ", tokenId.toString(),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ", getAttributes(tokenId)[0],'</text>',
            '<text x="50%" y="58%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ", getAttributes(tokenId)[1],'</text>',
            '<text x="50%" y="66%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ", getAttributes(tokenId)[2],'</text>',
            '<text x="50%" y="74%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ", getAttributes(tokenId)[3],'</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)    
            )
        );
    }
   
   function getAttributes(uint256 tokenId) public view returns (string[4] memory){
        return(
            [
                tokenIdToAttributes[tokenId].level.toString(),
                tokenIdToAttributes[tokenId].speed.toString(),
                tokenIdToAttributes[tokenId].strength.toString(),
                tokenIdToAttributes[tokenId].life.toString()
            ]
        );
   }
   
    function train(uint256 tokenId) public {
        require(tokenId < tokenID, "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");

        WarriorAttributes storage warriorAttribute = tokenIdToAttributes[tokenId];
        warriorAttribute.level += 1;
        warriorAttribute.speed += 1;
        warriorAttribute.strength += 1;
        warriorAttribute.life += 1;

        _setTokenURI(tokenId, generateTokenURI(tokenId));
    }


    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}