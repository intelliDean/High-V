// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IHighV.sol";
import "./HighV.sol";
import "./HighVNFT.sol";
import "./Errors.sol";

library HighVFactoryLib {
    function _initiateContract(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId
    ) public view returns (IHighV) {
        return IHighV(eventsAddresses[_eventId]);
    }

    //2
    function _getEventDetails(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId
    ) public view returns (IHighV.Event memory) {
        return _initiateContract(eventsAddresses, _eventId).getEventInfo();
    }

    //3
    function _getEventCreator(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId
    ) public view returns (address) {
        return _initiateContract(eventsAddresses, _eventId).getCreator();
    }

    //4
    function _userRegister4Event(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user,
        string memory _email
    ) public {
        _initiateContract(eventsAddresses, _eventId).register4Event(
            _user,
            _email
        );
    }

    //5
    function _getEventRegistrant(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user
    ) public view returns (IHighV.Registrant memory) {
        return
            _initiateContract(eventsAddresses, _eventId).getRegistrant(_user);
    }

    //6
    function _getAllEventRegistrants(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId
    ) public view returns (IHighV.Registrant[] memory) {
        return _initiateContract(eventsAddresses, _eventId).getAllRegistrant();
    }

    //7
    function _getAllEventAttendees(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId
    ) public view returns (IHighV.Registrant[] memory) {
        return _initiateContract(eventsAddresses, _eventId).getAllAttendees();
    }

    //8
    function _userMarkAttendance(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user
    ) public {
        _initiateContract(eventsAddresses, _eventId).markAttendance(_user);
    }

    //9
    function _creatorUpdateVenue(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user,
        string memory _venue
    ) public {
        _initiateContract(eventsAddresses, _eventId).updateVenue(_user, _venue);
    }

    //10
    function _creatorUpdateEmail(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user,
        string memory _creatorEmail
    ) public {
        _initiateContract(eventsAddresses, _eventId).updateCreatorEmail(
            _user,
            _creatorEmail
        );
    }

    //11
    function _creatorUpdateEventImageUrl(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user,
        string memory _eventImageUrl
    ) public {
        _initiateContract(eventsAddresses, _eventId).updateEventImageUrl(
            _user,
            _eventImageUrl
        );
    }

    //12
    function _updateEventPrice(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user,
        uint256 _price
    ) public {
        _initiateContract(eventsAddresses, _eventId).updateEventPrice(
            _user,
            _price
        );
    }

    //13
    function _creatorOpenOrCloseRegistration(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user
    ) public {
        _initiateContract(eventsAddresses, _eventId).openOrCloseRegistration(
            _user
        );
    }

    //14
    function _creatorStartEvent(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user
    ) public {
        _initiateContract(eventsAddresses, _eventId).startEvent(_user);
    }

    //15
    function _creatorWhitelistUsers(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _creator,
        address[] memory _user
    ) public returns (bool) {
        return
            _initiateContract(eventsAddresses, _eventId).whitelistUser(
                _creator,
                _user
            );
    }

    //16
    function _creatorUpdatePhoneNumber(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _creator,
        string memory _creatorPhoneNumber
    ) public {
        _initiateContract(eventsAddresses, _eventId).updateCreatorPhoneNumber(
            _creator,
            _creatorPhoneNumber
        );
    }

    //====
    //17
    function _creatorEndEvent(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _creator
    ) public {
        _initiateContract(eventsAddresses, _eventId).endEvent(_creator);
    }

    //18
    function _creatorCancelEvent(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _creator
    ) public {
        _initiateContract(eventsAddresses, _eventId).cancelEvent(_creator);
    }

    //19
    function _creatorPostponeEvent(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _creator
    ) public {
        _initiateContract(eventsAddresses, _eventId).postponeEvent(_creator);
    }

    //20
    function _attendeeClaimPOAP(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _attendee
    ) public {
        _initiateContract(eventsAddresses, _eventId).claimPOAP(_attendee);
    }

    //21
    function _creatorAddUserTypes(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _creator,
        string[] memory _userTypes
    ) public returns (bool) {
        return
            _initiateContract(eventsAddresses, _eventId).addUserTypes(
                _creator,
                _userTypes
            );
    }

    //22
    function _allUserTypes(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId
    ) public view returns (string[] memory) {
        return _initiateContract(eventsAddresses, _eventId).getAllUserTypes();
    }

    //23
    function _creatorAddTypeToUsers(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _creator,
        address[] memory _users,
        string memory _userType
    ) public returns (bool) {
        return
            _initiateContract(eventsAddresses, _eventId).addTypeToUsers(
                _creator,
                _users,
                _userType
            );
    }

    //24
    function _creatorPauseEvent(
        mapping(bytes32 => address) storage eventsAddresses,
        bytes32 _eventId,
        address _user
    ) public {
        _initiateContract(eventsAddresses, _eventId).pauseEvent(_user);
    }

    //25
    function _getAllEventDetails(address[] storage allEvents)
        public
        view
        returns (IHighV.Event[] memory _allEventDetails)
    {
        uint256 _length = allEvents.length;
        _allEventDetails = new IHighV.Event[](_length);

        for (uint256 i = 0; i < _length; ++i) {
            _allEventDetails[i] = IHighV(allEvents[i]).getEventInfo();
        }
    }

    //26
    function _creatorClaimEventNFT(
        mapping(bytes32 => address) storage eventsAddresses,
        address _caller,
        IHighV _creatorNFT,
        bytes32 _eventId
    ) public {
        IHighV.Event memory _event = _getEventDetails(
            eventsAddresses,
            _eventId
        );
        if (
            _caller == _event.creator &&
            _event.eventStatus == IHighV.EventStatus.ENDED
        ) {
            _creatorNFT.mint(_event.creator, 1);
        } else {
            revert Errors.INELLIGIBLE(_caller);
        }
    }
}
