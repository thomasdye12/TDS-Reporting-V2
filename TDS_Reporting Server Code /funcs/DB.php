<?php
require "/Server/app/mongoDBConfig/includes/vendor/autoload.php";
$connection = new MongoDB\Client("mongodb://main.db.local.thomasdye.net:27018");
$database = $connection->selectDatabase("TDSDocsStore");
$ReportingCollection = $database->selectCollection("Reporting");
$GLOBALS["redis_Storage"] = new Redis(); 
$GLOBALS["redis_Storage"] ->connect('127.0.0.1', 6121); 
$GLOBALS["redis_Storage"] ->Select(1);
