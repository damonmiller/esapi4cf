<!---
/*
 * OWASP Enterprise Security API for ColdFusion/CFML (ESAPI4CF)
 *
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2011 - The OWASP Foundation
 *
 * The ESAPI is published by OWASP under the BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 */
--->
<cfsetting requesttimeout="120">
<cfscript>
	Version = createObject("component", "org.owasp.esapi.util.Version");

	results = createObject("component", "mxunit.runner.DirectoryTestSuite").run(directory=expandPath("."), componentPath="esapi4cf.test.automation", recurse=true, excludes="esapi4cf.test.automation.org.owasp.esapi.util.TestCase");
</cfscript>
<cfoutput><!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Automation | #Version.getESAPI4CFName()# #Version.getESAPI4CFVersion()# [#Version.getCFMLEngine()# #Version.getCFMLVersion()#]</title>
</head>
<body>
<h1>Automation | #Version.getESAPI4CFName()# #Version.getESAPI4CFVersion()# [#Version.getCFMLEngine()# #Version.getCFMLVersion()#]</h1>
#results.getResultsOutput("html")#
</body>
</html>
</cfoutput>
