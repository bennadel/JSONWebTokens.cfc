component
	output = false
	hint = "I provide sign and verify methods for Hmac-based signing."
	{

	/**
	* I create a new Hmac-based signer with the given algorithm and key.
	* 
	* NOTE: The algorithm uses the names provided in the Java Cryptography Architecture
	* Standard Algorithm Name documentation: 
	* 
	* - HmacSHA256
	* - HmacSHA384
	* - HmacSHA512
	* 
	* @algorithm I am the Hmac algorithm.
	* @key I am the secret key used during hashing.
	* @output false
	*/

	public any function init(
		required string algorithm,
		required string key
		) {

		setAlgorithm( algorithm );
		setKey( key );

		return( this );

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
	* I set the given Hmac algorithm. Returns [this].
	* 
	* @newAlgorithm I am the new Hmac algorithm being set.
	*/
	public any function setAlgorithm( required string newAlgorithm ) {

		testAlgorithm( newAlgorithm );

		algorithm = newAlgorithm;

		return( this );

	}


	/**
	* I set the given secret key. Returns [this].
	*/
	public any function setKey( required string newKey ) {

		testKey( newKey );

		// Since the signing will always require a binary value, let's store the key
		// as a byte-array so we don't have to decode it every time we want to use it.
		key = charsetDecode( newKey, "utf-8" );

		return( this );

	}


	/**
	* I sign the given binary message using the current algorithm and secret key.
	* 
	* @message I am the message being signed.
	* @output false
	*/
	public binary function sign( required binary message ) {

		var mac = createObject( "java", "javax.crypto.Mac" ).getInstance( javaCast( "string", algorithm ) );

		mac.init(
			createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init(
				key,
				javaCast( "string", algorithm )
			)
		);

		return( mac.doFinal( message ) );

	}


	/**
	* I test the given algorithm. If the algorithm is not valid, I throw an error.
	* 
	* @newAlgorithm I am the new Hmac algorithm being tested.
	* @output false
	*/
	public void function testAlgorithm( required string newAlgorithm ) {

		switch ( newAlgorithm ) {
			case "HmacSHA256":
			case "HmacSHA384":
			case "HmacSHA512":
				return;	
			break;
		}

		throw(
			type = "JsonWebTokens.HmacSigner.InvalidAlgorithm",
			message = "The given algorithm is not supported.",
			detail = "The given algorithm [#newAlgorithm#] is not supported."
		);
		
	}


	/**
	* I test the given secret key. If the key is not valid, I throw an error.
	* 
	* @newKey I am the new key being tested.
	* @output false
	*/
	public void function testKey( required string newKey ) {

		if ( ! len( newKey ) ) {

			throw(
				type = "JsonWebTokens.HmacSigner.InvalidKey",
				message = "The secret key cannot be blank."
			);

		}

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

		var expectedSignature = sign( message );

		// Compare the two binary values using a quick hash.
		return( hash( signature ) == hash( expectedSignature ) );

	}

}