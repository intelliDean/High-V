// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IHighV.sol";
import "./Errors.sol";

library HighVLib {
    // 1
    function _createEvent(
        IHighV.Event storage eventDetails,
        IHighV.EventData memory _eventData,
        bytes32 _eventId
    ) internal {
        eventDetails.eventId = _eventId;
        eventDetails.creatorPhoneNumber = _eventData.creatorPhone;
        eventDetails.creatorEmail = _eventData.creatorEmail;
        eventDetails.eventImageUrl = _eventData.eventImageUrl;
        eventDetails.eventTitle = _eventData.eventTitle;
        eventDetails.description = _eventData.description;
        eventDetails.venue = _eventData.venue;
        eventDetails.price = _eventData.price;
        eventDetails.eventCategory = _eventData.eventCategory;
        eventDetails.eventType = _eventData.price > 0
            ? IHighV.EventType.PAID
            : IHighV.EventType.FREE;
        eventDetails.createdAt = block.timestamp;

        for (uint256 i = 0; i < _eventData.dateTime.length; i++) {
            eventDetails.dateTime.push(_eventData.dateTime[i]);
        }
    }

    //2
    function _getEventInfo(IHighV.Event storage eventDetails)
        internal
        pure
        returns (IHighV.Event memory)
    {
        return eventDetails;
    }

    //3
    function _getCreator(IHighV.Event storage eventDetails)
        internal
        view
        returns (address)
    {
        return eventDetails.creator;
    }

    //4
    function _register4Event(
        IHighV.Event storage eventDetails,
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees,
        mapping(address => bool) storage isWhitelisted,
        IHighV PAYMENT,
        address _user,
        address _contractAddress,
        string memory _email
    ) internal {
        if (!eventDetails.regIsOn) revert Errors.REG_IS_NOT_ON();

        if (isWhitelisted[_user]) {
            _addRegistrant(registrants, allAttendees, _user, _email);
        } else if (eventDetails.eventType == IHighV.EventType.PAID) {
            uint256 _userBalance = PAYMENT.balanceOf(_user);
            uint256 _eventPrice = eventDetails.price;

            if (_userBalance < _eventPrice)
                revert Errors.INSUFFICIENT_BALANCE(_userBalance);

            //if the event is paid, the user would first approve the contract to spend the event amount on his behalf
            if (!PAYMENT.transferFrom(_user, _contractAddress, _eventPrice))
                revert Errors.TRANSFER_FAIL();

            _addRegistrant(registrants, allAttendees, _user, _email);
        } else {
            _addRegistrant(registrants, allAttendees, _user, _email);
        }
    }

    //4a
    function _addRegistrant(
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees,
        address _user,
        string memory _email
    ) private {
        if (registrants[_user].regAddress != address(0))
            revert Errors.REGISTERED_ALREADY();

        IHighV.Registrant storage _registrant = registrants[_user];
        _registrant.regAddress = _user;
        _registrant.email = _email;
        _registrant.regType = 1;

        allAttendees.push(_user);
    }

    //5
    function _getRegistrant(
        mapping(address => IHighV.Registrant) storage registrants,
        address _user
    ) internal view returns (IHighV.Registrant memory) {
        return registrants[_user];
    }

    //6
    function _getAllRegistrant(
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees
    ) internal view returns (IHighV.Registrant[] memory _allRegistrants) {
        _allRegistrants = new IHighV.Registrant[](allAttendees.length);

        for (uint256 i = 0; i < allAttendees.length; ++i) {
            _allRegistrants[i] = registrants[allAttendees[i]];
        }
    }

    //7
    function _getAllAttendees(
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees
    ) internal view returns (IHighV.Registrant[] memory _allAttendees) {
        uint256 count = 0;
        uint256 _length = allAttendees.length;

        //i first get the number of atendees
        for (uint256 i = 0; i < _length; ++i) {
            if (registrants[allAttendees[i]].attended) {
                count++;
            }
        }

        //i use the number to create an array
        _allAttendees = new IHighV.Registrant[](count);

        //fill the new array with the attendees
        uint256 index = 0;
        for (uint256 i = 0; i < _length; ++i) {
            if (registrants[allAttendees[i]].attended) {
                _allAttendees[index] = registrants[allAttendees[i]];
                index++;
            }
        }
    }

    //8 this will be done with scanning of the QR code at the event
    // if you are not marked attended, you will not get the NFT
    function _markAttendance(
        IHighV.Event storage eventDetails,
        mapping(address => IHighV.Registrant) storage registrants,
        address _user
    ) internal {
        if (registrants[_user].regAddress == address(0))
            revert Errors.NOT_REGISTERED(_user);
        if (eventDetails.eventStatus != IHighV.EventStatus.STARTED)
            revert Errors.EVENT_STATUS_ERROR();

        registrants[_user].attended = true;
    }

    //9
    function _updateVenue(
        IHighV.Event storage eventDetails,
        string memory _venue
    ) internal {
        eventDetails.venue = _venue;
    }

    //10
    function _updateCreatorEmail(
        IHighV.Event storage eventDetails,
        string memory _creatorEmail
    ) internal {
        eventDetails.creatorEmail = _creatorEmail;
    }

    //11
    function _updateEventImageUrl(
        IHighV.Event storage eventDetails,
        string memory _eventImageUrl
    ) internal {
        eventDetails.eventImageUrl = _eventImageUrl;
    }

    //12
    //will update later to cater for different category with different price
    function _updateEventPrice(
        IHighV.Event storage eventDetails,
        uint256 _price
    ) internal {
        eventDetails.price = _price;

        eventDetails.eventType = eventDetails.price > 0
            ? IHighV.EventType.PAID
            : IHighV.EventType.FREE;
    }

    //13
    function _openOrCloseRegistration(IHighV.Event storage eventDetails)
        internal
    {
        if (
            eventDetails.eventStatus == IHighV.EventStatus.CANCELLED ||
            eventDetails.eventStatus == IHighV.EventStatus.ENDED
        ) revert Errors.EVENT_STATUS_ERROR();

        eventDetails.regIsOn = !eventDetails.regIsOn;
    }

    //14
    function _startEvent(IHighV.Event storage eventDetails) internal {
        if (
            eventDetails.eventStatus != IHighV.EventStatus.NULL ||
            eventDetails.eventStatus != IHighV.EventStatus.POSTPONED ||
            eventDetails.eventStatus != IHighV.EventStatus.PAUSED
        ) revert Errors.CANNOT_START_EVENT();
        eventDetails.eventStatus = IHighV.EventStatus.STARTED;
    }

    //15
    function _whitelistUser(
        mapping(address => bool) storage isWhitelisted,
        address[] memory _user
    ) internal returns (bool) {
        if (_user.length == 0) revert Errors.ZERO_ARRAY_LENGTH();

        for (uint256 i = 0; i < _user.length; ++i) {
            //do not whitelist address(0)
            if (_user[i] != address(0)) {
                isWhitelisted[_user[i]] = true;
            }
        }

        return true;
    }

    //16
    function _updateCreatorPhoneNumber(
        IHighV.Event storage eventDetails,
        string memory _creatorPhoneNumber
    ) internal {
        eventDetails.creatorPhoneNumber = _creatorPhoneNumber;
    }

    //17
    function _endEvent(IHighV.Event storage eventDetails) internal {
        if (
            eventDetails.eventStatus != IHighV.EventStatus.STARTED ||
            eventDetails.eventStatus != IHighV.EventStatus.PAUSED
        ) revert Errors.CANNOT_END_EVENT();
        eventDetails.eventStatus = IHighV.EventStatus.ENDED;
    }

    //18
    function _cancelEvent(IHighV.Event storage eventDetails) internal {
        if (
            eventDetails.eventStatus != IHighV.EventStatus.NULL ||
            eventDetails.eventStatus != IHighV.EventStatus.POSTPONED
        ) revert Errors.CANNOT_CANCEL_EVENT();
        eventDetails.eventStatus = IHighV.EventStatus.CANCELLED;
    }

    //19
    function _postponeEvent(IHighV.Event storage eventDetails) internal {
        if (eventDetails.eventStatus != IHighV.EventStatus.NULL)
            revert Errors.CANNOT_POSTPONE_EVENT();

        eventDetails.eventStatus = IHighV.EventStatus.POSTPONED;
    }

    //20
    function _claimPOAP(
        IHighV.Event storage eventDetails,
        mapping(address => IHighV.Registrant) storage registrants,
        IHighV HIGHVNFT,
        address _attendee
    ) internal returns (bool) {
        if (eventDetails.eventStatus != IHighV.EventStatus.ENDED)
            revert Errors.EVENT_NOT_ENDED();

        IHighV.Registrant memory _registrant = _getRegistrant(
            registrants,
            _attendee
        );

        if (_registrant.attended) {
            //minting of the POAP NFT
            HIGHVNFT.mint(_registrant.regAddress, _registrant.regType);
        } else {
            revert Errors.INELLIGIBLE(_attendee);
        }
        return true;
    }

    //21
    function _addUserTypes(
        mapping(string => uint8) storage userType,
        string[] storage allUserTypes,
        string[] memory _userTypes
    ) internal returns (bool) {
        if (_userTypes.length == 0) revert Errors.ZERO_ARRAY_LENGTH();

        for (uint8 i = 0; i < _userTypes.length; ++i) {
            userType[_userTypes[i]] = i + 1;
            allUserTypes.push(_userTypes[i]);
        }

        return true;
    }

    //22
    function _getAllUserTypes(string[] storage allUserTypes)
        internal
        pure
        returns (string[] memory)
    {
        return allUserTypes;
    }

    //23
    function _addTypeToUsers(
        mapping(address => IHighV.Registrant) storage registrants,
        mapping(string => uint8) storage userType,
        address[] memory _users,
        string memory _userType
    ) internal returns (bool) {
        if (_users.length == 0) revert Errors.ZERO_ARRAY_LENGTH();

        for (uint256 i = 0; i < _users.length; ++i) {
            registrants[_users[i]].regType = userType[_userType];
        }

        return true;
    }

    //24
    function _pauseEvent(IHighV.Event storage eventDetails) internal {
        if (eventDetails.eventStatus != IHighV.EventStatus.STARTED)
            revert Errors.CANNOT_PAUSE_EVENT();
        eventDetails.eventStatus = IHighV.EventStatus.PAUSED;
    }
}
