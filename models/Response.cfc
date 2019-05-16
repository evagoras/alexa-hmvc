component accessors=true {

	property name="format" 			type="string" 		default="json";
	property name="data" 			type="any"			default="";
	property name="error" 			type="boolean"		default="false";
	property name="binary" 			type="boolean"		default="false";
	property name="messages" 		type="array";
	property name="location" 		type="string"		default="";
	property name="jsonCallback" 	type="string"		default="";
	property name="jsonQueryFormat" type="string"		default="true" hint="JSON Only: This parameter can be a Boolean value that specifies how to serialize ColdFusion queries or a string with possible values row, column, or struct";
	property name="contentType" 	type="string"		default="";
	property name="statusCode" 		type="numeric"		default="200";
	property name="statusText" 		type="string"		default="OK";
	property name="responsetime"	type="numeric"		default="0";
	property name="cachedResponse" 	type="boolean"		default="false";
	property name="headers" 		type="array";

	/**
	* Constructor
	*/
	Response function init(){
		// Init properties
		variables.format 			= "json";
		variables.data 				= {};
		variables.error 			= false;
		variables.binary 			= false;
		variables.messages 			= [];
		variables.location 			= "";
		variables.jsonCallBack 		= "";
		variables.jsonQueryFormat 	= "query";
		variables.contentType 		= "";
		variables.statusCode 		= 200;
		variables.statusText 		=  "OK";
		variables.responsetime		= 0;
		variables.cachedResponse 	= false;
		variables.headers 			= [];
		
		resetData();

		return this;
	}

	function resetData() {
		variables.data = {
			"version" : "1.0",
			"sessionAttributes" : {},
			"response" : {
				"outputSpeech" : {
				  "type" : "SSML",
				  "ssml" : ""
				},
				"card" : {
				  "type" : "Simple",
				  "title"  : "",
				  "content"  : ""
				},
				"reprompt" : {
					"outputSpeech" : {
					   "type" : "SSML",
					   "ssml" :  "<speak>For assistance, say, help.</speak>"
					}
				},
				"shouldEndSession" : false
			}
		};
	}

	/**
	* Add some messages
	* @message Array or string of message to incorporate
	*/
	function addMessage( required any message ){
		if( isSimpleValue( arguments.message ) ){ arguments.message = [ arguments.message ]; }
		variables.messages.addAll( arguments.message );
		return this;
	}

	/**
	* Add a header
	* @name The header name ( e.g. "Content-Type" )
	* @value The header value ( e.g. "application/json" )
	*/
	function addHeader( required string name, required string value ){
		variables.headers.append({ name=arguments.name, value=arguments.value });
		return this;
	}

	/**
	* Returns a standard response formatted data packet
	* @reset Reset the 'data' element of the original data packet
	*/
	function getDataPacket( boolean reset=false ) {
		var packet = variables.data;
		// Are we reseting the data packet
		if( arguments.reset ){
			resetData();
		}
		return packet;
	}

	function setSessionVariable(required string key, required string value) {
		variables.data.sessionAttributes[key] = value;
		return this;
	}

	function clearSession() {
		variables.data.sessionAttributes.clear();
		return this;
	}

	function say(required string text) {
		variables.data.response.outputSpeech.ssml &= text;
		return this;
	}

	function reprompt(required string text) {
		variables.data.response.reprompt.outputSpeech.text = text;
		return this;
	}

	function endSession() {
		variables.data.response.shouldEndSession = true;
		return this;
	}

	function setCardTitle(required string title) {
		variables.data.response.card.title = title;
		return this;
	}

	function setCardText(required string content) {
		if (variables.data.response.card.keyExists("image")) {
			variables.data.response.card.text = content;
		} else {
			variables.data.response.card.content = content;
		}
		return this;
	}

	/**
	 * @hint Sets the URLs for the small or large Card Images
	 * 
	 * @smallIMageUrl 720w x 480h
	 * @largeImageUrl 1200w x 800h
	 */
	function setCardImages(
		required string smallIMageUrl,
		string largeImageUrl = ""
	) {
		variables.data.response.card.type = "Standard";
		variables.data.response.card["image"] = {"smallImageUrl" = smallImageUrl};
		if (largeImageUrl !== "") {
			variables.data.response.card["image"]["largeImageUrl"] = largeImageUrl;
		}
		variables.data.response.card["text"] = variables.data.response.card["content"];
		variables.data.response.card.delete("content");
		return this;
	}

}