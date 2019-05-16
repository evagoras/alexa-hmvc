component extends="coldbox.system.EventHandler" {

	property name="STATUS";
	
	// HTTP STATUS CODES
	STATUS = {
		"CREATED" 				: 201,
		"ACCEPTED" 				: 202,
		"SUCCESS" 				: 200,
		"NO_CONTENT" 			: 204,
		"RESET" 				: 205,
		"PARTIAL_CONTENT" 		: 206,
		"BAD_REQUEST" 			: 400,
		"NOT_AUTHORIZED" 		: 403,
		"NOT_AUTHENTICATED" 	: 401,
		"NOT_FOUND" 			: 404,
		"NOT_ALLOWED" 			: 405,
		"NOT_ACCEPTABLE" 		: 406,
		"TOO_MANY_REQUESTS" 	: 429,
		"EXPECTATION_FAILED" 	: 417,
		"INTERNAL_ERROR" 		: 500,
		"NOT_IMPLEMENTED" 		: 501
	};
	
	function aroundHandler(event, rc, prc, targetAction, eventArguments) {
		try {
			// start a resource timer
			var stime = getTickCount();
			// prepare argument execution
			var args = { event = arguments.event, rc = arguments.rc, prc = arguments.prc };
			args.append(arguments.eventArguments);
			// Incoming Format Detection
			if (rc.keyExists("format")) {
				prc.response.setFormat( rc.format );
			}
			if (arguments.eventArguments.keyExists("directExecution")) {
				return arguments.targetAction( argumentCollection=args );
			}
			// Execute action
			var actionResults = arguments.targetAction( argumentCollection=args );

			if (prc.requestEnvelope.request.type == "LaunchRequest") {
				prc.response.getData().sessionAttributes["lastresponse"] = prc.response.getData().response.outputSpeech.ssml;
			} else if (isDefined("prc.requestEnvelope.request.intent.name") && prc.requestEnvelope.request.intent.name != "AMAZON.HelpIntent") {
				prc.response.getData().sessionAttributes["lastresponse"] = prc.response.getData().response.outputSpeech.ssml;
			}	
			// automatically wrap the response with <speak> to always allow SSML.
			prc.response.getData().response.outputSpeech.ssml = "<speak>" & prc.response.getData().response.outputSpeech.ssml & "</speak>";
		} catch( Any e ) {
			dump(e);
			abort;
			// Log Locally
			log.error( 
				"Error calling #event.getCurrentEvent()#: #e.message# #e.detail#", 
				{
					"stacktrace" : e.stacktrace,
					"httpData" : getHTTPRequestData()
				} 
			);
			
			// Setup General Error Response
			prc.response
				.setError( true )
				.addMessage( "General application error: #e.message#" )
				.setStatusCode( STATUS.INTERNAL_ERROR )
				.setStatusText( "General application error" );
			// Development additions
			if ( getSetting( "environment" ) eq "development" ) {
				prc.response.addMessage( "Detail: #e.detail#" )
					.addMessage( "StackTrace: #e.stacktrace#" );
			}
		}
		
		// Development additions
		if (getSetting( "environment" ) eq "development" ) {
			prc.response.addHeader( "x-current-route", event.getCurrentRoute() )
				.addHeader( "x-current-routed-url", event.getCurrentRoutedURL() )
				.addHeader( "x-current-routed-namespace", event.getCurrentRoutedNamespace() )
				.addHeader( "x-current-event", event.getCurrentEvent() );
		}
		// end timer
		prc.response.setResponseTime( getTickCount() - stime );

		// Did the controllers set a view to be rendered? If not use renderdata, else just delegate to view.
		if ( 
			isNull( actionResults )
			AND (
				!len( event.getCurrentView() ) 
				OR
				structIsEmpty( event.getRenderData() )
			)
		) {
			// Get response data
			var responseData = prc.response.getDataPacket();
			// If we have an error flag, render our messages and omit any marshalled data
			if (prc.response.getError()) {
				responseData = prc.response.getDataPacket( reset=true );
			}
			// Magical renderings
			event.renderData( 
				type			= prc.response.getFormat(),
				data 			= responseData,
				contentType 	= prc.response.getContentType(),
				statusCode 		= prc.response.getStatusCode(),
				statusText 		= prc.response.getStatusText(),
				location 		= prc.response.getLocation(),
				isBinary 		= prc.response.getBinary(),
				jsonCallback 	= prc.response.getJsonCallback(),
				jsonQueryFormat	= prc.response.getJsonQueryFormat()
			);
		}
		 
		// Global Response Headers
		prc.response.addHeader( "x-response-time", prc.response.getResponseTime() )
			.addHeader( "x-cached-response", prc.response.getCachedResponse() );
		
		// Response Headers
		for (var thisHeader in prc.response.getHeaders()) {
			event.setHTTPHeader( name=thisHeader.name, value=thisHeader.value );
		}
		
		// If results detected, just return them, controllers requesting to return results
		if (!isNull(actionResults)) {
			return actionResults;
		}
	}

	/**
	* on localized errors
	*/
	function onError( event, rc, prc, faultAction, exception, eventArguments ){
		// Log Locally
		log.error( 
			"Error in base handler (#arguments.faultAction#): #arguments.exception.message# #arguments.exception.detail#", 
			{
				"stacktrace" : exception.stacktrace,
				"httpData" : getHTTPRequestData()
			} 
		);
		
		// Verify response exists, else create one
		if( !structKeyExists( prc, "Response" ) ){ 
			prc.response = getModel( "Response@alexa" ); 
		}

		// Setup General Error Response
		prc.response
			.setError( true )
			.addMessage( "Base Handler Application Error: #arguments.exception.message#" )
			.setStatusCode( STATUS.INTERNAL_ERROR )
			.setStatusText( "General application error" );
		
		// Development additions
		if( getSetting( "environment" ) eq "development" ){
			prc.response.addMessage( "Detail: #arguments.exception.detail#" )
				.addMessage( "StackTrace: #arguments.exception.stacktrace#" );
		}
		
		// If in development, then it will show full trace error template, else render data
		if( getSetting( "environment" ) neq "development" ){
			// Render Error Out
			event.renderData( 
				type		= prc.response.getFormat(),
				data 		= prc.response.getDataPacket( reset=true ),
				contentType = prc.response.getContentType(),
				statusCode 	= prc.response.getStatusCode(),
				statusText 	= prc.response.getStatusText(),
				location 	= prc.response.getLocation(),
				isBinary 	= prc.response.getBinary()
			);
		}
	}

	/**
	* on invalid http verbs
	*/
	function onInvalidHTTPMethod( event, rc, prc, faultAction, eventArguments ){
		// Log Locally
		log.warn( "InvalidHTTPMethod Execution of (#arguments.faultAction#): #event.getHTTPMethod()#", getHTTPRequestData() );
		// Setup Response
		prc.response = getModel( "Response@alexa" )
			.setError( true )
			.addMessage( "InvalidHTTPMethod Execution of (#arguments.faultAction#): #event.getHTTPMethod()#" )
			.setStatusCode( STATUS.NOT_ALLOWED )
			.setStatusText( "Invalid HTTP Method" );
		// Render Error Out
		event.renderData( 
			type		= prc.response.getFormat(),
			data 		= prc.response.getDataPacket( reset=true ),
			contentType = prc.response.getContentType(),
			statusCode 	= prc.response.getStatusCode(),
			statusText 	= prc.response.getStatusText(),
			location 	= prc.response.getLocation(),
			isBinary 	= prc.response.getBinary()
		);
	}

	/**
	* Invalid method execution
	**/
	function onMissingAction( event, rc, prc, missingAction, eventArguments ){
		// Log Locally
		log.warn( "Invalid HTTP Method Execution of (#arguments.missingAction#): #event.getHTTPMethod()#", getHTTPRequestData() );
		// Setup Response
		prc.response = getModel( "Response@alexa" )
			.setError( true )
			.addMessage( "Action '#arguments.missingAction#' could not be found" )
			.setStatusCode( STATUS.NOT_ALLOWED )
			.setStatusText( "Invalid Action" );
		// Render Error Out
		event.renderData( 
			type		= prc.response.getFormat(),
			data 		= prc.response.getDataPacket( reset=true ),
			contentType = prc.response.getContentType(),
			statusCode 	= prc.response.getStatusCode(),
			statusText 	= prc.response.getStatusText(),
			location 	= prc.response.getLocation(),
			isBinary 	= prc.response.getBinary()
		);			
	}

	/**************************** RESTFUL UTILITIES ************************/

	/**
	* Utility function for miscellaneous 404's
	**/
	private function routeNotFound( event, rc, prc ){
		
		if( !structKeyExists( prc, "Response" ) ){
			prc.response = getModel( "Response@alexa" );
		}

		prc.response.setError( true )
			.setStatusCode( STATUS.NOT_FOUND )
			.setStatusText( "Not Found" )
			.addMessage( "The object requested could not be found" );
	}

	/**
	* Utility method for when an expectation of the request failes ( e.g. an expected paramter is not provided )
	**/
	private function onExpectationFailed( 
		event 	= getRequestContext(), 
		rc 		= getRequestCollection(),
		prc 	= getRequestCollection( private=true ) 
	){
		if( !structKeyExists( prc, "Response" ) ){
			prc.response = getModel( "Response@alexa" );
		}

		prc.response.setError( true )
			.setStatusCode( STATUS.EXPECTATION_FAILED )
			.setStatusText( "Expectation Failed" )
			.addMessage( "An expectation for the request failed. Could not proceed" );		
	}

	/**
	* Utility method to render missing or invalid authentication credentials
	**/
	private function onAuthenticationFailure( 
		event 	= getRequestContext(), 
		rc 		= getRequestCollection(),
		prc 	= getRequestCollection( private=true ),
		abort 	= false 
	){
		if( !structKeyExists( prc, "Response" ) ){
			prc.response = getModel( "Response@alexa" );
		}

		log.warn( "Invalid Authentication", getHTTPRequestData() );

		prc.response.setError( true )
			.setStatusCode( STATUS.NOT_AUTHENTICATED )
			.setStatusText( "Invalid or Missing Credentials" )
			.addMessage( "Invalid or Missing Authentication Credentials" );
	}

	/**
	* Utility method to render a failure of authorization on any resource
	**/
	private function onAuthorizationFailure( 
		event 	= getRequestContext(), 
		rc 		= getRequestCollection(),
		prc 	= getRequestCollection( private=true ),
		abort 	= false 
	){
		if( !structKeyExists( prc, "Response" ) ){
			prc.response = getModel( "Response@alexa" );
		}

		log.warn( "Authorization Failure", getHTTPRequestData() );

		prc.response.setError( true )
			.setStatusCode( STATUS.NOT_AUTHORIZED )
			.setStatusText( "Unauthorized Resource" )
			.addMessage( "Your permissions do not allow this operation" );

		/**
		* When you need a really hard stop to prevent further execution ( use as last resort )
		**/
		if( arguments.abort ){

			event.setHTTPHeader( 
				name 	= "Content-Type",
	        	value 	= "application/json"
			);

			event.setHTTPHeader( 
				statusCode = "#STATUS.NOT_AUTHORIZED#",
	        	statusText = "Not Authorized"
			);
			
			writeOutput( 
				serializeJSON( prc.response.getDataPacket( reset=true ) ) 
			);
			flush;
			abort;
		}
	}

	/**
	 * Base Alexa handler for when the Request Skill ID is wrong.
	 */
	function InvalidRequest(event, rc, prc) allowedMethods="POST" {
		prc.response.say("I'm sorry, the request is invalid.")
			.endsession();
	}

}