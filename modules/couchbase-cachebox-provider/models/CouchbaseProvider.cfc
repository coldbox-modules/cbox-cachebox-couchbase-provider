/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author: Brad Wood, Luis Majano
Description:
	
This CacheBox provider communicates with a single Couchbase node or a 
cluster of Couchbase nodes for a distributed and highly scalable cache store.

*/
component 	name="CouchbaseProvider" 
			serializable="false" 
			// This is commented so the cache can work in ColdBox, CacheBox standalone, or WireBox standalone
			//	implements="coldbox.system.cache.ICacheProvider"
			accessors=true
{

	// All Cache Properties

	property name="couchbaseClient";
	property name="logger";
	property name="name";
	property name="version";
	property name="enabled";
	property name="reportingEnabled";
	property name="configuration";
	property name="cacheFactory";
	property name="eventManager";
	property name="cacheID";
	property name="elementCleaner";
	property name="utility";
	property name="UUIDHelper";
	// coldbox, wirebox, or cachebox depending on installation mode
	property name="classPrefix";

	// Provider STATIC Property Defaults
	variables.DEFAULTS = {
		objectDefaultTimeout      	= 30,
		kvTimeout                 	= 5000,
		ignoreCouchbaseTimeouts   	= true,
		bucket                      = "default",
		servers                     = "127.0.0.1:8091", // This can be an array
		username                    = "",
		password                    = ""
	};

	/**
    * Constructor
    */
	function init(){

		if( directoryExists( expandpath( '/coldbox/system/' ) ) ) {
			classPrefix = 'coldbox';
		} else if( directoryExists( expandpath( '/wirebox/system/' ) ) ) {
			classPrefix = 'wirebox';
		} else if( directoryExists( expandpath( '/cachebox/system/' ) ) ) {
			classPrefix = 'cachebox';
		} else {
			throw( 'Could not find coldbox, wirebox, or cachebox installed.  Please check your CF Mappings.' );
		}
		
		// provider name
		name 				= "";
		// provider version
		version				= "@build.version@+@build.number@";
		// provider enable flag
		enabled 			= false;
		// reporting enabled flag
		reportingEnabled 	= true;
		// configuration structure
		configuration 		= {};
		// cacheFactory composition
		cacheFactory 		= "";
		// event manager composition
		eventManager		= "";
		// storage composition, even if it does not exist, depends on cache
		store				= "";
		// the cache identifier for this provider
		cacheID				= createObject('java','java.lang.System' ).identityHashCode( this );
		// Element Cleaner Helper
		elementCleaner		= createObject( "#classPrefix#.system.cache.util.ElementCleaner" ).init( cacheProvider = this );
		// Utilities
		utility				= createObject( "#classPrefix#.system.core.util.Util" );
		// our UUID creation helper
		uuidHelper			= createobject( "java", "java.util.UUID");
		// For serialization of complex values
		converter			= createObject( "#classPrefix#.system.core.conversion.ObjectMarshaller" ).init();
		
		return this;
	}

	/**
    * get the cache name
    */    
	any function getName() output="false" {
		return variables.name;
	}
	
	/**
    * get the cache provider version
    */    
	any function getVersion() output="false" {
		return variables.version;
	}
	
	/**
    * set the cache name
    */    
	void function setName( required name ) output="false" {
		variables.name = arguments.name;
	}
	
	/**
    * set the event manager
    */
    void function setEventManager( required any eventManager ) output="false" {
    	variables.eventManager = arguments.eventManager;
    }
	
    /**
    * get the event manager
    */
    any function getEventManager() output="false" {
    	return variables.eventManager;
    }
    
	/**
    * get the cache configuration structure
    */
    any function getConfiguration() output="false" {
		return variables.configuration;
	}
	
	/**
    * set the cache configuration structure
    */
    void function setConfiguration( required any configuration ) output="false" {
		variables.configuration = arguments.configuration;
	}
	
	/**
    * get the associated cache factory
    */
    any function getCacheFactory() output="false" {
		return variables.cacheFactory;
	}
		
	/**
    * set the associated cache factory
    */
    void function setCacheFactory(required any cacheFactory) output="false" {
		variables.cacheFactory = arguments.cacheFactory;
	}
		
	/**
    * configure the cache for operation
    */
    void function configure() output="false" {
		var config = getConfiguration();
			
		// lock creation	
		lock name="Provider.config.#variables.cacheID#" type="exclusive" throwontimeout="true" timeout="20"{
		
			// Prepare the logger
			variables.logger = getCacheFactory().getLogBox().getLogger( this );
			variables.logger.debug( "Starting up Couchbase Provider Cache: #getName()# with configuration: #config.toString()#" );
			
			// Validate the configuration
			validateConfiguration();	
			
			try{
				// Build a CouchbaseClient according to configurations
				variables.couchbaseClient = createObject( "cfcouchbase.CouchbaseClient" ).init( config = config );

				// Ensure our cache views are created
				ensureViewExists();

			} catch( any e ){
				variables.logger.error( "There was an error creating the CouchbaseClient library: #e.message# #e.detail#", e );
				// Rethrow it, so we can see the cause
				throw( e );
			}
			
			// enabled the cache now
			variables.enabled 			= true;
			variables.logger.info( "Cache #getName()# started up successfully" );
		}
		
	}
	
	/**
    * shutdown the cache
    */
    void function shutdown() output="false" {
    	getCouchbaseClient().shutDown( 5 );
	}
	
	/*
	* Indicates if cache is ready for operation
	*/
	any function isEnabled() output="false" {
		return variables.enabled;
	} 

	/*
	* Indicates if cache is ready for reporting
	*/
	any function isReportingEnabled() output="false" {
		return variables.reportingEnabled;
	}
	
	/*
	* Get the cache statistics object as coldbox.system.cache.util.ICacheStats
	* @colddoc:generic coldbox.system.cache.util.ICacheStats
	*/
	any function getStats() output="false" {
		return {};
	}
	
	/**
    * clear the cache stats: 
    */
    void function clearStatistics() output="false" {
    	// Not implemented
	}
	
	/**
    * Returns the CouchbaseSDK Client
    */
    any function getObjectStore() output="false" {
    	// This provider uses an external object store
    	return getCouchbaseClient();
	}
	
	/**
    * get the cache's metadata report
    */
    any function getStoreMetadataReport() output="false" {	
		var md 		= {};
		var keys 	= getKeys();
		
		for( var item in keys ){
			md[ item ] = getCachedObjectMetadata( item );
		}
		
		return md;
	}
	
	/**
	* Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	*/
	any function getStoreMetadataKeyMap() output="false"{
		return {
			"lastAccessed"      = "LastAccessed",
			"isExpired"         = "isExpired",
			"timeout"           = "timeout",
			"lastAccessTimeout" = "lastAccessTimeout",
			"hits"              = "hits",
			"created"           = "createddate"
		};
	}
	
	/**
    * get all the keys in this provider
    */
    any function getKeys() output="false" {
		// ensure view exists
    	ensureViewExists();
    	
		var aResults = getCouchbaseClient().viewQuery(
			designDocumentName 	= "CacheBox",
			viewName 			= "allKeys",
			options 			= {
				stale 		= false,
				includeDocs = false
			}	
		);

		if( isNull( aResults ) ){
			return [];
		}

		return aResults.map( function( item ){
			return item.id;
		} );
	}
	
	/**
    * get an object's cached metadata
    */
    any function getCachedObjectMetadata( required any objectKey ) output="false" {
    	// lower case the keys for case insensitivity
		arguments.objectKey = lcase( arguments.objectKey );
		
		// prepare stats return map
    	local.keyStats = {
			timeout = "",
			lastAccessed = "",
			timeExpires = "",
			isExpired = 0,
			isDirty = 0,
			isSimple = 1,
			createdDate = "",
			metadata = {},
			cas = "",
			dataAge = 0,
			// We don't track these two, but I need a dummy values
			// for the CacheBox item report.
			lastAccessTimeout = 0,
			hits = 0
		};
    	
    	// Get stats for this key from the returned java future
    	local.stats = getCouchbaseClient().getKeyStats( objectKey ).get();
    	if( structKeyExists( local, "stats" ) ){
    		
    		// key_exptime
    		if( structKeyExists( local.stats, "key_exptime" ) and isNumeric( local.stats[ "key_exptime" ] ) ){
    			local.keyStats.timeExpires = dateAdd("s", local.stats[ "key_exptime" ], dateConvert( "utc2Local", "January 1 1970 00:00" ) ); 
    		}
    		// key_last_modification_time
    		if( structKeyExists( local.stats, "key_last_modification_time" ) and isNumeric( local.stats[ "key_last_modification_time" ] ) ){
    			local.keyStats.lastAccessed = dateAdd("s", local.stats[ "key_last_modification_time" ], dateConvert( "utc2Local", "January 1 1970 00:00" ) ); 
    		}
    		// state
    		if( structKeyExists( local.stats, "key_vb_state" ) ){
    			local.keyStats.isExpired = ( local.stats[ "key_vb_state" ] eq "active" ? false : true ); 
    		}
    		// dirty
			if( structKeyExists( local.stats, "key_is_dirty" ) ){
    			local.keyStats.isDirty = local.stats[ "key_is_dirty" ]; 
    		}
    		// data_age
			if( structKeyExists( local.stats, "key_data_age" ) ){
    			local.keyStats.dataAge = local.stats[ "key_data_age" ]; 
    		}
    		// cas
			if( structKeyExists( local.stats, "key_cas" ) ){
    			local.keyStats.cas = local.stats[ "key_cas" ]; 
    		}
    		
    	}
    	
    	// Add in metastats that we manually store in the JSON document
   		local.object = getCouchbaseClient().get( javacast( "string", arguments.objectKey ) );
		
		// item is no longer in cache, or it's not a JSON doc.  No metastats for us 
		if( !structKeyExists( local, "object" ) || !isJSON( local.object ) ){
    		return local.keyStats;
		}
				
		// inflate our object from JSON
		local.inflatedElement = deserializeJSON( local.object );

		// Simple values like 123 might appear to be JSON, but not a struct
		if(!isStruct(local.inflatedElement)) {
    		return local.keyStats;
		}
				
		// createdDate
		if( structKeyExists( local.inflatedElement, "createdDate" ) ){
   			local.keyStats.createdDate = local.inflatedElement.createdDate;
		}
		// timeout
		if( structKeyExists( local.inflatedElement, "timeout" ) ){
   			local.keyStats.timeout = local.inflatedElement.timeout;
		}
		// metadata
		if( structKeyExists( local.inflatedElement, "metadata" ) ){
   			local.keyStats.metadata = local.inflatedElement.metadata;
		}
		// isSimple
		if( structKeyExists( local.inflatedElement, "isSimple" ) ){
   			local.keyStats.isSimple = local.inflatedElement.isSimple;
		}
    	
    	return local.keyStats;
	}
	
	/**
    * get an item from cache, returns null if not found.
    */
    any function get(required any objectKey) output="false" {
    	return getQuiet( argumentCollection=arguments );
	}
	
	/**
    * get an item silently from cache, no stats advised: Stats not available on Couchbase
    */
    any function getQuiet( required any objectKey ) output="false" {
		// lower case the keys for case insensitivity
		arguments.objectKey = lcase( arguments.objectKey );
		
		try {
    		// local.object will always come back as a string
    		var object = getCouchbaseClient().get( id=arguments.objectKey, deserialize=false );
			
			// item is no longer in cache, return null
			if( isNull( object ) ){
				return;
			}
			
			//fix for serialization issue
			//object = object.Left(-1).Right(-1);
			
			// return if not our JSON
			if( !isJSON( object ) ){
				return object;
			}
			
			// inflate our object from JSON
			var inflatedElement = deserializeJSON( local.object );
			
			
			// Simple values like 123 might appear to be JSON, but not a struct
			if( !isStruct( inflatedElement ) ){
				return object;
			}
			
			// Is simple or not?
			if( structKeyExists( inflatedElement, "isSimple" ) and inflatedElement.isSimple ){
				return inflatedElement.data;
			}
			
			// else we deserialize and return
			if( structKeyExists( inflatedElement, "data" ) ){
				return variables.converter.deserializeObject( binaryObject=inflatedElement.data );
			}
			
			// who knows what this is?
			return local.object;
		} catch( any e ){
			
			if( isTimeoutException( e ) && getConfiguration().ignoreCouchbaseTimeouts ) {
				// log it
				variables.logger.error( "Couchbase timeout exception detected: #e.message# #e.detail#", e );
				// Return nothing as though it wasn't even found in the cache
				return;
			}
			
			// For any other type of exception, rethrow.
			rethrow;
		}
	}
	
	/**
    * Not implemented by this cache
    */
    any function isExpired(required any objectKey) output="false" {
		return getCachedObjectMetadata( arguments.objectKey ).isExpired;
	}
	 
	/**
    * check if object in cache
    */
    any function lookup(required any objectKey) output="false" {
		return getCouchbaseClient().exists( lcase( arguments.objectkey ) );
	}
	
	/**
    * check if object in cache with no stats: Stats not available on Couchbase
    */
    any function lookupQuiet(required any objectKey) output="false" {
		// not possible yet on Couchbase
		return lookup( arguments.objectKey );
	}
	
	/**
    * set an object in cache and returns an object future if possible
    * lastAccessTimeout.hint Not used in this provider
	*
	* @return A structure containing the id, cas, expiry and hashCode document metadata values
    */
    any function set(
		required any objectKey,
		required any object,
		any timeout=variables.configuration.objectDefaultTimeout,
		any lastAccessTimeout="0", // Not used for this provider
		any extra
	) output="false" {
		
		var setData = setQuiet( argumentCollection=arguments );
		
		var iData = { 
			cache							= this,
			cacheObject						= arguments.object,
			cacheObjectKey 					= arguments.objectKey,
			cacheObjectTimeout 				= arguments.timeout,
			cacheObjectLastAccessTimeout	= arguments.lastAccessTimeout,
			couchbaseData 					= setData
		};		

		getEventManager().announce( state="afterCacheElementInsert", interceptData=iData, async=true );
		
		return setData;
	}	
	
	/**
    * set an object in cache with no advising to events, returns a couchbase future if possible
    * lastAccessTimeout.hint Not used in this provider
	* 
	* @return A structure containing the id, cas, expiry and hashCode document metadata values
    */
    any function setQuiet(
		required any objectKey,
		required any object,
		any timeout=variables.configuration.objectDefaultTimeout,
		any lastAccessTimeout="0", // Not used for this provider
		any extra=structNew()
	) output="false" {
		
		// lower case the keys for case insensitivity
		arguments.objectKey = lcase( arguments.objectKey );
		
		// create storage element
		var sElement = {
			createdDate 	= dateformat( now(), "mm/dd/yyyy") & " " & timeformat( now(), "full" ),
			timeout 		= arguments.timeout,
			metadata 		= ( structKeyExists( arguments.extra, "metadata" ) ? arguments.extra.metadata : {} ),
			isSimple 		= isSimpleValue( arguments.object ),
			data 			= arguments.object
		};
		
		// Do we need to serialize incoming obj
		if( !sElement.isSimple ){
			sElement.data = variables.converter.serializeObject( arguments.object );
		}
		
		// Serialize element to JSON to store it in Couchbase
		sElement = serializeJSON( sElement );

    	try {
    		
			return getCouchbaseClient()
				.upsert( 
					id 		= arguments.objectKey,
					value 	= sElement,
					timeout = arguments.timeout
				);
		
		} catch( any e ){
			
			if( isTimeoutException( e ) && getConfiguration().ignoreCouchbaseTimeouts) {
				// log it
				variables.logger.error( "Couchbase timeout exception detected: #e.message# #e.detail#", e );
				// return nothing
				return '';
			}
			
			// For any other type of exception, rethrow.
			rethrow;
		}
	}	
		
	/**
    * Tries to get an object from the cache, if not found, it calls the 'produce' closure
    * to produce the data and cache it
    */
	any function getOrSet(
		required any objectKey,
		required any produce,
		any timeout=variables.configuration.objectDefaultTimeout,
		any lastAccessTimeout="0", // Not used for this provider
		any extra=structNew()
	) {

	var refLocal = {
			object = get( arguments.objectKey )
		};
	// Verify if it exists? if so, return it.
	if( structKeyExists( refLocal, "object" ) ){ return refLocal.object; }
	
	// else, produce it
	lock name="Provider.config.GetOrSet.#variables.cacheID#.#arguments.objectKey#" type="exclusive" throwontimeout="true" timeout="20" {
			//additional check to make sure another thread hasn't created it yet inside a different lock
			refLocal.object = get( arguments.objectKey );
			if( not structKeyExists( refLocal, "object" ) ){
				// produce it
				refLocal.object = arguments.produce();
				// store it
				set( objectKey=arguments.objectKey,
					 object=refLocal.object,
					 timeout=arguments.timeout,
					 lastAccessTimeout=arguments.lastAccessTimeout,
					 extra=arguments.extra );
			}

		}

		return refLocal.object;

	}
		
	/**
    * get cache size
    */
    any function getSize() output="false" {
		return arrayLen( getKeys() );
	}
	
	/**
    * Not implemented by this cache
    */
    void function reap() output="false" {
		// Not implemented by this provider
	}
	
	/**
    * clear all elements from cache
    */
    void function clearAll() output="false" {
		
		// If flush is not enabled for this bucket, no error will be thrown.  The call will simply return and nothing will happen.
		// Be very careful calling this.  It is an intensive asynch operation and the cache won't receive any new items until the flush
		// is finished which might take a few minutes.
		getCouchbaseClient().flush();		
				 
		var iData = {
			cache = this
		};
		
		// notify listeners		
		getEventManager().announce( "afterCacheClearAll", iData );
	}
	
	/**
    * clear an element from cache and returns the couchbase java future
    */
    any function clear( required any objectKey ) output="false" {
		// lower case the keys for case insensitivity
		arguments.objectKey = lcase( arguments.objectKey );
		
		// Delete from couchbase
		var results = getCouchbaseClient().remove( arguments.objectKey );
		
		//ColdBox events
		var iData = { 
			cache				= this,
			cacheObjectKey 		= arguments.objectKey,
			couchbaseResults	= results
		};		
		getEventManager().announce( state="afterCacheElementRemoved", interceptData=iData, async=true );
		
		return results;
	}
	
	/**
    * Clear with no advising to events and returns with the couchbase java future
    */
    any function clearQuiet(required any objectKey) output="false" {
		// normal clear, not implemented by Couchbase
		return clear( arguments.objectKey );
	}
	
	/**
	* Clear by key snippet
	*/
	void function clearByKeySnippet(required keySnippet, regex=false, async=false) output="false" {
		var threadName = "clearByKeySnippet_#replace( variables.uuidHelper.randomUUID(), "-", "", "all" )#";
		
		// Async? IF so, do checks
		if( arguments.async AND NOT variables.utility.inThread() ){
			thread name="#threadName#"{
				variables.elementCleaner.clearByKeySnippet( arguments.keySnippet, arguments.regex );
			}
		} else {
			variables.elementCleaner.clearByKeySnippet( arguments.keySnippet, arguments.regex );
		}
		
	}
	
	/**
    * Expiration not implemented by couchbase so clears are issued
    */
    void function expireAll() output="false"{ 
		clearAll();
	}
	
	/**
    * Expiration not implemented by couchbase so clear is issued
    */
    void function expireObject(required any objectKey) output="false"{
		clear( arguments.objectKey );
	}

	/************************************** PRIVATE *********************************************/

	/**
    * Ensure that a view exists on the cluster
    */
    private function ensureViewExists(){
		var viewName 			= "allKeys";
    	var designDocumentName 	= 'CacheBox';
		var couchbaseClient 	= getCouchbaseClient();

		// Verify if view exists
		if( !couchbaseClient.viewExists( designDocumentName, viewName ) ){
			
			// The view js
			var mapFunction = '
			function (doc, meta) {
			  emit(meta.id, null);
			}';

			// Create it
			couchbaseClient.saveView(
				designDocumentName 	= designDocumentName,
				viewName 			= viewName,
				mapFunction 		= mapFunction
			);
		}

		return this;
    }
	
	/**
	* Validate the incoming configuration and make necessary defaults
	**/
	private void function validateConfiguration() output="false"{
		var cacheConfig = getConfiguration();
		
		// Validate configuration values, if they don't exist, then default them to DEFAULTS
		for( var key in variables.DEFAULTS ){
			if( NOT structKeyExists( cacheConfig, key ) OR ( isSimpleValue( cacheConfig[ key ] ) AND NOT len( cacheConfig[ key ] ) ) ){
				cacheConfig[ key ] = variables.DEFAULTS[ key ];
			}
		}
	}
	
	/**
	* verifies if a timoeut exception is detected
	*/
	private boolean function isTimeoutException(required any exception){
    	return (
			exception.type 		== 'com.couchbase.client.core.error.TimeoutException' ||
			exception.type 		== 'com.couchbase.client.core.error.AmbiguousTimeoutException' ||
			exception.type 		== 'com.couchbase.client.core.error.UnambiguousTimeoutException' ||
			exception.type 		== 'net.spy.memcached.OperationTimeoutException' || 
			exception.message	== 'Exception waiting for value' || 
			exception.message 	== 'Interrupted waiting for value' || 
			exception.message 	contains 'Timeout'
		);
	}
	
}