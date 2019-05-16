component extends="BaseHandler" {

	/**************************** Custom Intents ************************/

	function NameNumberIntent(event, rc, prc) {
		prc.response
			.say("'Ok. Tell me any number after a signal. Beep!")
			.reprompt("'Please tell me a number.");
	}

	function AnswerIntent(event, rc, prc) {
		prc.response
			.say("The number is #rc.numberAnswer#")
			.setSessionVariable("number", rc.numberAnswer);
	}
	
	function ExampleIntent(event, rc, prc) {
		prc.response
			.say("This is the example intent.  You can also say, stop, cancel, help, repeat, or start over, as those are all intents defaulted in the template.")
			.reprompt("This is the reprompt.  It will be read if the user fails to respond after 8 seconds.");
	}
	
	function PersonIntent(event, rc, prc) {
		param rc.firstName = "";
		param rc.lastName = "";
		prc.response
			.say("This is the person intent. You asked for #rc.firstName#  #rc.lastName#.")
			.reprompt("This is the reprompt.  I say remprompt.")
			.setCardTitle("#rc.firstName# #rc.lastName#")
			.setCardText('My name is Evagoras Charalambous and I am a Software Consultant, 
				offering custom solutions for Web and Mobile applications. 
				You can usually find me solving interesting problems using HTML, CSS, JavaScript, PHP and ColdFusion.
				
				I use this blog to write about the solutions I come up with for every day coding issues at work – 
				whether they are about Desktop, Web or Mobile software development.
				
				The purpose of this blog is to give back some knowledge to the community, 
				but also to learn from it, by experimenting and having a healthy, intelligent conversation with my readers. 
				So, feel free to comment on my posts or to contact me directly.')
			.setCardImages("https://www.evagoras.com/wp-content/uploads/strikingr/images/921_evagoras_charalambous_headshot-290x290.jpg",
				"https://www.evagoras.com/wp-content/uploads/strikingr/images/921_evagoras_charalambous_headshot-290x290.jpg");
	}


	/**************************** Amazon Default Intents ************************/
	
	function LaunchRequest(event, rc, prc) {
		prc.response
			.say("Welcome. This template has one custom intent. Say, example, to activate the intent.")
			.reprompt("Please tell me what you would like to do.")
			.setCardTitle("Title for the card goes here")
			.setCardText("Text for the card goes here")
			.setCardImages("https://lorempixel.com/780/420/sports/", "https://lorempixel.com/1200/800/technics/");
	}
	
	function SessionEndedRequest(event, rc, prc) {
		return {};
	}
	
	function AMAZONHelpIntent(event, rc, prc) {
		prc.response
			.say("Besides example, you can say, stop, cancel, help, repeat or start over, as those are all intents in the template.")
			.reprompt("You can also say, repeat.  Or say, start over, to begin a new session.");
	}

	function AMAZONCancelIntent(event, rc, prc) {
		prc.response
			.say("Ok, we can stop.  Have a good day.")
			.endsession();
	}

	function AMAZONStopIntent(event, rc, prc) {
		prc.response
			.say("Ok, talk to ya later.  Have a good day.")
			.endsession();
	}

	function AMAZONFallbackIntent(event, rc, prc) {
		prc.response
			.say("I didn't get that.  Let me repeat. ")
			.say(rc.sessions.lastresponse)
			.say("Or say, stop, to quit.")
			.reprompt("Say, help, if you want some hints to get you going.");
	}

	function AMAZONRepeatIntent(event, rc, prc) {
		prc.response.say(rc.sessions.lastresponse);
	}

	function AMAZONStartOverIntent(event, rc, prc) {
		prc.response.clearSession();
		runEvent(event = "alexa:Home.LaunchRequest", eventArguments = { directExecution=true });
	}

	function InvalidRequest(event, rc, prc) {
		prc.response
			.say("I'm sorry, the request is invalid.")
			.endsession();
	}

}