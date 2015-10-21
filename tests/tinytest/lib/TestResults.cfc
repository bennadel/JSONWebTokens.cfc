component
	output = false
	hint = "I represent the results of a test suite."
	{

	public any function init() {

		// For duration of testing.
		startTime = getTickCount();	
		endTime = 0;

		// The number of test methods that have been executed.
		testCount = 0;

		// Will contain an instance of the Error.cfc if there is an error.
		error = "";

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I end the tests with a successful conclusion.
	public void function endTestingWithSuccess() {

		if ( isComplete() ) {

			throw( type = "InvalidState", message = "Testing is already complete." );

		}

		endTime = getTickCount();

	}


	public void function endTestingWithError( required tinytest.lib.Error error ) {

		if ( isComplete() ) {

			throw( type = "InvalidState", message = "Testing is already complete." );

		}

		endTime = getTickCount();

		variables.error = error;

	}


	public numeric function getDuration() {

		if ( isComplete() ) {

			return( endTime - startTime );

		}

		return( getTickCount() - startTime );

	}


	public numeric function getTestCount() {

		return( testCount );

	}


	public void function incrementTestCount() {

		testCount++;

	}


	public boolean function isComplete() {

		return( endTime != 0 );

	}


	public any function getError() {

		if ( isSimpleValue( error ) ) {

			return;

		}
		
		return( error );

	}


	public boolean function isFailed() {

		if ( ! isComplete() ) {

			throw( type = "InvalidState", message = "Testing is not complete." );

		}

		return( ! isSimpleValue( error ) );

	}


	public boolean function isPassed() {

		if ( ! isComplete() ) {

			throw( type = "InvalidState", message = "Testing is not complete." );

		}

		return( !! isSimpleValue( error ) );

	}


	// ---
	// PRIVATE METHODS.
	// ---

}