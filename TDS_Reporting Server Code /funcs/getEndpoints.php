<?php


// getEndpoints

function getEndpoints($userinfo) {
    return $GLOBALS["endpoints"];
}

//  function to add an array of endpoints to the endpoints array

function addEndpoints($endpoints) {
    $GLOBALS["endpoints"] = array_merge($GLOBALS["endpoints"], $endpoints);
}