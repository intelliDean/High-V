// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/IHighV.sol";
import "contracts/HighVLib.sol";
import "contracts/Errors.sol";
import "contracts/HighVNFT.sol";

contract HighV {
    using HighVLib for *;

    IHighV HIGHVNFT;
    IHighV PAYMENT;

    address immutable creator;
    address[] allAttendees;
    string[] allUserTypes;

    IHighV.Event eventDetails;

    mapping(address => IHighV.Registrant) public registrants;
    mapping(address => bool) public isWhitelisted;
    mapping(string => uint8) userType;

    event ContractCreated(address contractAddress);

    constructor(
        address _creator,
        address _paymentAddress,
        address nftContract,
        IHighV.EventData memory _eventData
    ) {
        creator = _creator;

        //NFT Contract
        HIGHVNFT = IHighV(nftContract);
        PAYMENT = IHighV(_paymentAddress);

        //1
        eventDetails._createEvent(_eventData);

        emit ContractCreated(address(this));
    }

    modifier onlyOwner(address _user) {
        if (_user != creator) revert Errors.ONLY_OWNER(_user);
        _;
    }

    //2
    function getEventInfo() external view returns (IHighV.Event memory) {
        return eventDetails._getEventInfo();
    }

    //3
    function getCreator() external view returns (address) {
        return creator._getCreator();
    }

    //4
    //register for event
    function register4Event(address _user, string memory _email) external {
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
    function markAttendance(address _user) external {
        registrants._markAttendance(_user);
    }

    //=========================
    //9
    function updateVenue(address _user, string memory _venue)
        external
        onlyOwner(_user)
    {
        eventDetails._updateVenue(_venue);
    }

    //10
    function updateCreatorEmail(address _user, string memory _creatorEmail)
        external
        onlyOwner(_user)
    {
        eventDetails._updateCreatorEmail(_creatorEmail);
    }

    //11
    function updateEventImageUrl(address _user, string memory _eventImageUrl)
        external
        onlyOwner(_user)
    {
        eventDetails._updateEventImageUrl(_eventImageUrl);
    }

    //12
    function updateEventPrice(address _user, uint256 _price)
        external
        onlyOwner(_user)
    {
        eventDetails._updateEventPrice(_price);
    }

    //13
    function openOrCloseRegistration(address _user) external onlyOwner(_user) {
        eventDetails._openOrCloseRegistration();
    }

    //14
    function startOrEndEvent(address _user) external onlyOwner(_user) {
        eventDetails._startEvent();
    }

    //15
    //there will be a check for these people. they are not paying to register
    //this will be the speaker, volunteers and other special attendees
    function whitelistUser(address _creator, address[] memory _user)
        external
        onlyOwner(_creator)
    {
        isWhitelisted._whitelistUser(_user);
    }

    //16
    function updateCreatorPhoneNumber(
        address _user,
        string memory _creatorPhoneNumber
    ) external onlyOwner(_user) {
        eventDetails._updateCreatorPhoneNumber(_creatorPhoneNumber);
    }

    //17
    function endEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._endEvent();
    }

    //18
    function cancelEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._cancelEvent();
    }

    //19
    function postponeEvent(address _creator) external onlyOwner(_creator) {
        eventDetails._postponeEvent();
    }

    //20
    function claimPOAP(address _attendee) external {
        HighVLib._claimPOAP(eventDetails, registrants, HIGHVNFT, _attendee);
    }

    //21
    function addUserTypes(address _creator, string[] memory _userTypes)
        external
        onlyOwner(_creator)
    {
        HighVLib._addUserTypes(userType, allUserTypes, _userTypes);
    }

    //22
    function getAllUserTypes() external view returns (string[] memory) {
        return allUserTypes._getAllUserTypes();
    }

    //23
    function addTypeToUsers(
        address _creator,
        address[] memory _users,
        string memory _userType
    ) external onlyOwner(_creator) {
        HighVLib._addTypeToUsers(registrants, userType, _users, _userType);
    }

    //you can whitelist users so they register freely
    //then as a creator, you can go ahead to edit their type
    //an array of user and a single usertype
}
