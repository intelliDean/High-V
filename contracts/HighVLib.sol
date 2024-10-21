// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/IHighV.sol";
import "contracts/Errors.sol";

library HighVLib {
    // 1
    function _createEvent(
        IHighV.Event storage eventDetails,
        IHighV.EventData memory _eventData
    ) public {
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
        public
        pure
        returns (IHighV.Event memory)
    {
        return eventDetails;
    }

    //3
    function _getCreator(address _creator) public pure returns (address) {
        return _creator;
    }

    //4
    //this will be updated later to include payment and also the whitelisted users
    function _register4Event(
        IHighV.Event storage eventDetails,
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees,
        mapping(address => bool) storage isWhitelisted,
        IHighV PAYMENT,
        address _user,
        address _contractAddress,
        string memory _email
    ) public {

        if (isWhitelisted[_user]) {
            _addRegistrant(registrants, allAttendees, _user, _email);

        } else if (eventDetails.eventType == IHighV.EventType.PAID) {

            uint256 _userBalance = PAYMENT.balanceOf(_user);
            uint256 _eventPrice = eventDetails.price;

            if (_userBalance < _eventPrice)
                revert Errors.INSUFFICIENT_BALANCE(_userBalance);

            if (!PAYMENT.transferFrom(_user, _contractAddress, _eventPrice))
                revert Errors.TRANSFER_FAIL();

            _addRegistrant(registrants, allAttendees, _user, _email);

        } else {
            
            _addRegistrant(registrants, allAttendees, _user, _email);
        }
    }

    function _addRegistrant(
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees,
        address _user,
        string memory _email
    ) private {
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
    ) public view returns (IHighV.Registrant memory) {
        return registrants[_user];
    }

    //6
    function _getAllRegistrant(
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees
    ) public view returns (IHighV.Registrant[] memory _allRegistrants) {
        _allRegistrants = new IHighV.Registrant[](allAttendees.length);

        for (uint256 i = 0; i < allAttendees.length; i++) {
            _allRegistrants[i] = registrants[allAttendees[i]];
        }
    }

    //7
    function _getAllAttendees(
        mapping(address => IHighV.Registrant) storage registrants,
        address[] storage allAttendees
    ) public view returns (IHighV.Registrant[] memory _allAttendees) {
        uint256 count = 0;
        uint256 _length = allAttendees.length;

        for (uint256 i = 0; i < _length; i++) {
            if (registrants[allAttendees[i]].attended) {
                count++;
            }
        }

        _allAttendees = new IHighV.Registrant[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < _length; i++) {
            if (registrants[allAttendees[i]].attended) {
                _allAttendees[index] = registrants[allAttendees[i]];
                index++;
            }
        }
    }

    //8
    function _markAttendance(
        mapping(address => IHighV.Registrant) storage registrants,
        address _user
    ) public {
        registrants[_user].attended = true;
    }

    //9
    function _updateVenue(
        IHighV.Event storage eventDetails,
        string memory _venue
    ) public {
        eventDetails.venue = _venue;
    }

    //10
    function _updateCreatorEmail(
        IHighV.Event storage eventDetails,
        string memory _creatorEmail
    ) public {
        eventDetails.creatorEmail = _creatorEmail;
    }

    //11
    function _updateEventImageUrl(
        IHighV.Event storage eventDetails,
        string memory _eventImageUrl
    ) public {
        eventDetails.eventImageUrl = _eventImageUrl;
    }

    //12
    function _updateEventPrice(
        IHighV.Event storage eventDetails,
        uint256 _price
    ) public {
        eventDetails.price = _price;

        eventDetails.eventType = eventDetails.price > 0
            ? IHighV.EventType.PAID
            : IHighV.EventType.FREE;
    }

    //13
    function _openOrCloseRegistration(IHighV.Event storage eventDetails)
        public
    {
        eventDetails.regIsOn = !eventDetails.regIsOn;
    }

    //14
    function _startEvent(IHighV.Event storage eventDetails) public {
        eventDetails.eventStatus = IHighV.EventStatus.START;
    }

    //15
    function _whitelistUser(
        mapping(address => bool) storage isWhitelisted,
        address[] memory _user
    ) public {
        for (uint256 i = 0; i < _user.length; i++) {
            isWhitelisted[_user[i]] = true;
        }
    }

    //16
    function _updateCreatorPhoneNumber(
        IHighV.Event storage eventDetails,
        string memory _creatorPhoneNumber
    ) public {
        eventDetails.creatorPhoneNumber = _creatorPhoneNumber;
    }

    //17
    function _endEvent(IHighV.Event storage eventDetails) public {
        eventDetails.eventStatus = IHighV.EventStatus.ENDED;
    }

    //18
    function _cancelEvent(IHighV.Event storage eventDetails) public {
        eventDetails.eventStatus = IHighV.EventStatus.CANCELLED;
    }

    //19
    function _postponeEvent(IHighV.Event storage eventDetails) public {
        eventDetails.eventStatus = IHighV.EventStatus.POSTPONED;
    }

    //20
    function _claimPOAP(
        IHighV.Event storage eventDetails,
        mapping(address => IHighV.Registrant) storage registrants,
        IHighV HIGHVNFT,
        address _attendee
    ) public {
        if (eventDetails.eventStatus != IHighV.EventStatus.ENDED)
            revert Errors.EVENT_NOT_ENDED();

        IHighV.Registrant memory _registrant = _getRegistrant(
            registrants,
            _attendee
        );

        if (_registrant.attended) {
            HIGHVNFT.mint(_registrant.regAddress, _registrant.regType, 1);
        } else {
            revert Errors.INELLIGIBLE(_attendee);
        }
    }

    //21
    function _addUserTypes(
        mapping(string => uint8) storage userType,
        string[] storage allUserTypes,
        string[] memory _userTypes
    ) public {
        for (uint8 i = 0; i < _userTypes.length; i++) {
            userType[_userTypes[i]] = i + 1;
            allUserTypes.push(_userTypes[i]);
        }
    }

    //22
    function _getAllUserTypes(string[] storage allUserTypes)
        public
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
    ) public {
        for (uint256 i = 0; i < _users.length; i++) {
            registrants[_users[i]].regType = userType[_userType];
        }
    }
}
