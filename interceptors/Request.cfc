component extends="coldbox.system.Interceptor" {

	property name="settings" inject="coldbox:modulesettings:alexa";

	function onRequestCapture(event, interceptData, buffer, rc, prc) {
		// All requests have to be with verb POST
		if (event.getHTTPMethod() != "POST" ) {
			event.noRender();
			return;
		}
		// This Function and RC and PRC Scope variables
		prc.response = getModel("Response@alexa");
		prc.requestEnvelope = deserializeJson(getHTTPRequestData().content);
		var methodName = "";
		var handlerName = "";
		var skillId = "";
		for (var skill in settings.skills) {
			if (prc.requestEnvelope.session.application.applicationid == skill.id) {
				handlerName = skill.handler;
				skillId = skill.id;
				break;
			}
		}
		// No Skill configuration found
		if (skillId == "") {
			event.overrideEvent(event = "alexa:BaseHandler.InvalidRequest");
			return;
		}
		prc.sessions = prc.requestEnvelope?.session?.attributes ?: {};
		switch (prc.requestEnvelope.request.type) {
			case "SessionEndedRequest":
				methodName = "SessionEndedRequest";
				break;
			case "LaunchRequest":
				methodName = "LaunchRequest";
				break;
			case "IntentRequest":
				methodName = prc.requestEnvelope.request.intent.name.replace(".", "", "all");
				// check to see if Alexa sent any slots and save them in the RC scope
				if (prc.requestEnvelope.request.intent.keyExists("slots")) {
					var slots = prc.requestEnvelope.request.intent.slots;
					for (var slot in slots) {
						if (slots[slot].keyExists("value")) {
							rc[slots[slot].name] = slots[slot].value;
						} else {
							/* handle optional values */
							rc[slots[slot].name] = "";
						}
					}
				}
				break;
			default:
				methodName = "LaunchRequest";
				break;
		}
		// Call the resolved right Handler and Method
		event.overrideEvent(event = "alexa:#handlerName#.#methodName#");
	}
}