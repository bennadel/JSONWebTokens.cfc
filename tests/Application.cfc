component
	extends = "tinytest.Application"
	output = false
	hint = "I provide the application settings and event handlers for your testing." 
	{

	// Add any mappings that you need in order to load your modules from within
	// the unit test specifications.
	// --
	// NOTE: You can use the evaluatePathTraversal() method to navigate upto your application,
	// and then down into any ColdFusion libraries you need to reference.
	this.mappings[ "/app" ] = evaluatePathTraversal( "../" );
	this.mappings[ "/lib" ] = evaluatePathTraversal( "../lib/" );

}