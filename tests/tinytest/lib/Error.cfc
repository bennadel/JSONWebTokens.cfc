component
	output = false
	hint = "I represent the error that was thrown during a TestCase execution."
	{

	public any function init( required any exception ) {

		errorMessage = getErrorFromException( exception );

		stackTrace = getStackTraceFromException( exception );
		
		fullStackTrace = getFullStackTraceFromException( exception );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	public string function getErrorMessage() {

		return( errorMessage );

	}


	public string function getFullStackTrace() {

		return( fullStackTrace );

	}


	public array function getStackTrace() {

		return( stackTrace );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	private string function getErrorFromException( required any exception ) {

		if ( 
			! structKeyExists( exception, "message" ) ||
			! len( exception.message )
			) {

			return( "An unexpected error has occurred." );

		}

		return( exception.message );

	}


	private string function getFullStackTraceFromException( required any exception ) {
		
		if ( ! structKeyExists( exception, "stackTrace" ) ) {

			return( "" );

		}
		
		return( exception.stackTrace );

	}


	private string function getMethodNameFromContext( 
		required string rawTrace,
		required string filepath
		) {

		var methodNameCallout = reMatch( "\$func[^.]+", rawTrace );

		// If no method was mentioned in the raw stack trace, return the empty string.
		if ( ! arrayLen( methodNameCallout ) ) {

			return( "" );

		}

		// Remove the non-method-name portions of the method name.
		var methodName = lcase( replace( methodNameCallout[ 1 ], "$func", "", "one" ) );

		// At this point, the method name will be all-caps since ColdFusion reports it without
		// case-sensitivity. To get around this, let's see if we can get the proper casing of 
		// the method name directly from the file that contains the method definition.
		try {

			var fileContent = fileRead( filepath );

			var escapedMethodName = reReplace( methodName, "([\\$])", "\\\1", "all" );

			// Look for both the script-based and tag-based definitions.
			var methodDefinitions = reMatch( "(?i)\b#escapedMethodName#\s*\(|""#escapedMethodName#""", fileContent );

			// If we found the definition, return the true-cased name, less the other method
			// definition markers we needed for the regex match.
			if ( arrayLen( methodDefinitions ) ) {

				return( 
					reReplace( methodDefinitions[ 1 ], "[\s(""]+", "", "all" ) 
				);

			}

		// Ingore any file I/O errors.
		} catch ( any fileIOError ) {

			// ...

		}

		// If we couldn't find the true-cased method name, just return the fake one.
		return( methodName );

	}


	private array function getStackTraceFromException( required any exception ) {

		if ( ! structKeyExists( exception, "tagContext" ) ) {

			return( arrayNew( 1 ) );

		}

		var simplifiedContext = [];

		for ( var tagContext in exception.tagContext ) {

			// For generated templates, this will not be a file path. This is caused by the
			// use of the evaluate() method to invoke a compoonent method.
			if ( isPhysicalTemplatePath( tagContext.template ) ) {

				arrayAppend(
					simplifiedContext,
					{
						fileName = getFileFromPath( tagContext.template ),
						filePath = tagContext.template,
						lineNumber = tagContext.line,
						methodName = getMethodNameFromContext( tagContext.raw_trace, tagContext.template )
					}
				);
				
			}

		}

		return( simplifiedContext );

	}


	private boolean function isPhysicalTemplatePath( required string templatePath ) {

		return( templatePath != "<generated>" );

	}

}