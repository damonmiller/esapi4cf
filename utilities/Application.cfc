﻿/*
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
component {

	this.name = "ESAPI4CF-Utilities";
	this.sessionManagement = true;
	this.clientManagement = false;

	this.mappings["/org"] = expandPath("/esapi4cf/org");
	this.mappings["/test"] = expandPath("/esapi4cf/test");

}