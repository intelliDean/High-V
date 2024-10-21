// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/HighV.sol";
import "contracts/IHighV.sol";
import "contracts/HighVNFT.sol";

contract HighVFactory {
    address immutable owner;

    mapping(bytes32 => address) public eventsAddresses;
    address[] allEvents;

    event EventCreated(bytes32 eventId);

    constructor(address _owner) {
        owner = _owner;
    }

    //1
    function createEvent(
        string memory _nftURI,
        address _paymentAddress,
        IHighV.EventData memory _eventData
    ) external {

        address highV = address(
            new HighV(
                msg.sender,
                _paymentAddress,
                address(new HighVNFT(msg.sender, _nftURI)),
                _eventData
            )
        );

        bytes32 _eventId = keccak256(abi.encode(msg.sender, _eventData));

        eventsAddresses[_eventId] = highV;

        emit EventCreated(_eventId);
    }

    function initiateContract(bytes32 _eventId) private view returns (IHighV) {
        return IHighV(eventsAddresses[_eventId]);
    }

    //2
    function getEventDetails(bytes32 _eventId)
        external
        view
        returns (IHighV.Event memory)
    {
        return initiateContract(_eventId).getEventInfo();
    }

    //3
    function getEventCreator(bytes32 _eventId) external view returns (address) {
        return initiateContract(_eventId).getCreator();
    }

    //4
    function userRegister4Event(bytes32 _eventId, string memory _email)
        external
    {
        initiateContract(_eventId).register4Event(msg.sender, _email);
    }

    //5
    function getEventRegistrant(bytes32 _eventId, address _user)
        external
        view
        returns (IHighV.Registrant memory)
    {
        return initiateContract(_eventId).getRegistrant(_user);
    }

    //6
    function getAllEventRegistrants(bytes32 _eventId)
        external
        view
        returns (IHighV.Registrant[] memory)
    {
        return initiateContract(_eventId).getAllRegistrant();
    }

    //7
    function getAllEventAttendees(bytes32 _eventId)
        external
        view
        returns (IHighV.Registrant[] memory)
    {
        return initiateContract(_eventId).getAllAttendees();
    }

    //8
    //this will be done with user scanning QR code
    function userMarkAttendance(bytes32 _eventId, address _user) external {
        initiateContract(_eventId).markAttendance(_user);
    }

    //["Base Event", "dean@gmail.com", "08095729090", "image.com", "Base event for base developers", "The Zone, Gbagada", [[433973097539, 4339730973475, 4339730973900]], "DeFi", 0]

    //9
    function CreatorUpdateVenue(bytes32 _eventId, string memory _venue)
        external
    {
        initiateContract(_eventId).updateVenue(msg.sender, _venue);
    }

    //10
    function CreatorUpdateEmail(bytes32 _eventId, string memory _creatorEmail)
        external
    {
        initiateContract(_eventId).updateCreatorEmail(
            msg.sender,
            _creatorEmail
        );
    }

    //11
    function creatorUpdateEventImageUrl(
        bytes32 _eventId,
        string memory _eventImageUrl
    ) external {
        initiateContract(_eventId).updateEventImageUrl(
            msg.sender,
            _eventImageUrl
        );
    }

    //12
    function updateEventPrice(bytes32 _eventId, uint256 _price) external {
        initiateContract(_eventId).updateEventPrice(msg.sender, _price);
    }

    //13
    function creatorOpenOrCloseRegistration(bytes32 _eventId) external {
        initiateContract(_eventId).openOrCloseRegistration(msg.sender);
    }

    //14
    function startOrEndEvent(bytes32 _eventId) external {
        initiateContract(_eventId).startOrEndEvent(msg.sender);
    }

    //15
    function whitelistUser(bytes32 _eventId, address[] memory _user) external {
        initiateContract(_eventId).whitelistUser(msg.sender, _user);
    }

    //16
    function creatorUpdatePhoneNumber(
        bytes32 _eventId,
        string memory _creatorPhoneNumber
    ) external {
        initiateContract(_eventId).updateCreatorPhoneNumber(
            msg.sender,
            _creatorPhoneNumber
        );
    }
}

//0x269bcb8185c6493965f26d6bd8f9bc28fecbdc72810b15a1682153d61f683066
//0x6cd337e638f4bd6e4a35d641fe1c6609e41b2864116de469ea10f477b19d2de9
