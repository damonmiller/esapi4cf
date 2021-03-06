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

/**
 * This class provides a generic static method that loads a
 * {@code java.security.Provider} either by some generic name
 * (i.e., {@code Provider.getName()}) or by a fully-qualified class name.
 * It is intended to be called dynamically by an application to add a
 * specific JCE provider at runtime.
 * </p><p>
 * If the {@code ESAPI.properties} file has a the property
 * {@code ESAPI.PreferredJCEProvider} defined to either a recognized
 * JCE provider (see below for list) or a fully qualified path name of
 * that JCE provider's {@code Provider} class, then the reference implementation
 * of ESAPI cryptography ({@code org.owasp.esapi.reference.crypto.JavaEncryptor})
 * tries to load this specified JCE provider via
 * {@link SecurityProviderLoader#insertProviderAt(String,int)}.
 * </p>
 */
component extends="org.owasp.esapi.util.Object" {

	variables.ESAPI = "";
	variables.logger = "";

    //
    // Load the table with known providers. We load the (short) JCE name
    // and the corresponding provider class. We don't 'new' the actual
    // class name here because that would mean we would have to have all
    // these jars. Instead we use reflection and do it dynamically only
    // when SecurityProviderLoader.insertProviderAt() is called because
    // presumably they will have the jar in their classpath for the
    // provider they wish to use.
    //
    variables.jceProviders = {};
        // SunJCE is installed by default and should always be available
        // with Sun-based JREs. As of JDK 1.3 and later, it is part of the
        // standard JRE install.
    variables.jceProviders.put("SunJCE", "com.sun.crypto.provider.SunJCE");

        // IBMJCE is default for WebSphere and is used by IBM JDKs. They
        // also have IBMJCEFIPS, but not sure if this is *always* provided
        // with WebSphere or just an add-on, hence not including it. IBMJCEFIPS
    	// is a FIPS 140-2 compliant JCE provider from IBM.
    variables.jceProviders.put("IBMJCE", "com.ibm.crypto.provider.IBMJCE");
    // variables.jceProviders.put("IBMJCEFIPS", "com.ibm.crypto.fips.provider.IBMJCEFIPS");

        // GnuCrypto is JCE provider for GNU Compiler for Java (GCJ)
    variables.jceProviders.put("GnuCrypto", "gnu.crypto.jce.GnuCrypto");

        // Bouncy Castle -- http://www.bouncycastle.org/ - FOSS, maintained.
    variables.jceProviders.put("BC", "org.bouncycastle.jce.provider.BouncyCastleProvider");

        // IAIK -- http://jce.iaik.tugraz.at/ -- No longer free.
    variables.jceProviders.put("IAIK", "iaik.security.provider.IAIK");

        // IBM FIPS 140-2 compliant provider -- Commercial
        // See above comments.
    // variables.jceProviders.put("IBMJCEFIPS", "com.ibm.crypto.fips.provider.IBMJCEFIPS");

        // RSA FIPS 142-2 compliant provider -- Commercial
    // variables.jceProviders.put("RSA", "com.rsa.jsafe.crypto.CryptoJ");

        // Cryptix -- http://www.cryptix.org/ - FOSS, not maintained.
        // Cryptix JCE code signing cert expired 2009/08/29 and was not
        // renewed.
    variables.jceProviders.put("CryptixCrypto", "cryptix.jce.provider.CryptixCrypto");
    variables.jceProviders.put("Cryptix", "cryptix.jce.provider.CryptixCrypto");

        // ABA - FOSS, not maintained - Google for it, or maybe search for
        // old copy at http://www.archive.org/
    variables.jceProviders.put("ABA", "au.net.aba.crypto.provider.ABAProvider");

	public SecurityProviderLoader function init(required org.owasp.esapi.ESAPI ESAPI) {
		variables.ESAPI = arguments.ESAPI;
		variables.logger = variables.ESAPI.getLogger(getMetaData(this).fullName);
		return this;
	}

    /**
     * This methods adds a provider to the {@code SecurityManager}
     * either by some generic name or by the class name.
     * </p><p>
     * The following generic JCE provider names are built-in:
     * <ul>
     * <li>SunJCE</li>
     * <li>IBMJCE [for WebSphere]</li>
     * <li>GnuCrypto [for use with GNU Compiler for Java, i.e., gcj]</li>
     * <li>BC [i.e., Bouncy Castle]</li>
     * <li>IAIK</li>
     * <li>CryptixCrypto (or Cryptix)
     * <li>ABA
     * </ul>
     * Note that neither Cryptix or ABA are actively maintained so
     * it is recommended that you do not start using them for ESAPI
     * unless your application already has a dependency on them. Furthermore,
     * the Cryptix JCE jars likely will not work as the Cryptix code signing
     * certificate has expired as of August 28, 2009. (This likely is true
     * for ABA, but I can't even find a copy to download!). Lastly, the IAIK
     * provider is no longer offered as free, open source. It is not a
     * commercial product. See {@link "http://jce.iaik.tugraz.at/"} for
     * details. While some older versions were offered free, it is not clear
     * whether the accompanying license still allows you to use it, and if
     * it does, whether or not the code signing certificate used to sign
     * their JCE jar(s) has expired are not.  Therefore, if you are looking
     * for a FOSS alternative to SunJCE, Bouncy Castle
     * ({@link "http://www.bouncycastle.org/"} is probably your best bet. The
     * BC provider does support many the "combined cipher modes" that provide
     * both confidentiality and authenticity. (See the {@code ESAPI.properties}
     * property {@code Encryptor.cipher_modes.combined_modes} for details.)
     * </p><p>
     * For those working in the U.S. federal government, it should be noted
     * that <i>none</i> of the providers listed here are considered validated
     * by NIST's Cryptographic Module Validation Program and are therefore
     * <b>not</b> considered FIPS 140-2 compliant. There are a few approved
     * JCE compatible Java libraries that are on NIST's CMVP list, but this
     * list changes constantly so they are not listed here. For further details
     * on NIST's CMVP, see
     * {@link "http://csrc.nist.gov/groups/STM/cmvp/index.html"}.
     * </p><p>
     * Finally, if you wish to use some other JCE provider not recognized above,
     * you must specify the provider's fully-qualified class name (which in
     * turn must have a public, no argument constructor).
     * </p><p>
     * The application must be given the {@code SecurityPermission} with a
     * value of {@code insertProvider.&lt;provider_name&gt;} (where
     * &lt;provider_name&gt; is the name of the algorithm provider if
     * a security manager is installed.
     * </p>
     *
     * @param algProvider Name of the JCE algorithm provider. If the name
     *                    contains a ".", this is interpreted as the name
     *                    of a {@code java.security.Provider} class name.
     * @param pos         The preference position (starting at 1) that the
     *                    caller would like for this provider. If you wish
     *                    for it to be installed as the <i>last</i> provider
     *                    (as of the time of this call), set {@code pos} to -1.
     * @return The actual preference position at which the provider was added,
     *         or -1 if the provider was not added because it is already
     *         installed.
     * @exception NoSuchProviderException - thrown if the provider class
     *         could not be loaded or added to the {@code SecurityManager} or
     *         any other reason for failure.
     */
    public numeric function insertProviderAt(required string algProvider, required numeric pos) {
        // We assume that if the algorithm provider contains a ".", then
        // we interpret this as a crypto provider class name and dynamically
        // add the provider. If it's one of the special ones we know about,
        // we also dynamically create it. Otherwise, we assume the provider
        // is in the "java.security" file.
        var providerClass = "";
        var clzName = "";
        var cryptoProvider = "";
        if (arguments.pos < -1 || arguments.pos == 0) raiseException("Position pos must be -1 or integer >= 1");
        try {
            // Does algProvider look like a class name?
            if (arguments.algProvider.indexOf(".") != -1) {
                clzName = arguments.algProvider;
            } else if (structKeyExists(variables.jceProviders, arguments.algProvider)) {
                // One of the special cases we know about.
                clzName = variables.jceProviders[arguments.algProvider];
            } else {
                raiseException(createObject("java", "java.security.NoSuchProviderException").init("Unable to locate Provider class for provider " & arguments.algProvider & ". Try using fully qualified class name or check provider name for typos. Builtin provider names are: " & variables.jceProviders.toString()));
            }

            providerClass = clzName;
            cryptoProvider = createObject("java", providerClass);

            // Found from above. Note that Security.insertProviderAt() can
            // throw a SecurityException if a Java SecurityManager is
            // installed and application doesn't have appropriate
            // permissions in policy file.
            //
            // However, since SecurityException is a RuntimeException it
            // doesn't need to be explicitly declared on the throws clause.
            // The application must be given the SecurityPermission with
            // a value of "insertProvider.<provider_name>" (where
            // <provider_name> is the name of the algorithm provider) if
            // a SecurityManager is installed.
            var ret = "";
            if ( arguments.pos == -1 ) {      // Special case: Means place _last_.
                ret = createObject("java", "java.security.Security").addProvider(cryptoProvider);
            } else {
                ret = createObject("java", "java.security.Security").insertProviderAt(cryptoProvider, javaCast("int", arguments.pos));
            }
            if ( ret == -1 ) {
                // log INFO that provider was already loaded.
                var msg = "JCE provider '" & arguments.algProvider & "' already loaded";
                if (arguments.pos == -1) {
                    // The just wanted it available (loaded last) and it is, so
                    // this is not critical.
                    variables.logger.always(variables.Logger.SECURITY_SUCCESS, msg);
                } else {
                    // In this case, it's a warning because it may have already
                    // been loaded, but *after* the position they requested.
                    // For example, if they were trying to load a FIPS 140-2
                    // compliant JCE provider at the first position and it was
                    // already loaded at position 3, then this is not FIPS 140-2
                    // compliant. Therefore, we make it a warning and a failure.
                	// Also log separately using 'always' in case warnings suppressed
                	// as per NSA suggestion.
                    variables.logger.warning(variables.Logger.SECURITY_FAILURE, msg);
                    variables.logger.always(variables.Logger.SECURITY_FAILURE, "(audit) " & msg);
                }
            } else {
            	// As per NSA suggestion.
                variables.logger.always(variables.Logger.SECURITY_AUDIT, "Successfully loaded preferred JCE provider " & arguments.algProvider & " at position " & arguments.pos);
            }
            return ret;
        } catch(java.lang.SecurityException ex) {
            // CHECKME: Log security event here too? This is a RuntimeException.
        	// It would only be thrown if a SecurityManager is installed that
        	// prohibits Security.addProvider() or Security.insertProviderAt()
        	// by the current user of this thread. Will log it here. Can always
        	// be ignored.
        	variables.logger.always(variables.Logger.SECURITY_FAILURE, "Failed to load preferred JCE provider " & arguments.algProvider & " at position " & arguments.pos, ex);
            raiseException(createObject("java", "java.lang.SecurityException").init(ex.message));
        } catch(any ex) {
            // Possibilities include: ClassNotFoundException,
            //                        InstantiationException, and others???
            //
            // Log an error & re-throw original message as NoSuchProviderException,
            // since that what it probably really implied here. This probably a configuration
        	// error (e.g., classpath problem, etc.) so we use EVENT_FAILURE rather than
        	// SECURITY_FAILURE here.
            variables.logger.error(variables.Logger.EVENT_FAILURE, "Failed to insert failed crypto provider " & arguments.algProvider & " at position " & arguments.pos, ex);
            raiseException(createObject("java", "java.security.NoSuchProviderException").init("Failed to insert crypto provider for " & arguments.algProvider & "; exception msg: " & ex.toString()));
        }
    }

    /**
     * Load the preferred JCE provider for ESAPI based on the <b>ESAPI.properties</b>
     * property {@code Encryptor.PreferredJCEProvider}. If this property is null
     * (i.e., unset) or set to an empty string, then no JCE provider is inserted
     * at the "preferred" position and thus the Java VM continues to use whatever
     * the default it was using for this (generally specified in the file
     * {@code $JAVA_HOME/jre/security/java.security}).
     * @return The actual preference position at which the provider was added,
     *         (which is expected to be 1) or -1 if the provider was not added
     *         because it is already installed at some other position. -1 is also
     *         returned if the {@code Encryptor.PreferredJCEProvider} was not set
     *         or set to an empty string, i.e., if the application <i>has</i> no
     *         preferred JCE provider.
     * @exception NoSuchProviderException - thrown if the provider class
     *         could not be loaded or added to the {@code SecurityManager} or
     *         any other reason for failure.
     * @see <a href="http://owasp-esapi-java.googlecode.com/svn/trunk/documentation/esapi4java-core-2.0-symmetric-crypto-user-guide.htm">
     *      ESAPI 2.0 Symmetric Encryption User Guide</a>
     */
    public numeric function loadESAPIPreferredJCEProvider() {
        var prefJCEProvider = variables.ESAPI.securityConfiguration().getPreferredJCEProvider();
        try {
            // If unset or set to empty string, then don't try to change it.
            if ( isNull(prefJCEProvider) || len(trim(prefJCEProvider)) == 0) {
            		// Always log, per NSA suggestion.
                variables.logger.always(variables.Logger.SECURITY_AUDIT, "No Encryptor.PreferredJCEProvider specified.");
                return -1;  // Unchanged; it is, whatever it is.
            } else {
                return insertProviderAt(prefJCEProvider, 1);
            }
        } catch (java.security.NoSuchProviderException ex) {
            // Will already have logged with exception msg.
        	var msg = "failed to load *preferred* JCE crypto provider, " & prefJCEProvider;
        	variables.logger.always(variables.Logger.SECURITY_AUDIT, msg);	// Per NSA suggestion.
            variables.logger.error(variables.Logger.SECURITY_FAILURE, msg);
            raiseException(ex);
        }
    }
}
