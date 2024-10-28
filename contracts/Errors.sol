// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Errors {
    error ONLY_OWNER(address);
    error ADDRESS_ZERO();
    error NFT_NOT_TRANSFERABLE();
    error INELLIGIBLE(address);
    error EVENT_NOT_ENDED();
    error INSUFFICIENT_ALLOWANCE(uint256);
    error TRANSFER_FAIL();
    error REG_IS_NOT_ON();
    error EVENT_STATUS_ERROR();
    error REGISTERED_ALREADY();
    error ZERO_ARRAY_LENGTH();
    error NOT_REGISTERED(address);
    error CANNOT_END_EVENT();
    error CANNOT_CANCEL_EVENT();
    error CANNOT_START_EVENT();
    error CANNOT_POSTPONE_EVENT();
    error CANNOT_PAUSE_EVENT();
    error WHEN_EVENT_ENDS();
    error ALREADY_CLAIMED();
}
