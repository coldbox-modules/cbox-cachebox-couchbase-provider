/**
* Module Configuration for the Provider
*/
component {

	// Module Properties
	this.title 				= "Couchbase Provider";
	this.author 			= "Ortus Solutions";
	this.webURL 			= "https://www.ortussolutions.com";
	this.description 		= "Couchbase Provider for Cachebox";
	this.version			= "@build.version@+@build.number@";
	this.viewParentLookup 	= true;
	this.layoutParentLookup = true;
	this.modelNamespace		= "couchbaseProvider";
	this.cfmapping			= "couchbaseProvider";
	this.dependencies 		= [ 'cfcouchbase'];
	
	/**
	* Configure
	*/
	function configure(){
		settings = {
			// The default couchbase caches
			caches = {
				// Named cache for all coldbox event and view template caching
				"template"	= getDefaultCacheConfig( "templateCache" ),
				// Default named cache
				"couchBase"	= getDefaultCacheConfig( "defaultCache", false )
			}
		};
		parseParentSettings();
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		var cachebox 		= wirebox.getCachebox();
		var currentCaches 	= cachebox.getCaches().keyArray();

		// Iterate and register user defined caches
		var couchbaseCaches = variables.settings.caches;
		for( var cacheName in couchbaseCaches ){
			var cacheConfig = couchbaseCaches[ cacheName ];

			// Construct the cache according to provider specified
			var oCache = wirebox.getInstance( cacheConfig.provider );
			// Register Name
			oCache.setName( cacheName );
			// Link Properties
			oCache.setConfiguration( cacheConfig.properties );
			// Register the cache with CacheBox or replace it
			if( arrayFindNoCase( currentCaches, cachename ) ){
				cacheBox.removeCache( name=cacheName );
			}
			cachebox.addCache( oCache );
		}

	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

	/**
	* Check parent settings
	*/
	private function parseParentSettings(){
		var oConfig 			= controller.getSetting( "ColdBoxConfig" );
		var configStruct 		= controller.getConfigSettings();
		var couchbaseSettings	= oConfig.getPropertyMixin( "couchbase", "variables", {} );
			
		// default config struct
		configStruct.couchbase = variables.settings;

		// Incorporate user settings
		structAppend( configStruct.couchbase, couchbaseSettings, true );
	}

	/**
	* Prepare default cache configurations
	*
	* @bucketName The bucket name for the configuration
	* @coldbox ColdBox enhanced provider or not, defaults to true
	*/
	private struct function getDefaultCacheConfig( required string bucketName = "default", boolean coldbox = false ){
		return {
			"provider" 		: "CouchbaseProvider.models." & ( arguments.coldbox ? "CouchbaseColdboxProvider" : "CouchbaseProvider" ),
			"properties"	: {
				objectDefaultTimeout          	: 120,
				objectDefaultLastAccessTimeout	: 30,
				useLastAccessTimeouts         	: true,
				freeMemoryPercentageThreshold 	: 0,
				reapFrequency                 	: 5,
				evictionPolicy                	: "LRU",
				evictCount                    	: 2,
				maxObjects                    	: 300,
				objectStore                   	: "ConcurrentSoftReferenceStore", //memory sensitive
				bucket                        	: arguments.bucketName,
				servers							: "127.0.0.1:8091"
			}
		};

	}

}