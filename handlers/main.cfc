/**
* My Event Handler Hint
*/
component{

	property name="couchbase" inject="cachebox:couchbase";

	function preHandler( event, rc, prc ){
		couchbase.set( "testData", {
			name = "luis majano",
			when = now(),
			id   = createUUID()
		} );
	}

	// Index
	any function index( event,rc, prc ){
		prc.allKeys = couchbase.getKeys();
		prc.data    = couchbase.get( "testData" );

		event.setView( "main/index" );
	}

	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}