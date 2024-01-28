<cfcomponent>
  <!--- ------ --->
  <!--- getMP3 --->
  <!--- ------ --->
  <cffunction name="getMP3" output="true" returnType="query">
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
      <CFFILE ACTION="write" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#songs.xml" OUTPUT="#addString#">
      <!--- We loop through until done recursing drive --->
      <cfif not isDefined("dirInfo")>
        <cfset dirInfo = queryNew("name,directory,id")>
      </cfif>
      <cfset thisDir = getMP3(directory,filter,"ASC",false)>
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
  <!--- ----------- --->
  <!--- playlistXML --->
  <!--- ----------- --->
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
      <CFFILE ACTION="write" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists.xml" OUTPUT="#addString#">
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
  <!--- ------- --->
  <!--- songM3U --->
  <!--- ------- --->
  <cffunction name="songM3U" output="true" returnType="query">
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
      <cfset addString = '##EXTM3U' />
      <CFFILE ACTION="write" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists/Default.m3u" OUTPUT="#addString#">
      <!--- We loop through until done recursing drive --->
      <cfif not isDefined("dirInfo")>
        <cfset dirInfo = queryNew("name,directory,id")>
      </cfif>
      <cfset thisDir = songM3U(directory,filter,"ASC",false)>
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
          <cfset shortname = Mid(name, 1,Len(name) - 4)>
          <cfset addString = '##EXTINF:-1, #shortname#' />
          <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists/Default.m3u" OUTPUT="#addString#">
          <cfset addString = '/songs/#name#' />
          <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#playlists/Default.m3u" OUTPUT="#addString#">
        </cfif>
      </cfloop>
    </cfif>
    <cfreturn dirInfo>
  </cffunction>
  <!--- ------- --->
  <!--- songXML --->
  <!--- ------- --->
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
</cfcomponent>
