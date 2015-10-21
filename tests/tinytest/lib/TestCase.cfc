component
	output = false
	hint = "I provide the base class for unit test cases."
	{

	/**
	* @hint I initialize the component.
	* @output false
	*/
	public any function init() {

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* @hint I get called once after all the test methods have executed.
	* @output false
	*/
	public void function afterTests() {

		// Abstract method...

	}


	/**
	* @hint I get called once before any tests methods have executed.
	* @output false
	*/
	public void function beforeTests() {

		// Abstract method...

	}


	/**
	* @hint I get called before every test method is executed.
	* @output false
	*/
	public void function setup() {

		// Abstract method...

	}


	/**
	* @hint I get called after every test method has executed.
	* @output false
	*/
	public void function teardown() {

		// Abstract method...

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* @hint I am a short-hand for the assertTrue() method.
	* @output false
	* @value A True or False value that will be passed on to the assertTrue method.
	* @additionalInfo If provided, this value will be output along with the failure message (if failure occurs).
	*/
	private void function assert(
		required boolean value,
		string additionalInfo = ""
		) {

		assertTrue( value, additionalInfo );

	}


	/**
	* @hint I test to see if the supplied values are equal or not.
	* @output false
	* @valueA The first value to be compared.
	* @valueB The value to compare against valueA.
	* @additionalInfo If provided, this value will be output along with the failure message (if failure occurs).
	*/
	private void function assertEquals(
		required string valueA,
		required string valueB,
		string additionalInfo = ""
		) {

		if ( valueA != valueB ) {

			fail( "Expected [#valueA#] to equal [#valueB#].", additionalInfo );

		}

	}


	/**
	* @hint I test to see if the supplied value is equal to False.
	* @output false
	* @value A True or False value to test.
	* @additionalInfo If provided, this value will be output along with the failure message (if failure occurs).
	*/
	private void function assertFalse(
		required boolean value,
		string additionalInfo = ""
		 ) {

		if ( value ) {

			fail( "Expected [#value#] to be falsey.", additionalInfo );

		}

	}


	/**
	* @hint I test to see if the supplied values are equal or not.
	* @output false
	* @valueA The first value to be compared.
	* @valueB The value to compare against valueA.
	* @additionalInfo If provided, this value will be output along with the failure message (if failure occurs).
	*/
	private void function assertNotEquals(
		required string valueA,
		required string valueB,
		string additionalInfo = ""
		) {

		if ( valueA == valueB ) {

			fail( "Expected [#valueA#] to not equal [#valueB#].", additionalInfo );

		}

	}


	/**
	* @hint I test to see if the supplied value is equal to True.
	* @output false
	* @value A True or False value to test.
	* @additionalInfo If provided, this value will be output along with the failure message (if failure occurs).
	*/
	private void function assertTrue(
		required boolean value,
		string additionalInfo = ""
		) {
		
		if ( ! value ) {

			fail( "Expected [#value#] to be truthy.", additionalInfo );
		}

	}


	/**
	* @hint I send a failure message back to the calling application.
	* @output false
	* @message The message provided from the assert method.
	* @additionalInfo If provided, this value will be output along with the failure message (if failure occurs).
	*/
	private void function fail(
		required string message,
		string additionalInfo = ""
		) {

		if ( len( additionalInfo ) ) {

			message &= ( " " & additionalInfo );

		}

		throw( type = "tinytest.AssertionFailed", message = message );

	}

}
