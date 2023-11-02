// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import './ERC721Enumerable.sol';

contract AndrehNFT is ERC721Enumerable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    mapping(string => bool) private mintedNFTs;
    mapping(uint256 => string) private unmintedNFTUris;
    mapping(string => bool) private addedToUnminted;
    uint256 public unmintedCount = 0;

    constructor() ERC721Enumerable("YourOwnNFT", "YON") {}

    function mintNFT(address owner) public returns (uint256) {
        require(unmintedCount > 0, "No NFTs available for minting");
        
        uint256 newItemId = _tokenIds.increment().current();
        _mint(owner, newItemId);

        string memory uri = unmintedNFTUris[unmintedCount];
        _setTokenURI(newItemId, uri);
        
        mintedNFTs[uri] = true;
        delete unmintedNFTUris[unmintedCount];
        unmintedCount--;

        return newItemId;
    }

    function addUnmintedNFTUri(string memory uri) public {
        require(!mintedNFTs[uri] && !addedToUnminted[uri], 'NFT is already added or minted');
        
        unmintedCount++;
        unmintedNFTUris[unmintedCount] = uri;
        addedToUnminted[uri] = true;
    }

    function getOwnedURIs(address owner) public view returns(string[] memory) {
        uint256[] memory tokenIds = _ownedTokensIds(owner);
        string[] memory uris = new string[](tokenIds.length);
        
        for(uint256 i = 0; i < tokenIds.length; i++) {
            uris[i] = tokenURI(tokenIds[i]);
        }

        return uris;
    }
}
