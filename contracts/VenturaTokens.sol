// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {VenturaErrors} from "./VenturaErrors.sol";

contract VenturaTokens is ERC1155, Ownable {

    uint256 public constant VENTURA = 0;
    uint256 public constant CREATOR_NFT_ID = 1;
    uint256 public constant  POAT_NFT_ID = 2;
    

    uint8 public constant TOKEN_LIMIT = 1;

    string[] public nft_metadata;

    mapping(uint256 => string) public tokenURI;

    constructor(address _owner) ERC1155("") Ownable(_owner) {
        _setURIS();
    }

    function _setURIS() private {

        nft_metadata.push(
            "https://ipfs.io/ipfs/QmfThmmntg4dKSa8EHmbRQWUkt36fzCK54EV3BeT4Ks7hE/ventura.json"
        );
        tokenURI[1] = "https://ipfs.io/ipfs/QmfThmmntg4dKSa8EHmbRQWUkt36fzCK54EV3BeT4Ks7hE/ventura.json";

        nft_metadata.push(
            "https://ipfs.io/ipfs/QmfThmmntg4dKSa8EHmbRQWUkt36fzCK54EV3BeT4Ks7hE/creator.json"
        );

        tokenURI[2] = "https://ipfs.io/ipfs/QmfThmmntg4dKSa8EHmbRQWUkt36fzCK54EV3BeT4Ks7hE/creator.json";

        nft_metadata.push(
            "https://ipfs.io/ipfs/QmfThmmntg4dKSa8EHmbRQWUkt36fzCK54EV3BeT4Ks7hE/poap.json"
        );

        tokenURI[3] =  "https://ipfs.io/ipfs/QmfThmmntg4dKSa8EHmbRQWUkt36fzCK54EV3BeT4Ks7hE/poap.json";
    }

    function mint(address to, uint256 id, uint256 value, bytes memory data) external {
        super._mint(to, id, value, data);
    }

    
    function contractURI() public pure returns (string memory) {
        return
            "https://ipfs.io/ipfs/QmfThmmntg4dKSa8EHmbRQWUkt36fzCK54EV3BeT4Ks7hE/ventura.json";
    }

    function getIDSpace() private view returns(uint256) {
        return nft_metadata.length;
    }

    function _insetURI(string memory _uri) internal {

        uint256 _id = getIDSpace() + 1;

        tokenURI[_id] = _uri;
        nft_metadata.push(_uri);
        emit URI(_uri, _id);
    }

    function setURI( string memory _uri) external onlyOwner {
        _insetURI(_uri);
    }

    function uri(uint256 _id) public view override returns (string memory) {
        // return nft_metadata[_id];
        return tokenURI[_id];
    }

    // function mintNFT(address recipient, uint256 nftId) external onlyOwner {
        
    //      _mint(recipient, nftId, TOKEN_LIMIT, "");
    // }

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
