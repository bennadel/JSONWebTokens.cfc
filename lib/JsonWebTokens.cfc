component
	output = false
	hint = "I provide a ColdFusion gateway for creating and consuming JSON Web Tokens (JWT)."
	{

	// If the user doesn't provide an algorithm, we'll use this one by default.
	DEFAULT_ALGORITHM = "HS256";


	/**
	* I initialize the JSON Web Tokens gateway. The gateway can create clients; or, it
	* can proxy a client for ease-of-use.
	* 
	* @output false
	*/
	public any function init() {

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I create a JSON Web Token client with the default utility components and the given 
	* secret key. The client can then be used to encode() and decode() JWT values.
	* 
	* @key I am the secret key used to encode and decode the payloads.
	* @algorithm I am the algorithm to be used when signing and verifying the payloads.
	* @output false
	*/
	public any function createClient( 
		required string key,
		string algorithm = DEFAULT_ALGORITHM
		) {

		var client = new client.JsonWebTokensClient(
			new encode.JsonEncoder(),
			new encode.Base64urlEncoder(),
			key,
			algorithm
		);

		return( client );

	}


	/**
	* I decode the given JSON Web Token and return the deserialized payload.
	* 
	* NOTE: If you plan to use the same key and algorithm for a number of operations,
	* it would be more efficient to create and cache a web-tokens client instead of using
	* this one-off method.
	* 
	* @token I am the JSON Web Token being decoded.
	* @key I am the shared secret key that was used for the encoding.
	* @algorithm I am the algorithm to be used if no algorithm is present in the header.
	* @output false
	*/
	public struct function decode(
		required string token,
		required string key,
		string algorithm = DEFAULT_ALGORITHM
		) {

		return( createClient( key, algorithm ).decode( token ) );
		
	}


	/**
	* I encode the given payload and return the JSON Web Token.
	* 
	* NOTE: If you plan to use the same key and algorithm for a number of operations,
	* it would be more efficient to create and cache a web-tokens client instead of using
	* this one-off method.
	* 
	* @payload I am the payload being encoded for transport.
	* @key I am the shared secret key for encoding.
	* @algorithm I am the algorithm to be used to generate the signature.
	* @output false
	*/
	public string function encode(
		required struct payload,
		required string key,
		string algorithm = DEFAULT_ALGORITHM
		) {

		return( createClient( key, algorithm ).encode( payload ) );

	}

}
