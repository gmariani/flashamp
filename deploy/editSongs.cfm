<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>FlashAmp Music Manager</title>
<link href="css/cfm.css" rel="stylesheet" type="text/css"/>
<script src="../common.js" type="text/javascript"></script>
<script type="text/javascript">
	function toggleLayer(whichLayer, vis) {
		if (document.getElementById) {
			// this is the way the standards work
			var style2 = document.getElementById(whichLayer).style;
			style2.display = vis;
		} else if (document.all) {
			// this is the way old msie versions work
			var style2 = document.all[whichLayer].style;
			style2.display = vis;
		} else if (document.layers)	{
			// this is the way nn4 works
			var style2 = document.layers[whichLayer].style;
			style2.display = vis;
		}
	}
	function  checkUpload(form_this) {
		if (form_this.song1.value == "" && form_this.song2.value == "" && form_this.song3.value == "" && form_this.song4.value == "") {
			alert("Please enter songs to upload.");
			return false;
		}
		return true;
	}
	function  checkDelete(form_this) {
	var result = confirm("Are you sure you want to delete this song(s)?");
		if (result == false) {
			form_this.deleteSongs.disabled=false;			
			return false;
		}
		return true;
	}
</script>
</head>
<body >
<cfoutput></cfoutput>
<div id="content_bg"><br />
    <div id="content_title" />
    <br />
    <br />
    <div id="content_menu"><br /><form action="editSongs.cfm" method="post" >
        <input name="Button" type="button" onclick="toggleLayer('delete_form','');toggleLayer('upload_form','block');" value="Upload Songs" />
        <input name="Button" type="button" onclick="toggleLayer('delete_form','block');toggleLayer('upload_form','');" value="Delete Songs" />
		<input name="updateM3U" type="submit" value="Update Playlist" /></form>
        <!--- ----------- --->
        <!--- Upload MP3s --->
        <!--- ----------- --->
        <br />
		<cfif isdefined("form.song1") or isdefined("form.song2") or isdefined("form.song3") or isdefined("form.song4")>
			<cfif len(form.song1) GT 0 OR len(form.song2) GT 0 OR len(form.song3) GT 0 OR len(form.song4) GT 0>
				<cfif len(form.song1) GT 0><cffile action="upload" filefield="song1" destination="#GetDirectoryFromPath(ExpandPath('./songs/'))#" nameconflict="overwrite"><h1>File 1 Uploaded!</h1></cfif>
    			<cfif len(form.song2) GT 0><cffile action="UPLOAD" filefield="song2" destination="#GetDirectoryFromPath(ExpandPath('./songs/'))#" nameconflict="overwrite"><h1>File 2 Uploaded!</h1></cfif>
    			<cfif len(form.song3) GT 0><cffile action="UPLOAD" filefield="song3" destination="#GetDirectoryFromPath(ExpandPath('./songs/'))#" nameconflict="overwrite"><h1>File 3 Uploaded!</h1></cfif>
    			<cfif len(form.song4) GT 0><cffile action="UPLOAD" filefield="song4" destination="#GetDirectoryFromPath(ExpandPath('./songs/'))#" nameconflict="overwrite"><h1>File 4 Uploaded!</h1></cfif>
    			<cfset args = StructNew()>
    			<cfset args.directory = #GetDirectoryFromPath(ExpandPath('./songs/'))#>
    			<cfset args.filter = "">
    			<cfset args.sort = "name asc" >
    			<cfinvoke component="cfc.fileInfo" method="songM3U" argumentcollection="#args#" returnVariable="SongListing" />
			</cfif>                
    	</cfif>	
        <!--- ----------- --->
        <!--- Delete MP3s --->
        <!--- ----------- --->
        <cfif isdefined("form.songList")>
            <cfloop index="ListElement" delimiters="," list="#form.songList#">
                <cffile action="delete" file="#GetDirectoryFromPath(ExpandPath('./songs/'))##ListElement#">
                <h1>File: <cfoutput>#ListElement#</cfoutput> Deleted!</h1>
            </cfloop>
        </cfif>
        <!--- ------------------ --->
        <!--- Update M3U and XML --->
        <!--- ------------------ --->
        <cfif isdefined("form.updateM3U")>
            <cfset args = StructNew()>
            <cfset args.directory = #GetDirectoryFromPath(ExpandPath('./songs/'))#>
            <cfset args.filter = "">
            <cfset args.sort = "name asc" >
            <cfinvoke component="cfc.fileInfo" method="songM3U" argumentcollection="#args#" returnVariable="SongListing" />            
            <cfoutput><a href="playlists/Default.m3u"><b>Song listing saved!</b></a><br /></cfoutput>
            <cfset args = StructNew()>
            <cfset args.directory = #GetDirectoryFromPath(ExpandPath('./playlists/'))#>
            <cfset args.filter = "">
            <cfset args.sort = "name asc" >
            <cfinvoke component="cfc.fileInfo" method="playlistXML" argumentcollection="#args#" returnVariable="SongListing" />
            <cfoutput><a href="playlists.xml"><b>Play lists saved!</b></a><div class="timestamp">(#DateFormat(Now(),"mm/dd/yy")# #TimeFormat(Now(),"hh:mm:ss tt")#)</div></cfoutput>
        </cfif>
    </div>
    <!--- ------- --->
    <!--- Queries --->
    <!--- ------- --->
    <cfset args = StructNew()>
    <cfset args.directory = #GetDirectoryFromPath(ExpandPath('./songs/'))#>
    <cfset args.filter = "">
    <cfset args.sort = "name asc" >
    <cfinvoke component="cfc.fileInfo" method="getMP3" argumentcollection="#args#" returnVariable="SongListing" />
    
    <div class="content_form" id="upload_form"> <br />
        <form id="uploadFrm" onsubmit="return checkUpload(this)" action="editSongs.cfm" method="post" enctype="multipart/form-data">
            <span class="header3">Please select songs to upload to server:</span><br />
            <input name="song1" type="file" size="50" onchange="document.forms['uploadFrm'].uploadSongs.disabled=false" />
            <br />
            <input name="song2" type="file" size="50" onchange="document.forms['uploadFrm'].uploadSongs.disabled=false" />
            <br />
            <input name="song3" type="file" size="50" onchange="document.forms['uploadFrm'].uploadSongs.disabled=false" />
            <br />
            <input name="song4" type="file" size="50" onchange="document.forms['uploadFrm'].uploadSongs.disabled=false" />
            <br />
            <input name="uploadSongs" type="submit" onclick="document.forms['uploadFrm'].uploadSongs.disabled=true;" value="Upload Songs" />
        </form>
    </div>
    <div class="content_form" id="delete_form"> <br />
        <form id="deleteFrm" action="editSongs.cfm" onsubmit="return checkDelete(this)" method="post" enctype="multipart/form-data">
            <select name="songList" size="10" multiple="true">
                <CFOUTPUT query="SongListing">
                    <option value="#name#" onclick="document.forms['deleteFrm'].deleteSongs.disabled=false" >#name#</option>
                </CFOUTPUT>
            </select>
            <br />
            <input name="deleteSongs" type="submit" onclick="document.forms['deleteFrm'].deleteSongs.disabled=true" value="Delete Songs" />
        </form>
    </div>
</div>
<script type="text/javascript">
	document.forms['uploadFrm'].uploadSongs.disabled=true;
	document.forms['deleteFrm'].deleteSongs.disabled=true;
	toggleLayer('upload_form','block');
</script>
</body>
</html>
