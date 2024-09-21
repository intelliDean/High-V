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
        string eventTitle;
        string description;
        string venue;
        uint256 price;
        address[] admins;
        address[] participants;
        uint256[] eventDate;
        string startTime;
        uint256 eventDurationInDays;
        EventType eventType;
        uint256 createdAt;
        bool regIsOn;
    }

    struct EventData {
        string eventTitle;
        string description;
        string venue;
        uint256[] eventDate;
        string startTime;
        EventType eventType;
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
}
