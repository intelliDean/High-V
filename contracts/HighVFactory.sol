// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "./HighV.sol";
// import "./IHighV.sol";
// import "./HighVNFT.sol";
import "./HighVFactoryLib.sol";
import "./DeploymentLib.sol";

contract HighVFactory {
    using HighVFactoryLib for *;
    using DeploymentLib for *;

    address immutable owner;
    IHighV immutable creatorNFT;

    mapping(bytes32 => address) public eventsAddresses;
    address[] public allEvents;

    event FactoryCreatedEvent(
        address indexed creator,
        bytes32 indexed _eventId
    );

    event CreatorClaimEventNFT(
        address indexed creator,
        bytes32 indexed eventId,
        uint256 NFT_Type
    );

    event Registered(address indexed user, bytes32 indexed eventId);
    event Attendance(address indexed user, bytes32 indexed eventId);
    event UpdatePrice(bytes32 indexed eventId, uint256 indexed _price);
    event Updated(
        bytes32 indexed eventId,
        string indexed fieldUpdated,
        string indexed update
    );

    event Result(bytes32 indexed _eventId, bool result);

    constructor(address payable _owner, address _creatorNFT) payable {
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
        address _creator = msg.sender;

        bytes32 _eventId = keccak256(abi.encode(_creator, _eventData));

        address nft = DeploymentLib._deployNFTContract(_nftURI, _creator);

        address highV = DeploymentLib._deployHighVContract(
            _eventData,
            _creator,
            _paymentAddress,
            nft,
            _eventId
        );

        allEvents.push(highV);

        eventsAddresses[_eventId] = highV;

        emit FactoryCreatedEvent(_creator, _eventId);
    }

    //2
    function getEventDetails(
        bytes32 _eventId
    ) public view returns (IHighV.Event memory) {
        return eventsAddresses._getEventDetails(_eventId);
    }

    //3
    function getEventCreator(bytes32 _eventId) public view returns (address) {
        return eventsAddresses._getEventCreator(_eventId);
    }

    //4
    function userRegister4Event(
        bytes32 _eventId,
        string memory _email
    ) external {
        address _registrant = msg.sender;
        eventsAddresses._userRegister4Event(_eventId, _registrant, _email);
        emit Registered(_registrant, _eventId);
    }

    //5
    function getEventRegistrant(
        bytes32 _eventId,
        address _user
    ) external view returns (IHighV.Registrant memory) {
        return eventsAddresses._getEventRegistrant(_eventId, _user);
    }

    //6
    function getAllEventRegistrants(
        bytes32 _eventId
    ) external view returns (IHighV.Registrant[] memory) {
        return eventsAddresses._getAllEventRegistrants(_eventId);
    }

    //7
    function getAllEventAttendees(
        bytes32 _eventId
    ) external view returns (IHighV.Registrant[] memory) {
        return eventsAddresses._getAllEventAttendees(_eventId);
    }

    //8
    //this will be done with user scanning QR code
    function userMarkAttendance(
        bytes32 _eventId,
        address _user
    ) external {
        eventsAddresses._userMarkAttendance(_eventId, _user);
        emit Attendance(_user, _eventId);
    }

    //["Base Event", "dean@gmail.com", "08095729090", "image.com", "Base event for base developers", "The Zone, Gbagada", [[433973097539, 4339730973475, 4339730973900]], "DeFi", 0]
// 0x6ff206d0b25b7dc84a1be54b869e6ef2206de85b5582d28307d378d02704d8b9

    //9
    function creatorUpdateVenue(
        bytes32 _eventId,
        string memory _venue
    ) external {
        eventsAddresses._creatorUpdateVenue(_eventId, msg.sender, _venue);

        emit Updated(_eventId, "Venue", _venue);
    }

    //10
    function creatorUpdateEmail(
        bytes32 _eventId,
        string memory _creatorEmail
    ) external {
        eventsAddresses._creatorUpdateEmail(
            _eventId,
            msg.sender,
            _creatorEmail
        );

        emit Updated(_eventId, "Email", _creatorEmail);
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
        emit Updated(_eventId, "ImageUrl", _eventImageUrl);
    }

    //12
    function updateEventPrice(bytes32 _eventId, uint256 _price) external {
        eventsAddresses._updateEventPrice(_eventId, msg.sender, _price);

        emit UpdatePrice(_eventId, _price);
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
    function creatorWhitelistUsers(
        bytes32 _eventId,
        address[] memory _user
    ) external {
        if (eventsAddresses._creatorWhitelistUsers(_eventId, msg.sender, _user))
            emit Result(_eventId, true);
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

        emit Updated(_eventId, "Phone Number", _creatorPhoneNumber);
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
    function creatorAddUserTypes(
        bytes32 _eventId,
        string[] memory _userTypes
    ) external {
        if (
            eventsAddresses._creatorAddUserTypes(
                _eventId,
                msg.sender,
                _userTypes
            )
        ) emit Result(_eventId, true);
    }

    receive() external payable {
        (bool success, ) = owner.call{value: msg.value}("");
        if (!success) revert Errors.TRANSFER_FAIL();
    }

    //22
    function allUserTypes(
        bytes32 _eventId
    ) external view returns (string[] memory) {
        return eventsAddresses._allUserTypes(_eventId);
    }

    //23
    function creatorAddTypeToUsers(
        bytes32 _eventId,
        address[] memory _users,
        string memory _userType
    ) external {
        if (
            eventsAddresses._creatorAddTypeToUsers(
                _eventId,
                msg.sender,
                _users,
                _userType
            )
        ) emit Result(_eventId, true);
    }

    //24
    function creatorPauseEvent(bytes32 _eventId) external {
        eventsAddresses._creatorPauseEvent(_eventId, msg.sender);
    }

    //25
    function getEventStatus(
        bytes32 _eventId
    ) public view returns (IHighV.EventStatus) {
        return eventsAddresses._getEventStatus(_eventId);
    }

    //26
    function getAllEventDetails()
        external
        view
        returns (IHighV.Event[] memory)
    {
        return allEvents._getAllEventDetails();
    }

    //27
    function creatorClaimEventNFT(bytes32 _eventId) external {
        address _creator = msg.sender;
        HighVFactoryLib._creatorClaimEventNFT(
            eventsAddresses,
            _creator,
            creatorNFT,
            _eventId
        );
        emit CreatorClaimEventNFT(_creator, _eventId, 1);
    }

    function creatorWithdrawLockedEther(
        bytes32 _eventId
    ) external payable returns (bool) {
        return eventsAddresses._creatorWithdrawLockedEther(_eventId);
    }
}
