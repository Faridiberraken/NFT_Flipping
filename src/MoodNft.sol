// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721{
    error MoodNft__CantFlipMoodIfNotOwner();
    enum NFTState{
        HAPPY,
        SAD
    }
    uint256 private s_tokenCounter;
    string private s_sadSvgUri;
    string private s_happySvgUri;

    mapping(uint256 => NFTState) private s_tokenIdToState;

    event CreatedNFT(uint256 indexed tokenId);

    constructor(string memory sadSvgUri, string memory happySvgUri) ERC721("Mood NFT", "MN"){
        s_tokenCounter = 0;
        s_sadSvgUri = sadSvgUri;
        s_happySvgUri = happySvgUri;
    }

    function mintNft() public{
        uint256 tokenId = s_tokenCounter;
        _safeMint(msg.sender, tokenId);
        s_tokenCounter +=1;
        emit CreatedNFT(tokenId);
    }

    function flipMood(uint256 tokenId) public {
        if (getApproved(tokenId)!=msg.sender && ownerOf(tokenId)!=msg.sender){
            revert MoodNft__CantFlipMoodIfNotOwner();
        } 
        NFTState tokenState= s_tokenIdToState[tokenId];
        if(tokenState==NFTState.SAD){
            s_tokenIdToState[tokenId] = NFTState.HAPPY;
        }
        else{
            s_tokenIdToState[tokenId] = NFTState.SAD;
        }
    }
    
    function _baseURI() internal pure override returns(string memory){
    
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        string memory _base = _baseURI();
        string memory imageURI;
        if(s_tokenIdToState[tokenId]==NFTState.HAPPY){
            imageURI = s_happySvgUri;
        }
        else{
            imageURI = s_sadSvgUri;

        }

        return string(
            abi.encodePacked(
                _base,
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(), // You can add whatever name here
                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )

                )
            )
        );
        

    }
    
    ///////////////GETTERS/////////////////////
    function getHappySVG() public view returns (string memory) {
        return s_happySvgUri;
    }

    function getSadSVG() public view returns (string memory) {
        return s_sadSvgUri;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

   
        
   

}
