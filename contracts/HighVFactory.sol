// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./HighV.sol";
import "./IHighV.sol";
import "./HighVNFT.sol";
import "./HighVFactoryLib.sol";
import "./DeploymentLib.sol";

contract HighVFactory {
    using HighVFactoryLib for *;
    using DeploymentLib for *;

    address immutable owner;
    IHighV immutable creatorNFT;

    mapping(bytes32 => address) public eventsAddresses;
    address[] allEvents;

    event FactoryCreatedEvent(
        address indexed creator,
        bytes32 indexed _eventId
    );

    event CreatorClaimEventNFT(
        address indexed creator,
        bytes32 indexed eventId,
        uint256 NFT_Type
    );

    constructor(address _owner, address _creatorNFT) {
        if (_owner == address(0) && _creatorNFT == address(0))
            revert Errors.ADDRESS_ZERO();
        owner = _owner;
        creatorNFT = IHighV(_creatorNFT);
    }

    //1
    function createEvent(
        string memory _nftURI,
        address _paymentAddress,
        IHighV.EventData memory _eventData
    ) external {
        bytes32 _eventId = keccak256(abi.encode(msg.sender, _eventData));

        address nft = DeploymentLib._deployNFTContract(_nftURI, msg.sender);

        address highV = DeploymentLib._deployHighVContract(
            _eventData,
            msg.sender,
            _paymentAddress,
            nft,
            _eventId
        );

        allEvents.push(highV);

        eventsAddresses[_eventId] = highV;

        emit FactoryCreatedEvent(msg.sender, _eventId);
    }

    //2
    function getEventDetails(bytes32 _eventId)
        public
        view
        returns (IHighV.Event memory)
    {
        return eventsAddresses._getEventDetails(_eventId);
    }

    //3
    function getEventCreator(bytes32 _eventId) public view returns (address) {
        return eventsAddresses._getEventCreator(_eventId);
    }

    //4
    function userRegister4Event(bytes32 _eventId, string memory _email)
        external
    {
        eventsAddresses._userRegister4Event(_eventId, msg.sender, _email);
    }

    //5
    function getEventRegistrant(bytes32 _eventId, address _user)
        external
        view
        returns (IHighV.Registrant memory)
    {
        return eventsAddresses._getEventRegistrant(_eventId, _user);
    }

    //6
    function getAllEventRegistrants(bytes32 _eventId)
        external
        view
        returns (IHighV.Registrant[] memory)
    {
        return eventsAddresses._getAllEventRegistrants(_eventId);
    }

    //7
    function getAllEventAttendees(bytes32 _eventId)
        external
        view
        returns (IHighV.Registrant[] memory)
    {
        return eventsAddresses._getAllEventAttendees(_eventId);
    }

    //8
    //this will be done with user scanning QR code
    function userMarkAttendance(bytes32 _eventId, address _user) external {
        eventsAddresses._userMarkAttendance(_eventId, _user);
    }

    //["Base Event", "dean@gmail.com", "08095729090", "image.com", "Base event for base developers", "The Zone, Gbagada", [[433973097539, 4339730973475, 4339730973900]], "DeFi", 0]

    //9
    function creatorUpdateVenue(bytes32 _eventId, string memory _venue)
        external
    {
        eventsAddresses._creatorUpdateVenue(_eventId, msg.sender, _venue);
    }

    //10
    function creatorUpdateEmail(bytes32 _eventId, string memory _creatorEmail)
        external
    {
        eventsAddresses._creatorUpdateEmail(
            _eventId,
            msg.sender,
            _creatorEmail
        );
    }

    //11
    function creatorUpdateEventImageUrl(
        bytes32 _eventId,
        string memory _eventImageUrl
    ) external {
        eventsAddresses._creatorUpdateEventImageUrl(
            _eventId,
            msg.sender,
            _eventImageUrl
        );
    }

    //12
    function updateEventPrice(bytes32 _eventId, uint256 _price) external {
        eventsAddresses._updateEventPrice(_eventId, msg.sender, _price);
    }

    //13
    function creatorOpenOrCloseRegistration(bytes32 _eventId) external {
        eventsAddresses._creatorOpenOrCloseRegistration(_eventId, msg.sender);
    }

    //14
    function creatorStartEvent(bytes32 _eventId) external {
        eventsAddresses._creatorStartEvent(_eventId, msg.sender);
    }

    //15
    function creatorWhitelistUsers(bytes32 _eventId, address[] memory _user)
        external
        returns (bool)
    {
        return
            eventsAddresses._creatorWhitelistUsers(_eventId, msg.sender, _user);
    }

    //16
    function creatorUpdatePhoneNumber(
        bytes32 _eventId,
        string memory _creatorPhoneNumber
    ) external {
        eventsAddresses._creatorUpdatePhoneNumber(
            _eventId,
            msg.sender,
            _creatorPhoneNumber
        );
    }

    //17
    function creatorEndEvent(bytes32 _eventId) external {
        eventsAddresses._creatorEndEvent(_eventId, msg.sender);
    }

    //18
    function creatorCancelEvent(bytes32 _eventId) external {
        eventsAddresses._creatorCancelEvent(_eventId, msg.sender);
    }

    //19
    function creatorPostponeEvent(bytes32 _eventId) external {
        eventsAddresses._creatorPostponeEvent(_eventId, msg.sender);
    }

    //20
    function attendeeClaimPOAP(bytes32 _eventId, address _attendee) external {
        eventsAddresses._attendeeClaimPOAP(_eventId, _attendee);
    }

    //21
    function creatorAddUserTypes(bytes32 _eventId, string[] memory _userTypes)
        external
        returns (bool)
    {
        return
            eventsAddresses._creatorAddUserTypes(
                _eventId,
                msg.sender,
                _userTypes
            );
    }

    //22
    function allUserTypes(bytes32 _eventId)
        external
        view
        returns (string[] memory)
    {
        return eventsAddresses._allUserTypes(_eventId);
    }

    //23
    function creatorAddTypeToUsers(
        bytes32 _eventId,
        address[] memory _users,
        string memory _userType
    ) external returns (bool) {
        return
            eventsAddresses._creatorAddTypeToUsers(
                _eventId,
                msg.sender,
                _users,
                _userType
            );
    }

    //24
    function creatorPauseEvent(bytes32 _eventId) external {
        eventsAddresses._creatorPauseEvent(_eventId, msg.sender);
    }

    //25
    function getAllEventDetails()
        external
        view
        returns (IHighV.Event[] memory)
    {
        return allEvents._getAllEventDetails();
    }

    //26
    function creatorClaimEventNFT(bytes32 _eventId) external {
        HighVFactoryLib._creatorClaimEventNFT(
            eventsAddresses,
            msg.sender,
            creatorNFT,
            _eventId
        );
        emit CreatorClaimEventNFT(msg.sender, _eventId, 1);
    }
}
