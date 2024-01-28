<cfset args = StructNew()>
<cfset args.directory = #GetDirectoryFromPath(ExpandPath('./songs/'))#>
<cfset args.filter = "">
<cfset args.sort = "name asc" >
<cfinvoke component="cfc.fileInfo" method="songM3U" argumentcollection="#args#" returnVariable="SongListing" />
<cfoutput>&complete=true</cfoutput> 