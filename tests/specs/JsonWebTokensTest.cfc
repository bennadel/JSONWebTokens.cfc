component
	extends = "TestCase"
	output = false
	hint = "I test the JSON Web Tokens component."
	{

	public void function test_that_the_client_works() {

		var client = new lib.JsonWebTokens().createClient( "secret", "HS256" );

		// NOTE: Values pulled from http://jwt.io/
		var payload = {
			"sub": "1234567890",
			"name": "John Doe",
			"admin": true
		};

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test the full life-cycle 
		// and ensure that the decoded value matches the original input.
		var token = client.encode( payload );
		var newPayload = client.decode( token );

		assert( payload.sub == newPayload.sub );
		assert( payload.name == newPayload.name );
		assert( payload.admin == newPayload.admin );

	}


	public void function test_that_decoding_works() {

		var jwt = new lib.JsonWebTokens();

		// NOTE: Values pulled from http://jwt.io/
		var payload = jwt.decode( "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6dHJ1ZSwibmFtZSI6IkpvaG4gRG9lIiwic3ViIjoxMjM0NTY3ODkwfQ.5lwOHou_CUazP24HNO4Zc0MQVMay5e48eCIsiJYZAs0", "secret" );

		assert( payload.sub == "1234567890" );
		assert( payload.name == "John Doe" );
		assert( payload.admin == true );

	}


	public void function test_that_encoding_lifecycle_works() {

		var jwt = new lib.JsonWebTokens();

		// NOTE: Values pulled from http://jwt.io/
		var payload = {
			"sub": "1234567890",
			"name": "John Doe",
			"admin": true
		};

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test the full life-cycle 
		// and ensure that the decoded value matches the original input.
		var token = jwt.encode( payload, "secret" );
		var newPayload = jwt.decode( token, "secret" );

		assert( payload.sub == newPayload.sub );
		assert( payload.name == newPayload.name );
		assert( payload.admin == newPayload.admin );

	}


	public void function test_complex_data_with_encoding_lifecycle() {

		var algorithms = [ "HS256", "HS384", "HS512" ];

		// Try it for each supported algorithm.
		for ( algorithm in algorithms ) {

			var client = new lib.JsonWebTokens().createClient( "secret", algorithm );

			var payload = {
				"id": 4,
				"name": "Kim Smith",
				"likes": [ "Movies", "Walks", "Food" ],
				"strengths": {
					"kindness": 7,
					"quirkiness": 9,
					"fun": 10
				}
			};

			// NOTE: Because we the order of the serialized keys affects the token, it's hard 
			// to consistently test the encoded value. But, we can test the full life-cycle 
			// and ensure that the decoded value matches the original input.
			var token = client.encode( payload );
			var newPayload = client.decode( token );

			assert( payload.id == newPayload.id );
			assert( payload.name == newPayload.name );
			assert( payload.likes[ 1 ] == "Movies" );
			assert( payload.likes[ 2 ] == "Walks" );
			assert( payload.likes[ 3 ] == "Food" );
			assert( payload.strengths.kindness == newPayload.strengths.kindness );
			assert( payload.strengths.quirkiness == newPayload.strengths.quirkiness );
			assert( payload.strengths.fun == newPayload.strengths.fun );
			
		}

	}


	public void function test_complex_data_decoding() {

		var client = new lib.JsonWebTokens().createClient( "secret", "HS256" );

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test that the decoded value
		// matches a known encoded token.
		var newPayload = client.decode( "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NCwibmFtZSI6IktpbSBTbWl0aCIsImxpa2VzIjpbIk1vdmllcyIsIldhbGtzIiwiRm9vZCJdLCJzdHJlbmd0aHMiOnsia2luZG5lc3MiOjcsInF1aXJraW5lc3MiOjksImZ1biI6MTB9fQ.QKkMlaC0mSCryIwcmI7sIJ_WfY6n0a8DmkjJYajk100" );

		var expectedPayload = {
			"id": 4,
			"name": "Kim Smith",
			"likes": [ "Movies", "Walks", "Food" ],
			"strengths": {
				"kindness": 7,
				"quirkiness": 9,
				"fun": 10
			}
		};

		assert( expectedPayload.id == newPayload.id );
		assert( expectedPayload.name == newPayload.name );
		assert( expectedPayload.likes[ 1 ] == "Movies" );
		assert( expectedPayload.likes[ 2 ] == "Walks" );
		assert( expectedPayload.likes[ 3 ] == "Food" );
		assert( expectedPayload.strengths.kindness == newPayload.strengths.kindness );
		assert( expectedPayload.strengths.quirkiness == newPayload.strengths.quirkiness );
		assert( expectedPayload.strengths.fun == newPayload.strengths.fun );

	}


	public void function test_that_algorithms_result_in_different_tokens() {

		var jwt = new lib.JsonWebTokens();

		var payload = {
			"id": 4,
			"name": "Kim Smith"
		};

		var token256 = jwt.encode( payload, "secret", "HS256" );
		var token384 = jwt.encode( payload, "secret", "HS384" );
		var token512 = jwt.encode( payload, "secret", "HS512" );

		assert( token256 != token384 );
		assert( token256 != token512 );
		assert( token384 != token512 );

	}

}