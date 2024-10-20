// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "contracts/Errors.sol";

contract HighVNFT is ERC1155Burnable, Ownable {

    string nftURI;

    uint8 public constant TOKEN_LIMIT = 1;


    constructor(address _owner, string memory _nftURI) 
    ERC1155("") 
    Ownable(_owner) {

        nftURI = string(abi.encodePacked("https://ipfs.io/ipfs/", _nftURI, "/"));
    }

    function mint(address recipient, uint nftId, uint quantity) external  {
         _mint(recipient, nftId, quantity, "");
    }

    function contractURI() public view  returns (string memory) {
        return uri(0);
    }
   
    function uri(uint256 _tokenid) public   override    view returns (string memory) {
        return string(abi.encodePacked(nftURI, Strings.toString(_tokenid), ".json"));
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
            revert Errors.NFT_NOT_TRANSFERABLE();
    }
}
