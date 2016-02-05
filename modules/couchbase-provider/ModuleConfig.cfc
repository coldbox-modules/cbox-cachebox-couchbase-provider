/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component {

	// Module Properties
	this.title 				= "Couchbase Provider";
	this.author 			= "Ortus Solutions";
	this.webURL 			= "http://www.ortussolutions.com";
	this.description 		= "Couchbase Provider for Cachebox";
	this.version			= "2.0.0.@build.version@";
	
	this.viewParentLookup 	= true;
	
	this.layoutParentLookup = true;
	
	this.entryPoint			= "/CouchbaseProvider";

	this.modelNamespace		= "CouchbaseProvider";
	
	this.cfmapping			= "CouchbaseProvider";
	
	this.dependencies 		= ['cbjavaloader'];
	

	function configure(){

		parseParentSettings();

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		
		//ensure cbjavaloader is active
		if(!Wirebox.getColdbox().getModuleService().isModuleActive( 'cbjavaloader' )){

			Wirebox.getColdbox().getModuleService().reload( 'cbjavaloader' );	
		
		}

		var modulePath = getDirectoryFromPath( getCurrentTemplatePath() );

		var jLoader = Wirebox.getInstance("loader@cbjavaloader");
		
		jLoader.appendPaths( modulePath & '/lib/' );


		binder.map( "Provider@CouchbaseProvider" )
			.to("CouchbaseProvider.models.Couchbase.ColdboxProvider");

		binder.map( "Stats@CouchbaseProvider" )
			.to("CouchbaseProvider.models.Couchbase.Stats")
			.noInit();

	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
		//evict our configured caches and cleanup


	}


	private function parseParentSettings(){

		var oConfig 			= controller.getSetting( "ColdBoxConfig" );
		var configStruct 		= controller.getConfigSettings();
		var CouchbaseSettings	= oConfig.getPropertyMixin( "Couchbase", "variables", {} );
			
		//default config struct
		configStruct.Couchbase = {
			// The default couchbase caches
			caches = {
				// Named cache for all coldbox event and view template caching
				"template":getDefaultCacheConfig( "templateCache" ),
				"couchBase":getDefaultCacheConfig( "defaultCache" )
			}
		};

		//check if a config has been misplaced within the custom settings structure
		if( structIsEmpty( CouchbaseSettings ) and structKeyExists( configStruct, "Couchbase" ) ){
			CouchbaseSettings = duplicate( configStruct.Couchbase );
		}
		// Incorporate settings
		structAppend( configStruct.Couchbase, CouchbaseSettings, true );

		VARIABLES.CouchbaseConfig = configStruct.Couchbase;

	}

	private function getDefaultCacheConfig( required string bucketName = "default" ){
		var defaultConfig = {
			"provider":"Provider@CouchbaseProvider",
			"properties":{
				objectDefaultTimeout:120,
				objectDefaultLastAccessTimeout:30,
				useLastAccessTimeouts:true,
				freeMemoryPercentageThreshold:0,
				reapFrequency:5,
				evictionPolicy:"LRU",
				evictCount:2,
				maxObjects:300,
				objectStore:"ConcurrentSoftReferenceStore", //memory sensitive
				bucket:ARGUMENTS.bucketName
			}
		};

	}

}