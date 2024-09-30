// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVentura {
    enum EventType {
        NULL,
        FREE,
        PAID
    }

    struct Event {
        address creator;
        bytes32 eventId;
        string imageUrl;
        string eventTitle;
        string description;
        string venue;
        uint256 price;
        address[] participants;
        uint256[] eventDate;
        Timing timing;
        EventType eventType;
        uint256 createdAt;
        BoolCheck boolCheck;
    }

    struct BoolCheck {
        bool regIsOn;
        bool isOver;
        bool cancelled;
    }

    struct Timing {
        string startTime;
        string endTime;
    }

    struct EventData {
        string eventTitle;
        string imageUrl;
        string description;
        uint256 price;
        string venue;
        uint256[] eventDate;
        string startTime;
        string endTime;
    }

    struct Participants {
        address participantAddress;
        string email;
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

    event EventCancelled(bytes32 indexed _eventId);

    event RegInfo(bytes32 indexed eventId, string message);
}
