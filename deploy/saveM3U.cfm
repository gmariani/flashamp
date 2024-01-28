<title>FlashAmp Default Playlist Generator</title>
<h2>Saving Songs listing and Play Lists...</h2>
<!--- Queries --->
<cfset args = StructNew()>
<cfset args.directory = #GetDirectoryFromPath(ExpandPath('./songs/'))#>
<cfset args.filter = "">
<cfset args.sort = "name asc" >
<cfinvoke component="cfc.fileInfo" method="songM3U" argumentcollection="#args#" returnVariable="SongListing" />
<cfoutput><a href="playlists/Default.m3u"><b>Song listing saved</b></a>! (#DateFormat(Now(),"mm/dd/yy")# #TimeFormat(Now(),"hh:mm:ss tt")#)<br />
</cfoutput>
<cfset args = StructNew()>
<cfset args.directory = #GetDirectoryFromPath(ExpandPath('./playlists/'))#>
<cfset args.filter = "">
<cfset args.sort = "name asc" >
<cfinvoke component="cfc.fileInfo" method="playlistXML" argumentcollection="#args#" returnVariable="SongListing" />
<cfoutput><a href="playlists.xml"><b>Play lists saved</b></a>! (#DateFormat(Now(),"mm/dd/yy")# #TimeFormat(Now(),"hh:mm:ss tt")#)<br />
</cfoutput>