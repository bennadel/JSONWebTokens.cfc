component
	output = false
	hint = "I provide encoding and decoding methods for JSON Web Tokens (JWT)."
	{

	// These values are based on the algorithm names from the Java standard naming 
	// documentation for hashing, digesting, and signing security methods.
	// --
	// Read More: http://docs.oracle.com/javase/7/docs/technotes/guides/security/StandardNames.html
	algorithms = {
		HS256 = "HmacSHA256",
		HS384 = "HmacSHA384",
		HS512 = "HmacSHA512"
		// NOTE: These are currently commented-out because they are are not supported by this 
		// component. RSA is only available in Enterprise-level ColdFusion instances. I am 
		// keeping them here for future-compatibility and documentation.
		// --
		// RS256 = "SHA256withRSA",
		// RS384 = "SHA384withRSA",
		// RS512 = "SHA512withRSA",
		// ES256 = "SHA256withECDSA",
		// ES384 = "SHA384withECDSA",
		// ES512 = "SHA512withECDSA"
	};


	/**
	* I initialize the JSON Web Tokens client with the given key and algorithm.
	* 
	* @jsonEncoder I am the JSON encoding utility.
	* @base64urlEncoder I am the base64url encoding utility.
	* @key I am the key used to sign and verify payloads.
	* @algorithm I am the signing algorithm to be used when signing.
	* @output false
	*/
	public any function init(
		required any jsonEncoder,
		required any base64urlEncoder,
		required string key,
		required string algorithm
		) {

		// Store the private variables.
		setJsonEncoder( jsonEncoder );
		setBase64urlEncoder( base64urlEncoder );
		setKey( key );
		setAlgorithm( algorithm );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I decode the given JSON Web Token and return the deserialized payload.
	* 
	* @token I am the JWT token being decoded.
	* @output false
	*/
	public struct function decode( required string token ) {

		// Extract the JSON Web token segments.
		var segments = listToArray( token, "." );
		var headerSegment = segments[ 1 ];
		var payloadSegment = segments[ 2 ];
		var signatureSegment = segments[ 3 ];

		// Parse the data segments.
		var header = parseHeaderSegment( headerSegment );
		var payload = parsePayloadSegment( payloadSegment );

		// By default, we'll use the client-specific algorithm.
		var algorithmForDecoding = algorithm;

		// However, if an algorithm was supplied in the header, use that one instead.
		if ( structKeyExists( header, "alg" ) ) {

			algorithmForDecoding = header.alg;

			try {

				testAlgorithm( algorithmForDecoding );
				
			} catch ( any error ) {

				throw(
					type = "JsonWebTokens.InvalidAlgorithm",
					message = "The algorithm supplied by the header is not supported.",
					detail = "The header specified the algorithm [#algorithmForDecoding#] which is not currently supported.",
					extendedInfo = "JSON Web Token: [#token#]."
				);

			}

		}

		// Validate that signature is correct before we return payload.
		var expectedSignatureSegment = generateSignatureSegment( headerSegment, payloadSegment, algorithms[ algorithmForDecoding ] );
		
		if ( signatureSegment != expectedSignatureSegment ) {

			throw(
				type = "JsonWebTokens.SignatureMismatch",
				message = "The JSON Web Token signature is invalid.",
				detail = "The given JSON Web Token signature [#signatureSegment#] does not match the expected signature [#expectedSignatureSegment#].",
				extendedInfo = "JSON Web Token: [#token#]."
			);

		}

		return( payload );

	}


	/**
	* I encode the given payload for JWT transportation.
	* 
	* @payload I am the payload being encoded for transport.
	* @output false
	*/
	public string function encode( required struct payload ) {

		// I am the standardized header for a secured JSON Web Token.
		var header = {
			"typ" = "JWT",
			"alg" = ucase( algorithm )
		};

		// Generate segments of the token.
		var headerSegment = generateHeaderSegment( header );
		var payloadSegment = generatePayloadSegment( payload );
		var signatureSegment = generateSignatureSegment( headerSegment, payloadSegment, algorithms[ algorithm ] );

		// Return the JSON web token.
		return( headerSegment & "." & payloadSegment & "." & signatureSegment );

	}


	/**
	* I set the algorithm being used to used to generate the signature. Returns [this].
	* 
	* @newKey I am the new algorithm being used by the hasher.
	* @output false
	*/
	public any function setAlgorithm( required string newAlgorithm ) {

		testAlgorithm( newAlgorithm );

		algorithm = newAlgorithm;

		return( this );

	}


	/**
	* I set the base64url encoder implementation. Returns [this].
	* 
	* @newBase64urlEncoder I am the new base64url encoder.
	* @output false
	*/
	public any function setBase64urlEncoder( required any newBase64urlEncoder ) {

		base64urlEncoder = newBase64urlEncoder;

		return( this );

	}


	/**
	* I set the JSON encoder implementation used to serialize and deserialize portions
	* of the request. Returns [this].
	* 
	* @newJsonEncoder I am the new JSON encoder.
	* @output false
	*/
	public any function setJsonEncoder( required any newJsonEncoder ) {

		jsonEncoder = newJsonEncoder;

		return( this );

	}


	/**
	* I set the secret key being used to sign the message. Returns [this].
	* 
	* @newKey I am the new secret key.
	* @output false
	*/
	public any function setKey( required string newKey ) {

		testKey( newKey );

		key = newKey;

		return( this );

	}


	/**
	* I test the given algorithm to make sure it is valid (and supported by the current
	* implementation). If the algorithm is not valid, I throw an error.
	* 
	* @newAlgorithm I am the new algorithm being tested.
	* @output false
	*/
	public void function testAlgorithm( required string newAlgorithm ) {

		if ( ! structKeyExists( algorithms, newAlgorithm ) ) {

			throw(
				type = "JsonWebTokens.InvalidAlgorithm",
				message = "The JSON Web Token algorithm is not supported.",
				detail = "The algorithm [#newAlgorithm#] is not currently supported."
			);

		}

	}


	/**
	* I test the given secret key to make sure it is valid. If the key is not valid,
	* I throw an error.
	* 
	* @newKey I am the new key being tested.
	* @output false
	*/
	public void function testKey( required string newKey ) {

		if ( ! len( newKey ) ) {

			throw(
				type = "JsonWebTokens.InvalidKey",
				message = "The secret key cannot be empty."
			);

		}

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I generate the header segment of the token using the given header.
	* 
	* @header I am the header to be serialized.
	* @output false
	*/
	private string function generateHeaderSegment( required struct header ) {

		var serializedHeader = jsonEncoder.encode( header );

		return( base64urlEncoder.encode( serializedHeader ) );

	}


	/**
	* I generate the payload segment of the token using the given payload.
	* 
	* @payload I am the payload to be serialized.
	* @output false
	*/
	private string function generatePayloadSegment( required struct payload ) {

		var serializedPayload = jsonEncoder.encode( payload );

		return( base64urlEncoder.encode( serializedPayload ) );

	}


	/**
	* I generate the signature for the given portions of the token. The signature is returned
	* as a base64url-encoded string.
	* 
	* @header I am the serialized header.
	* @payload I am the serialized payload.
	* @algorithm I am the name of the Java cryptography / hashing algorithm to use.
	* @output false
	*/
	private string function generateSignatureSegment(
		required string header,
		required string payload,
		required string hmacAlgorithm
		) {

		var mac = createObject( "java", "javax.crypto.Mac" ).getInstance( javaCast( "string", hmacAlgorithm ) );

		mac.init(
			createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init(
				charsetDecode( key, "utf-8" ),
				javaCast( "string", hmacAlgorithm )
			)
		);

		var hashedBytes = mac.doFinal( charsetDecode( "#header#.#payload#", "utf-8" ) );

		return( base64urlEncoder.encodeBytes( hashedBytes ) );

	}


	/**
	* I parse the header segment of the token, returning the deserialized header.
	* 
	* @header I am the header to be parse.
	* @output false
	*/
	private struct function parseHeaderSegment( required string header ) {

		var serializedHeader = base64urlEncoder.decode( header );

		return( jsonEncoder.decode( serializedHeader ) );

	}


	/**
	* I parse the payload segment of the token, returning the deserialized payload.
	* 
	* @payload I am the payload to be parse.
	* @output false
	*/
	private struct function parsePayloadSegment( required string payload ) {

		var serializedPayload = base64urlEncoder.decode( payload );

		return( jsonEncoder.decode( serializedPayload ) );

	}

}