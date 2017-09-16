/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author: Brad Wood, Luis Majano
Description:
	
Stats for Couchbase Provider
*/
component 	name="CouchbaseStats" 
			implements="coldbox.system.cache.util.ICacheStats" 
			accessors="true" 
			serializable=false
{
	
	// The cache provider this stats are linked to
	property name="cacheProvider" serializable="false";

	/**
	* Constructor
	* 
	* @cacheProvider The cache provider I belong to.
	*/
	function init( cacheProvider ){
		setCacheProvider( arguments.cacheProvider );
		
		variables.cluster       = arguments.cacheProvider.getCouchbaseClient().couchbaseCluster;
		variables.bucket        = arguments.cacheProvider.getCouchbaseClient().getCouchbaseBucket();
		variables.bucketManager = variables.bucket.bucketManager();

		return this;
	}

	any function getCachePerformanceRatio() output="false"{
		var hits 		= getHits();
		var requests 	= hits + getMisses();
		
	 	if ( requests eq 0){
	 		return 0;
		}
		
		return ( hits / requests ) * 100;
	}
	
	any function getObjectCount() output="false"{
		return getAggregateStat( 'vb_active_curr_items' );
	}
	
	void function clearStatistics() output="false"{
		// not yet implemented by CouchBase
	}
	
	any function getGarbageCollections() output="false"{
		return 0;
	}
	
	any function getEvictionCount() output="false"{
		return 0;
	}
	
	any function getHits() output="false"{
		return getAggregateStat( 'get_hits' );
	}
	
	any function getMisses() output="false"{
		return getAggregateStat( 'get_misses' );
	}
	
	any function getLastReapDatetime() output="false"{
		return "";
	}
	
	/************************************** private *********************************************/
	
	private any function getAggregateStat(string statName ){
		var results = 0;
		var info 	= deserializeJSON( couchbase.getCouchbaseClient().getcouchbaseBucket().bucketManager().info().raw().toString() );
		
		// For each node, loop and add up
		for( var thisNode in info.nodes ){
			// make sure the stat exists
			if( structKeyExists( thisNode.interestingStats, arguments.statName ) ){
				results += val( thisNode.interestingStats[ arguments.statName ] );	
			}
		}
		
		return results;
	}
	
}