// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract LotteryNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping (uint256 => uint8[4]) public lotteryInfo;
    mapping (uint256 => uint256) public lotteryAmount;
    mapping (uint256 => uint256) public issueIndex;
    mapping (uint256 => bool) public claimInfo;

    constructor() ERC721("GoldenGoose Lottery Ticket", "GLT") {}


    /**
    * @notice remove onlyOwner for testing purpose
     */
    function newLotteryItem(address player, uint8[4] memory _lotteryNumbers, uint256 _amount, uint256 _issueIndex)
        external
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        lotteryInfo[newItemId] = _lotteryNumbers;
        lotteryAmount[newItemId] = _amount;
        issueIndex[newItemId] = _issueIndex;
        // claimInfo[newItemId] = false; default is false here
        // _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function getLotteryNumbers(uint256 tokenId) external view returns (uint8[4] memory) {
        return lotteryInfo[tokenId];
    }
    function getLotteryAmount(uint256 tokenId) external view returns (uint256) {
        return lotteryAmount[tokenId];
    }
    function getLotteryIssueIndex(uint256 tokenId) external view returns (uint256) {
        return issueIndex[tokenId];
    }
    function claimReward(uint256 tokenId) external onlyOwner {
        claimInfo[tokenId] = true;
    }
    function multiClaimReward(uint256[] memory tokenIds) external onlyOwner {
        for (uint i = 0; i < tokenIds.length; i++) {
            claimInfo[tokenIds[i]] = true;
        }
    }
    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }
    function getClaimStatus(uint256 tokenId) external view returns (bool) {
        return claimInfo[tokenId];
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');
        return tokenIdToSVG(tokenId);
    }

    function tokenIdToSVG(uint256 tokenId) internal view returns(string memory) {
        string[5] memory parts;
        string memory glow = 'glow';
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350" width="350" height="350" fill="none">';
        parts[1] = '<style>.head {font: italic 45px sans-serif;} .timestamp { font: 12px sans-serif; fill: gray;} .round {font: bold 35px sans-serif; fill: #fe0879;} .tokenId { font: bold 60px sans-serif; fill: #CAF0F8;} .st { stroke: black; stroke-width: 2px; }   background-size: cover;} .winner { font: bold 60px sans-serif; fill: yellow; } .glow { animation: glow 0.5s alternate infinite ease-in-out; } @keyframes glow { 0% { filter: drop-shadow(0px 0px 1px #888) drop-shadow(0px 0px 1.5px #fff) drop-shadow(0px 0px 2.5px #f7e6ad) drop-shadow(0px 0px 5px #f98404) drop-shadow(0px 0px 8px #fff338); } 100% { filter: drop-shadow(0px 0px 1px #fff) drop-shadow(0px 0px 2px #fff) drop-shadow(0px 0px 3px #f7e6ad) drop-shadow(0px 0px 6px #f98404) drop-shadow(0px 0px 10px #fff338); } }</style>';
        parts[2] = '<rect x="0" y="0" width="100%" height="100%" stroke-width="10" fill="#0F0E0E"/>';
        parts[3] = string(abi.encodePacked('<rect x="0" y="0" width="100%" height="100%" stroke-width="10" stroke="#FED715" class="',glow,'"/><text x="20" y="82" class="head" stroke="black" stroke-width="3">GoldenGoose</text><text x="25" y="85" class="head ',glow,'" stroke="red" fill="#fe0879" stroke-width="2">GoldenGoose</text><text x="30" y="87" class="head ',glow,'" stroke="#FED715" stroke-width="2">GoldenGoose</text><path d="M80 130H250" stroke="#FED715" stroke-width="3" stroke-linecap="round"/>'));
        parts[4] = string(abi.encodePacked('<text x="75" y="250" class="tokenId st ',glow,'">',toString(lotteryInfo[tokenId][0]),' ',toString(lotteryInfo[tokenId][1]),' ',toString(lotteryInfo[tokenId][2]),' ',toString(lotteryInfo[tokenId][3]),'</text></svg>'));
        
        string memory card =  string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4]));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "GoldenGoose Lottery #', Strings.toString(tokenId),'", "description": "GoldenGoose Lottery is the collectible lotto. lets turn your risk on!", "attributes": ',tokenIdToMetadata(tokenId),', "image": "data:image/svg+xml;base64,', Base64.encode(bytes(card)), '"}'))));
        return string(abi.encodePacked('data:application/json;base64,', json));
        // return string(abi.encodePacked('data:image/svg+xml;base64,',Base64.encode(bytes(card))));
    }

    function tokenIdToMetadata(uint256 tokenId) internal view returns(string memory) {
        string memory metadataString = string(
                abi.encodePacked(
                    '{"trait_type":"tokenId","value":"',
                    toString(tokenId),
                    '"},'
                    '{"trait_type":"issueIndex","value":"',
                    toString(issueIndex[tokenId]),
                    '"},'
                    '{"trait_type":"lotteryAmount","value":"',
                    toString(lotteryAmount[tokenId]),
                    '"},'
                    '{"trait_type":"Status","value":"',
                    claimInfo[tokenId] == true ? "Claimed" : "Not Claimed",
                    '"}'
                )
            );
        return string(abi.encodePacked("[", metadataString, "]"));
    }

    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
