component
	extends = "TestCase"
	output = false
	hint = "I test the JSON Web Tokens component."
	{

	public void function test_that_the_client_works() {

		var jwtClient = new lib.JsonWebTokens().createClient( "HS256", "secret" );

		// NOTE: Values pulled from http://jwt.io/
		var payload = {
			"sub": "1234567890",
			"name": "John Doe",
			"admin": true
		};

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test the full life-cycle 
		// and ensure that the decoded value matches the original input.
		var token = jwtClient.encode( payload );
		var newPayload = jwtClient.decode( token );

		assert( payload.sub == newPayload.sub );
		assert( payload.name == newPayload.name );
		assert( payload.admin == newPayload.admin );

	}


	public void function test_that_hmac_decoding_works() {

		var jwt = new lib.JsonWebTokens();

		// NOTE: Values pulled from http://jwt.io/
		var payload = jwt.decode( 
			"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6dHJ1ZSwibmFtZSI6IkpvaG4gRG9lIiwic3ViIjoxMjM0NTY3ODkwfQ.5lwOHou_CUazP24HNO4Zc0MQVMay5e48eCIsiJYZAs0", 
			"HS256",
			"secret"
		);

		assert( payload.sub == "1234567890" );
		assert( payload.name == "John Doe" );
		assert( payload.admin == true );

	}


	public void function test_that_rsa_decoding_works() {

		var jwt = new lib.JsonWebTokens();

		// NOTE: Values pulled from http://jwt.io/
		var payload = jwt.decode( 
			"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.R4hFfsggj06JDaxUw36RUcMkTcuhvjFqNUs8CNtqhCYDXFLFl5bwaeiASMYs0A79acFVDYKQC8r5euKEpldyE3Nn_opsjnTaC91z3LCdbYBUMd5EkTQO1c-NOZID5xMA_ff5xR9hn3Pg3OZas_2LP24krM6ZDlUxSHkdWi36cYE",
			"RS256",
			getPublicKey(),
			getPrivateKey()
		);

		assert( payload.sub == "1234567890" );
		assert( payload.name == "John Doe" );
		assert( payload.admin == true );

	}


	public void function test_that_hmac_encoding_lifecycle_works() {

		var jwt = new lib.JsonWebTokens();

		var payload = {
			"sub": "1234567890",
			"name": "John Doe",
			"admin": true
		};

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test the full life-cycle 
		// and ensure that the decoded value matches the original input.
		var token = jwt.encode( payload, "HS256", "secret" );
		var newPayload = jwt.decode( token, "HS256", "secret" );

		assert( payload.sub == newPayload.sub );
		assert( payload.name == newPayload.name );
		assert( payload.admin == newPayload.admin );

	}


	public void function test_that_rsa_encoding_lifecycle_works() {

		var jwt = new lib.JsonWebTokens();

		var payload = {
			"sub": "1234567890",
			"name": "John Doe",
			"admin": true
		};

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test the full life-cycle 
		// and ensure that the decoded value matches the original input.
		var token = jwt.encode( payload, "RS256", getPublicKey(), getPrivateKey() );
		var newPayload = jwt.decode( token, "RS256", getPublicKey(), getPrivateKey() );

		assert( payload.sub == newPayload.sub );
		assert( payload.name == newPayload.name );
		assert( payload.admin == newPayload.admin );

	}


	public void function test_complex_data_with_hmac_encoding_lifecycle() {

		var algorithms = [ "HS256", "HS384", "HS512" ];

		// Try it for each supported algorithm.
		for ( algorithm in algorithms ) {

			var jwtClient = new lib.JsonWebTokens().createClient( algorithm, "secret" );

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
			var token = jwtClient.encode( payload );
			var newPayload = jwtClient.decode( token );

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


	public void function test_complex_data_with_rsa_encoding_lifecycle() {

		var algorithms = [ "RS256", "RS384", "RS512" ];

		// Try it for each supported algorithm.
		for ( algorithm in algorithms ) {

			var jwtClient = new lib.JsonWebTokens().createClient( algorithm, getPublicKey(), getPrivateKey() );

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
			var token = jwtClient.encode( payload );
			var newPayload = jwtClient.decode( token );

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


	public void function test_complex_data_with_hmac_decoding() {

		var jwtClient = new lib.JsonWebTokens().createClient( "HS256", "secret" );

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test that the decoded value
		// matches a known encoded token.
		// --
		// Signature validated on http://jwt.io/
		var newPayload = jwtClient.decode( "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NCwibmFtZSI6IktpbSBTbWl0aCIsImxpa2VzIjpbIk1vdmllcyIsIldhbGtzIiwiRm9vZCJdLCJzdHJlbmd0aHMiOnsia2luZG5lc3MiOjcsInF1aXJraW5lc3MiOjksImZ1biI6MTB9fQ.QKkMlaC0mSCryIwcmI7sIJ_WfY6n0a8DmkjJYajk100" );

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


	public void function test_complex_data_with_rsa_decoding() {

		var jwtClient = new lib.JsonWebTokens().createClient( "RS256", getPublicKey(), getPrivateKey() );

		// NOTE: Because we the order of the serialized keys affects the token, it's hard 
		// to consistently test the encoded value. But, we can test that the decoded value
		// matches a known encoded token.
		// --
		// Signature validated on http://jwt.io/
		var newPayload = jwtClient.decode( "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NCwibmFtZSI6IktpbSBTbWl0aCIsImxpa2VzIjpbIk1vdmllcyIsIldhbGtzIiwiRm9vZCJdLCJzdHJlbmd0aHMiOnsia2luZG5lc3MiOjcsInF1aXJraW5lc3MiOjksImZ1biI6MTB9fQ.kFz_oLiiM5VRlqX-5XidsnDDB7R5IYyxTf87mMyYRpOop2mMrqVQFiKULaZDjQGYB_MKuJLQv2ocmUSbUWXqcpZC__amORjIW-8lTMwtNQM3vDQhQcvmCfU31hQeznxoI6_0u1WEqcuArANZXc7guM66rSS9j48AevhvPFgI79Q" );

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


	public void function test_that_hmac_algorithms_result_in_different_tokens() {

		var jwt = new lib.JsonWebTokens();

		var payload = {
			"id": 4,
			"name": "Kim Smith"
		};

		var token256 = jwt.encode( payload, "HS256", "secret" );
		var token384 = jwt.encode( payload, "HS384", "secret" );
		var token512 = jwt.encode( payload, "HS512", "secret" );

		assert( token256 != token384 );
		assert( token256 != token512 );
		assert( token384 != token512 );

	}


	public void function test_that_rsa_algorithms_result_in_different_tokens() {

		var jwt = new lib.JsonWebTokens();

		var payload = {
			"id": 4,
			"name": "Kim Smith"
		};

		var token256 = jwt.encode( payload, "RS256", getPublicKey(), getPrivateKey() );
		var token384 = jwt.encode( payload, "RS384", getPublicKey(), getPrivateKey() );
		var token512 = jwt.encode( payload, "RS512", getPublicKey(), getPrivateKey() );

		assert( token256 != token384 );
		assert( token256 != token512 );
		assert( token384 != token512 );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I get the private RSA key in PEM format.
	private string function getPrivateKey() {

		var lines = [
			"-----BEGIN RSA PRIVATE KEY-----",
			"MIICXAIBAAKBgQCq8RpMWK5mEt9qypbw6+zafEgQIpR1uUjHbIbZ6dadW/uxU3DZ",
			"D0KW+KVAXnJb11dYCv48O5O/8h95z/SdAnHchc6hjk7wkAPwG1p3rpMVoSCftkoh",
			"y+qzdELmDir8Sr61gaEXUnZfp2gkfmubiAITHovHFfRk5hNGZTHxol7LJwIDAQAB",
			"AoGAYiVkMAmKuFiFpk8DMviCWT+aMIlqK91iB/4rvtofuuGhNULvO/EjDoNcfgS8",
			"LDcLkyVcq0CZqE9f+xSHIc7RiBegv4uxGJQ6/rivfbOh2KjfLAIkniovN3FOR86B",
			"GJ6MWm3Bo28gGrPoODkRrnZvDHtfRvUXnzyGTxH5yOCJxAECQQDTP4j9yMTuOaag",
			"AG51RQ7cP6aVazZY8e4+MO8+8R0XrU5C1kEzfhh+FGS6laxoaay0LIFnhYB2ozXD",
			"YjiVX+qBAkEAzyepeZQaH9/f6/l3Hnme9Qxfhl+4bnHjR2TEnzb+QLkBnVwYb42P",
			"cO8VnZ1VJadZCX4k2+rEZ1hBc5+yxppRpwJAS4G9NIELqt7eaPhegvohGqaBo4zD",
			"yz0GXCJfkY7bSDhA7fDpMz+R/5bIfky7aELFYU07H8Z/KWii8ehssy+qgQJAVGVI",
			"OmwIKKxAwhakXRoXlKYx1MDylqx3eAKpyGPTOfMloUKAAhKeOdht6gTLR8fiEmf+",
			"BEqlMaVXJRAO+bKtSQJBAIof8obXnfxr4ruNzv7bFSvRSLMXxqOi+5TRbpjpwtRz",
			"yCRXDbakPi05ywzWRDJ/AoON63ZWyFVTFDZQEp2hRwQ=",
			"-----END RSA PRIVATE KEY-----"
		];

		return( arrayToList( lines, chr( 10 ) ) );

	}


	// I get the public RSA key in PEM format.
	private string function getPublicKey() {

		var lines = [
			"-----BEGIN PUBLIC KEY-----",
			"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCq8RpMWK5mEt9qypbw6+zafEgQ",
			"IpR1uUjHbIbZ6dadW/uxU3DZD0KW+KVAXnJb11dYCv48O5O/8h95z/SdAnHchc6h",
			"jk7wkAPwG1p3rpMVoSCftkohy+qzdELmDir8Sr61gaEXUnZfp2gkfmubiAITHovH",
			"FfRk5hNGZTHxol7LJwIDAQAB",
			"-----END PUBLIC KEY-----"

		];

		return( arrayToList( lines, chr( 10 ) ) );

	}

}