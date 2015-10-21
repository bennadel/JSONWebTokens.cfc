
<cfscript>


	// Param the form fields.
	param name="form.submitted" type="boolean" default=false;
	param name="form.selectedTestCases" type="string" default="";
	param name="form.autorun" type="string" default="off";


	// NOTE: Since this template is included INTO the Application.cfc, we have access to the "this" scope;
	// and, therefore, have direct access to the mappings collection.
	testSuite = new tinytest.lib.TestSuite( this.mappings[ "/specs" ] );

	testCaseNames = testSuite.getTestCaseNames();

	testStatus = "start";


	// Only run the tests if at least one test was selected.
	if ( form.submitted && len( form.selectedTestCases ) ) {

		testResults = testSuite.runTestCases( form.selectedTestCases );

		testStatus = ( testResults.isPassed() ? "pass" : "fail" );

	}


</cfscript>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>

	<!doctype html>
	<html>
	<head>
		<meta charset="utf-8" />
		<meta name="author" content="Ben Nadel, ben@bennadel.com" />

		<title>Tiny Test : Test-Driven Development</title>

		<link rel="stylesheet" type="text/css" href="tinytest/assets/app/css/test-suite.css"></link>
	</head>
	<body>

		<!-- BEGIN: Form. -->
		<form method="post" action="#cgi.script_name#">

			<!-- Flag the form as submitted. -->
			<input type="hidden" name="submitted" value="true" />

			<!-- Track the current test status for JavaScript interactions. -->
			<input type="hidden" name="testStatus" value="#htmlEditFormat( testStatus )#" />


			<!-- BEGIN: Site Info. -->
			<div class="siteInfo">

				<a href="#cgi.script_name#" class="name">
					TinyTest
				</a>

				<span class="tddMentality">
					Red - Green - Refactor
				</span>

				<span class="author">
					by <a href="http://www.bennadel.com" target="bennadelcom">Ben Nadel</a>
				</span>

			</div>
			<!-- END: Site Info. -->


			<!--- BEGIN: Status Output. --->
			<cfif ( testStatus eq "start" )>


				<!-- BEGIN: Test Status. -->
				<div class="testStatus start">

					<button type="submit" class="callToAction">

						<div class="subtitle">
							<span>Test Driven Development</span>
						</div>

						<div class="status">
							Start
						</div>

						<div class="button">
							Run Selected Tests
						</div>

					</button>

				</div>
				<!-- END: Test Status. -->


			<cfelseif ( testStatus eq "pass" )>


				<!-- BEGIN: Test Status. -->
				<div class="testStatus pass">

					<button type="submit" class="callToAction">

						<div class="subtitle">
							<span>You Ran #numberFormat( testResults.getTestCount(), "," )# Tests In #numberFormat( testResults.getDuration(), "," )# ms</span>
						</div>

						<div class="status">
							Passed
						</div>

						<div class="button">
							Run Tests Again
						</div>

					</button>

				</div>
				<!-- END: Test Status. -->


			<cfelseif ( testStatus eq "fail")>


				<!-- BEGIN: Test Status. -->
				<div class="testStatus fail">

					<button type="submit" class="callToAction">

						<div class="subtitle">
							<span>You Ran #numberFormat( testResults.getTestCount(), "," )# Tests In #numberFormat( testResults.getDuration(), "," )# ms</span>
						</div>

						<div class="status">
							Failed
						</div>

						<div class="button">
							Try Again
						</div>

						<div class="errorInfo">

							<div class="subtitle">
								<span>What Went Wrong</span>
							</div>

							<cfloop
								index="stackItem"
								array="#testResults.getError().getStackTrace()#">

								<!---
									Ignore some aspects of the stack trace that are not relevant to the
									user's error. These include both ColdFusion and Tiny Test framework files.
								--->
								<cfif listFindNoCase( "Application.cfc,test-suite.cfm,TestSuite.cfc,TestCase.cfc", stackItem.fileName )>

									<cfcontinue />

								</cfif>

								<div title="#htmlEditFormat( stackItem.filePath )#" class="file">
									#stackItem.fileName# : Line #stackItem.lineNumber#

									<!--- Output the contextual method, if available. --->
									<cfif len( stackItem.methodName )>
										
										&mdash; #stackItem.methodName#()

									</cfif>
								</div>

							</cfloop>

							<div class="message">
								#htmlEditFormat( testResults.getError().getErrorMessage() )#
							</div>

						</div>

					</button>

				</div>
				<!-- END: Test Status. -->


			</cfif>
			<!--- END: Status Output. --->


			<!--- Make sure the user actually has test cases to run. --->
			<cfif arrayLen( testCaseNames )>


				<!-- BEGIN: Test List. -->
				<div class="testList">

					<div class="header">

						<div class="title">
							<span class="text">You Have #arrayLen( testCaseNames )# Test Cases</span>
							<span class="selectAll">( <a href="##">Select All</a> )</span>
						</div>

						<input type="text" placeholder="Filter test cases" tabindex="1" class="filter" />

					</div>

					<ol class="tests">

						<cfloop
							index="testCaseName"
							array="#testCaseNames#">

							<li class="test">

								<label>

									<input
										type="checkbox"
										name="selectedTestCases"
										value="#htmlEditFormat( testCaseName )#"
										<cfif listFind( form.selectedTestCases, testCaseName )>
											checked="checked"
										</cfif>
										/>

									#htmlEditFormat( testCaseName )#

								</label>

							</li>

						</cfloop>

					</ol>

				</div>
				<!-- END: Test List. -->


			<!--- There are no test cases available. --->
			<cfelse>


				<!-- BEGIN: No Test List. -->
				<div class="noTestList">

					<strong>Oops</strong>: There are no test cases in your "specs" directory.<br />

					See the <a href="./README.md">Readme.md</a> file for instructions.

				</div>
				<!-- END: No Test List. -->


			</cfif>


			<!-- BEGIN: Auto-Run. -->
			<label for="autorun" class="autorun <cfif ( form.autorun eq "on" )>on</cfif>">

				<input id="autorun" type="checkbox" name="autorun" value="on"
					<cfif ( form.autorun eq "on" )>
						checked="checked"
					</cfif>
					/>
				Auto-run tests when window is focused.

			</label>
			<!-- END: Auto-Run. -->


		</form>
		<!-- END: Form. -->


		<!-- BEGIN: Processing. -->
		<div class="processingOverlay">

			<div class="message">

				<div class="plan">
					Running <span class="count">0</span> Test Cases
				</div>

				<div class="patience">
					Get ready to refactor...
				</div>

			</div>

		</div>
		<!-- END: Processing. -->


		<!-- Initialize interface scripts. -->
		<script type="text/javascript" src="./tinytest/assets/jquery/jquery-1.9.1.min.js"></script>
		<script type="text/javascript" src="./tinytest/assets/app/main.js"></script>

	</body>
	</html>

</cfoutput>