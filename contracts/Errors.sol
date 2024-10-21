// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Errors {

    error ONLY_OWNER(address);
    error NFT_NOT_TRANSFERABLE();
    error INELLIGIBLE(address);
    error EVENT_NOT_ENDED();
    error INSUFFICIENT_BALANCE(uint);
    error TRANSFER_FAIL();
}