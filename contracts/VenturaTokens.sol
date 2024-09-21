// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {VenturaErrors} from "./VenturaErrors.sol";

contract VenturaTokens is ERC1155Burnable, Ownable {
    uint256 public constant CREATOR_NFT_ID = 1;
    uint256 public constant ADMIN_NFT_ID = 2;
    uint256 public constant POAT_NFT_ID = 3;

    uint8 public constant TOKEN_LIMIT = 1;

    string[] public nft_metadata;

    mapping(uint256 => string) public tokenURI;

    constructor(address _owner) ERC1155("") Ownable(_owner) {
        _setURIS();
    }

    function _setURIS() private {
        nft_metadata.push(
            "https://ipfs.io/ipfs/QmRxnCg8DShn8pyYfDD8MyM9vsnAUYGSarU8SK4BykGUKv/ventura_metadata.json"
        );

        _insetURI(
            1,
            "https://ipfs.io/ipfs/QmadBkQMh6cjAKG1ZzJRSAa89MSQW1HSqYMbahW66eD2C7/coin_metadata.json"
        );
        _insetURI(
            2,
            "https://ipfs.io/ipfs/Qmcgo9gWVQPt2QxTNxyAJhpruy4TF7r5cMEbzSdRr5FCUN/trophy_metadata.json"
        );
    }

    function contractURI() public pure returns (string memory) {
        return
            "https://ipfs.io/ipfs/QmRxnCg8DShn8pyYfDD8MyM9vsnAUYGSarU8SK4BykGUKv/ventura_metadata.json";
    }

    function _insetURI(uint256 _id, string memory _uri) internal {
        tokenURI[_id] = _uri;
        nft_metadata.push(_uri);
        emit URI(_uri, _id);
    }

    function setURI(uint256 _id, string memory _uri) external onlyOwner {
        _insetURI(_id, _uri);
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return tokenURI[_id];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public override {
        _notTransferable();
        _safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override {
        _notTransferable();
        _safeBatchTransferFrom(from, to, ids, values, data);
    }

    function _notTransferable() internal view {
        if (msg.sender.code.length >= 0)
            revert VenturaErrors.TOKEN_NOT_TRANSFERABLE();
    }
}
