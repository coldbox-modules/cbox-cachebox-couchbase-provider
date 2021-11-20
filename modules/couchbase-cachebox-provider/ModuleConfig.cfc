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
	this.modelNamespace		= "couchbaseCacheBoxProvider";
	this.cfmapping			= "couchbaseCacheBoxProvider";
	this.dependencies 		= [ 'cfcouchbase'];
	
	/**
	* Configure
	*/
	function configure(){
		settings = {
			// The default couchbase caches
			caches = {
			}
		};
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

}