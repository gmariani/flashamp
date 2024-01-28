<!--- playlistXML --->
<cffunction name="playlistXML" output="true" returnType="query">
  <cfargument name="directory" type="string" required="true">
  <cfargument name="filter" type="string" required="false" default="">
  <cfargument name="sort" type="string" required="false" default="ASC">
  <cfargument name="recurse" type="boolean" required="false" default="true">
  <!--- temp vars --->
  <cfargument name="dirInfo" type="query" required="false">
  <cfargument name="thisDir" type="query" required="false">
  <cfset var path="">
  <cfset var temp="">
  <cfset var folderPath = "">
  <cfset var counter=0>
  <!--- DO NOT MODIFY ABOVE THIS LINE --->
  <cfif not recurse>
    <cfdirectory name="temp" directory="#directory#" filter="#filter#" sort="#sort#">
    <cfreturn temp>
    <cfelse>
    <cfset addString = "<PlayLists>" />
    <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists.xml" OUTPUT="#addString#">
    <!--- We loop through until done recursing drive --->
    <cfif not isDefined("dirInfo")>
      <cfset dirInfo = queryNew("name,directory,id")>
    </cfif>
    <cfset thisDir = playlistXML(directory,filter,"ASC",false)>
    <cfif server.os.name contains "Windows">
      <cfset path = "\">
      <cfelse>
      <cfset path = "/">
    </cfif>
    <cfloop query="thisDir">
      <cfset queryAddRow(dirInfo)>
      <cfset querySetCell(dirInfo,"name",name)>
      <cfset querySetCell(dirInfo,"directory",directory)>
      <cfset counter = counter + 1>
      <cfset querySetCell(dirInfo,"ID",counter)>
      <cfif find(".m3u",name) OR find(".M3U",name) OR find(".M3u",name) OR find(".m3U",name)>
        <cfset addString = '<list label="#name#"/>' />
        <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists.xml" OUTPUT="#addString#">
      </cfif>
    </cfloop>
  </cfif>
  <cfset addString = "</PlayLists>" />
  <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists.xml" OUTPUT="#addString#">
  <cfreturn dirInfo>
</cffunction>
<!--- songXML --->
<cffunction name="songXML" output="true" returnType="query">
  <cfargument name="directory" type="string" required="true">
  <cfargument name="filter" type="string" required="false" default="">
  <cfargument name="sort" type="string" required="false" default="ASC">
  <cfargument name="recurse" type="boolean" required="false" default="true">
  <!--- temp vars --->
  <cfargument name="dirInfo" type="query" required="false">
  <cfargument name="thisDir" type="query" required="false">
  <cfset var path="">
  <cfset var temp="">
  <cfset var folderPath = "">
  <cfset var counter=0>
  <!--- DO NOT MODIFY ABOVE THIS LINE --->
  <cfif not recurse>
    <cfdirectory name="temp" directory="#directory#" filter="#filter#" sort="#sort#">
    <cfreturn temp>
    <cfelse>
    <cfset addString = "<Library>" />
    <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#songs.xml" OUTPUT="#addString#">
    <!--- We loop through until done recursing drive --->
    <cfif not isDefined("dirInfo")>
      <cfset dirInfo = queryNew("name,directory,id")>
    </cfif>
    <cfset thisDir = songXML(directory,filter,"ASC",false)>
    <cfif server.os.name contains "Windows">
      <cfset path = "\">
      <cfelse>
      <cfset path = "/">
    </cfif>
    <cfloop query="thisDir">
      <cfset queryAddRow(dirInfo)>
      <cfset querySetCell(dirInfo,"name",name)>
      <cfset querySetCell(dirInfo,"directory",directory)>
      <cfset counter = counter + 1>
      <cfset querySetCell(dirInfo,"ID",counter)>
      <cfif find(".mp3",name) OR find(".MP3",name) OR find(".Mp3",name)>
        <cfset addString = '<song label="#name#"/>' />
        <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#songs.xml" OUTPUT="#addString#">
      </cfif>
    </cfloop>
  </cfif>
  <cfset addString = "</Library>" />
  <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#songs.xml" OUTPUT="#addString#">
  <cfreturn dirInfo>
</cffunction>
<!--- Queries --->
<cffile action="delete" file="#GetDirectoryFromPath(ExpandPath('*.*'))#songs.xml">
<cffile action="delete" file="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists.xml">
<CFSET SongListing = songXML(#GetDirectoryFromPath(ExpandPath('./songs/'))#,"","name asc")>
<cfoutput>Song listing saved! (#DateFormat(Now(),"mm/dd/yy")# #TimeFormat(Now(),"hh:mm:ss tt")#)<br /></cfoutput>
<CFSET FolderListing = playlistXML(#GetDirectoryFromPath(ExpandPath('./playlists/'))#,"","name asc")>
<cfoutput>Play lists saved! (#DateFormat(Now(),"mm/dd/yy")# #TimeFormat(Now(),"hh:mm:ss tt")#)<br /></cfoutput> 