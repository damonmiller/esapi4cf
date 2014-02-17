<!---
/**
 * OWASP Enterprise Security API (ESAPI)
 *
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2011 - The OWASP Foundation
 *
 * The ESAPI is published by OWASP under the BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 *
 * @author Damon Miller
 * @created 2011
 */
--->
<cfcomponent implements="org.owasp.esapi.Executor" extends="org.owasp.esapi.util.Object" output="false" hint="Reference implementation of the Executor interface. This implementation is very restrictive. Commands must exactly equal the canonical path to an executable on the system. Valid characters for parameters are codec dependent, but will usually only include alphanumeric, forward-slash, and dash.">

	<cfscript>
		variables.ESAPI = "";

		/** The logger. */
		variables.logger = "";

		//variables.MAX_SYSTEM_COMMAND_LENGTH = 2500;
	</cfscript>

	<cffunction access="public" returntype="org.owasp.esapi.Executor" name="init" output="false">
		<cfargument required="true" type="org.owasp.esapi.ESAPI" name="ESAPI"/>

		<cfscript>
			variables.ESAPI = arguments.ESAPI;
			variables.logger = variables.ESAPI.getLogger("Executor");

			return this;
		</cfscript>

	</cffunction>

	<cffunction access="public" returntype="String" name="executeSystemCommand" output="false"
	            hint="The reference implementation sets the work directory, escapes the parameters as per the Codec in use, and then executes the command without using concatenation. If there are failures, it will be logged. Privacy Note: Be careful if you pass PII to the executor, as the reference implementation logs the parameters. You MUST change this behavior if you are passing credit card numbers, TIN/SSN, or health information through this reference implementation, such as to a credit card or HL7 gateway.">
		<cfargument required="true" name="executable" hint="java.io.File"/>
		<cfargument required="true" name="params" hint="java.util.List"/>
		<cfargument required="true" name="workdir" hint="java.io.File"/>
		<cfargument required="true" name="codec" hint="org.owasp.esapi.codecs.Codec"/>

		<cfscript>
			// CF8 requires 'var' at the top
			var msgParams = [];
			var i = "";
			var param = "";
			var command = "";
			var process = "";
			var output = "";
			var errors = "";

			try {
				msgParams = [arguments.executable, arrayToList(arguments.params, " "), arguments.workdir];
				variables.logger.warning(getSecurityType("SECURITY_SUCCESS"), true, variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_initiating_message", msgParams));

				// command must exactly match the canonical path and must actually exist on the file system
				// using equalsIgnoreCase for Windows, although this isn't quite as strong as it should be
				if(!arguments.executable.getCanonicalPath().equalsIgnoreCase(arguments.executable.getPath())) {
					msgParams = [arguments.executable];
					throwException(createObject("component", "org.owasp.esapi.errors.ExecutorException").init(variables.ESAPI, variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_invalidPath_userMessage", msgParams), variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_invalidPath_logMessage", msgParams)));
				}
				if(!arguments.executable.exists()) {
					msgParams = [arguments.executable];
					throwException(createObject("component", "org.owasp.esapi.errors.ExecutorException").init(variables.ESAPI, variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_invalidInput_userMessage", msgParams), variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_invalidInput_logMessage", msgParams)));
				}

				// escape any special characters in the parameters
				for(i = 1; i <= arrayLen(arguments.params); i++) {
					param = arguments.params[i];
					arguments.params[i] = variables.ESAPI.encoder().encodeForOS(arguments.codec, param);
				}

				// working directory must exist
				if(!arguments.workdir.exists()) {
					msgParams = [arguments.workdir.getPath()];
					throwException(createObject("component", "org.owasp.esapi.errors.ExecutorException").init(variables.ESAPI, variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_directoryDoesNotExist_userMessage", msgParams), variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_directoryDoesNotExist_logMessage", msgParams)));
				}

				arrayPrepend(arguments.params, arguments.executable.getCanonicalPath());
				command = arguments.params;
				process = createObject("java", "java.lang.Runtime").getRuntime().exec(javaCast("string[]", command), javaCast("string[]", arrayNew(1)), arguments.workdir);
				// Future - this is how to implement this in Java 1.5+
				// ProcessBuilder pb = new ProcessBuilder(arguments.params);
				// Map env = pb.environment();
				// Security check - clear environment variables!
				// env.clear();
				// pb.directory(arguments.workdir);
				// pb.redirectErrorStream(true);
				// Process process = pb.start();
				output = readStream(process.getInputStream());
				errors = readStream(process.getErrorStream());
				if(errors != "" && errors.length() > 0) {
					msgParams = [errors];
					variables.logger.warning(getSecurityType("SECURITY_FAILURE"), false, variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_error_message", msgParams));
				}
				msgParams = [arrayToList(arguments.params, " ")];
				variables.logger.warning(getSecurityType("SECURITY_SUCCESS"), true, variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_complete_message", msgParams));
				return output;
			}
			catch(java.lang.Exception e) {
				msgParams = [e.getMessage()];
				throwException(createObject("component", "org.owasp.esapi.errors.ExecutorException").init(variables.ESAPI, variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_failure_userMessage", msgParams), variables.ESAPI.resourceBundle().messageFormat("Executor_executeSystemCommand_failure_logMessage", msgParams), e));
			}
		</cfscript>

	</cffunction>

	<cffunction access="private" returntype="String" name="readStream" output="false"
	            hint="readStream reads lines from an input stream and returns all of them in a single string">
		<cfargument required="true" name="is" hint="input stream to read from"/>

		<cfscript>
			var isr = createObject("java", "java.io.InputStreamReader").init(arguments.is);
			var br = createObject("java", "java.io.BufferedReader").init(isr);
			var sb = createObject("java", "java.lang.StringBuffer").init();
			var line = "";
			// prevent lockups by checking ready state
			if (!br.ready()) {
				throw(object=createObject("java", "java.lang.RuntimeException").init("BufferedReader not ready to be read."));
			}
			line = br.readLine();
			while(isDefined("line") && !isNull(line)) {
				sb.append(line & "\n");
				line = br.readLine();
			}
			return sb.toString();
		</cfscript>

	</cffunction>

</cfcomponent>