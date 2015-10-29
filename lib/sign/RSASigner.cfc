component
	output = false
	hint = "I provide sign and verify methods for RSA-based signing."
	{

	/**
	* I create a new RSA Signer using the given algorithm and public and private keys.
	* 
	* NOTE: The algorithm uses the names provided in the Java Cryptography Architecture
	* Standard Algorithm Name documentation: 
	* 
	* - SHA256withRSA
	* - SHA384withRSA
	* - SHA512withRSA
	* 
	* CAUTION: The keys are assumed to be in PEM format.
	* 
	* @algorithm I am the RSA-based signature algorithm being used.
	* @publicKey I am the plain-text public key.
	* @privateKey I am the plain-text private key.
	* @output false
	*/
	public any function init(
		required string algorithm,
		required string publicKey,
		required string privateKey
		) {

		setAlgorithm( algorithm );
		setPublicKeyFromText( publicKey );
		setPrivateKeyFromText( privateKey );

		return( this );

	}


	// ---
	// STATIC METHODS.
	// ---


	/**
	* I add the BounceCastleProvider to the underlying crypto APIs.
	* 
	* CAUTION: I don't really understand why this is [sometimes] required. But, if you
	* run into the error, "Invalid RSA private key encoding.", adding BouncyCastle may
	* solve the problem.
	* 
	* This method only needs to be called once per ColdFusion application life-cycle. 
	* But, it can be called multiple times without error.
	* 
	* @output false
	*/
	public void function addBouncyCastleProvider() {

		createObject( "java", "java.security.Security" )
			.addProvider( createObject( "java", "org.bouncycastle.jce.provider.BouncyCastleProvider" ).init() )
		;

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I get the current algorithm name.
	* 
	* @output false
	*/
	public string function getAlgorithm() {

		return( algorithm );

	}


	/**
	* I set the given RSA algorithm. Returns [this].
	* 
	* NOTE: The algorithm uses the names provided in the Java Cryptography Architecture
	* Standard Algorithm Name documentation: 
	* 
	* - SHA256withRSA
	* - SHA384withRSA
	* - SHA512withRSA
	* 
	* @newAlgorithm I am the RSA-based signature algorithm being set.
	* @output false
	*/
	private any function setAlgorithm( required string newAlgorithm ) {

		testAlgorithm( newAlgorithm );

		algorithm = newAlgorithm;

		return( this );

	}


	/**
	* I set the public key using the plain-text public key content. Returns [this].
	* 
	* NOTE: Keys are expected to be in PEM format.
	* 
	* @newPublicKeyText I am the plain-text public key.
	* @output false
	*/
	public any function setPublicKeyFromText( required string newPublicKeyText ) {

		testKey( newPublicKeyText );

		var publicKeySpec = createObject( "java", "java.security.spec.X509EncodedKeySpec" ).init(
			binaryDecode( stripKeyDelimiters( newPublicKeyText ), "base64" )
		);

		publicKey = createObject( "java", "java.security.KeyFactory" )
			.getInstance( javaCast( "string", "RSA" ) )
			.generatePublic( publicKeySpec )
		;

		return( this );

	}


	/**
	* I set the private key using the plain-text private key content. Returns [this].
	* 
	* NOTE: Keys are expected to be in PEM format.
	* 
	* @newPrivateKeyText I am the plain-text private key.
	* @output false
	*/
	public any function setPrivateKeyFromText( required string newPrivateKeyText ) {

		testKey( newPrivateKeyText );

		var privateKeySpec = createObject( "java", "java.security.spec.PKCS8EncodedKeySpec" ).init(
			binaryDecode( stripKeyDelimiters( newPrivateKeyText ), "base64" )
		);

		privateKey = createObject( "java", "java.security.KeyFactory" )
			.getInstance( javaCast( "string", "RSA" ) )
			.generatePrivate( privateKeySpec )
		;

		return( this );

	}


	/**
	* I test the given algorithm. If the algorithm is not valid, I throw an error.
	* 
	* @newAlgorithm I am the new RSA algorithm being tested.
	* @output false
	*/
	public void function testAlgorithm( required string newAlgorithm ) {

		switch ( newAlgorithm ) {
			case "SHA256withRSA":
			case "SHA384withRSA":
			case "SHA512withRSA":
				return;	
			break;
		}

		throw(
			type = "JsonWebTokens.RSASigner.InvalidAlgorithm",
			message = "The given algorithm is not supported.",
			detail = "The given algorithm [#newAlgorithm#] is not supported."
		);
		
	}


	/**
	* I test the given key (public or private). If the key is not valid, I throw an error.
	* 
	* @newKey I am the new key being tested.
	* @output false
	*/
	public void function testKey( required string newKey ) {

		if ( ! len( stripKeyDelimiters( newKey ) ) ) {

			throw(
				type = "JsonWebTokens.RSASigner.InvalidKey",
				message = "The key cannot be blank."
			);

		}

	}


	/**
	* I sign the given binary message using the current algorithm and private key.
	* 
	* @message I am the message being signed.
	* @output false
	*/
	public binary function sign( required binary message ) {

		var signer = createObject( "java", "java.security.Signature" )
			.getInstance( javaCast( "string", algorithm ) )
		;

		signer.initSign( privateKey );
		signer.update( message );

		return( signer.sign() );

	}


	/**
	* I verify that the given signature was generated from the given message.
	* 
	* @message I am the binary message input.
	* @signature I am the binary signature being verified.
	* @output false
	*/
	public boolean function verify(
		required binary message,
		required binary signature
		) {

		var verifier = createObject( "java", "java.security.Signature" )
			.getInstance( javaCast( "string", algorithm ) )
		;

		verifier.initVerify( publicKey );
		verifier.update( message );

		return( verifier.verify( signature ) );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I strip the plain-text key delimiters, to isolate the key content.
	* 
	* @keyText I am the plain-text key input.
	* @output false
	*/
	private string function stripKeyDelimiters( required string keyText ) {

		// Strips out the leading / trailing boundaries:
		keyText = reReplace( keyText, "-----(BEGIN|END)[^\r\n]+", "", "all" );

		return( trim( keyText ) );

	}

}