<?php




addEndpoints(array(
    "v1/report/Submit" => "SubmitReport",
    "v1/report/Update" => "UpdateReport",
));




function SubmitReport($user, $report) {
    global $ReportingCollection;

    // Decode JSON if passed as string
    // if (is_string($report)) {
    //     $report = json_decode($report, true);
    // }

    // echo json_encode($report, JSON_PRETTY_PRINT);
    // Basic validation
    $requiredFields = ['title', 'severity', 'type', 'status', 'description', 'topic', 'id', 'firstSeen', 'user'];
    foreach ($requiredFields as $field) {
        if (empty($report[$field])) {
            http_response_code(400);
            echo json_encode(["error" => "Missing required field: $field"]);
            return;
        }
    }

    // Validate user structure
    $user = $report['user'];
    $requiredUserFields = ['GUUID', 'username'];
    foreach ($requiredUserFields as $field) {
        if (empty($user[$field])) {
            http_response_code(400);
            echo json_encode(["error" => "Missing required user field: $field"]);
            return;
        }
    }

    // Sanitize inputs
    $report['title'] = htmlspecialchars($report['title']);
    $report['description'] = htmlspecialchars($report['description']);
    $report['topic'] = htmlspecialchars($report['topic']);
    $report['type'] = htmlspecialchars($report['type']);
    $report['status'] = htmlspecialchars($report['status']);
    $report['severity'] = htmlspecialchars($report['severity']);
    $report['user']['username'] = htmlspecialchars($user['username']);
    $report['user']['GUUID'] = htmlspecialchars($user['GUUID']);
    $report['user']['apnsToken'] = isset($user['apnsToken']) ? $user['apnsToken'] : "";

    // Save to MongoDB or any collection
    try {
        $ReportingCollection->insertOne($report);
        http_response_code(200);
        ReportUpdatedNotification($report, "new");
        echo json_encode(["status" => "success", "message" => "Report submitted successfully."]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["error" => "Failed to save report: " . $e->getMessage()]);
    }
}


function UpdateReport($user, $report) {
    if (ManagerOfReports($report, $user) == false) {
        http_response_code(403);
        return ["error" => "You do not have permission to update this report."];
    }
    global $ReportingCollection;

    // Validate input
    if (empty($report['id'])) {
        http_response_code(400);
        return ["error" => "Missing report ID."];
    }

    // Build update object
    $updates = [];

    if (isset($report['status'])) {
        $updates['status'] = htmlspecialchars($report['status']);
    }

    // support update for topic , type , severity
    if (isset($report['topic'])) {
        $updates['topic'] = htmlspecialchars($report['topic']);
    }
    if (isset($report['type'])) {
        $updates['type'] = htmlspecialchars($report['type']);
    }
    if (isset($report['severity'])) {
        $updates['severity'] = htmlspecialchars($report['severity']);
    }
    if (isset($report['description'])) {
        $updates['description'] = htmlspecialchars($report['description']);
    }
    if (isset($report['title'])) {
        $updates['title'] = htmlspecialchars($report['title']);
    }
    if (isset($report['comments']) && is_array($report['comments'])) {
        $updates['comments'] = array_map(function ($comment) {
            return [
                'id' => $comment['id'],
                'username' => htmlspecialchars($comment['username']),
                'GUUID' => $comment['GUUID'],
                'Comments' => htmlspecialchars($comment['Comments']),
                'timestamp' => $comment['timestamp']
            ];
        }, $report['comments']);
    }

    if (empty($updates)) {
        http_response_code(400);
        return ["error" => "No updatable fields provided."];
    }

    // Attempt to update
        $result = $ReportingCollection->updateOne(
            ['_id' => new MongoDB\BSON\ObjectId($report['id'])],
            ['$set' => $updates]
        );

        if ($result->getModifiedCount() > 0) {
            http_response_code(200);
            ReportUpdatedNotification($report, "update");
            return ["status" => "success", "message" => "Report updated."];
        } else {
            http_response_code(404);
            return ["error" => "No report found or nothing changed."];
        }
}



function ReportUpdatedNotification($report,$key) {

    include_once "/Server/app/support/APNS.php";
    // Send a notification to the user
    $message = "Report " . $report['title'] . " has been updated.";
    $apnsToken = $report["user"]['apnsToken'];

    $apnsarray["devkey"] = "G7NMVQ2XHH";
    $apnsarray["dev"] = "net.thomasdye.TDS-Reporting-V2";
    $apnsarray["title"] = "Report Updated";
    $apnsarray["interuptionlevel"] = "time-sensitive";
    $apnsarray["notname"] = $message;
    // $apnsarray["userarray"] = "thomas";
    $apnsarray["dev_NEWAPNS"] = true;
    $apnsarray["production"] = isset($report["user"]['apnsToken']["ENV"]) ? ($report["user"]['apnsToken']["ENV"] == "production" ? true : false) : false;
    $apnsarray["id"] = $report["user"]['apnsToken']["APNStoken"];
    sendapns($apnsarray);
   

    // send APNS to Admin users to let them know a report has been updated
    if ($key == "new") {
        $message = "New Report: " . $report['title'] . " has been submitted.";
    } else {
       return;
    }

    $apnsarray = array();
    $apnsarray["production"] = true;
    $apnsarray["id"] = "";
    $apnsarray["devkey"] = "G7NMVQ2XHH";
    $apnsarray["dev"] = "net.thomasdye.TDS-Reporting-V2";
    $apnsarray["title"] = "Report Created by " . $report['user']['username'];
    $apnsarray["interuptionlevel"] = "time-sensitive";
    $apnsarray["notname"] = "New Report: " . $report['title'] . " has been submitted, sensitvity level: " . $report['severity'];
    // $apnsarray["userarray"] = "thomas";
    $apnsarray["dev_NEWAPNS"] = true;
    $apnsarray["TDSNotificationGroup"] = "net.thomasdye.APNS.TDSReporting.Group1";
    sendapns($apnsarray);

}
