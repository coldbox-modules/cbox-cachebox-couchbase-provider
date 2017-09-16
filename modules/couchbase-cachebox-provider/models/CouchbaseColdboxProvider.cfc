/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author: Brad Wood
Description:
	
This CacheBox provider communicates with a single Couchbase node or a 
cluster of Couchbase nodes for a distributed and highly scalable cache store.
This provider is for use in a ColdBox application.

*/
component 	name="CouchbaseColdboxProvider" 
			serializable="false"
			extends="CouchbaseProvider" 
			implements="coldbox.system.cache.IColdboxApplicationCache" 
			accessors=true
{

	/**
	* Constructor
	* @wirebox WireBox reference
	* @wirebox.inject wirebox
	*/
	function init( required wirebox ){
		super.init( arguments.wirebox );
		
		// Cache Prefixes
		this.VIEW_CACHEKEY_PREFIX 	= "couchbase_view-";
		this.EVENT_CACHEKEY_PREFIX 	= "couchbase_event-";
		
		// URL Facade Utility
		instance.eventURLFacade		= arguments.wirebox.getinstance( 
			name          = "coldbox.system.cache.util.EventURLFacade", 
			initArguments = { cacheProvider = this } 
		);
		
		return this;
	}
	
	any function getViewCacheKeyPrefix() output="false"{ 
		return this.VIEW_CACHEKEY_PREFIX; 
	}
	any function getEventCacheKeyPrefix() output="false"{ 
		return this.EVENT_CACHEKEY_PREFIX; 
	}
	
	void function setColdbox( required any coldbox ) output="false"{
		variables.coldbox = arguments.coldbox;
	}
	
	any function getColdbox() output="false"{ 
		return coldbox; 
	}
	
	any function getEventURLFacade() output="false"{ 
		return instance.eventURLFacade; 
	}
	
	/**
	* Clear all events
	* TODO: Change this to use Couchbase view based on metastats
	*/
	void function clearAllEvents( async=false ) output="false"{
		var threadName = "clearAllEvents_#replace( instance.uuidHelper.randomUUID(), "-", "", "all" )#";
		
		// Async? IF so, do checks
		if( arguments.async AND NOT instance.utility.inThread() ){
			thread name="#threadName#"{
				instance.elementCleaner.clearAllEvents();
			}
		} else {
			instance.elementCleaner.clearAllEvents();
		}
	}
	
	/**
	* Clear all views
	* TODO: Change this to use Couchbase view based on metastats
	*/
	void function clearAllViews( async=false ) output="false"{
		var threadName = "clearAllViews_#replace(instance.uuidHelper.randomUUID(), "-", "", "all" )#";
		
		// Async? IF so, do checks
		if( arguments.async AND NOT instance.utility.inThread() ){
			thread name="#threadName#"{
				instance.elementCleaner.clearAllViews();
			}
		} else {
			instance.elementCleaner.clearAllViews();
		}
	}
	
	/**
	* Clear event
	*/
	void function clearEvent( required eventsnippet, queryString="") output="false"{
		instance.elementCleaner.clearEvent( arguments.eventsnippet, arguments.queryString );
	}
	
	/**
	* Clear multiple events
	*/
	void function clearEventMulti( required eventsnippets,queryString="" ) output="false"{
		instance.elementCleaner.clearEventMulti( arguments.eventsnippets, arguments.queryString );
	}
	
	/**
	* Clear view
	*/
	void function clearView( required viewSnippet ) output="false"{
		instance.elementCleaner.clearView( arguments.viewSnippet );
	}
	
	/**
	* Clear multiple view
	*/
	void function clearViewMulti( required viewsnippets ) output="false"{
		instance.elementCleaner.clearView( arguments.viewsnippets );
	}
	
}