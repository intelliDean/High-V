// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {VenturaTokens} from "./VenturaTokens.sol";
import {IVentura} from "./IVentura.sol";
import {VenturaErrors} from "./VenturaErrors.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Ventura is IVentura, Ownable {
    IERC20 private immutable USDT;
    VenturaTokens private immutable NFT;

    Event[] public events;
    Event[] _creatorEvents;

    mapping(bytes32 => Event) public eventsCreated;
    mapping(address => mapping(bytes32 => bool)) private isParticipant;
    mapping(address => mapping(bytes32 => bool)) private attended;

    constructor(
        address _owner,
        address _paymentToken,
        address nftAddress
    ) Ownable(_owner) {
        USDT = IERC20(_paymentToken); //Tether: 0xdAC17F958D2ee523a2206206994597C13D831ec7 this is the token that will be used in production
        NFT = VenturaTokens(nftAddress);
    }

    //prod: event creator will give us image for their NFT
    function createEvent(EventData memory _eventData) external returns (bool _success) {

        Event memory _event = initEvent(_eventData);

        events.push(_event);

        _success = true;

        emit EventCreated(
            msg.sender,
            _event.eventId,
            _event.eventType,
            _eventData.eventTitle
        );
    } 

    function initEvent(EventData memory _eventData) private returns (Event memory)  {
        bytes32 _eventId = keccak256(abi.encode(_eventData));

        Event storage _event = eventsCreated[_eventId];

        _event.creator = msg.sender;
        _event.eventId = _eventId;
        _event.eventTitle = _eventData.eventTitle;
        _event.imageUrl = _eventData.imageUrl;
        _event.venue = _eventData.venue;
        _event.description = _eventData.description;

        if (_eventData.price == 0) {
            _event.eventType = EventType.FREE;
            _event.price = 0;
        } else if (_eventData.price > 0) {
            _event.eventType = EventType.PAID;
            _event.price = _eventData.price;
        }

        _event.eventDate = _eventData.eventDate;
        _event.timing.startTime = _eventData.startTime;
        _event.timing.endTime = _eventData.endTime;
        _event.createdAt = block.timestamp;

        return _event;
    }

    function cancelEvent(bytes32 _eventId) external {
        
        Event memory _event = checkEvent(_eventId);

        if (_event.creator != msg.sender) revert VenturaErrors.UNAUTHORIZED();
        if (_event.eventDate[0] <= block.timestamp)
            revert VenturaErrors.TOO_LATE_TO_CANCEL_EVENT();

        _event.boolCheck.cancelled = true;
        eventsCreated[_eventId] = _event;   

        emit EventCancelled(_eventId);
    }

    function checkEvent(bytes32 _eventId) private view returns (Event memory) {
        Event memory _event = eventsCreated[_eventId];

        if (_event.eventId == bytes32(0))
            revert VenturaErrors.EVENT_NOT_FOUND(_eventId);

        return _event;
    }

    function eventIsOver(bytes32 _eventId) external {

        Event memory _event = checkEvent(_eventId);

        if (msg.sender != _event.creator) revert OwnableUnauthorizedAccount(msg.sender);
        if (_event.eventDate[_event.eventDate.length - 1] >= block.timestamp) revert VenturaErrors.EVENT_STILL_ON();

        _event.boolCheck.isOver = true;
        eventsCreated[_eventId] = _event;       
    }

    function mintCreatorNFT(bytes32 _eventId) external onlyOwner {

        Event memory _event = checkEvent(_eventId);

        if (!_event.boolCheck.isOver) revert VenturaErrors.EVENT_STILL_ON();

        NFT.mint(_event.creator, 1, 1, "");
    }


    function getEventById(bytes32 _eventId) external view returns (Event memory) {
        return checkEvent(_eventId);
    }

    function getAllEvents() external view returns (Event[] memory) {
        if (events.length == 0) revert VenturaErrors.N0_EVENT();
        return events;
    }

    function getEeventsByCreator(address _creator)
        external
        returns (Event[] memory _allEvents)
    {
        Event[] memory _events = events;

        for (uint256 i = 0; i < _events.length; i++) {
            if (_events[i].creator == _creator) {
                _creatorEvents.push(_events[i]);
            }
        }

        if (_creatorEvents.length == 0) revert VenturaErrors.N0_EVENT();
        _allEvents = _creatorEvents;

        delete _creatorEvents;
    }

    function registrationOn(bytes32 _eventId) external returns (bool) {

        Event memory _event = checkEvent(_eventId);

        if (msg.sender != _event.creator) revert OwnableUnauthorizedAccount(msg.sender);
        if (_event.eventDate[_event.eventDate.length - 1] < block.timestamp) revert VenturaErrors.REG_IS_OVER();

        _event.boolCheck.regIsOn = true;
        eventsCreated[_eventId] = _event;

        emit RegInfo(_eventId, "Reistration is on");

        return true;
    }

    function registrationOver(bytes32 _eventId) external returns (bool) {
       
        Event memory _event = checkEvent(_eventId);
        if (msg.sender != _event.creator) revert OwnableUnauthorizedAccount(msg.sender);

        _event.boolCheck.regIsOn = false;
        eventsCreated[_eventId] = _event;
        return true;
    }

    function registerForEvent(bytes32 _eventId) external {
        if (eventsCreated[_eventId].eventId == bytes32(0))
            revert VenturaErrors.EVENT_NOT_FOUND(_eventId);

        Event storage _event = eventsCreated[_eventId];

        if (!_event.boolCheck.regIsOn)
            //check if reg is on
            revert VenturaErrors.REGISTRATION_NOT_ON();

        if (isParticipant[msg.sender][_eventId])
            //check if registered already
            revert VenturaErrors.IS_A_PARTICIPANT(msg.sender);

        if (_event.creator == msg.sender)
            //check if user is the creator
            revert VenturaErrors.CAN_NOT_REGISTER_FOR_YOUR_OWN_EVENT();

        //before here, the user would have approved the contract to spend on his behalf
        if (_event.eventType == EventType.PAID) {
            
            uint256 _price = _makePayment(_event, msg.sender);

            _event.participants.push(msg.sender);

            isParticipant[msg.sender][_eventId] = true;

            emit Registered(msg.sender, _eventId, _price);
        } else if (_event.eventType == EventType.FREE) {
            _event.participants.push(msg.sender);
            isParticipant[msg.sender][_eventId];
        }
    }

    function _makePayment(Event memory _event, address _participant)
        private
        returns (uint256)
    {
        uint256 _allowance = USDT.allowance(_participant, address(this));
        uint256 _price = _event.price;
        
        if (_allowance < _price)
            revert VenturaErrors.INSUFFICIENT_VALUE(_allowance);

        require(
            USDT.transferFrom(_participant, address(this), _price),
            "Payment Failed"
        );
        return _price;
    }

    function markAttendnceWithBarcode(address _participant, bytes32 _eventId)
        external
    {
        if (_participant == address(0))
            revert VenturaErrors.ADDRESS_ZERO_NOT_ALLOWED();

        if (!isParticipant[msg.sender][_eventId])
            revert VenturaErrors.NOT_REGISTERED();

        attended[_participant][_eventId] = true;

        emit BarcodeScanned(msg.sender, _participant, _eventId);
    }
}
