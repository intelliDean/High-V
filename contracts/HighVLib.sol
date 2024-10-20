// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IVentura.sol";
import "./Errors.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

library HighVLib {

    function _createEvent(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        bytes32[] storage events,
        IVentura.EventData memory _eventData,
        address _creator
    ) public returns (bytes32) {
        if (_creator == address(0)) revert Errors.ADDRESS_NOT_ALLOWED(_creator);
        if (_eventData.dateTime[0].eventDate < block.timestamp)
            revert Errors.INCORRECT_TIME_DATE();

        bytes32 _eventId = keccak256(abi.encode(_eventData, _creator));
        IVentura.Event storage _event = eventsCreated[_eventId];

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
            ? IVentura.EventType.PAID
            : IVentura.EventType.FREE;

        _event.createdAt = block.timestamp;

        for (uint256 i = 0; i < _eventData.dateTime.length; i++) {
            _event.dateTime.push(_eventData.dateTime[i]);
        }

        events.push(_eventId);

        return _eventId;
    }


    function _getAllEvents(
        bytes32[] storage events,
        mapping(bytes32 => IVentura.Event) storage eventsCreated
    ) public view returns (IVentura.Event[] memory _allEvents) {
        uint256 _eventLength = events.length;
        _allEvents = new IVentura.Event[](_eventLength);

        for (uint256 i = 0; i < _eventLength; i++) {
            _allEvents[i] = eventsCreated[events[i]];
        }
    }

    function _getEventById(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        bytes32 _eventId
    ) public view returns (IVentura.Event storage) {
        return eventsCreated[_eventId];
    }

    function _getAllMyEvents(
        bytes32[] storage events,
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        address _creator
    ) public view returns (IVentura.Event[] memory _myEvents) {
        // _myEvents = new IVentura.Event[](0);

        for (uint256 i = 0; i < events.length; i++) {
            IVentura.Event memory _event = eventsCreated[events[i]];

            if (_event.creator == _creator) {
                _myEvents[i] = _event;
            }
        }
    }

    function _updateCreatorEmail(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator,
        string memory _newEmail
    ) public {
        IVentura.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        _event.creatorEmail = _newEmail;
    }

    function _updateVenue(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator,
        string memory _newVenue
    ) public {
        IVentura.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        _event.venue = _newVenue;
    }

    function _openRegistration(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        address _creator,
        bytes32 _eventId
    ) public {
        IVentura.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (!_event.checks.regIsOn) {
            _event.checks.regIsOn = true;
        }
    }

    function _closeRegistration(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        address _creator,
        bytes32 _eventId
    ) public {
        IVentura.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (_event.checks.regIsOn) {
            _event.checks.regIsOn = false;
        }
    }

    function _register4Event(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        mapping(address => mapping(bytes32 => IVentura.Participant))
            storage participants,
        IERC20 PAYMENT,
        bytes32 _eventId,
        address _user,
        address _cotractAddress,
        string memory _email
    ) public {
        IVentura.Event storage _event = eventsCreated[_eventId];

        if (!_event.checks.regIsOn) revert Errors.REG_IS_NOT_ON();
        if (participants[_user][_eventId].participantAddress != address(0))
            revert Errors.REGISTERED_ALREADY();

        if (_event.eventType == IVentura.EventType.PAID) {//PAID EVENT

            uint256 _userBalance = PAYMENT.balanceOf(_user);
            uint256 _eventPrice = _event.price;

            if (_userBalance < _eventPrice)
                revert Errors.INSUFFICIENT_BALANCE(_userBalance);

            //User would have approved this tx from the payment contract
            //usually frontend will call the payment contract directly so the user can approve this tx
            if (PAYMENT.transferFrom(_user, _cotractAddress, _eventPrice)) {
                _addParticipant(participants, _event, _user, _eventId, _email);
            } else {
                revert Errors.REG_FAILED();
            }
        } else {//FREE EVENT
            _addParticipant(participants, _event, _user, _eventId, _email);
        }
    }

    function _addParticipant(
        mapping(address => mapping(bytes32 => IVentura.Participant))
            storage participants,
        IVentura.Event storage _event,
        address _user,
        bytes32 _eventId,
        string memory _email
    ) private {
        IVentura.Participant storage _participant = participants[_user][
            _eventId
        ];
        _participant.participantAddress = _user;
        _participant.email = _email;
        _participant.userType = 1;

        _event.participants.push(_user);
    }

    function _creatorWhitelistAddress(
        mapping(address => bool) storage isWhitelisted,
        address _user
    ) {
        code
    }

    // function _creatorAddUser(
    //     mapping(bytes32 => IVentura.Event) storage eventsCreated,
    //     mapping(address => mapping(bytes32 => IVentura.Participant))
    //         storage participants,
    //     bytes32 _eventId,
    //     address _creator,
    //     address _user,
    //     string memory _email
    // ) public {
    //     IVentura.Event storage _event = _getEventById(eventsCreated, _eventId);
    //     if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);



    // }


    function _getAllEventParticipants(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        mapping(address => mapping(bytes32 => IVentura.Participant))
            storage participants,
        bytes32 _eventId
    ) public view returns (IVentura.Participant[] memory _allParticipants) {
        address[] memory _participantsAddress = eventsCreated[_eventId]
            .participants;

        for (uint256 i = 0; i < _participantsAddress.length; i++) {
            _allParticipants[i] = participants[_participantsAddress[i]][
                _eventId
            ];
        }
    }

    function _turnEventOn(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator
    ) public {
        IVentura.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (!_event.checks.eventIsOn) {
            _event.checks.eventIsOn = true;
        }
    }

    function _endEvent(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        bytes32 _eventId,
        address _creator
    ) public {
        IVentura.Event storage _event = _getEventById(eventsCreated, _eventId);
        if (_creator != _event.creator) revert Errors.ONLY_OWNER(_creator);

        if (_event.checks.eventIsOn) {
            _event.checks.eventIsOn = false;
        }
    }

    function _markAttendance(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        mapping(address => mapping(bytes32 => IVentura.Participant))
            storage participants,
        bytes32 _eventId,
        address _participant
    ) public {
        if (!eventsCreated[_eventId].checks.eventIsOn)
            revert Errors.EVENT_NOT_ON();
        if (
            participants[_participant][_eventId].participantAddress ==
            address(0)
        ) revert Errors.NOT_REGISTERED(_participant, _eventId);

        if (!participants[_participant][_eventId].attended) {
            participants[_participant][_eventId].attended = true;
        }
    }

    function _getAllAttendees(
        mapping(bytes32 => IVentura.Event) storage eventsCreated,
        mapping(address => mapping(bytes32 => IVentura.Participant))
            storage participants,
        bytes32 _eventId
    ) public view returns (IVentura.Participant[] memory _allAttendees) {
        address[] memory _participantsAddress = eventsCreated[_eventId]
            .participants;

        for (uint256 i = 0; i < _participantsAddress.length; i++) {
            IVentura.Participant memory _attendee = participants[
                _participantsAddress[i]
            ][_eventId];

            if (_attendee.attended) {
                _allAttendees[i] = _attendee;
            }
        }
    }
}
