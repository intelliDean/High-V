// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Game is ERC1155Burnable, Ownable {
    uint256 public constant TOKEN_ID = 1;
    uint256 public constant NFT_ID = 2;

    mapping(uint256 => string) public tokenURI;

    constructor()
    ERC1155(
    /*"https://ipfs.io/ipfs/QmQrT7LmL8xvXmBoHy4SwB8GFVkYGXaQjba71KrAqADQtX/{id}.json"*/
    ""
    ) Ownable(msg.sender) {
        setURI(1, "https://ipfs.io/ipfs/QmadBkQMh6cjAKG1ZzJRSAa89MSQW1HSqYMbahW66eD2C7/coin_metadata.json");
        setURI(2, "https://ipfs.io/ipfs/Qmcgo9gWVQPt2QxTNxyAJhpruy4TF7r5cMEbzSdRr5FCUN/trophy_metadata.json");
        _mint(msg.sender, TOKEN_ID, 100, "");
        _mint(msg.sender, NFT_ID, 1, "");
    }

    // function uri(uint256 _tokenId)
    //     public
    //     pure
    //     override
    //     returns (string memory)
    // {
    //     return
    //         string(
    //             abi.encodePacked(
    //                 "https://ipfs.io/ipfs/QmQrT7LmL8xvXmBoHy4SwB8GFVkYGXaQjba71KrAqADQtX/",
    //                 Strings.toString(_tokenId),
    //                 ".json"
    //             )
    //         );
    // }

    function contractURI() public pure returns (string memory) {
        return
        // "https://ipfs.io/ipfs/QmQrT7LmL8xvXmBoHy4SwB8GFVkYGXaQjba71KrAqADQtX/collection.json";
            "https://ipfs.io/ipfs/QmRxnCg8DShn8pyYfDD8MyM9vsnAUYGSarU8SK4BykGUKv/ventura_metadata.json";
    }

    function airdrop(uint256 _tokenId, address[] calldata recipients)
    external
    onlyOwner
    {
        for (uint256 i = 0; i < recipients.length; i++) {
            _safeTransferFrom(msg.sender, recipients[i], _tokenId, 1, "");

            if (
                balanceOf(owner(), TOKEN_ID) == 90 &&
                balanceOf(owner(), NFT_ID) == 1
            ) {
                _safeTransferFrom(msg.sender, recipients[i], NFT_ID, 1, "");
            }
        }
    }

    function setURI(uint256 _id, string memory _uri) internal  {
        tokenURI[_id] = _uri;
        emit URI(_uri, _id);
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return tokenURI[_id];
    }

    // function _beforeTokenTransfer(
    //     address operator,
    //     address from,
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     bytes memory data) internal override {
    //         super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    //         require(msg.sender == owner() || to == address(0), "Token cannot be transferred, can only be burned");
    // }
}
