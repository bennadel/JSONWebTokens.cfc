component
	output = false
	hint = "I provide encoding and decoding methods for JSON Web Tokens (JWT)."
	{

	// I map the Java algorithm names onto the common JWT algorithm names.
	// --
	// Read More: http://docs.oracle.com/javase/7/docs/technotes/guides/security/StandardNames.html
	mapToJwtAlgorithm = {
		HmacSHA256 = "HS256",
		HmacSHA384 = "HS384",
		HmacSHA512 = "HS512",
		SHA256withRSA = "RS256",
		SHA384withRSA = "RS384",
		SHA512withRSA = "RS512"
		// --
		// Not yet supported. 
		// --
		// SHA256withECDSA = "ES256",
		// SHA384withECDSA = "ES384",
		// SHA512withECDSA = "ES512"
	};


	/**
	* I initialize the JSON Web Tokens client with the given signer.
	* 
	* @jsonEncoder I am the JSON encoding utility.
	* @base64urlEncoder I am the base64url encoding utility.
	* @signer I am the secure message signer and verifier.
	* @output false
	*/
	public any function init(
		required any jsonEncoder,
		required any base64urlEncoder,
		required any signer
		) {

		// Store the private variables.
		setJsonEncoder( jsonEncoder );
		setBase64urlEncoder( base64urlEncoder );
		setSigner( signer );

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

		// CAUTION: We never use the algorithm defined in the header. Not only can we
		// not be sure that we have the appropriate signer, we also open ourselves up
		// to potential abuse. As such, the client will always use the predefined, 
		// internal signer when verifying the signature.

		if ( ! verifySignatureSegment( headerSegment, payloadSegment, signatureSegment ) ) {

			throw(
				type = "JsonWebTokens.SignatureMismatch",
				message = "The JSON Web Token signature is invalid.",
				detail = "The given JSON Web Token signature [#signatureSegment#] could not be verified by the signer.",
				extendedInfo = "JSON Web Token: [#token#]."
			);

		}

		return( parsePayloadSegment( payloadSegment ) );

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
			"alg" = mapToJwtAlgorithm[ signer.getAlgorithm() ]
		};

		// Generate segments of the token.
		var headerSegment = generateHeaderSegment( header );
		var payloadSegment = generatePayloadSegment( payload );
		var signatureSegment = generateSignatureSegment( headerSegment, payloadSegment );

		// Return the JSON web token.
		return( headerSegment & "." & payloadSegment & "." & signatureSegment );

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
	* I set the message signer and verifier. Returns [this].
	* 
	* @newSigner I am the new message signer.
	* @output false
	*/
	public any function setSigner( required any newSigner ) {

		signer = newSigner;

		return( this );

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
	* I generate the signature for the given portions of the token. The signature is 
	* returned as a base64url-encoded string.
	* 
	* @header I am the serialized header.
	* @payload I am the serialized payload.
	* @output false
	*/
	private string function generateSignatureSegment(
		required string header,
		required string payload
		) {

		var hashedBytes = signer.sign( charsetDecode( "#header#.#payload#", "utf-8" ) );

		return( base64urlEncoder.encodeBytes( hashedBytes ) );

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


	/**
	* I verify that the given signature was produced by the given message segments.
	* 
	* @header I am the base64url-encoded header segment.
	* @payload I am the base64url-encoded payload segment.
	* @signature I am the base64url-encoded signature segment.
	* @output false
	*/
	private string function verifySignatureSegment(
		required string header,
		required string payload,
		required string signature
		) {

		var base64Signature = base64urlEncoder.convertToBase64( signature );

		return(
			signer.verify(
				charsetDecode( "#header#.#payload#", "utf-8" ),
				binaryDecode( base64Signature, "base64" )
			)
		);

	}

}