<?php
// handle auth and get the user info
ini_set('memory_limit', '9000M');
// ini_set("zlib.output_compression", 1);
// show errors
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
// incress max upload size 5 GB
ini_set('upload_max_filesize', '5000M');
ini_set('post_max_size', '5000M');
ini_set('max_input_time', 3600);
ini_set('max_execution_time', 3600);
// set the max number of requests per min
$GLOBALS["TDS_Auth_Request_MaxRequests"] = 100;
header('Content-Type: application/json; charset=utf-8');
// set header that says `TDS Docs API`
header('X-Powered-By: TDS API 3');


// CORS headers
// header_remove("Access-Control-Allow-Origin"); // optional
// header("Access-Control-Allow-Origin: http://main.db.local.thomasdye.net:3000");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
// Access-Control-Allow-Credentials
header("Access-Control-Allow-Credentials: true");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204); // No Content
    exit;
}



// Get the base path of the current script
$basePath = dirname($_SERVER['SCRIPT_NAME']);

// Get the user's path
$path = $_SERVER['REQUEST_URI'];

// Remove the base path from the user's path
$path = str_replace($basePath, '', $path);

// Remove any leading or trailing slashes
$path = trim($path, '/');
// i want to remove the get params from the path
$path = explode('?', $path)[0];

// echo $_SERVER['REQUEST_URI'];
// Define the available endpoints and their corresponding functions
$endpoints = [
  "endpoints" => "getEndpoints",
  "" => "getEndpoints",
];



// inlucd the conetnrs of this dir /Library/Server/Web/Data/Sites/status.thomasdye.net/app/funcs

include_once "/Library/Server/Web/Data/Sites/Default/app/TDS_Reporting/funcs/include.php";

// Check if the requested path matches any endpoint
$matchedEndpoint = null;
$matchedParams = [];
foreach ($endpoints as $endpoint => $function) {
    // Convert the endpoint to a regular expression pattern
    $pattern = '/^' . str_replace('/', '\/', $endpoint) . '$/';
     // Replace {id} with \w+ to match any alphanumeric value
     $pattern = str_replace('{id}', '([0-9a-f]{6,8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{10,12})', $pattern);
     $pattern = str_replace('{all}', '(all)', $pattern);
     $pattern = str_replace('{String}', '([\w.\\-]+)', $pattern);
    //   string with space as %20 
        $pattern = str_replace('{String+}', '([\w.\\-\s]+)', $pattern);
        // string optional 
        $pattern = str_replace('{String?}', '([\w.\\-]*)', $pattern);
     // string optional 
        $pattern = str_replace('{String?}', '([\w.\\-]*)', $pattern);
     $pattern = str_replace('{date-formatted}', '(\d{4}-\d{2}-\d{2})', $pattern);

    // Check if the path matches the pattern
    if (preg_match($pattern, $path, $matches)) {
        $matchedEndpoint = $endpoint;
        $matchedParams = array_slice($matches, 1);
        break;
    }
}
include_once "/Server/app/auth/VAuthJWT.php";
$userinfo = getuserinfofromjwt();
$matchedParams[] = $GLOBALS["userinfo"];




// if its post request get the post data and add it as a param
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // check the content type
    if (isset($_SERVER["CONTENT_TYPE"]) && strpos($_SERVER["CONTENT_TYPE"], "application/json") !== false) {
        $matchedParams[] = json_decode(file_get_contents('php://input'), true);
    } else {
        $matchedParams[] = file_get_contents('php://input');
    }
} else {
    // if its get request get the get data and add it as a param
    $matchedParams[] = null;
}
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // check the content type
    if (isset($_SERVER["CONTENT_TYPE"]) && strpos($_SERVER["CONTENT_TYPE"], "application/json") !== false) {
        $matchedParams[] = json_decode(file_get_contents('php://input'), true);
    } else {
        $matchedParams[] = file_get_contents('php://input');
    }

}

if ($matchedEndpoint) {
    try {
        $function = $endpoints[$matchedEndpoint];
        // set json header
        $reponse = call_user_func_array($function, $matchedParams);
        // if the key error is set then there was an error
        if (isset($reponse["error"])) {
            header('Content-Type: application/json');
            // set error code 
            http_response_code(isset($reponse["code"]) ? $reponse["code"] : 400);
            // return the error
        }
        if($reponse != null) {
            header('Content-Type: application/json');
            echo json_encode($reponse, JSON_PRETTY_PRINT);
        }
    } catch (ArgumentCountError $e) {
        // set error code 
        http_response_code(400);
        // Handle the error here
        // You can log the error, display a custom error message, or perform any other necessary actions
        echo "An error occurred: " . $e->getMessage();
    }
    // Call the corresponding function and pass the matched parameters
    // echo call_user_func_array($function, $matchedParams);
} else {
    // No matching endpoint found, set 404 status
    http_response_code(404);
    echo "404 - Not Found, path 1";
}