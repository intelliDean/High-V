// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "contracts/VenturaLib.sol";
import "contracts/Tokens/VenturaNFT.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./IVentura.sol";

contract HighV {
    
    using VenturaLib for *;
    address immutable owner;

    IERC20 immutable PAYMENT;

    bytes32[] public events;

    mapping(bytes32 => IVentura.Event) eventsCreated;
    mapping(address => mapping(bytes32 => IVentura.Participant)) participants;
    mapping(address => bool) isWhitelisted;

    event ContractCreated(address indexed contractAddress);
    event EventCreated(address indexed _creator, bytes32 indexed _eventId);

    constructor(address _owner, address _paymentAddress) {
        if (_owner == address(0)) revert Errors.ADDRESS_NOT_ALLOWED(_owner);
        if (_paymentAddress == address(0))
            revert Errors.ADDRESS_NOT_ALLOWED(_paymentAddress);

        owner = _owner;
        PAYMENT = IERC20(_paymentAddress); //Tether: 0xdAC17F958D2ee523a2206206994597C13D831ec7 this is the token that will be used in production

        emit ContractCreated(address(this));
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Errors.ONLY_OWNER(msg.sender);
        _;
    }

    function createEvent(IVentura.EventData memory _eventData) external {
        bytes32 _eventId = VenturaLib._createEvent(
            eventsCreated,
            events,
            _eventData,
            msg.sender
        );

        emit EventCreated(_creator, _eventId);
    }

    function getAllEvents() external view returns (IVentura.Event[] memory) {
        return VenturaLib._getAllEvents(events, eventsCreated);
    }

    function getEventById(bytes32 _eventId)
        external
        view
        returns (IVentura.Event memory)
    {
        return eventsCreated._getEventById(_eventId);
    }

    function _getAllMyEvents() external view returns (IVentura.Event[] memory) {
        return VenturaLib._getAllMyEvents(events, eventsCreated, msg.sender);
    }

    function updateCreatorEmail(bytes32 _eventId, string memory _newEmail)
        external
    {
        eventsCreated._updateCreatorEmail(_eventId, msg.sender, _newEmail);
    }

    function updateVenue(bytes32 _eventId, string memory _newVenue) external {
        eventsCreated._updateVenue(_eventId, msg.sender, _newVenue);
    }

    function openRegistration(bytes32 _eventId) external {
        eventsCreated._openRegistration(msg.sender, _eventId);
    }

    function closeRegistration(bytes32 _eventId) external {
        eventsCreated._closeRegistration(msg.sender, _eventId);
    }

    function register4Event(bytes32 _eventId, string memory _email) external {
        VenturaLib._register4Event(
            eventsCreated,
            participants,
            PAYMENT,
            _eventId,
            msg.sender,
            address(this),
            _email
        );
    }

    function getAllEventParticipants(bytes32 _eventId)
        external
        view
        returns (IVentura.Participant[] memory)
    {
        return
            VenturaLib._getAllEventParticipants(
                eventsCreated,
                participants,
                _eventId
            );
    }

    function turnEventOn(bytes32 _eventId) external {
        eventsCreated._turnEventOn(_eventId, msg.sender);
    }

    function endEvent(bytes32 _eventId) external {
        eventsCreated._endEvent(_eventId, msg.sender);
    }

    function markAttendance(bytes32 _eventId) external {
        VenturaLib._markAttendance(
            eventsCreated,
            participants,
            _eventId,
            msg.sender
        );
    }

    function getAllAttendees(bytes32 _eventId)
        external
        view
        returns (IVentura.Participant[] memory)
    {
        return
            VenturaLib._getAllAttendees(eventsCreated, participants, _eventId);
    }
}
