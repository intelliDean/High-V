// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VenturaTokens} from "./VenturaTokens.sol";
import {IVentura} from "./IVentura.sol";
import {VenturaErrors} from "./VenturaErrors.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Ventura is IVentura, VenturaTokens {
    IERC20 private immutable USDT;

    address[] private admins;
    Event[] public events;

    mapping(bytes32 => Event) public eventsCreated;
    mapping(address => mapping(bytes32 => bool)) private isParticipant;
    mapping(address => mapping(bytes32 => bool)) private isAdmin;
    mapping(address => mapping(bytes32 => bool)) private attended;

    constructor(address _owner, address _paymentToken) VenturaTokens(_owner) {
        USDT = IERC20(_paymentToken); //Tether: 0xdAC17F958D2ee523a2206206994597C13D831ec7 this is the token that will be used in production
    }

    function createEvent(EventData memory _eventData)
    external
    returns (bool _success)
    {
        if (msg.sender == address(0))
            revert VenturaErrors.ADDRESS_ZERO_NOT_ALLOWED();

        bytes32 _eventId = keccak256(abi.encode(_eventData));
        Event storage _event = eventsCreated[_eventId];

        _event.creator = msg.sender;
        _event.eventId = _eventId;
        _event.eventTitle = _eventData.eventTitle;
        _event.venue = _eventData.venue;
        _event.description = _eventData.description;
        _event.eventDate = _eventData.eventDate;
        _event.eventDurationInDays = _eventData.eventDate.length;
        _event.eventType = _eventData.eventType;
        _event.startTime = _eventData.startTime;
        _event.createdAt = block.timestamp;

        events.push(_event);

        //this is from the toke ventura token contract to munt creator NFT to the creator of the event
        _mint(msg.sender, CREATOR_NFT_ID, TOKEN_LIMIT, "");

        _success = true;

        emit EventCreated(
            msg.sender,
            _eventId,
            _eventData.eventType,
            _eventData.eventTitle
        );
    }

    function getEventById(bytes32 _eventId)
    external
    view
    returns (Event memory)
    {
        if (eventsCreated[_eventId].eventId == bytes32(0))
            revert VenturaErrors.EVENT_NOT_FOUND(_eventId);

        return eventsCreated[_eventId];
    }

    function creatorAddAdmins(bytes32 _eventId, address[] memory _admins)
    external
    {
        Event storage _event = eventsCreated[_eventId];

        if (msg.sender != _event.creator)
            //check if creator
            revert OwnableUnauthorizedAccount(msg.sender);

        if (_admins.length > 5)
            //check if the number of admins added are not more than 5
            revert VenturaErrors.TOO_MUCH_ADMINS(_admins.length);

        for (uint256 i = 0; i < _admins.length; i++) {
            if (
                _admins[i] == address(0) ||
                isAdmin[_admins[i]][_eventId] ||
                isParticipant[_admins[i]][_eventId]
            ) continue;

            if (_event.admins.length == 5)
                //check if admin limit is reached
                break;

            //add admin to the admin array/mapping
            _event.admins.push(_admins[i]);
            isAdmin[_admins[i]][_eventId] = true;

            //mint admin nft
            _mint(_admins[i], ADMIN_NFT_ID, TOKEN_LIMIT, "");
        }

        emit AdminAdded(msg.sender, _eventId, _event.admins.length);
    }

    //approval will be done outside of this contract, on the token contract directly
    // function userApprovesContract(bytes32 _eventId) external {
    //     uint256 _eventPrice = eventsCreated[_eventId].price;
    //     uint256 _usdtBalance = USDT.balanceOf(msg.sender);
    //     if ( _eventPrice > _usdtBalance)
    //         revert VenturaErrors.INSUFFICIENT_BALANCE(_usdtBalance);

    //     USDT.approve(address(this), _eventPrice);
    // }

    function registrationOn(bytes32 _eventId) external returns (bool) {
        Event storage _event = eventsCreated[_eventId];

        if (msg.sender != _event.creator)
            //check if creator
            revert OwnableUnauthorizedAccount(msg.sender);

        if (_event.eventDate[_event.eventDate.length - 1] < block.timestamp)
            revert VenturaErrors.REG_IS_OVER();

        _event.regIsOn = true;

        emit RegInfo(_eventId, "Reistration is on");

        return true;
    }

    function registrationOver(bytes32 _eventId) external returns (bool) {
        Event storage _event = eventsCreated[_eventId];

        if (msg.sender != _event.creator)
            //check if creator
            revert OwnableUnauthorizedAccount(msg.sender);

        _event.regIsOn = false;
        return true;
    }

    function registerForEvent(bytes32 _eventId) external {
        Event storage _event = eventsCreated[_eventId];
        if (!_event.regIsOn)
            //check if reg is on
            revert VenturaErrors.REGISTRATION_IS_OVER();

        if (isParticipant[msg.sender][_eventId])
            //check if registered already
            revert VenturaErrors.IS_A_PARTICIPANT(msg.sender);

        if (isAdmin[msg.sender][_eventId])
            //check if user is admin
            revert VenturaErrors.IS_AN_ADMIN(msg.sender);

        if (_event.creator == msg.sender)
            //check if user is the creator
            revert VenturaErrors.CAN_NOT_REGISTER_FOR_YOUR_OWN_EVENT();

        if (_event.eventType == EventType.PAID) {
            uint256 _allowance = _makePayment(_event, msg.sender);

            _event.participants.push(msg.sender);

            emit Registered(msg.sender, _eventId, _allowance);
        } else if (_event.eventType == EventType.FREE) {
            _event.participants.push(msg.sender);
        }
    }

    function _makePayment(Event memory _event, address _participant)
    private
    returns (uint256)
    {
        uint256 _allowance = USDT.allowance(_participant, address(this));
        uint256 _price = _event.price;
        if (_allowance != _price)
            revert VenturaErrors.INCORRECT_VALUE(_allowance);

        require(
            USDT.transferFrom(_participant, address(this), _allowance),
            "Payment Failed"
        );
        return _allowance;
    }

    function barcodeScanned(address _participant, bytes32 _eventId) external {
        if (
            msg.sender != eventsCreated[_eventId].creator ||
            isAdmin[msg.sender][_eventId]
        ) revert OwnableUnauthorizedAccount(msg.sender);

        if (_participant == address(0))
            revert VenturaErrors.ADDRESS_ZERO_NOT_ALLOWED();

        attended[_participant][_eventId] = true;

        emit BarcodeScanned(msg.sender, _participant, _eventId);
    }
}
