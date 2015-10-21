component
	extends = "tinytest.lib.TestCase"
	output = false
	hint = "I provide a hook for adding shared methods to your test cases; such as custom assertion methods, or commong setup/teardown methods."
	{

	// Example of a custom assertion that you provide for your test cases. All assertions should
	// return void and should either run without exception; or, make one call to fail() with a
	// required error message.
	private void function assertIsValidEmail( 
		required string email,
		string additionalInfo = ""
		) {

		if ( ! isValid( "email", email ) ) {

			// fail() will end the test with an error.
			fail( "Expected [#email#] to be a valid email address.", additionalInfo );

		}

	}

}