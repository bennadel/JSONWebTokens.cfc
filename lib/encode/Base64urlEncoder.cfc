component
	output = false
	hint = "I encode and decode values using the Base64url character set (which is a variation of the Base64 standard intended for use with URLs)."
	{

	/**
	* I initialize the Base64url encoder.
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
	* I convert the given base64 value into the the base64url character set.
	* 
	* @input I am the base64 value to convert to base64url.
	* @output false
	*/
	public string function convertFromBase64( required string input ) {

		input = replace( input, "+", "-", "all" );
		input = replace( input, "/", "_", "all" );
		input = replace( input, "=", "", "all" );

		return( input );

	}


	/**
	* I convert the given base64url value into the the base64 character set.
	* 
	* @input I am the base64url value to convert to base64.
	* @output false
	*/
	public string function convertToBase64( required string input ) {

		input = replace( input, "-", "+", "all" );
		input = replace( input, "_", "/", "all" );

		var paddingLength = ( 4 - ( len( input ) % 4 ) );
		
		return( input & repeatString( "=", paddingLength ) );

	}


	/**
	* I decode the given base64url value and return the original UTF-8 input.
	* 
	* @input I am the encoded input that needs to be decoded.
	* @output false
	*/
	public string function decode( required string input ) {

		return( charsetEncode( binaryDecode( convertToBase64( input ), "base64" ), "utf-8" ) );

	}


	/**
	* I decode the given binary representation (of a base64url string) and return the
	* original UTF-8 input.
	* 
	* @input I am the binary value that needs to be decoded.
	* @output false
	*/
	public string function decodeBytes( required binary input ) {

		return( decode( charsetEncode( binary, "utf-8" ) ) );

	}


	/**
	* I encode the given UTF-8 input using the base64url character set.
	* 
	* @input I am the UTF-8 value that needs to be encoded using base64url.
	* @output false
	*/
	public string function encode( required string input ) {

		return( encodeBytes( charsetDecode( input, "utf-8" ) ) );

	}


	/**
	* I encode the given binary value using the base64url character set.
	* 
	* @input I am the binary value to encode using base64url.
	* @output false
	*/
	public string function encodeBytes( required binary input ) {

		return( convertFromBase64( binaryEncode( input, "base64" ) ) );

	}

}