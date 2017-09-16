<cfoutput>
<h1>Couchbase Provider</h1>
<p>Keys Found</p>

<ul>
<cfloop array="#prc.allKeys#" index="thisKey">
	<li>#thisKey#</li>
</cfloop>
</ul>

<cfdump var="#prc.data#">

<h1>Caches Defined</h1>
<cfdump var="#cachebox.getCaches().keyArray()#">
</cfoutput>