// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract VenturaErrors {

    error ONLY_OWNER(address);
    error ADDRESS_ZERO_NOT_ALLOWED();
    error EVENT_NOT_FOUND(bytes32);
    error IS_A_PARTICIPANT(address);
    error IS_AN_ADMIN(address);
    error ADMIN_COMPLETED();
    error TOKEN_NOT_TRANSFERABLE();
    error INCORRECT_VALUE(uint256);
    error INSUFFICIENT_BALANCE(uint256);
    error TOO_MUCH_ADMINS(uint);
    error CAN_NOT_REGISTER_FOR_YOUR_OWN_EVENT();
    error REGISTRATION_NOT_ON();
    error REG_IS_OVER();
    error UNAUTHORIZED();
    error INSUFFICIENT_VALUE(uint256);
    error TOO_LATE_TO_CANCEL_EVENT();
    error N0_EVENT();
    error NOT_REGISTERED();
    error OwnableUnauthorizedAccount(address);
    error EVENT_STILL_ON();
}