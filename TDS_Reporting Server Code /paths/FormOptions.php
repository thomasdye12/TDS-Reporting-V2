<?php


addEndpoints(array(
    "v1/report/FormOptions" => "FormOptions",
));


function FormOptions($user) {
    $getHouseRooms = file_get_contents("http://homeserverapi.local.thomasdye.net/Brain/api/dashboard/getAllRooms");
    $getHouseRooms = json_decode($getHouseRooms, true);

    $staticTopics = [
        "Software",
        "Hardware",
        "Plumbing",
        "Electrical",
        "Internet",
        "Security",
        "Cleaning",
        "Other"
    ];

    $roomTopics = [];
    $roomTypeOptions = [];

    foreach ($getHouseRooms as $room) {
        $roomName = "Room - ". $room['name'] ?? null;

        if (!$roomName) continue; // skip unnamed rooms

        $roomTopics[] = $roomName;
        $types = [];

        if (!empty($room['devices'])) {
            $types[] = "Device issue";
        }

        if (!empty($room['Skyqbox'])) {
            $types[] = "SkyQ issue";
        }

        if (!empty($room['Cam'])) {
            $types[] = "Camera issue";
        }

        if (!empty($room['Sonosname'])) {
            $types[] = "Sonos issue";
        }

        $types[] = "Other";
        if (!empty($types)) {
            $roomTypeOptions[$roomName] = $types;
        }
    }

    $formOptions = [
        "topics" => array_merge($staticTopics, $roomTopics),
        "typeOptions" => array_merge([
            "Software" => ["Incorrect behavior", "Crash", "Suggestion"],
            "Hardware" => ["Broken", "Doesn't work", "Improvement"],
            "Plumbing" => ["Leak", "Blockage", "Other"],
            "Electrical" => ["Power issue", "Faulty socket", "Danger"],
            "Internet" => ["No connection", "Slow speed", "Router problem"],
            "Security" => ["Alarm issue", "CCTV offline", "Access denied"],
            "Cleaning" => ["Missed area", "Supplies needed", "Schedule issue"],
            "Other" => ["General issue", "Feedback", "Other"]
        ], $roomTypeOptions),
        "customQuestions" => [
            "Software" => [
                "Environment" => [
                    "Which operating system are you using?",
                    "Is this issue reproducible?"
                ],
                "Details" => [
                    "What version of the software are you using?",
                    "Any logs or screenshots?"
                ]
            ],
            "Plumbing" => [
                "Location" => [
                    "Which room is affected?",
                    "Is water currently running or shut off?"
                ],
                "Severity" => [
                    "Is it a small drip or major leak?",
                    "Is the area safe?"
                ]
            ],
            "Security" => [
                "Access" => [
                    "Was access denied for a user or system?",
                    "What time did the issue occur?"
                ]
            ]
        ]
    ];

    return $formOptions;
}
