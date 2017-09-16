component{

	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "Couchbase Provider Shell",
			eventName 				= "event",

			//Development Settings
			reinitPassword			= "",
			handlersIndexAutoReload = true,

			//Implicit Events
			defaultEvent			= "main.index",
			requestStartHandler		= "",
			requestEndHandler		= "",
			applicationStartHandler = "",
			applicationEndHandler	= "",
			sessionStartHandler 	= "",
			sessionEndHandler		= "",
			missingTemplateHandler	= "",

			//Extension Points
			applicationHelper 			= "includes/helpers/ApplicationHelper.cfm",
			viewsHelper					= "",
			modulesExternalLocation		= [],
			viewsExternalLocation		= "",
			layoutsExternalLocation 	= "",
			handlersExternalLocation  	= "",
			requestContextDecorator 	= "",

			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate		= "/coldbox/system/includes/BugReport.cfm",

			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= false,
			proxyReturnCollection 	= false
		};

		// custom settings
		settings = {
		};

		// Module Directives
		modules = {
			//Turn to false in production, on for dev
			autoReload = false
		};

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				files={class="coldbox.system.logging.appenders.RollingFileAppender",
					properties = {
						filename = "app", filePath="/#appMapping#/logs"
					}
				}
			},
			// Root Logger
			root = { levelmax="DEBUG", appenders="*" },
			// Implicit Level Categories
			info = [ "coldbox.system" ]
		};

		//Register interceptors as an array, we need order
		interceptors = [
			//SES
			{class="coldbox.system.interceptors.SES",
			 properties={}
			}
		];

		moduleSettings = {
			/**
			* Couchbase provider settings
			**/
			couchbaseCacheboxProvider = {
				caches : { 
					"template" : {
						provider 	: "couchbaseCacheboxProvider.models.CouchbaseColdBoxProvider",
						properties 	: {
							ignoreCouchBaseTimeouts : true,				
							bucket:"default",
							password:"",
							servers:"127.0.0.1:8091"
						}
					},
					"couchbase" : {
						provider 	: "couchbaseCacheboxProvider.models.CouchbaseProvider",
						properties 	: {
							ignoreCouchBaseTimeouts : true,				
							bucket:"default",
							password:"",
							servers:"127.0.0.1:8091"
						}
					},
					"couchtest" : {
						provider 	: "couchbaseCacheboxProvider.models.CouchbaseProvider",
						properties 	: {
							ignoreCouchBaseTimeouts : true,				
							bucket:"default",
							password:"",
							servers:"127.0.0.1:8091"
						}
					}
				}    
			}
		};

	}


}