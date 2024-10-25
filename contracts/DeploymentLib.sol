// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./HighVNFT.sol";
import "./IHighV.sol";
import "./HighV.sol";

library DeploymentLib {
    function _deployNFTContract(string memory _nftURI, address _owner)
        public
        returns (address)
    {
        return address(new HighVNFT(_owner, _nftURI));
    }

    function _deployHighVContract(
        IHighV.EventData memory _eventData,
        address _owner,
        address _paymentAddress,
        address nftAddress,
        bytes32 _eventId
    ) public returns (address) {
        return
            address(
                new HighV{
                    salt: keccak256(abi.encodePacked(msg.sender, _eventId))
                }(_owner, _paymentAddress, nftAddress, _eventData, _eventId)
            );
    }
}
