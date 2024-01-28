<!--- getDir --->
<cffunction name="getDir" output="true" returnType="query">
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
    <!--- We loop through until done recursing drive --->
    <cfif not isDefined("dirInfo")>
      <cfset dirInfo = queryNew("name,type,directory,id")>
    </cfif>
    <cfset thisDir = getDir(directory,filter,"ASC",false)>
    <cfif server.os.name contains "Windows">
      <cfset path = "\">
      <cfelse>
      <cfset path = "/">
    </cfif>
    <cfloop query="thisDir">
      <cfif type is "dir">
        <cfset queryAddRow(dirInfo)>
        <cfset querySetCell(dirInfo,"name",name)>
        <cfset querySetCell(dirInfo,"type",type)>
        <cfset querySetCell(dirInfo,"directory",directory)>
        <cfset counter = counter + 1>
        <cfset querySetCell(dirInfo,"ID",counter)>
      </cfif>
    </cfloop>
  </cfif>
  <cfreturn dirInfo>
</cffunction>
<!--- getMP3 --->
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
    <CFFILE ACTION="append" FILE="#GetDirectoryFromPath(ExpandPath('*.*'))#songs.xml" OUTPUT="#addString#">
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
<!--- ---------------- --->
<!--- CF Create Folder --->
<!--- ---------------- --->
<CFIF IsDefined ("FORM.new")>
	<cfscript>
	/**
	 * Create all non exitant directories in a path.
	 * 
	 * @param p 	 The path to create. (Required)
	 * @return Returns nothing. 
 	* @author Jorge Iriso (jiriso@fitquestsl.com) 
 	* @version 1, September 21, 2004 
 	*/
	function makeDirs(p){
		createObject("java", "java.io.File").init(p).mkdirs();
	}
	makeDirs('c:\www\grandpa\parent\son');
	</cfscript>
</CFIF>
<!--- Queries --->
<CFSET SongListing = getMP3(#GetDirectoryFromPath(ExpandPath('./songs/'))#,"","name asc")>
<CFSET FolderListing = getDir(#GetDirectoryFromPath(ExpandPath('./songs/'))#,"","name asc")>
<html>
<SCRIPT src="../common.js"></SCRIPT>
<script language="JavaScript" type="text/JavaScript">
<!--
/////////////////
// Reload Page //
/////////////////
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
///////////////////
// Select Folder //
///////////////////
function  folderSelect(form_this) {
	if (form_this.folderList.length > 1) {
			alert("Please select one folder only.");
			return false;
	}
	return true;
}
//////////////////////
// Delete Folder(s) //
//////////////////////
function  folderDelete(form_this) {
	if (form_this.folderList.length < 1) {
			alert("Please select atleast one folder.");
			return false;
	}
	var agree=confirm("Are you sure you want to delete records "+form_this.selectedIDs+"?");
	var delID = form_this.selectedIDs;
	if (agree) {
		parent.location = 'delete.cfm?id=' + delID;
	} else {
		return false ;
	}
	return true;
}
///////////////////////
// Create New Folder //
///////////////////////
function  folderNew(val) {
	if (val ==  "") {
		alert("Please enter a folder name.");
		return false;
	}
	parent.location = 'folderNew.cfm?name=' + val;
	return true;
}
//
MM_reloadPage(true);
//-->
</script>
<head>
<title>FlashAmp Music Manager</title>
<link href="css/cfm.css" rel="stylesheet" type="text/css">
</head>
<body>
<div id="bgStar" style="position:absolute; left:-20; top:-50; width:296px; height:267px; z-index:2; visibility: visible;"><img src="images/bg_star.png" width="547" height="544"></div>
<div id="bgGrey" style="position:absolute; left:50; top:50; width:90%; height:800; z-index:1; visibility: visible;"><img src="images/bg_grey.jpg" width="100%" height="100%"></div>
<div id="formSongs" style="position:absolute; left:150; top:100; width:500; height:250; z-index:4; visibility: hidden;">
  <form action="" method="post" enctype="multipart/form-data" name="upload_songs">
    <div align="center">Please select songs to upload to server: <br>
      <input name="file" type="file" size="50">
      <br>
      <input name="file" type="file" size="50">
      <br>
      <input name="file" type="file" size="50">
      <br>
      <input name="file" type="file" size="50">
      <br>
      <input name="uploadSongs" type="submit" id="uploadSongs" value="Upload Songs">
      <br>
      <br>
      <SELECT name="folderList"  size="10" multiple  id="folderList" onChange="setUser(this.value,this.name)">
        <CFOUTPUT query="SongListing">
          <OPTION value="#ID#">#name#</OPTION>
        </CFOUTPUT>
      </SELECT>
      <br>
      <input name="deleteSongs" type="submit" id="deleteSongs" value="Delete Songs">
    </div>
  </form>
</div>
<div id="formPlaylist" style="position:absolute; left:150; top:100; width:500; height:250; z-index:5; visibility: hidden;">
  <form action="" method="post" enctype="multipart/form-data" name="upload_songs">
    <div align="center">Playlist Options <br>
      <input name="browsePlaylist" type="file" id="browsePlaylist" size="50">
      <br>
      <input name="uploadPlaylist" type="submit" id="uploadPlaylist" value="Upload Playlist">
      <br>
      <br>
      <select name="select">
      </select>
      <br>
      <input name="deletePlaylist" type="submit" id="deletePlaylist" value="Delete Playlist">
      <br>
      <br>
      <select name="songList" id="songList">
      </select>
      <br>
      <input name="newPlaylist" type="submit" id="newPlaylist" value="Create Playlist">
    </div>
  </form>
</div>
<div id="formFolder" style="position:absolute; left:150; top:100; width:500; height:250; z-index:6; visibility: visible;">
  <div align="center">
    <form name="folderSettings" method="post" action="">
      <input name="newName" type="text" id="newName" size="50" maxlength="50">
      <br>
      <input name="newFolder" type="button" id="newFolder" onClick="folderNew(newName.value)" value="Create New Folder">
      <br>
      <br>
      <!-- Create update buttons function, updates setFolder to disable if more than one is selected --->
      <SELECT onChange="updateButtons()" <cfif FolderListing.RecordCount eq 0>disabled</cfif>  name="folderList"  size="5" multiple  id="folderList">
        <cfif FolderListing.RecordCount gt 0>
          <CFOUTPUT query="FolderListing">
            <OPTION value="#ID#">#name#</OPTION>
          </CFOUTPUT>
          <cfelse>
          <OPTION value="0">- None -</OPTION>
        </cfif>
      </SELECT>
      <br>
      <input name="deleteFolder" type="button" id="deleteFolder" onClick="folderDelete(folderSettings)" value="Delete Selected Folder">
      <input name="setFolder" type="button" id="setFolder" onClick="folderSelect(folderSettings)" value="Change Current Folder to Selected">
    </form>
  </div>
</div>
</body>
</html>
