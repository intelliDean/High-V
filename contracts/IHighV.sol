// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHighV {
    struct Event {
        address creator;
        bytes32 eventId;
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
        STARTED,
        CANCELLED,
        POSTPONED,
        PAUSED,
        ENDED
    }

    enum EventType {
        NULL,
        FREE,
        PAID
    }

    //2
    function getEventInfo() external view returns (IHighV.Event memory);

    //3
    function getCreator() external view returns (address);

    //4
    //register for event
    function register4Event(address _user, string memory _email) external;

    //5
    function getRegistrant(address _user)
        external
        view
        returns (IHighV.Registrant memory);

    //6
    function getAllRegistrant()
        external
        view
        returns (IHighV.Registrant[] memory);

    //7
    function getAllAttendees()
        external
        view
        returns (IHighV.Registrant[] memory);

    //8
    function markAttendance(address _user) external;

    //9
    function updateVenue(address _creator, string memory _venue) external;

    //10
    function updateCreatorEmail(address _creator, string memory _creatorEmail)
        external;

    //11
    function updateEventImageUrl(address _creator, string memory _eventImageUrl)
        external;

    //12
    function updateEventPrice(address _creator, uint256 _price) external;

    //13
    function openOrCloseRegistration(address _creator) external;

    //14
    function startEvent(address _creator) external;

    //15 special attendees
    function whitelistUser(address _creator, address[] memory _user)
        external
        returns (bool);

    //16
    function updateCreatorPhoneNumber(
        address _creator,
        string memory _creatorPhoneNumber
    ) external;

    //17
    function endEvent(address _creator) external;

    //18
    function cancelEvent(address _creator) external;

    //19
    function postponeEvent(address _creator) external;

    //20
    function claimPOAP(address _attendee) external;

    //21 types could be speaker, vip, volunteers, etc
    function addUserTypes(address _creator, string[] memory _userTypes)
        external
        returns (bool);

    //22
    function getAllUserTypes() external view returns (string[] memory);

    function addTypeToUsers(
        address _creator,
        address[] memory _users,
        string memory _userType
    ) external returns (bool);

    //24
    function pauseEvent(address _creator) external;

    //=============== NFT CONTRACT ========================
    function mint(address recipient, uint256 nftId) external;

    //=============== ERC20 CONTRACT ========================
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
