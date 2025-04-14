<?php




addEndpoints(array(
    "v1/report/View" => "ViewReports",
    "v1/report/View/{String}" => "ViewReport",
    
));



// ViewReports


function ViewReports($user) {
    global $ReportingCollection;

    // Fetch from DB, most recent first (you could remove this sort entirely if unnecessary)
    $cursor = $ReportingCollection->find([], ['sort' => ['firstSeen' => -1]]);

    $reports = [];
    foreach ($cursor as $report) {
        $report = BuildReport($report, $user);
        if (!CanSeeReport($report, $user)) {
            continue;
        }
        $reports[] = $report;
    }

    // Sort by severity (Critical > High > Medium > Low)
    usort($reports, function ($a, $b) {
        $priority = [
            "Critical" => 4,
            "High"     => 3,
            "Medium"   => 2,
            "Low"      => 1
        ];

        return ($priority[$b['severity']] ?? 0) <=> ($priority[$a['severity']] ?? 0);
    });

    http_response_code(200);
    return [
        "status" => "success",
        "reports" => $reports
    ];
}

function BuildReport($report, $user) {
    // Build the report object
    $report = iterator_to_array($report);
    $report['editable'] = ManagerOfReports($report, $user);
    $report['editableV2'] = ManagerOfReportsV2($report, $user);
    $report["id"] = $report["_id"]->__toString();
    $report["customAnswers"] = isset($report["customAnswers"]) ? iterator_to_array($report["customAnswers"]) : null;
    return $report;

}

function CanSeeReport($report, $user) {
    // Check if the user can see the report
    if ($report['user']['GUUID'] == $user['GeneratedUID']) {
        return true;
    };

    if (TDSAccountHasAccessToService("net.thomasdye.TDS-Reporting-V2.Manage", $user['GeneratedUID'])) {
        return true;
    }
    return false;
}
function ManagerOfReports($report, $user) {
    if (TDSAccountHasAccessToService("net.thomasdye.TDS-Reporting-V2.Manage", $user['GeneratedUID'])) {
        return true;
    }
    // if the report is completed, the user can see it
    if ($report['status'] == "Completed") {
        return false;
    }

    // Check if the user is the manager of the report
    if ($report['user']['GUUID'] == $user['GeneratedUID']) {
        return true;
    };


    return false;
}

function ManagerOfReportsV2($report, $user) {
    if (TDSAccountHasAccessToService("net.thomasdye.TDS-Reporting-V2.Manage", $user['GeneratedUID'])) {
        return "Manager";
    }
    // if the report is completed, the user can see it
    if ($report['status'] == "Completed") {
        return "Completed";
    }

    // Check if the user is the manager of the report
    if ($report['user']['GUUID'] == $user['GeneratedUID']) {
        return "selfCreated";
    };

    return false;
}




function ViewReport($id, $user) {
    global $ReportingCollection;

    // Fetch the report from the database
    $cursor = $ReportingCollection->find(['_id' => new MongoDB\BSON\ObjectId($id)]);


    $reports = [];
    foreach ($cursor as $report) {
        $report = BuildReport($report, $user);
        if (!CanSeeReport($report, $user)) {
            continue;
        }
        $reports[] = $report;
    }
    if (!$report) {
        http_response_code(404);
        return ["error" => "Report not found."];
    }

    http_response_code(200);
    return [
        "status" => "success",
        "reports" => $reports
    ];
}