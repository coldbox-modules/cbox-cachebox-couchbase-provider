<cfoutput>
<h1>Couchbase Provider</h1>
<p>Keys Found</p>

<ul>
<cfloop array="#prc.allKeys#" index="thisKey">
	<li>#thisKey#</li>
</cfloop>
</ul>

<cfdump var="#prc.data#">
</cfoutput>