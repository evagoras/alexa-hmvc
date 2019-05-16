component {

	// Module Properties
	this.title 				= "alexa";
	this.author 			= "Evagoras Charalambous";
	this.webURL 			= "https://github.com/evagoras/alexa-coldbox";
	this.description 		= "A ColdBox HMVC based template for creating one or more Alexa apps.";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= false;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = false;
	// Module Entry Point
	this.entryPoint			= "alexa";
	// Inherit Entry Point
	this.inheritEntryPoint 	= true;
	// Model Namespace
	this.modelNamespace		= "alexa";
	// CF Mapping
	this.cfmapping			= "alexa";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies
	this.dependencies 		= [];

	function configure(){

		// parent settings
		parentSettings = {

		};

		// module settings - stored in modules.name.settings
		settings = {
			skills = [
				{
					id = "amzn1.ask.skill.72d796ac-dd1b-4c5f-8738-ecfa1a5d1b0f",
					handler = "Home"
				}
			]
		};

		// Layout Settings
		layoutSettings = {
			defaultLayout = ""
		};

		// SES Routes
		routes = [
			// Module Entry Point
		];

		// SES Resources
		resources = [
			// { resource = "" }
		];

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// Custom Declared Interceptors
		interceptors = [
			{
				class = "alexa.interceptors.Request",
				name = "ClientRequest",
				properties = {}
			}
		];

		// Binder Mappings
		// binder.map("Alias").to("#moduleMapping#.models.MyService");

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		config.jsonPayloadToRC = false;
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}