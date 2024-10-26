// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Errors.sol";

contract HighVNFT is ERC1155Burnable, Ownable {
    string nftURI;

    uint8 public constant TOKEN_LIMIT = 1;

    constructor(address _owner, string memory _nftURI)
        ERC1155("")
        Ownable(_owner)
    {
        nftURI = string(
            bytes.concat(
                bytes("https://ipfs.io/ipfs/"),
                bytes(_nftURI),
                bytes("/")
            )
        );
    }

    function mint(address recipient, uint256 nftId) external {
        _mint(recipient, nftId, TOKEN_LIMIT, "");
    }

    function contractURI() public view returns (string memory) {
        return uri(0);
    }

    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                bytes.concat(
                    bytes(nftURI),
                    bytes(Strings.toString(_tokenId)),
                    bytes(".json")
                )
            );
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
        if (msg.sender.code.length >= 0) revert Errors.NFT_NOT_TRANSFERABLE();
    }
}
