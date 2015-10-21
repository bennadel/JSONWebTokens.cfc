
component
	output = false
	hint = "I run a suite of test cases."
	{

	// I initialize the component.
	public any function init( required string testDirectory ) {

		variables.testDirectory = testDirectory;

		results = "";

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I get the list of tests that this runner knows about (based on the directory).
	public array function getTestCaseNames() {

		var names = [];

		var files = directoryList( testDirectory, false, "name", "*Test.cfc" );

		for ( var file in files ) {

			arrayAppend( names, listFirst( file, "." ) );

		}

		return( names );

	}


	public any function runTestCases( required string testCaseList ) {

		results = new TestResults();
		
		var testCases = getTestCaseNames();

		try {

			for ( var testCaseName in testCases ) {

				if ( ! listFind( testCaseList, testCaseName ) ) {

					continue;

				}

				runTestsInTestCase( new "specs.#testCaseName#"() );

			}

			results.endTestingWithSuccess();

		} catch ( any error ) {

			results.endTestingWithError( new tinytest.lib.Error( error ) );

		}

		return( results );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	private array function getTestMethodNames( required any testCase ) {

		var methodNames = [];

		// structKeyArray() will make sure that only public methods are picked up.
		for ( var methodName in structKeyArray( testCase ) ) {

			if ( isTestMethodName( methodName ) ) {

				arrayAppend( methodNames, methodName );

			}

		}

		return( methodNames );

	}


	private boolean function isTestMethodName( required string methodName ) {

		// All test methods must start with the term, "test". 
		return( !! reFindNoCase( "^test", methodName ) );

	}


	private void function runTestMethod( 
		required any testCase,
		required string methodName 
		) {

		testCase.setup();

		evaluate( "testCase.#methodName#()" );

		testCase.teardown();

	}


	public void function runTestsInTestCase( required any testCase ) {

		testCase.beforeTests();

		// When running the tests, we want to stop on failure; however, we also want to make
		// sure that we always run the after-tests teardown.
		try {			

			var testMethods = getTestMethodNames( testCase );

			for ( var methodName in testMethods ) {

				results.incrementTestCount();

				runTestMethod( testCase, methodName );

			}
			
		// Rethrow errors - we want to prevent future tests.
		} catch( any error ) {

			rethrow;

		// Guarantee that after tests run.
		} finally {
			
			// Execute after
			testCase.afterTests();

		}

	}

}