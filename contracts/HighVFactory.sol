// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./HighV.sol";
import "./IHighV.sol";
import "./Errors.sol";
import "./HighVNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract HighVFactory {

    address owner;

    uint256 noOfEventsCreated;

    IERC20 immutable PAYMENT;


    mapping (address => VenCont) venContracts;

    struct VenCont {
        address owner;
        address venturaContract;
        address nftContract;
    }

    constructor (address _owner, address _payment) {
        if (_owner == address(0)) revert Errors.ADDRESS_NOT_ALLOWED(_owner);
        if (_payment == address(0)) revert Errors.ADDRESS_NOT_ALLOWED(_payment);

        PAYMENT = IERC20(_payment); //Tether: 0xdAC17F958D2ee523a2206206994597C13D831ec7 this is the token that will be used in production
        owner = _owner;
    }
}


