
component
	output = false
	hint = "I define the application settings and event handlers." 
	{


	// Define the application settings.
	this.name = ( "TinyTest:" & hash( getCurrentTemplatePath() ) );

	// Keep the application timeout very low since this application isn't meant to be 
	// persistent - it has no state and will be spun-up every time the tests run (more
	// or less).
	this.applicationTimeout = createTimeSpan( 0, 0, 5, 0 );

	// Turn off session management - you don't need session management to run unit 
	// tests since the functionality can be tested with successive assertions.
	this.sessionManagement = false;

	// Turn off client cookies - you don't need cookes to run unit tests since the 
	// functionality can be tested with successive assertions.
	this.setClientCookies = false;

	// The root of the current tiny test directory.
	this.mappings[ "/tinytest" ] = getDirectoryFromPath( getCurrentTemplatePath() );

	// The root of the testing application (ie. parent directory).
	this.mappings[ "/specs" ] = ( this.mappings[ "/tinytest" ] & "../specs/" );

	
	// --- 
	// PUBLIC METHODS.
	// ---


	// I execute the page request.
	public void function onRequest() {

		// Override any existing output and just execute the test suite template.
		include "./templates/test-suite.cfm";

	}


	// --- 
	// PRIVATE METHODS.
	// ---


	// I evaluate the given path traversal against the PARENT directory. This is intended
	// to be called from the sub-class Application.cfc.
	private string function evaluatePathTraversal( required string traversal ) {

		var currentDirectory = createObject( "java", "java.net.URI" ).init(
			javaCast( "string", this.mappings[ "/tinytest" ] )
		);

		var parentDirectory = currentDirectory.resolve( javaCast( "string", "../" ) );

		var targetPath = parentDirectory.resolve( javaCast( "string", traversal ) );

		return( targetPath.toString() );

	}


}