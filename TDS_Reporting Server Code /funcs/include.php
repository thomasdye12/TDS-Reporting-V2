<?php

$supportfiles = scandir("/Library/Server/Web/Data/Sites/Default/app/TDS_Reporting/funcs");
foreach ($supportfiles as $supportfile) {
    if (substr($supportfile, -4) == ".php") {
        include_once "/Library/Server/Web/Data/Sites/Default/app/TDS_Reporting/funcs/" . $supportfile;
    }
}


$supportfiles = scandir("/Library/Server/Web/Data/Sites/Default/app/TDS_Reporting/paths");
foreach ($supportfiles as $supportfile) {
    if (substr($supportfile, -4) == ".php") {
        include_once "/Library/Server/Web/Data/Sites/Default/app/TDS_Reporting/paths/" . $supportfile;
    }
}
