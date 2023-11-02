// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * @title ERC721Enumerable Implementation
 * @dev This contract provides enumeration capabilities for ERC721 tokens.
 */
contract ERC721Enumerable is IERC721Enumerable, ERC721URIStorage {
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;
    mapping(address => uint256[]) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;

    function _mint(address to, uint256 tokenId) internal override(ERC721) {
        super._mint(to, tokenId);
        _addToAllTokensEnumeration(tokenId);
        _addToOwnerEnumeration(to, tokenId);
    }

    function _addToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _addToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        require(index < totalSupply(), 'Global index out of bounds');
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(address owner, uint index) public view override returns (uint256) {
        require(index < balanceOf(owner), 'Owner index out of bounds');
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view override returns (uint256) {
        return _allTokens.length;
    }

    function ownedTokensIds(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }
}
