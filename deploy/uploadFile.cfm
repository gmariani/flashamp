<!--- Files are uploaded into the songs folder. --->
<cffile action="upload" fileField="Filedata" destination="#ExpandPath ('songs')#" nameConflict="makeUnique" />