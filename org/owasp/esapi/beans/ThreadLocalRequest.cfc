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

/**
 * Defines the ThreadLocalRequest to store the current request for this thread.
 */
component extends="org.owasp.esapi.util.ThreadLocal" {

	variables.ESAPI = "";

	public ThreadLocalRequest function init(required org.owasp.esapi.ESAPI ESAPI) {
		variables.ESAPI = arguments.ESAPI;

		return this;
	}

	public function initialValue() {
		//return new SafeRequest(variables.ESAPI, getPageContext().getRequest());
		return "";
	}

	public function getRequest() {
		return super.get();
	}

	public void function setRequest(required org.owasp.esapi.beans.SafeRequest newRequest) {
		super.set(arguments.newRequest);
	}

}