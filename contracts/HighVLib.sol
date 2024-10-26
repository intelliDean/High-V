// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IHighV.sol";
import "./Errors.sol";

library HighVLib {
    // 1
    function _createEvent(
        IHighV.Event storage eventDetails,
        IHighV.EventData memory _eventData,
        address _creator,
        bytes32 _eventId
    ) internal {
        eventDetails.eventId = _eventId;
        eventDetails.creator = _creator;
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

        uint _length = _eventData.dateTime.length;

        for (uint256 i = 0; i < _length; ) {
            eventDetails.dateTime.push(_eventData.dateTime[i]);
            unchecked {
                ++i; // increment without overflow check
            }
        }
    }

    //2
    function _getEventInfo(
        IHighV.Event storage eventDetails
    ) internal pure returns (IHighV.Event memory) {
        return eventDetails;
    }

    //3
    function _getCreator(
        IHighV.Event storage eventDetails
    ) internal view returns (address) {
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
            uint256 _allowance = PAYMENT.allowance(_user, _contractAddress);
            uint256 _eventPrice = eventDetails.price;

            if (_allowance < _eventPrice)
                revert Errors.INSUFFICIENT_ALLOWANCE(_allowance);

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

        uint _length = allAttendees.length;

        for (uint256 i = 0; i < _length; ) {
            _allRegistrants[i] = registrants[allAttendees[i]];
            unchecked {
                ++i; // increment without overflow check
            }
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
        for (uint256 i = 0; i < _length; ) {
            if (registrants[allAttendees[i]].attended) {
                count++;
            }
            unchecked {
                ++i; // increment without overflow check
            }
        }

        //i use the number to create an array
        _allAttendees = new IHighV.Registrant[](count);

        //fill the new array with the attendees
        uint256 index = 0;
        for (uint256 i = 0; i < _length; ++i) {
            if (registrants[allAttendees[i]].attended) {
                _allAttendees[index] = registrants[allAttendees[i]];

                unchecked {
                    ++index;
                }
            }
            unchecked {
                ++i; // increment without overflow check
            }
        }
    }

    //8 this will be done with scanning of the QR code at the event
    // if you are not marked attended, you will not get the NFT
    function _markAttendance(
        IHighV.Event storage eventDetails,
        mapping(address => IHighV.Registrant) storage registrants,
        address _user
    ) internal checkStarted(eventDetails) {
        if (registrants[_user].regAddress == address(0))
            revert Errors.NOT_REGISTERED(_user);

        registrants[_user].attended = true;
    }

    modifier checkStarted(IHighV.Event storage eventDetails) {
        if (eventDetails.eventStatus != IHighV.EventStatus.STARTED)
            revert Errors.EVENT_STATUS_ERROR();
        _;
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
    function _openOrCloseRegistration(
        IHighV.Event storage eventDetails
    ) internal returns (bytes32) {
        if (
            eventDetails.eventStatus == IHighV.EventStatus.CANCELLED ||
            eventDetails.eventStatus == IHighV.EventStatus.ENDED
        ) revert Errors.EVENT_STATUS_ERROR();

        eventDetails.regIsOn = !eventDetails.regIsOn;
        return eventDetails.eventId;
    }

    //14
    function _startEvent(
        IHighV.Event storage eventDetails
    ) internal returns (bytes32) {
        if (
            eventDetails.eventStatus != IHighV.EventStatus.NULL ||
            eventDetails.eventStatus != IHighV.EventStatus.POSTPONED ||
            eventDetails.eventStatus != IHighV.EventStatus.PAUSED
        ) revert Errors.CANNOT_START_EVENT();
        eventDetails.eventStatus = IHighV.EventStatus.STARTED;

        return eventDetails.eventId;
    }

    //15
    function _whitelistUser(
        mapping(address => bool) storage isWhitelisted,
        address[] memory _user
    ) internal returns (bool) {
        if (_user.length == 0) revert Errors.ZERO_ARRAY_LENGTH();

        uint _length = _user.length;

        for (uint256 i = 0; i < _length; ) {
            //do not whitelist address(0)
            if (_user[i] != address(0)) {
                isWhitelisted[_user[i]] = true;
            }
            unchecked {
                ++i; // increment without overflow check
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
    function _endEvent(
        IHighV.Event storage eventDetails
    ) internal checkStarted(eventDetails) returns (bytes32) {
        if (eventDetails.eventStatus != IHighV.EventStatus.PAUSED)
            revert Errors.CANNOT_END_EVENT();

        eventDetails.eventStatus = IHighV.EventStatus.ENDED;
        return eventDetails.eventId;
    }

    //18
    function _cancelEvent(
        IHighV.Event storage eventDetails
    ) internal returns (bytes32) {
        if (
            eventDetails.eventStatus != IHighV.EventStatus.NULL ||
            eventDetails.eventStatus != IHighV.EventStatus.POSTPONED
        ) revert Errors.CANNOT_CANCEL_EVENT();
        eventDetails.eventStatus = IHighV.EventStatus.CANCELLED;
        return eventDetails.eventId;
    }

    //19
    function _postponeEvent(
        IHighV.Event storage eventDetails
    ) internal returns (bytes32) {
        if (eventDetails.eventStatus != IHighV.EventStatus.NULL)
            revert Errors.CANNOT_POSTPONE_EVENT();

        eventDetails.eventStatus = IHighV.EventStatus.POSTPONED;
        return eventDetails.eventId;
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

        IHighV.Registrant memory _registrant = registrants[_attendee];

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
        mapping(string => uint256) storage userType,
        string[] storage allUserTypes,
        string[] memory _userTypes
    ) internal returns (bool) {
        if (_userTypes.length == 0) revert Errors.ZERO_ARRAY_LENGTH();

        uint _length = _userTypes.length;

        for (uint256 i = 0; i < _length; ) {
            userType[_userTypes[i]] = i + 1;
            allUserTypes.push(_userTypes[i]);

            unchecked {
                ++i; // increment without overflow check
            }
        }

        return true;
    }

    //22
    function _getAllUserTypes(
        string[] storage allUserTypes
    ) internal pure returns (string[] memory) {
        return allUserTypes;
    }

    //23
    function _addTypeToUsers(
        mapping(address => IHighV.Registrant) storage registrants,
        mapping(string => uint256) storage userType,
        address[] memory _users,
        string memory _userType
    ) internal returns (bool) {
        if (_users.length == 0) revert Errors.ZERO_ARRAY_LENGTH();

        uint _length = _users.length;

        for (uint256 i = 0; i < _length; ) {
            registrants[_users[i]].regType = userType[_userType];

            unchecked {
                ++i; // increment without overflow check
            }
        }

        return true;
    }

    //24
    function _pauseEvent(
        IHighV.Event storage eventDetails
    ) internal checkStarted(eventDetails) {
        eventDetails.eventStatus = IHighV.EventStatus.PAUSED;
    }

    //25
    function _getEventStatus(
        IHighV.Event storage eventDetails
    ) internal view returns (IHighV.EventStatus) {
        return eventDetails.eventStatus;
    }

    //26
    function _withdrawLockedEther(
        IHighV.Event storage eventDetails
    ) internal returns (bool) {
        (bool success, ) = eventDetails.creator.call{value: msg.value}("");
        if (!success) revert Errors.TRANSFER_FAIL();
        return success;
    }
}
