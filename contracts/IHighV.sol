// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IHighV {
    enum EventType {
        NULL,
        FREE,
        PAID
    }

    struct Event {
        address creator;
        string creatorEmail;
        bytes32 eventId;
        string eventImageUrl;
        string eventTitle;
        string description;
        string venue;
        uint256 price;
        address[] participants;
        DateTime[] dateTime;
        string eventCategory;
        EventType eventType;
        uint256 createdAt;
        Checks checks;
    }

    struct Checks {
        bool regIsOn;
        bool eventIsOn;
    }

    struct DateTime {
        uint256 eventDate;
        uint256 startTime;
        uint256 endTime;
    }

    struct EventData {
        string eventTitle;
        string creatorEmail;
        string eventImageUrl;
        string description;
        string venue;
        DateTime[] dateTime;
        string eventCategory;
        uint256 price;
    }

    struct Participant {
        address participantAddress;
        string email;
        bool attended;
    }

    struct Creator {
        address creatorAddress;
        string email;
        string phoneNumber;
    }

    event EventCreated(
        address indexed creator,
        bytes32 indexed eventId,
        EventType indexed EventType,
        string eventTitle
    );

    event AdminAdded(
        address indexed creator,
        bytes32 indexed eventId,
        uint256 numberOfAdmins
    );

    event Registered(
        address indexed participant,
        bytes32 indexed eventId,
        uint256 indexed price
    );

    event BarcodeScanned(
        address indexed scanner,
        address indexed participant,
        bytes32 indexed eventId
    );

    event RegInfo(bytes32 indexed eventId, string message);

     function _createEvent(EventData memory _eventData) external;
}
