// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./HighVLib.sol";
import "./HighVNFT.sol";
import "./IHighV.sol";

contract HighV {

    using HighVLib for *;
    address immutable owner;
    

    bytes32[] public events;

    mapping(bytes32 => IHighV.Event) public eventsCreated;
    mapping(address => mapping(bytes32 => IHighV.Participant)) participants;


    event ContractCreated(address indexed contractAddress);
    event EventCreated(address indexed _creator, bytes32 indexed _eventId);

    constructor(address _owner) {
        if (_owner == address(0)) revert Errors.ADDRESS_NOT_ALLOWED(_owner);
        owner = _owner;

        emit ContractCreated(address(this));
    }

    function createEvent(IHighV.EventData memory _eventData) external {

       bytes32 _eventId = HighVLib._createEvent(
            eventsCreated,
            events,
            _eventData,
            msg.sender
        );

        emit EventCreated(msg.sender, _eventId);
    }

    function getAllEvents() external view returns (IHighV.Event[] memory) {
        return HighVLib._getAllEvents(events, eventsCreated);
    }

    function getEventById(bytes32 _eventId) external view returns (IHighV.Event memory) {
        return eventsCreated._getEventById(_eventId);
    }

    function _getAllMyEvents() external view returns (IHighV.Event[] memory) {
        return HighVLib._getAllMyEvents(events, eventsCreated, msg.sender);
    }

    function updateCreatorEmail(bytes32 _eventId, string memory _newEmail) external {
        eventsCreated._updateCreatorEmail(_eventId, msg.sender, _newEmail);
    }

    function updateVenue( bytes32 _eventId, string memory _newVenue) external {
        eventsCreated._updateVenue(_eventId, msg.sender, _newVenue);
    }

    function openRegistration(bytes32 _eventId) external {
        eventsCreated._openRegistration(msg.sender, _eventId);
    }

    function closeRegistration(address _creator, bytes32 _eventId) external {
        eventsCreated._closeRegistration(_creator, _eventId);
    }

    function register4Event(bytes32 _eventId, string memory _email) external {
        HighVLib._register4Event(eventsCreated, participants, _eventId, msg.sender, _email);
    }

    function getAllEventParticipants(bytes32 _eventId) external view returns (IHighV.Participant[] memory) {
        return HighVLib._getAllEventParticipants(eventsCreated, participants, _eventId);
    }

    function turnEventOn(bytes32 _eventId) external {
        eventsCreated._turnEventOn(_eventId, msg.sender);
    }

    function endEvent(bytes32 _eventId) external {
        eventsCreated._endEvent(_eventId, msg.sender);
    }

    function markAttendance(bytes32 _eventId) external {
        HighVLib._markAttendance(eventsCreated, participants, _eventId, msg.sender);
    }

    function getAllAttendees(bytes32 _eventId) external view returns (IHighV.Participant[] memory) {
        return HighVLib._getAllAttendees(eventsCreated, participants, _eventId);
    }
}
