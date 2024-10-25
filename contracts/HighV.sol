// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IHighV.sol";
import "./HighVLib.sol";
import "./Errors.sol";
import "./HighVNFT.sol";

contract HighV {
    using HighVLib for *;

    IHighV HIGHVNFT;
    IHighV PAYMENT;

    IHighV.Event eventDetails;

    address[] allAttendees;
    string[] allUserTypes;

    mapping(address => IHighV.Registrant) public registrants;
    mapping(address => bool) public isWhitelisted;
    mapping(string => uint8) public userType;

    event ContractCreated(
        address indexed contractAddress,
        address indexed nftContract,
        address indexed paymentAddress
    );
    event Registered(address indexed user, bytes32 indexed eventId);
    event Attendance(address indexed user, bytes32 indexed eventId);
    event UpdatePrice(bytes32 indexed eventId, uint256 indexed _price);
    event Updated(
        bytes32 indexed eventId,
        string indexed fieldUpdated,
        string indexed update
    );
    event RegStatus(bytes32 indexed eventId, bool regStatus);
    event EventStatus(bytes32 indexed eventId, IHighV.EventStatus eventStatus);
    event ClaimPOAP(
        bytes32 indexed eventId,
        address indexed _attendee,
        uint8 indexed POAP_Type
    );

    constructor(
        address _creator,
        address _paymentAddress,
        address nftContract,
        IHighV.EventData memory _eventData,
        bytes32 _eventId
    ) {
        eventDetails.creator = _creator;

        //NFT Contract
        HIGHVNFT = IHighV(nftContract);
        PAYMENT = IHighV(_paymentAddress);

        //1
        eventDetails._createEvent(_eventData, _eventId);

        emit ContractCreated(address(this), nftContract, _paymentAddress);
    }

    modifier onlyOwner(address _creator) {
        if (_creator != eventDetails.creator)
            revert Errors.ONLY_OWNER(_creator);
        _;
    }

    modifier addressZeroCheck(address _user) {
        if (_user == address(0)) revert Errors.ADDRESS_ZERO();
        _;
    }

    //2
    function getEventInfo() external view returns (IHighV.Event memory) {
        return eventDetails._getEventInfo();
    }

    //3
    function getCreator() external view returns (address) {
        return eventDetails._getCreator();
    }

    //4
    //register for event
    function register4Event(address _user, string memory _email)
        external
        addressZeroCheck(_user)
    {
        HighVLib._register4Event(
            eventDetails,
            registrants,
            allAttendees,
            isWhitelisted,
            PAYMENT,
            _user,
            address(this),
            _email
        );

        emit Registered(_user, eventDetails.eventId);
    }

    //5
    function getRegistrant(address _user)
        external
        view
        returns (IHighV.Registrant memory)
    {
        return registrants._getRegistrant(_user);
    }

    //6
    function getAllRegistrant()
        external
        view
        returns (IHighV.Registrant[] memory)
    {
        return HighVLib._getAllRegistrant(registrants, allAttendees);
    }

    //7
    function getAllAttendees()
        external
        view
        returns (IHighV.Registrant[] memory)
    {
        return HighVLib._getAllAttendees(registrants, allAttendees);
    }

    //8
    function markAttendance(address _user) external addressZeroCheck(_user) {
        HighVLib._markAttendance(eventDetails, registrants, _user);

        emit Attendance(_user, eventDetails.eventId);
    }

    //9
    function updateVenue(address _creator, string memory _venue)
        external
        onlyOwner(_creator)
    {
        eventDetails._updateVenue(_venue);
        emit Updated(eventDetails.eventId, "Venue", _venue);
    }

    //10
    function updateCreatorEmail(address _creator, string memory _creatorEmail)
        external
        onlyOwner(_creator)
    {
        eventDetails._updateCreatorEmail(_creatorEmail);
        emit Updated(eventDetails.eventId, "Email", _creatorEmail);
    }

    //11
    function updateEventImageUrl(address _creator, string memory _eventImageUrl)
        external
        onlyOwner(_creator)
    {
        eventDetails._updateEventImageUrl(_eventImageUrl);
        emit Updated(eventDetails.eventId, "Image", _eventImageUrl);
    }

    //12
    function updateEventPrice(address _creator, uint256 _price)
        external
        onlyOwner(_creator)
    {
        eventDetails._updateEventPrice(_price);
        emit UpdatePrice(eventDetails.eventId, _price);
    }

    //13
    function openOrCloseRegistration(address _creator)
        external
        onlyOwner(_creator)
    {
        eventDetails._openOrCloseRegistration();

        emit RegStatus(eventDetails.eventId, eventDetails.regIsOn);
    }

    //14
    function startEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._startEvent();
        emit EventStatus(eventDetails.eventId, eventDetails.eventStatus);
    }

    //15 special attendees
    function whitelistUser(address _creator, address[] memory _user)
        external
        onlyOwner(_creator)
        returns (bool)
    {
        return isWhitelisted._whitelistUser(_user);
    }

    //16
    function updateCreatorPhoneNumber(
        address _creator,
        string memory _creatorPhoneNumber
    ) external onlyOwner(_creator) {
        eventDetails._updateCreatorPhoneNumber(_creatorPhoneNumber);
        emit Updated(eventDetails.eventId, "Phone Number", _creatorPhoneNumber);
    }

    //17
    function endEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._endEvent();
        emit EventStatus(eventDetails.eventId, eventDetails.eventStatus);
    }

    //18
    function cancelEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._cancelEvent();
        emit EventStatus(eventDetails.eventId, eventDetails.eventStatus);
    }

    //19
    function postponeEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._postponeEvent();
        emit EventStatus(eventDetails.eventId, eventDetails.eventStatus);
    }

    //20
    function claimPOAP(address _attendee) external addressZeroCheck(_attendee) {
        if (HighVLib._claimPOAP(eventDetails, registrants, HIGHVNFT, _attendee))
            emit ClaimPOAP(
                eventDetails.eventId,
                _attendee,
                registrants[_attendee].regType
            );
    }

    //21 types could be speaker, vip, volunteers, etc
    function addUserTypes(address _creator, string[] memory _userTypes)
        external
        onlyOwner(_creator)
        returns (bool)
    {
        return HighVLib._addUserTypes(userType, allUserTypes, _userTypes);
    }

    //22
    function getAllUserTypes() external view returns (string[] memory) {
        return allUserTypes._getAllUserTypes();
    }

    //23 before ending the event, you wanna sort your users to their types
    //so you select different users ang give them their type
    //this is useful for minting the NFT but it must be done before calling the endEvent function
    function addTypeToUsers(
        address _creator,
        address[] memory _users,
        string memory _userType
    ) external onlyOwner(_creator) returns (bool) {
        return
            HighVLib._addTypeToUsers(registrants, userType, _users, _userType);
    }

    //24
    function pauseEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._pauseEvent();
        emit EventStatus(eventDetails.eventId, eventDetails.eventStatus);
    }
}
