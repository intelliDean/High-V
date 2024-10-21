// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHighV {
    struct Event {
        string creatorEmail;
        string creatorPhoneNumber;
        string eventImageUrl;
        string eventTitle;
        string description;
        string venue;
        uint256 price;
        string eventCategory;
        IHighV.EventType eventType;
        uint256 createdAt;
        bool regIsOn;
        EventStatus eventStatus;
        IHighV.DateTime[] dateTime;
    }

    struct EventData {
        string eventTitle;
        string creatorEmail;
        string creatorPhone;
        string eventImageUrl;
        string description;
        string venue;
        DateTime[] dateTime;
        string eventCategory;
        uint256 price;
    }

    struct DateTime {
        uint256 eventDate;
        uint256 startTime;
        uint256 endTime;
    }

    struct Registrant {
        address regAddress;
        string email;
        uint8 regType;
        bool attended;
    }

    enum EventStatus {
        NULL,
        START,
        CANCELLED,
        POSTPONED,
        ENDED
    }

    enum EventType {
        NULL,
        FREE,
        PAID
    }

    function getEventInfo() external view returns (IHighV.Event memory);

    function getCreator() external view returns (address);

    function getAllAttendees()
        external
        view
        returns (IHighV.Registrant[] memory);

    function register4Event(address _user, string memory _email) external;

    function getRegistrant(address _user)
        external
        view
        returns (IHighV.Registrant memory);

    function getAllRegistrant()
        external
        view
        returns (IHighV.Registrant[] memory);

    function markAttendance(address _user) external;

    function updateVenue(address _user, string memory _venue) external;

    function updateCreatorEmail(address _user, string memory _creatorEmail)
        external;

    function updateCreatorPhoneNumber(
        address _user,
        string memory _creatorPhoneNumber
    ) external;

    function updateEventImageUrl(address _user, string memory _eventImageUrl)
        external;

    function updateEventPrice(address _user, uint256 _price) external;

    function openOrCloseRegistration(address _user) external;

    function startOrEndEvent(address _user) external;

    function whitelistUser(address _creator, address[] memory _user) external;

    //17
    function endEvent(address _creator) external;

    //18
    function cancelEvent(address _creator) external;

    //19
    function postponeEvent(address _creator) external;

    //20
    function claimPOAP(address _attendee) external;

    //21
    function addUserTypes(address _creator, string[] memory _userTypes)
        external;

    //22
    function getAllUserTypes() external view returns (string[] memory);

    //23
    function addTypeToUsers(
        address _creator,
        address[] memory _users,
        string memory _userType
    ) external;

    //=============== NFT CONTRACT ========================
    function mint(
        address recipient,
        uint256 nftId,
        uint256 quantity
    ) external;

    //=============== ERC20 CONTRACT ========================
    function balanceOf(address account) external view returns (uint256);
    
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
