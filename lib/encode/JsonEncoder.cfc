component
	output = false
	hint = "I encode and decode values using JavaScript Object Notation (JSON)."
	{

	/**
	* I initialize the JSON encoder.
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
	* I decode the given JSON-encoded value and return the original input.
	* 
	* @input I am the encoded input that needs to be decoded.
	* @output false
	*/
	public any function decode( required string input ) {

		return( deserializeJson( input ) );

	}


	/**
	* I encode the given value using JavaScript Object Notation.
	* 
	* @input I am the data structure that needs to be encoded.
	* @output false
	*/
	public string function encode( required any input ) {

		return( serializeJson( input ) );

	}

}