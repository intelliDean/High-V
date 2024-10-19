// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IHighV.sol";
import "./Errors.sol";

library VenturaLib {

    function _createEvent(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        bytes32[] storage events,
        IHighV.EventData memory _eventData,
        address _creator
    ) public returns (bytes32) {
        if (_creator == address(0)) revert Errors.ADDRESS_NOT_ALLOWED(_creator);
        if (_eventData.dateTime[0].eventDate < block.timestamp) revert Errors.INCORRECT_TIME_DATE();

        bytes32 _eventId = keccak256(abi.encode(_eventData, _creator));
        IHighV.Event storage _event = eventsCreated[_eventId];

        _event.creator = _creator;
        _event.creatorEmail = _eventData.creatorEmail;
        _event.eventId = _eventId;
        _event.eventImageUrl = _eventData.eventImageUrl;
        _event.eventTitle = _eventData.eventTitle;
        _event.description = _eventData.description;
        _event.venue = _eventData.venue;
        _event.price = _eventData.price;
        _event.eventCategory = _eventData.eventCategory;

        _event.eventType = _eventData.price > 0
            ? IHighV.EventType.PAID
            : IHighV.EventType.FREE;

        _event.createdAt = block.timestamp;

        for (uint256 i = 0; i < _eventData.dateTime.length; i++) {
            _event.dateTime.push(_eventData.dateTime[i]);
        }

        events.push(_eventId);

        return _eventId;
    }

    function _getAllEvents(
        bytes32[] storage events,
        mapping(bytes32 => IHighV.Event) storage eventsCreated
    ) public view returns (IHighV.Event[] memory _allEvents) {
        uint256 _eventLength = events.length;
        _allEvents = new IHighV.Event[](_eventLength);

        for (uint256 i = 0; i < _eventLength; i++) {
            _allEvents[i] = eventsCreated[events[i]];
        }
    }

    function _getEventById( 
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        bytes32 _eventId
    ) public view returns (IHighV.Event storage) {
        return eventsCreated[_eventId];
    }

    function _getAllMyEvents(
        bytes32[] storage events,
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        address _creator
    ) public view returns (IHighV.Event[] memory _myEvents) {

        // _myEvents = new IHighV.Event[](0);

        for (uint256 i = 0; i < events.length; i++) {
            IHighV.Event memory _event = eventsCreated[events[i]];

            if (_event.creator == _creator) {
                _myEvents[i] = _event;
            }
        }
    }

    function _updateCreatorEmail(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator,
        string memory _newEmail
    ) public {

        IHighV.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        _event.creatorEmail = _newEmail;
    }

    function _updateVenue(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator,
        string memory _newVenue
    ) public {

        IHighV.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        _event.venue = _newVenue;
    }

    function _openRegistration(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        address _creator,
        bytes32 _eventId
    ) public {

        IHighV.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (!_event.checks.regIsOn) {
            _event.checks.regIsOn = true;
        }
    }

    function _closeRegistration(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        address _creator,
        bytes32 _eventId
    ) public {

        IHighV.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (_event.checks.regIsOn) {
            _event.checks.regIsOn = false;
        }
    }

    function _register4Event(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        mapping (address => mapping (bytes32 => IHighV.Participant)) storage participants,
        bytes32 _eventId,
        address _user,
        string memory _email
    ) public {

        IHighV.Event storage _event = eventsCreated[_eventId];

        if (!_event.checks.regIsOn) revert Errors.REG_IS_NOT_ON();
        if (participants[_user][_eventId].participantAddress != address(0)) 
            revert Errors.REGISTERED_ALREADY();

       IHighV.Participant storage _participant = participants[_user][_eventId];
       _participant.participantAddress = _user;
       _participant.email = _email;

        _event.participants.push(_user);
    }

    function _getAllEventParticipants(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        mapping (address => mapping (bytes32 => IHighV.Participant)) storage participants,
        bytes32 _eventId
    ) public view returns (IHighV.Participant[] memory _allParticipants) {

        address[] memory _participantsAddress = eventsCreated[_eventId].participants;

        for (uint256 i = 0; i < _participantsAddress.length; i++) {
            _allParticipants[i] = participants[_participantsAddress[i]][_eventId];
        }   
    }

    function _turnEventOn(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator
    ) public {

        IHighV.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (!_event.checks.eventIsOn) {
            _event.checks.eventIsOn = true;
        }
    }

    function _endEvent(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator
    ) public {

        IHighV.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (_event.checks.eventIsOn) {
            _event.checks.eventIsOn = false;
        }
    }

    function _markAttendance(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        mapping (address => mapping (bytes32 => IHighV.Participant)) storage participants,
        bytes32 _eventId,
        address _participant
    ) public {

        if (!eventsCreated[_eventId].checks.eventIsOn) revert Errors.EVENT_NOT_ON();
        if (participants[_participant][_eventId].participantAddress == address(0))
            revert Errors.NOT_REGISTERED(_participant, _eventId);

            if (!participants[_participant][_eventId].attended) {
                participants[_participant][_eventId].attended = true;
            }
    }

    function _getAllAttendees(
        mapping(bytes32 => IHighV.Event) storage eventsCreated,
        mapping (address => mapping (bytes32 => IHighV.Participant)) storage participants,
        bytes32 _eventId
    ) public view returns (IHighV.Participant[] memory _allAttendees) {

        address[] memory _participantsAddress = eventsCreated[_eventId].participants;

        for (uint256 i = 0; i < _participantsAddress.length; i++) {

            IHighV.Participant memory _attendee = participants[_participantsAddress[i]][_eventId];

            if (_attendee.attended) {
                _allAttendees[i] = _attendee;
            }
        }   
    }
}
