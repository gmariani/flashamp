import flash.net.FileReference;
//
class FlashAmp extends MovieClip {
	public var trackNum:Number = 0;
	private static var myTextFormat:TextFormat;
	private static var Sound_Obj:Sound;
	private static var trackInterval:Number;
	private static var volumeInterval:Number;
	private static var tooltipInterval:Number;
	private static var songtickerInterval:Number;
	private static var infoInterval:Number;
	private static var alphaInterval:Number;
	private static var currentVolume:Number;
	private static var currentPos:Number;
	private static var lastTime:Number = 0;
	private static var infoTitle:Number = 0;
	private static var volumeAdjust:Boolean = false;
	private static var countDown:Boolean = false;
	private static var shuffle_bool:Boolean = false;
	private static var repeat_all_bool:Boolean = false;
	private static var repeat_track_bool:Boolean = false;
	private static var songTicker:Boolean = false;
	private static var currentAction:String;
	private static var _local:MovieClip;
	private static var _Player:MovieClip;
	private static var _PlayListEditor;
	private static var _OpenFiles;
	private static var _rowCount:Number;
	private static var mouseListener:Object;
	private static var mouseListener2:Object;
	private static var fileRefListener:Object;
	private static var fileRef:FileReference;
	private static var songs_xml:XML;
	private static var playlist_xml:XML;
	private static var songInit:Boolean;
	private static var MP3List:Boolean = false;
	private static var M3UList:Boolean = false;
	private static var albumName:String;
	private static var remove_obj:Object;
	private static var add_obj:Object;
	private static var sel_obj:Object;
	private static var manage_obj:Object;
	/* Constructor */
	/////////////////
	public function FlashAmp() {
		_local = this;
		_Player = _local.Player;
		_PlayListEditor = _local.SongListEditor;
		_OpenFiles = _local.playList;
		_Player.track_mc.progress._xscale = 0;
		_Player.track_mc.load_progress._xscale = 0;
		_Player.tf_Title.text = "";
		_Player.tf_Title.autoSize = "left";
		_Player.tf_Timer.autoSize = "left";
		_Player.disabler_btn._visible = false;
		_PlayListEditor.disabler_btn._visible = false;
		_PlayListEditor.songList.setStyle("fontSize", 11);
		_PlayListEditor.songList.setStyle("indentation", 0);
		_PlayListEditor.songList.setStyle("borderCapColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("borderColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("buttonColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("highlightColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("shadowCapColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("shadowColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("defaultLeafIcon", "");
		_PlayListEditor.songList.setStyle("color", 0xFFFFFF);
		_PlayListEditor.songList.setStyle("backgroundColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("rollOverColor", 0x6688C8);
		_PlayListEditor.songList.setStyle("selectionColor", 0x1A3A78);
		_PlayListEditor.songList.setStyle("textRollOverColor", 0xFFFFFF);
		_PlayListEditor.songList.setStyle("textSelectedColor", 0x6688C8);
		_Player.MLPL_mc.PL_Icon._visible = _Player.MLPL_mc.ML_Icon._visible=false;
		_PlayListEditor._visible = false;
		_OpenFiles._visible = false;
		_local.popupwindow_mc._visible = false;
		_local.popupLoading_mc._visible = false;
		_local.popupProcess_mc._visible = false;
		_global.styles.ScrollSelectList.setStyle("openDuration", 0);
		////////////////////////////////////////////////////////////////////
		// Load XML
		////////////////////////////////////////////////////////////////////
		_local.albumName = "Default";
		loadXML("playlists/Default.m3u", populateSongs, "songs_xml");
		loadXML("playlists.xml", populatePlayList, "playList_xml");
		////////////////////////////////////////////////////////////////////
		// Init Sound Object
		////////////////////////////////////////////////////////////////////
		Sound_Obj = new Sound(_Player);
		_soundbuftime = 0;
		Sound_Obj.onSoundComplete = function() {
			clearInterval(trackInterval);
			if (repeat_track_bool == true) {
				// Restart Song
				_local.stopMusic();
				_local.playMusic();
			} else if ((_PlayListEditor.songList.selectedIndex == (_PlayListEditor.songList.length-1)) && repeat_all_bool == true) {
				// If last song, restart at top
				var url = _PlayListEditor.songList.getItemAt(1).attributes.data;
				_PlayListEditor.songList.selectedNode = _PlayListEditor.songList.getNodeDisplayedAt(1);
				_local.loadMusic(url);
			} else if (_PlayListEditor.songList.selectedIndex != (_PlayListEditor.songList.length-1)) {
				// If not last song, goto next song
				_local.changeSong(1);
			} else {
				// Stop Music
				_local.stopMusic();
			}
		};
		Sound_Obj.onLoad = function(success) {
			if (success) {
				currentPos = Sound_Obj.position;
				songInit = true;
			} else {
				_Player.tf_Title.text = "ERROR - Failed To Load Track.";
			}
		};
		Sound_Obj.onID3 = function() {
			for (var prop in this.id3) {
				//trace(prop+" : "+this.id3[prop]);
			}
			_local.setTimer();
			_local.resetTitle();
			if (!songtickerInterval) {
				songtickerInterval = setInterval(_local.updateTitle, 100);
			}
		};
		////////////////////////////////////////////////////////////////////
		// Load Saved Settings
		////////////////////////////////////////////////////////////////////
		/* Repeat Settings */
		switch (openSO("repeat_setting")) {
		case undefined :
			trace("No saved 'Repeat' Settings");
			break;
		case "repeat_all" :
			repeat_all_bool = false;
			repeat_track_bool = false;
			toggleRepeat();
			break;
		case "repeat_track" :
			repeat_all_bool = true;
			repeat_track_bool = false;
			toggleRepeat();
			break;
		default :
			trace("Can't Load Repeat_Setting SO");
		}
		/* Volume Settings */
		var temp_so = openSO("volume_setting");
		if (temp_so != undefined) {
			Sound_Obj.setVolume(temp_so);
			_Player.volume_mc.progress_bar._xscale = temp_so;
			_Player.volume_mc.slider._x = Math.round((temp_so/100)*(_Player.volume_mc.progress_groove._width-18));
			currentVolume = temp_so;
		} else {
			currentVolume = 100;
		}
		/* Player Position */
		var temp_so = openSO("player_pos_setting", "xPos");
		if (temp_so != undefined) {
			_Player._x = openSO("player_pos_setting", "xPos");
			_Player._y = openSO("player_pos_setting", "yPos");
		}
		/* Playlist Editor Settings */ 
		var temp_so = openSO("playlisteditor_setting", "xPos");
		if (temp_so != undefined) {
			_PlayListEditor._x = openSO("playlisteditor_setting", "xPos");
			_PlayListEditor._y = openSO("playlisteditor_setting", "yPos");
		}
		var temp_so = openSO("playlisteditor_setting", "display");
		if (temp_so != undefined) {
			_Player.MP3List = temp_so;
			_Player.MLPL_mc.PL_Icon._visible = temp_so;
			_PlayListEditor._visible = temp_so;
		}
		var temp_so = openSO("playlisteditor_setting", "buffTime");
		if (temp_so != undefined) {
			_soundbuftime = temp_so;
			_PlayListEditor.buffer_txt.text = temp_so;
		}
		delete temp_so;
		////////////////////////////////////////////////////////////////////
		// Init ToolTip
		////////////////////////////////////////////////////////////////////
		mouseListener = new Object();
		myTextFormat = new TextFormat();
		myTextFormat.align = "Left";
		myTextFormat.font = "Tw Cen MT";
		myTextFormat.size = 12;
		myTextFormat.indent = 1;
		mouseListener.onMouseMove = function() {
			// Set ToolTip Position
			// Extra "4" added to aide in tooltip disappearing after rolling off
			_local.tool_mc._x = _root._xmouse+_local.tool_mc.background_mc._width/2;
			_local.tool_mc._y = _root._ymouse+_local.tool_mc.background_mc._height/2+20;
			updateAfterEvent();
		};
		////////////////////////////////////////////////////////////////////
		// Init Mute Button
		////////////////////////////////////////////////////////////////////
		_Player.Mute_mc.mute_off.onRollOver = _Player.Mute_mc.mute_on.onRollOver=function () {
			addToolTip("Toggle Mute");
		};
		_Player.Mute_mc.mute_off.onRollOut = _Player.Mute_mc.mute_on.onRollOut=function () {
			removeToolTip();
		};
		_Player.Mute_mc.mute_off._visible = false;
		_Player.Mute_mc.mute_on.onRelease = function() {
			_local.toggleMute(true);
			_local.changeTitle("MUTE ON");
			this._visible = false;
			_parent.mute_off._visible = true;
		};
		_Player.Mute_mc.mute_off.onRelease = function() {
			_local.toggleMute(false);
			_local.changeTitle("MUTE OFF");
			this._visible = false;
			_parent.mute_on._visible = true;
		};
		////////////////////////////////////////////////////////////////////
		// Init Pause
		////////////////////////////////////////////////////////////////////
		_Player.btn_Pause.onRollOver = function() {
			addToolTip("Pause");
		};
		_Player.btn_Pause.onRollOut = function() {
			removeToolTip();
		};
		_Player.btn_Pause.onPress = function() {
			if (currentAction != "Stop") {
				_local.toggleControlIcon(false);
			}
		};
		_Player.btn_Pause.onRelease = function() {
			if (currentAction != "Stop") {
				_local.togglePause();
				_local.toggleControlIcon(true);
			}
		};
		////////////////////////////////////////////////////////////////////
		// Init Play
		////////////////////////////////////////////////////////////////////
		_Player.btn_Play.onRollOver = function() {
			addToolTip("Play");
		};
		_Player.btn_Play.onRollOut = function() {
			removeToolTip();
		};
		_Player.btn_Play.onPress = function() {
			_local.toggleControlIcon(false);
		};
		_Player.btn_Play.onRelease = function() {
			_local.playMusic();
			_local.toggleControlIcon(true);
		};
		////////////////////////////////////////////////////////////////////
		// Init Stop
		////////////////////////////////////////////////////////////////////
		_Player.btn_Stop.onRollOver = function() {
			addToolTip("Stop");
		};
		_Player.btn_Stop.onRollOut = function() {
			removeToolTip();
		};
		_Player.btn_Stop.onPress = function() {
			_local.toggleControlIcon(false);
		};
		_Player.btn_Stop.onRelease = function() {
			_local.stopMusic();
			_local.toggleControlIcon(true);
		};
		////////////////////////////////////////////////////////////////////
		// Init Next
		////////////////////////////////////////////////////////////////////
		_Player.btn_Next.onRollOver = function() {
			addToolTip("Next");
		};
		_Player.btn_Next.onRollOut = function() {
			removeToolTip();
		};
		_Player.btn_Next.onPress = function() {
			_local.toggleControlIcon(false);
		};
		_Player.btn_Next.onRelease = function() {
			_local.changeSong(1);
			_local.toggleControlIcon(true);
		};
		////////////////////////////////////////////////////////////////////
		// Init Previous
		////////////////////////////////////////////////////////////////////
		_Player.btn_Prev.onRollOver = function() {
			addToolTip("Previous");
		};
		_Player.btn_Prev.onRollOut = function() {
			removeToolTip();
		};
		_Player.btn_Prev.onPress = function() {
			_local.toggleControlIcon(false);
		};
		_Player.btn_Prev.onRelease = function() {
			_local.changeSong(-1);
			_local.toggleControlIcon(true);
		};
		////////////////////////////////////////////////////////////////////
		// Init Volume
		////////////////////////////////////////////////////////////////////
		_Player.volume_mc.slider.onRollOver = function() {
			this.gotoAndStop(2);
			addToolTip("Volume");
		};
		_Player.volume_mc.slider.onRollOut = function() {
			this.gotoAndStop(1);
			removeToolTip();
		};
		_Player.volume_mc.slider.onPress = function() {
			_Player.Mute_mc.mute_off._visible = false;
			_Player.Mute_mc.mute_on._visible = true;
			volumeAdjust = true;
			this.gotoAndStop(3);
			volumeInterval = setInterval(_local.updateVolume, 10);
			var bounds_obj:Object = _parent.progress_groove.getBounds(_parent);
			this.startDrag(false, bounds_obj.xMin, this._y, bounds_obj.xMax-17, this._y);
		};
		_Player.volume_mc.slider.onReleaseOutside = _Player.volume_mc.slider.onRelease=function () {
			volumeAdjust = false;
			clearInterval(infoInterval);
			var mask_bounds = _Player.display_mask.getBounds(_Player);
			_Player.tf_Title._x = (((mask_bounds.xMax-mask_bounds.xMin)/2)+mask_bounds.xMin)-(_Player.tf_Title.textWidth/2);
			_local.resetTitle();
			songtickerInterval = setInterval(_local.updateTitle, 100);
			clearInterval(volumeInterval);
			this.gotoAndStop(1);
			this.stopDrag();
		};
		////////////////////////////////////////////////////////////////////
		// Init Timer
		////////////////////////////////////////////////////////////////////
		_Player.btn_Timer.onRelease = function() {
			if (countDown) {
				countDown = false;
			} else {
				countDown = true;
			}
		};
		////////////////////////////////////////////////////////////////////
		// Init Shuffle
		////////////////////////////////////////////////////////////////////
		_Player.display_shuffle.onRelease = _Player.btn_Shuffle.onRelease=function () {
			_local.toggleShuffle();
		};
		_Player.display_shuffle.onRollOver = _Player.btn_Shuffle.onRollOver=function () {
			addToolTip("Toggle Playlist Shuffling");
		};
		_Player.display_shuffle.onRollOut = _Player.btn_Shuffle.onRollOut=function () {
			removeToolTip();
		};
		////////////////////////////////////////////////////////////////////
		// Init Repeat
		////////////////////////////////////////////////////////////////////
		_Player.display_repeat.onRollOver = _Player.Repeat_mc.btn_Repeat_All.onRollOver=_Player.Repeat_mc.btn_Repeat_Track.onRollOver=function () {
			addToolTip("Toggle Playlist/Song Repeating");
		};
		_Player.display_repeat.onRollOut = _Player.Repeat_mc.btn_Repeat_All.onRollOut=_Player.Repeat_mc.btn_Repeat_Track.onRollOut=function () {
			removeToolTip();
		};
		_Player.display_repeat.onRelease = function() {
			_local.toggleRepeat();
			if (repeat_track_bool) {
				_Player.Repeat_mc.btn_Repeat_All._visible = false;
				_Player.Repeat_mc.btn_Repeat_Track._visible = true;
			} else {
				_Player.Repeat_mc.btn_Repeat_Track._visible = false;
				_Player.Repeat_mc.btn_Repeat_All._visible = true;
			}
		};
		_Player.Repeat_mc.btn_Repeat_All.onRelease = function() {
			_local.toggleRepeat();
			if (repeat_track_bool) {
				this._visible = false;
				_parent.btn_Repeat_Track._visible = true;
			}
		};
		_Player.Repeat_mc.btn_Repeat_Track.onRelease = function() {
			_local.toggleRepeat();
			this._visible = false;
			_parent.btn_Repeat_All._visible = true;
		};
		////////////////////////////////////////////////////////////////////
		// Init Media Library / Play List MC
		////////////////////////////////////////////////////////////////////
		_Player.MLPL_mc.open_files.onRollOver = function() {
			addToolTip("Open File(s)");
		};
		_Player.MLPL_mc.open_files.onRollOut = function() {
			removeToolTip();
		};
		_Player.MLPL_mc.open_files.onRelease = function() {
			_local.toggleM3UList();
		};
		_Player.MLPL_mc.play_list.onRollOver = function() {
			_Player.MLPL_mc.PL_Icon._visible = false;
			addToolTip("Playlist Editor");
		};
		_Player.MLPL_mc.play_list.onRollOut = function() {
			if (_Player.MP3List == true) {
				_Player.MLPL_mc.PL_Icon._visible = true;
			}
			removeToolTip();
		};
		_Player.MLPL_mc.play_list.onRelease = function() {
			_local.toggleMP3List();
		};
		_Player.MLPL_mc.media_library.onRollOver = function() {
			addToolTip("Media Library");
		};
		_Player.MLPL_mc.media_library.onRollOut = function() {
			removeToolTip();
		};
		////////////////////////////////////////////////////////////////////
		// Init Title Bar - Player
		////////////////////////////////////////////////////////////////////
		_Player.title_bar.onPress = function() {
			_local.selectWindow(_Player);
			_Player.startDrag();
		};
		_Player.title_bar.onRelease = function() {
			_Player.stopDrag();
			var posObj = new Object();
			posObj.xPos = _Player._x;
			posObj.yPos = _Player._y;
			_local.saveSO("player_pos_setting", posObj);
		};
		_Player.minimize_btn.onRollOver = function() {
			addToolTip("Minimize FlashAmp");
		};
		_Player.minimize_btn.onRollOut = function() {
			removeToolTip();
		};
		_Player.windowshade_btn.onRollOver = function() {
			addToolTip("Windowshade Mode");
		};
		_Player.windowshade_btn.onRollOut = function() {
			removeToolTip();
		};
		_Player.close_btn.onRollOver = function() {
			addToolTip("Exit FlashAmp");
		};
		_Player.close_btn.onRollOut = function() {
			removeToolTip();
		};
		_Player.info_btn.onRollOver = function() {
			addToolTip("Main Menu");
		};
		_Player.info_btn.onRollOut = function() {
			removeToolTip();
		};
		////////////////////////////////////////////////////////////////////
		// Init Title Bar - Playlist Editor
		////////////////////////////////////////////////////////////////////
		_PlayListEditor.title_bar.onPress = function() {
			_local.selectWindow(_PlayListEditor);
			_PlayListEditor.startDrag();
		};
		_PlayListEditor.title_bar.onRelease = function() {
			_PlayListEditor.stopDrag();
			var posObj = new Object();
			posObj.xPos = _PlayListEditor._x;
			posObj.yPos = _PlayListEditor._y;
			_local.saveSO("playlisteditor_setting", posObj);
		};
		_PlayListEditor.windowshade_btn.onRollOver = function() {
			addToolTip("Windowshade Mode");
		};
		_PlayListEditor.windowshade_btn.onRollOut = function() {
			removeToolTip();
		};
		_PlayListEditor.close_btn.onRollOver = function() {
			addToolTip("Close Window");
		};
		_PlayListEditor.close_btn.onRollOut = function() {
			removeToolTip();
		};
		_PlayListEditor.close_btn.onPress = function() {
			_local.selectWindow(_PlayListEditor);
		};
		_PlayListEditor.close_btn.onRelease = function() {
			_local.toggleMP3List();
		};
		_PlayListEditor.info_btn.onRollOver = function() {
			addToolTip("Main Menu");
		};
		_PlayListEditor.info_btn.onRollOut = function() {
			removeToolTip();
		};
		_PlayListEditor.buffer_txt.restrict = "0-9";
		_PlayListEditor.buffer_txt.onChanged = function() {
			if (_PlayListEditor.buffer_txt.length>0) {
				_soundbuftime = _PlayListEditor.buffer_txt.text;
				trace("Changed: "+_PlayListEditor.buffer_txt.text);
				var posObj = new Object();
				posObj.buffTime = Number(_PlayListEditor.buffer_txt.text);
				_local.saveSO("playlisteditor_setting", posObj);
			} else {
				_PlayListEditor.buffer_txt.text = _soundbuftime;
			}
		};
		////////////////////////////////////////////////////////////////////
		// Init Misc
		////////////////////////////////////////////////////////////////////
		_Player.Config_mc.onRollOver = function() {
			addToolTip("Open Configuration Drawer");
		};
		_Player.Config_mc.onRollOut = function() {
			removeToolTip();
		};
		////////////////////////////////////////////////////////////////////
		// Init Pop Up Menus
		////////////////////////////////////////////////////////////////////
		_local.remove_obj = new Object();
		addNode(_local.remove_obj, "removeSelected", "Remove Selected  Delete");
		addNode(_local.remove_obj, "cropSelected", "Crop Selected    Ctrl+Delete");
		addNode(_local.remove_obj, "clearPlaylist", "Clear Playlist   Ctrl+Shift+Delete");
		var removeBranch = addNode(_local.remove_obj, "remove", "Remove...", true);
		addNode(removeBranch, "removeMissing", "Remove missing files from playlist  Alt+Delete");
		addNode(removeBranch, "removePhysical", "Physically remove selected file(s)");
		addNode(removeBranch, "removeDuplicate", "Remove Duplicate Entries            Shift+Delete");
		//
		_local.add_obj = new Object();
		addNode(_local.add_obj, "addFile", "Add file(s)   L");
		addNode(_local.add_obj, "addFolder", "Add folder   Shift+L");
		addNode(_local.add_obj, "addURL", "Add URL     Ctrl+L");
		//
		_local.sel_obj = new Object();
		addNode(_local.sel_obj, "selectAll", "Select all              Ctrl+A");
		addNode(_local.sel_obj, "selectNone", "Select none");
		addNode(_local.sel_obj, "selectInverse", "Invert selection   Ctrl+I");
		//
		_local.manage_obj = new Object();
		addNode(_local.manage_obj, "refreshDirectory", "Refresh Directory");
		////////////////////////////////////////////////////////////////////
		// Init Playlist Editor - Add/Rem/Select/Misc/Manage
		////////////////////////////////////////////////////////////////////
		_PlayListEditor.add_btn.onRelease = function() {
			_local.showMenu(_PlayListEditor.addMenu);
		};
		_PlayListEditor.rem_btn.onRelease = function() {
			_local.showMenu(_PlayListEditor.remMenu);
		};
		_PlayListEditor.sel_btn.onRelease = function() {
			_local.showMenu(_PlayListEditor.selMenu);
		};
		_PlayListEditor.manage_btn.onRelease = function() {
			_local.showMenu(_PlayListEditor.manageMenu);
		};
		initMenu();
		attachMenu("remMenu", _local.remove_obj, _PlayListEditor.rem_btn, "none", "above");
		attachMenu("addMenu", _local.add_obj, _PlayListEditor.add_btn, "none", "above");
		attachMenu("selMenu", _local.sel_obj, _PlayListEditor.sel_btn, "none", "above");
		attachMenu("manageMenu", _local.manage_obj, _PlayListEditor.manage_btn, "none", "above");
		/* Add Menu */
		// Add File
		_local.add_obj.addFile.target.onRelease = function() {
			fileRef.browse(allTypes);
		};
		_local.popupLoading_mc.title_bar.onPress = function() {
			_local.selectWindow(_local.popupLoading_mc);
			_local.popupLoading_mc.startDrag();
		};
		_local.popupLoading_mc.title_bar.onRelease = function() {
			_local.popupLoading_mc.stopDrag();
		};
		// Add Folder
		_local.add_obj.addFolder.target.onRelease = function() {
			//
		};
		// Add URL
		_local.add_obj.addURL.target.onRelease = function() {
			if (_local.popupwindow_mc._visible == false) {
				_local.popUpWindow();
			}
		};
		_local.popupwindow_mc.title_bar.onPress = function() {
			_local.selectWindow(_local.popupwindow_mc);
			_local.popupwindow_mc.startDrag();
		};
		_local.popupwindow_mc.title_bar.onRelease = function() {
			_local.popupwindow_mc.stopDrag();
		};
		/* Remove Menu */
		// Remove Selected
		_local.remove_obj.removeSelected.target.onRelease = function() {
			_PlayListEditor.songList.removeItemAt(_PlayListEditor.songList.selectedIndex);
		};
		// Crop Selected
		_local.remove_obj.cropSelected.target.onRelease = function() {
			var selIndices = _PlayListEditor.songList.selectedIndices;
			for (var i in _PlayListEditor.songList) {
				for (var j in selIndices) {
					if (_PlayListEditor.songList[i] != selIndices[j]) {
						_PlayListEditor.songList.removeItemAt(i);
					}
				}
			}
		};
		// Clear Playlist
		_local.remove_obj.clearPlaylist.target.onRelease = function() {
			_PlayListEditor.songList.removeAll();
			_rowCount = 0;
		};
		// Remove Missing
		_local.remove_obj.remove.removeMissing.target.onRelease = function() {
			//
		};
		// Remove Physical
		_local.remove_obj.remove.removePhysical.target.onRelease = function() {
			//
		};
		// Remove Duplicate
		_local.remove_obj.remove.removeDuplicate.target.onRelease = function() {
			//
		};
		/* Select Menu */
		// Select All
		_local.sel_obj.selectAll.target.onRelease = function() {
			//
		};
		// Select None
		_local.sel_obj.selectNone.target.onRelease = function() {
			//
		};
		// Select Inverse
		_local.sel_obj.selectInverse.target.onRelease = function() {
			//
		};
		/* Manage Playlist Menu */
		// Refresh Directory
		_local.manage_obj.refreshDirectory.target.onRelease = function() {
			var temp_lv:LoadVars = new LoadVars();
			temp_lv.onLoad = function(success:Boolean) {				
				if (success) {
					_local.popupProcess_mc.file_txt.text = "Directory Successfully Refreshed.";					
					_local.loadXML("playlists/"+_local.albumName+".m3u", _local.populateSongs, "songs_xml");
					_local.popupProcess_mc.loading_bar.gotoAndStop(101);
					_local.popupProcess_mc.ok_btn.enabled = true;
				} else {
					_local.popupProcess_mc.file_txt.text = "Directory Failed To Refresh.";
					_local.popupProcess_mc.loading_bar.gotoAndStop(101);
					_local.popupProcess_mc.ok_btn.enabled = true;
				}
			};
			_local.popUpProcessWindow();
			_local.popupProcess_mc.file_txt.text = "Refreshing Directory...";
			temp_lv.load("updatePlaylist.cfm");
		};
		_local.popupProcess_mc.title_bar.onPress = function() {
			_local.selectWindow(_local.popupProcess_mc);
			_local.popupProcess_mc.startDrag();
		};
		_local.popupProcess_mc.title_bar.onRelease = function() {
			_local.popupProcess_mc.stopDrag();
		};
		////////////////////////////////////////////////////////////////////
		// Remove Hand Cursor
		////////////////////////////////////////////////////////////////////
		removeHandCursor(_local);
		////////////////////////////////////////////////////////////////////
		// Init File Reference API
		////////////////////////////////////////////////////////////////////
		var allTypes:Array = new Array();
		var imageTypes:Object = new Object();
		imageTypes.description = "Music (*.mp3)";
		imageTypes.extension = "*.mp3";
		allTypes.push(imageTypes);
		//
		fileRefListener = new Object();
		fileRefListener.onSelect = function(file:FileReference):Void  {
			//trace("onSelect: "+file.name);
			if (!file.upload("http://www.coursevector.com/FlashAmp/uploadFile.cfm")) {
				trace("Upload dialog failed to open.");
			}
		};
		fileRefListener.onCancel = function(file:FileReference):Void  {
			//trace("onCancel");
		};
		fileRefListener.onOpen = function(file:FileReference):Void  {
			if (_local.popupLoading_mc._visible == false) {
				_local.popUpLoadWindow();
			}
		};
		fileRefListener.onProgress = function(file:FileReference, bytesLoaded:Number, bytesTotal:Number):Void  {
			var kiloLoaded = Math.floor(bytesLoaded/1000);
			var kiloTotal = Math.floor(bytesTotal/1000);
			_local.popupLoading_mc.file_txt.text = "Upoading: "+file.name+"\n"+kiloLoaded+"k / "+kiloTotal+"k";
			var temp_percent = Math.floor((bytesLoaded*100)/bytesTotal);
			_local.popupLoading_mc.loading_bar.gotoAndStop(temp_percent);
			_local.popupLoading_mc.ok_btn.enabled = false;
			_local.popupLoading_mc.cancel_btn.enabled = true;
		};
		fileRefListener.onComplete = function(file:FileReference):Void  {
			_local.popupLoading_mc.file_txt.text = file.name+" uploaded successfully!";
			var newSong = file.name.substr(0, file.name.length-4);
			_rowCount++;
			_PlayListEditor.songList.addTreeNode(_rowCount+". "+newSong, "http://www.coursevector.com/flashamp/songs/"+file.name);
			_local.popupLoading_mc.ok_btn.enabled = true;
			_local.popupLoading_mc.cancel_btn.enabled = false;
		};
		fileRefListener.onHTTPError = function(file:FileReference, httpError:Number):Void  {
			_local.popupLoading_mc.file_txt.text = "HTTP Error:\n"+file.name+" - "+httpError;
			_local.popupLoading_mc.ok_btn.enabled = true;
			_local.popupLoading_mc.cancel_btn.enabled = false;
		};
		fileRefListener.onIOError = function(file:FileReference):Void  {
			_local.popupLoading_mc.file_txt.text = "I/O Error:\n"+file.name;
			_local.popupLoading_mc.ok_btn.enabled = true;
			_local.popupLoading_mc.cancel_btn.enabled = false;
		};
		fileRefListener.onSecurityError = function(file:FileReference, errorString:String):Void  {
			_local.popupLoading_mc.file_txt.text = "Security Error:\n"+file.name+" - "+errorString;
			_local.popupLoading_mc.ok_btn.enabled = true;
			_local.popupLoading_mc.cancel_btn.enabled = false;
		};
		//
		fileRef = new FileReference();
		fileRef.addListener(fileRefListener);
	}
	//////////////////////
	//
	//
	//
	// Public Functions //
	//
	//
	//
	//////////////////////
	/* Load Music */
	public function loadMusic(song:String):Void {
		songInit = false;
		Sound_Obj.start(0);
		Sound_Obj.stop();
		Sound_Obj.loadSound(song, true);
		Sound_Obj.setVolume(currentVolume);
		if (currentVolume) {
			Sound_Obj.setVolume(currentVolume);
		}
		currentVolume = Sound_Obj.getVolume();
		currentAction = "Play";
		_local.toggleControlIcon(true);
		_Player.tf_Timer.text = "00:00";
		trackInterval = setInterval(updatePlayer, 100);
	}
	/* Play Music */
	public function playMusic():Void {
		if (currentAction == "Pause") {
			togglePause();
		} else if (currentAction == "Stop" || currentAction == "Play" || currentAction == "Loading") {
			Sound_Obj.start(0);
		}
		Sound_Obj.setVolume(currentVolume);
		currentAction = "Play";
		trackInterval = setInterval(updatePlayer, 100);
	}
	/* Stop Music */
	public function stopMusic():Void {
		currentAction = "Stop";
		clearInterval(trackInterval);
		Sound_Obj.stop();
		_Player.track_mc.progress._xscale = 0;
		//_Player.track_mc.load_progress._xscale = 0;
		_Player.track_mc.slider._x = _Player.track_mc.progress._width;
		currentPos = 0;
		_Player.tf_Timer.text = "00:00";
	}
	/* Next/Previous Song */
	public function changeSong(dir:Number):Void {
		currentAction = "Change";
		if (dir<0) {
			var changeSong = _PlayListEditor.songList.selectedIndex-1;
		} else if (dir>0) {
			var changeSong = _PlayListEditor.songList.selectedIndex+1;
		}
		var url = _PlayListEditor.songList.getItemAt(changeSong).attributes.data;
		if (url) {
			_PlayListEditor.songList.selectedNode = _PlayListEditor.songList.getNodeDisplayedAt(changeSong);
			Sound_Obj.stop();
			_local.loadMusic(url);
		}
	}
	///////////////////////
	//
	//
	//
	// Private Functions //
	//
	//
	//
	///////////////////////
	//////////////
	/* Load XML */
	//////////////
	private function loadXML(XMLFile:String, callBack:Function, returnVar:String):Void {
		_local[returnVar] = new XML();
		_local[returnVar].ignoreWhite = true;
		_local[returnVar].load(XMLFile);
		_local[returnVar].onLoad = callBack;
	}
	function change(event:Object) {
		if (_PlayListEditor.songList == event.target) {
			var node = _PlayListEditor.songList.selectedItem;
			// If this is a branch, expand/collapse it
			if (_PlayListEditor.songList.getIsBranch(node)) {
				_PlayListEditor.songList.setIsOpen(node, !_PlayListEditor.songList.getIsOpen(node), true);
			}
			var url = node.attributes.data;
			if (url) {
				_local.loadMusic(url);
			}
		}
		if (_OpenFiles == event.target) {
			var node = _OpenFiles.selectedItem;
			// If this is a branch, expand/collapse it
			if (_OpenFiles.getIsBranch(node)) {
				_OpenFiles.setIsOpen(node, !_OpenFiles.getIsOpen(node), true);
			}
			// If this is a hyperlink, jump to it   
			var playlist = node.attributes.label;
			if (playlist) {
				_local.albumName = substring(playlist, 0, playlist.length-4);
				_local.loadXML("playlists/"+playlist, _local.populateSongs, "songs_xml");
			}
		}
	}
	function doubleClick(event:Object) {
		if (_PlayListEditor.songList == event.target) {
			var node = _PlayListEditor.songList.selectedItem;
			// If this is a branch, expand/collapse it
			if (_PlayListEditor.songList.getIsBranch(node)) {
				_PlayListEditor.songList.setIsOpen(node, !_PlayListEditor.songList.getIsOpen(node), true);
			}
			var url = node.attributes.data;
			if (url) {
				_local.loadMusic(url);
			}
		}
		if (_OpenFiles == event.target) {
			var node = _OpenFiles.selectedItem;
			// If this is a branch, expand/collapse it
			if (_OpenFiles.getIsBranch(node)) {
				_OpenFiles.setIsOpen(node, !_OpenFiles.getIsOpen(node), true);
			}
			// If this is a hyperlink, jump to it   
			var playlist = node.attributes.label;
			if (playlist) {
				_local.albumName = substring(playlist, 0, playlist.length-4);
				_local.loadXML("playlists/"+playlist, _local.populateSongs, "songs_xml");
			}
		}
	}
	/* onLoad handler for XML data */
	/////////////////////////////////
	private function populateSongs() {
		_PlayListEditor.songList.removeAll();
		_local.songs_xml = _local.parseM3U(_local.songs_xml);
		var temp_xml = new XML(_local.songs_xml);
		var song_array = temp_xml.firstChild.childNodes;
		_rowCount = song_array.length;
		for (var i = 0; i<song_array.length; i++) {
			_PlayListEditor.songList.addTreeNode((i+1)+". "+song_array[i].attributes.label, song_array[i].attributes.data);
		}
		//_PlayListEditor.songList.dataProvider = _local.songs_xml;
		_PlayListEditor.songList.refresh();
		_PlayListEditor.songList.addEventListener("change", _local.change);
	}
	/* onLoad handler for XML data */
	/////////////////////////////////
	private function populatePlayList() {
		_OpenFiles.dataProvider = _local.playList_xml;
		_OpenFiles.addEventListener("change", _local.change);
	}
	/* Remove Hand Cursor */
	////////////////////////
	private function removeHandCursor(mc):Void {
		for (var i in mc) {
			if (typeof (mc[i]) == "movieclip" || typeof (mc[i]) == "object") {
				mc[i].useHandCursor = false;
				_local.removeHandCursor(mc[i]);
			}
		}
		break;
	}
	/* Select Window */
	///////////////////
	private function selectWindow(window_mc:MovieClip):Void {
		window_mc.swapDepths(_local.getNextHighestDepth());
		var a = 50;
		for (var i in _local) {
			_local[i].info_btn._alpha = a;
			_local[i].windowshade_btn._alpha = a;
			_local[i].close_btn._alpha = a;
			_local[i].minimize_btn._alpha = a;
			_local[i].title_bar.window_title._alpha = a;
			_local[i].title_bar.left_line._alpha = a;
			_local[i].title_bar.right_line._alpha = a;
		}
		window_mc.info_btn._alpha = 100;
		window_mc.windowshade_btn._alpha = 100;
		window_mc.close_btn._alpha = 100;
		window_mc.minimize_btn._alpha = 100;
		window_mc.title_bar.window_title._alpha = 100;
		window_mc.title_bar.left_line._alpha = 100;
		window_mc.title_bar.right_line._alpha = 100;
	}
	/* Pop Up Window */
	private function popUpWindow() {
		_local.popupwindow_mc.submit_btn.onRelease = function() {
			if (_local.popupwindow_mc.newURL.text != "") {
				var url = _local.popupwindow_mc.newURL.text;
				var url_array = url.split("/");
				var title = url_array[url_array.length-1];
				_PlayListEditor.songList.addTreeNode(title, url);
				_local.popupwindow_mc._visible = false;
				_local.popupwindow_mc.newURL.text = "";
			} else {
				_local.popupwindow_mc.cancel_btn.onRelease();
			}
		};
		_local.popupwindow_mc.cancel_btn.onRelease = function() {
			_local.popupwindow_mc._visible = false;
			_local.popupwindow_mc.newURL.text = "";
			_local.selectWindow(_PlayListEditor);
			_Player.disabler_btn._visible = false;
			_PlayListEditor.disabler_btn._visible = false;
		};
		_Player.disabler_btn._visible = true;
		_PlayListEditor.disabler_btn._visible = true;
		_local.selectWindow(_local.popupwindow_mc);
		_local.popupwindow_mc._visible = true;
	}
	private function popUpLoadWindow() {
		_local.popupLoading_mc.ok_btn.onRelease = function() {
			_local.popupLoading_mc._visible = false;
			_local.popupLoading_mc.file_txt.text = "";
			_local.selectWindow(_PlayListEditor);
			_Player.disabler_btn._visible = false;
			_PlayListEditor.disabler_btn._visible = false;
		};
		_local.popupLoading_mc.cancel_btn.onRelease = function() {
			fileRef.cancel();
			_local.popupLoading_mc._visible = false;
			_local.popupLoading_mc.file_txt.text = "";
			_local.selectWindow(_PlayListEditor);
			_Player.disabler_btn._visible = false;
			_PlayListEditor.disabler_btn._visible = false;
		};
		_local.popupLoading_mc.ok_btn.enabled = false;
		_Player.disabler_btn._visible = true;
		_PlayListEditor.disabler_btn._visible = true;
		_local.selectWindow(_local.popupLoading_mc);
		_local.popupLoading_mc._visible = true;
	}
	private function popUpProcessWindow() {
		_local.popupProcess_mc.ok_btn.onRelease = function() {
			_local.popupProcess_mc._visible = false;
			_local.popupProcess_mc.file_txt.text = "";
			_local.selectWindow(_PlayListEditor);
			_Player.disabler_btn._visible = false;
			_PlayListEditor.disabler_btn._visible = false;
		};
		_local.popupProcess_mc.ok_btn.enabled = false;
		_local.popupProcess_mc.loading_bar.gotoAndStop(100);
		_Player.disabler_btn._visible = true;		
		_PlayListEditor.disabler_btn._visible = true;
		_local.selectWindow(_local.popupProcess_mc);
		_local.popupProcess_mc._visible = true;
	}
	/* Update Player */
	///////////////////
	private function updatePlayer():Void {
		// >> Since this is called as a setInterval, it requires special targeting
		// Progress Bar
		_local.updatePlayHead();
	}
	/* Update Title */
	//////////////////
	private function updateTitle():Void {
		// >> Since this is called as a setInterval, it requires special targeting
		var mask_bounds = _Player.display_mask.getBounds(_Player);
		if (_Player.tf_Title.textWidth>260) {
			if (!songTicker) {
				if ((_Player.tf_Title._x+_Player.tf_Title.textWidth)>mask_bounds.xMax) {
					_Player.tf_Title._x -= 2;
				} else {
					songTicker = true;
				}
			} else {
				if (_Player.tf_Title._x<mask_bounds.xMin) {
					_Player.tf_Title._x += 2;
				} else {
					songTicker = false;
				}
			}
		} else {
			var mask_bounds = _Player.display_mask.getBounds(_Player);
			_Player.tf_Title._x = (((mask_bounds.xMax-mask_bounds.xMin)/2)+mask_bounds.xMin)-(_Player.tf_Title.textWidth/2);
		}
	}
	/* Update Volume */
	///////////////////
	private function updateVolume():Void {
		// >> Since this is called as a setInterval, it requires special targeting
		var pos:Number = Math.round(_Player.volume_mc.slider._x/(_Player.volume_mc.progress_groove._width-18)*100);
		_local.saveSO("volume_setting", pos);
		Sound_Obj.setVolume(pos);
		if (volumeAdjust) {
			_local.changeTitle("VOLUME: "+pos+"%");
		}
		_Player.volume_mc.progress_bar._xscale = pos;
		currentVolume = pos;
	}
	/* Update Play Head */
	//////////////////////
	private function updatePlayHead():Void {
		// Make sure Sound_Obj has init
		var pct:Number = Math.round(Sound_Obj.getBytesLoaded()/Sound_Obj.getBytesTotal()*100);
		_Player.track_mc.load_progress._xscale = pct;
		// If changing volume, stop updating
		if (!volumeAdjust && !infoInterval) {
			_local.resetTitle();
		}
		if (songInit) {
			// Display
			_local.setTimer();
			_Player.track_mc.load_progress._xscale = 0;
			var pos:Number = Math.round(Sound_Obj.position/Sound_Obj.duration*100);
			_Player.track_mc.progress._xscale = pos;
			_Player.track_mc.slider._x = _Player.track_mc.progress._width;
			currentPos = Sound_Obj.position;
		} else {
			_Player.track_mc.progress._xscale = 0;
			_Player.track_mc.slider._x = _Player.track_mc.progress._width;
		}
	}
	/* Update ToolTip */
	////////////////////
	private function updateToolTip(object:Object):Void {
		// Show the ToolTip if the mouse RollOver after set Delay
		if (!object.tool_mc._visible && (getTimer()-lastTime)>(500)) {
			object.tool_mc._visible = true;
			_local.fadeTo(10, 100, object.tool_mc);
			clearInterval(tooltipInterval);
		}
	}
	/* Change Title */
	//////////////////
	private function changeTitle(msg:String):Void {
		clearInterval(songtickerInterval);
		_Player.tf_Title.text = msg;
		var mask_bounds = _Player.display_mask.getBounds(_Player);
		_Player.tf_Title._x = (((mask_bounds.xMax-mask_bounds.xMin)/2)+mask_bounds.xMin)-(_Player.tf_Title.textWidth/2);
		infoTitle = 2;
		clearInterval(infoInterval);
		infoInterval = setInterval(_local.hideInfo, 500);
	}
	/* Hide Info */
	///////////////
	private function hideInfo():Void {
		// >> Since this is called as a setInterval, it requires special targeting
		infoTitle--;
		if (infoTitle<=0) {
			infoTitle = 0;
			clearInterval(infoInterval);
			var mask_bounds = _Player.display_mask.getBounds(_Player);
			_Player.tf_Title._x = (((mask_bounds.xMax-mask_bounds.xMin)/2)+mask_bounds.xMin)-(_Player.tf_Title.textWidth/2);
			_local.resetTitle();
			songtickerInterval = setInterval(_local.updateTitle, 100);
		}
	}
	/* Set Title */
	///////////////
	private function resetTitle():Void {
		if ((Sound_Obj.id3.artist != undefined || Sound_Obj.id3.TPE1 != undefined) && (Sound_Obj.id3.songname != undefined || Sound_Obj.id3.TIT2 != undefined)) {
			var totalSeconds:Number = Sound_Obj.duration/1000;
			var minutes:String = new Number(Math.floor(totalSeconds/60)).toString();
			var seconds:String = new Number(Math.floor(totalSeconds)%60).toString();
			if (seconds<10) {
				seconds = "0"+seconds;
			}
			if (Sound_Obj.id3.artist == undefined) {
				var artist = Sound_Obj.id3.TPE1;
			} else {
				var artist = Sound_Obj.id3.artist;
			}
			if (Sound_Obj.id3.songname == undefined) {
				var songtitle = Sound_Obj.id3.TIT2;
			} else {
				var songtitle = Sound_Obj.id3.songname;
			}
			_Player.tf_Title.text = artist+" - "+songtitle+" ("+minutes+":"+seconds+")";
		} else {
			_Player.tf_Title.text = "No Track Info";
			var mask_bounds = _Player.display_mask.getBounds(_Player);
			_Player.tf_Title._x = (((mask_bounds.xMax-mask_bounds.xMin)/2)+mask_bounds.xMin)-(_Player.tf_Title.textWidth/2);
		}
	}
	/* Set Timer */
	///////////////
	private function setTimer():Void {
		if (countDown) {
			var totalSeconds:Number = (Sound_Obj.duration-Sound_Obj.position)/1000;
		} else {
			var totalSeconds:Number = Sound_Obj.position/1000;
		}
		var minutes:String = new Number(Math.floor(totalSeconds/60)).toString();
		if (minutes<10) {
			minutes = "0"+minutes;
		}
		var seconds:String = new Number(Math.floor(totalSeconds)%60).toString();
		if (seconds<10) {
			seconds = "0"+seconds;
		}
		if (countDown) {
			_Player.tf_Timer.text = "-"+minutes+":"+seconds;
		} else {
			_Player.tf_Timer.text = minutes+":"+seconds;
		}
	}
	/* Toggle M3U List */
	/////////////////////
	private function toggleM3UList():Void {
		if (_OpenFiles._visible) {
			_Player.M3UList = false;
			_OpenFiles._visible = false;
		} else {
			_Player.M3UList = true;
			_OpenFiles._visible = true;
		}
	}
	/* Toggle MP3 List (Play List)*/
	////////////////////////////////
	private function toggleMP3List():Void {
		if (_PlayListEditor._visible) {
			_Player.MP3List = false;
			_Player.MLPL_mc.PL_Icon._visible = false;
			_PlayListEditor._visible = false;
			_local.selectWindow(_Player);
		} else {
			_Player.MP3List = true;
			_Player.MLPL_mc.PL_Icon._visible = true;
			_PlayListEditor._visible = true;
			_local.selectWindow(_PlayListEditor);
		}
		var posObj = new Object();
		posObj.display = _PlayListEditor._visible;
		_local.saveSO("playlisteditor_setting", posObj);
	}
	/* Toggle Mute */
	/////////////////
	private function toggleMute(bool:Boolean):Void {
		if (bool) {
			_Player.changeTitle("MUTE ON");
			_Player.volume_mc.slider._x = 0;
			_Player.volume_mc.progress_bar._xscale = 3;
			Sound_Obj.setVolume(0);
		} else {
			_Player.changeTitle("MUTE OFF");
			_Player.volume_mc.slider._x = Math.round(currentVolume*65/100);
			_Player.volume_mc.progress_bar._xscale = currentVolume;
			Sound_Obj.setVolume(currentVolume);
		}
	}
	/* Toggle Pause */
	//////////////////
	private function togglePause():Void {
		if (currentAction != "Pause") {
			currentAction = "Pause";
			Sound_Obj.stop();
		} else {
			currentAction = "Play";
			Sound_Obj.start(Math.floor(currentPos/1000));
		}
	}
	/* Toggle Shuffle */
	////////////////////
	private function toggleShuffle():Void {
		if (!shuffle_bool) {
			shuffle_bool = true;
			_Player.led_shuffle.gotoAndStop(2);
			_Player.display_shuffle._alpha = 100;
			_local.changeTitle("PLAYLIST SHUFFLING: ON");
			_local.shufflePlaylist(true);
		} else {
			shuffle_bool = false;
			_Player.led_shuffle.gotoAndStop(1);
			_Player.display_shuffle._alpha = 20;
			_local.changeTitle("PLAYLIST SHUFFLING: OFF");
			_local.shufflePlaylist(false);
		}
	}
	/* Toggle Repeat */
	///////////////////
	private function toggleRepeat():Void {
		if (!repeat_all_bool && !repeat_track_bool) {
			repeat_all_bool = true;
			repeat_track_bool = false;
			_Player.led_repeat.gotoAndStop(2);
			_Player.display_repeat._alpha = 100;
			_Player.display_repeat.gotoAndStop(1);
			_local.changeTitle("REPEAT: ALL");
			_local.repeatPlaylist(true, "all");
			_local.deleteSO("repeat_setting");
			_local.saveSO("repeat_setting", "repeat_all");
		} else if (repeat_all_bool && !repeat_track_bool) {
			repeat_all_bool = false;
			repeat_track_bool = true;
			_Player.led_repeat.gotoAndStop(2);
			_Player.display_repeat._alpha = 100;
			_Player.display_repeat.gotoAndStop(2);
			_local.changeTitle("REPEAT: TRACK");
			_local.repeatPlaylist(true, "track");
			_local.deleteSO("repeat_setting");
			_local.saveSO("repeat_setting", "repeat_track");
		} else if (!repeat_all_bool && repeat_track_bool) {
			repeat_all_bool = false;
			repeat_track_bool = false;
			_Player.led_repeat.gotoAndStop(1);
			_Player.display_repeat._alpha = 20;
			_Player.display_repeat.gotoAndStop(1);
			_local.changeTitle("REPEAT: OFF");
			_local.repeatPlaylist(false);
			_local.deleteSO("repeat_setting");
			_local.saveSO("repeat_setting", "repeat_none");
		}
	}
	/* Toggle Control Icon */
	/////////////////////////
	private function toggleControlIcon(bool:Boolean):Void {
		var Control_Array:Array = new Array("Play", "Pause", "Stop");
		for (var i = 0; i<Control_Array.length; i++) {
			_Player[Control_Array[i]+"_Icon"].gotoAndStop(1);
			_Player["display_"+Control_Array[i]]._alpha = 20;
		}
		if (bool) {
			// On
			_Player["display_"+currentAction]._alpha = 100;
			_Player[currentAction+"_Icon"].gotoAndStop(2);
		} else {
			// Off
			_Player[currentAction+"_Icon"].gotoAndStop(1);
		}
	}
	/* Shuffle Play List */
	///////////////////////
	private function shufflePlaylist(bool:Boolean):Void {
		// Shuffle Playlist
	}
	/* Repeat Play List */
	///////////////////////
	private function repeatPlaylist(bool:Boolean, repeatType:String):Void {
		// Shuffle Playlist
	}
	/* Fade To */
	/////////////
	private function fadeTo(speedRate:Number, alphaTarget:Number, obj:MovieClip):Void {
		clearInterval(alphaInterval);
		alphaInterval = setInterval(_local.updateAlpha, 10, speedRate, alphaTarget, obj);
	}
	/* Alpha Increment */
	/////////////////////
	private function updateAlpha(speedRate:Number, alphaTarget:Number, object:MovieClip):Void {
		if (alphaTarget>object._alpha) {
			object._alpha += speedRate;
			if (object._alpha>alphaTarget) {
				object._alpha = alphaTarget;
				clearInterval(alphaInterval);
			}
		} else if (alphaTarget<object._alpha) {
			object._alpha -= speedRate;
			if (object._alpha<alphaTarget) {
				object._alpha = alphaTarget;
				clearInterval(alphaInterval);
			}
		}
	}
	/* Adds ToolTip */
	//////////////////
	private static function addToolTip(msg:String):Void {
		_local.makeToolTip(msg);
		_local.tool_mc._visible = false;
		if (lastTime == 0) {
			lastTime = getTimer();
		}
		Mouse.addListener(mouseListener);
	}
	/* Removes ToolTip */
	/////////////////////
	private static function removeToolTip():Void {
		Mouse.removeListener(mouseListener);
		_local.tool_mc.removeMovieClip();
		clearInterval(tooltipInterval);
		lastTime = 0;
	}
	/* Make ToolTip */
	//////////////////
	private function makeToolTip(msg:String):Void {
		var x0:Number, x1:Number, x2:Number, x3:Number, y0:Number, y1:Number, y2:Number, y3:Number, w:Number, h:Number;
		var textTarget:TextField;
		// Create text Field
		_local.createEmptyMovieClip("tool_mc", 20000);
		_local.tool_mc.createEmptyMovieClip("shadow_mc", 9);
		_local.tool_mc.createEmptyMovieClip("background_mc", 10);
		_local.tool_mc.createTextField("ttText_mc", 11, 0, 0, 9, 9);
		textTarget = _local.tool_mc.ttText_mc;
		// Format Text
		textTarget.autoSize = "left";
		textTarget.multiline = true;
		textTarget.selectable = false;
		textTarget.text = msg;
		textTarget.setTextFormat(myTextFormat);
		textTarget._x = 0-textTarget._width/2;
		textTarget._y = 0-textTarget._height/2;
		// Make Background
		w = textTarget._width+5;
		h = textTarget._height;
		x0 = x3=-w/2;
		x1 = x2=w/2;
		y2 = y3=-h/2;
		y0 = y1=h/2;
		with (_local.tool_mc.background_mc) {
			clear();
			// Does ToolTip Border Show?
			lineStyle(1, 0x000000, 100);
			beginFill(0xFDFDE8, 100);
			moveTo(x0, y0);
			lineTo(x1, y1);
			lineTo(x2, y2);
			lineTo(x3, y3);
			lineTo(x0, y0);
			endFill();
		}
		with (_local.tool_mc.shadow_mc) {
			clear();
			lineStyle(1, 0x000000, 0);
			beginFill(0x000000, 30);
			moveTo(x0, y0);
			lineTo(x1, y1);
			lineTo(x2, y2);
			lineTo(x3, y3);
			lineTo(x0, y0);
			endFill();
			_local.tool_mc.shadow_mc._x = _local.tool_mc.background_mc._x+3;
			_local.tool_mc.shadow_mc._y = _local.tool_mc.background_mc._y+3;
		}
		_local.tool_mc._alpha = 0;
		_local.tool_mc._x = _root._xmouse+_local.tool_mc.background_mc._width/2;
		_local.tool_mc._y = _root._ymouse+_local.tool_mc.background_mc._height/2+20;
		if (tooltipInterval) {
			clearInterval(tooltipInterval);
		}
		tooltipInterval = setInterval(updateToolTip, 10, this);
	}
	/* Parse M3U */
	///////////////
	private function parseM3U(m3u:XML):String {
		var stm:String = unescape(m3u.toString());
		var _TITLEFOUND:Number = 2;
		var _PATHFOUND:Number = 3;
		var returnVar:String = "<node label='"+_local.albumName+"'>";
		var lineBegin = stm.indexOf("\n", stm.indexOf("#EXTM3U", 0))+1;
		//Find BOF and skip it.
		var lineEnd = lineBegin;
		var lineCount:Number = 0;
		var currentLine:String = "";
		var titleBuffer;
		while (lineEnd != -1) {
			lineBegin = (lineCount == 0) ? 0 : lineEnd+1;
			lineEnd = stm.indexOf("\n", lineEnd+1);
			currentLine = stm.substring(lineBegin, lineEnd-1);
			//tokenize by carriage return :-)
			lineCount++;
			var hasTitle = (currentLine.indexOf("#EXTINF", 0) != -1);
			if (hasTitle) {
				var totalseconds = currentLine.substring(currentLine.indexOf(":", 0)+1, currentLine.indexOf(",", 0));
				var minutes = Math.floor(totalseconds/60);
				var seconds = totalseconds-minutes*60;
				if (minutes<10) {
					minutes = "0"+minutes;
				}
				if (seconds<10) {
					seconds = "0"+seconds;
				}
				titleBuffer = currentLine.substring(currentLine.indexOf(",", 0)+1, currentLine.length);
			} else {
				if (currentLine.length>1) {
					returnVar += "<node label='"+titleBuffer+"' data='"+currentLine+"'/>";
				}
			}
		}
		returnVar += "</node>";
		return returnVar;
	}
	/* Draw Box */
	//////////////
	private function drawBox(h, w, mc, lineColor, lineSize, fillColor, alpha) {
		// 10, 10, this, 0x000000, 2, 0xFDFDE8, 100
		var x0 = 0;
		var x1 = w;
		var y0 = 0;
		var y1 = h;
		mc.clear();
		mc.lineStyle(1, lineColor, alpha+25);
		mc.beginFill(fillColor, alpha);
		mc.moveTo(x0, y0);
		mc.lineTo(x1, y0);
		mc.lineTo(x1, y1);
		mc.lineTo(x0, y1);
		mc.lineTo(x0, y0);
		mc.endFill();
	}
	/* Draw Triangle */
	///////////////////
	private function drawTriangle(h, w, mc, lineColor, lineSize, fillColor, alpha) {
		// 10, 10, this, 0x000000, 2, 0xFDFDE8, 100
		var x0 = 0;
		var x1 = w;
		var y0 = 0;
		var y1 = h/2;
		var y2 = h;
		mc.clear();
		mc.lineStyle(1, lineColor, alpha+25);
		mc.beginFill(fillColor, alpha);
		mc.moveTo(x0, y0);
		mc.lineTo(x1, y1);
		mc.lineTo(x0, y2);
		mc.lineTo(x0, y0);
		mc.endFill();
	}
	/////////////////////////////////////////////////////////////////////////////////////
	/* Pop Up Menu Functions                                                           */
	/////////////////////////////////////////////////////////////////////////////////////
	/* Init Menu */
	///////////////
	private function initMenu() {
		_global.menu_array = new Array();
		/* When you click the mouse, check to see if the cursor is within 
		the boundaries of the Stage. If so, increment the number of shots. */
		_local.mouseListener2 = new Object();
		_local.mouseListener2.onMouseDown = function() {
			for (var i in _global.menu_array) {
				var hide = true;
				// Cycle thru all children in menu
				hide = _local.checkChildren(_global.menu_array[i]);
				// If none were clicked on thruout menu, hide it
				if (hide == true) {
					_local.hideMenu(_global.menu_array[i]);
				}
			}
		};
		Mouse.addListener(_local.mouseListener2);
	}
	/* Check Children */
	////////////////////
	private function checkChildren(menu_mc) {
		for (var i in menu_mc) {
			if (menu_mc[i].hitTest(_xmouse, _ymouse, false)) {
				return false;
			}
			if (menu_mc[i]._name.substr(0, 3) == "sub") {
				if (!checkChildren(menu_mc[i])) {
					return false;
				}
			}
		}
		menu_mc.bg_mc._alpha = 0;
		menu_mc._visible = false;
		return true;
	}
	/* Attach Menu */
	/////////////////
	private function attachMenu(newName, menu_obj, owner, xPos, yPos) {
		var menuRoot = owner._parent.createEmptyMovieClip(newName, owner._parent.getNextHighestDepth()+50);
		var menuBG = owner._parent[newName].createEmptyMovieClip("bgGrey_mc", 5, {_x:0, _y:0});
		if (newName.substr(0, 3) != "sub") {
			_global.menu_array.push(menuRoot);
		}
		var columnY = 4;
		var largestH = 0;
		var largestW = 0;
		var totalHeight = 0;
		var counter = 0;
		for (var i in menu_obj) {
			if (menu_obj[i].label != undefined) {
				if (menu_obj[i].isBranch) {
					var item_targ = addMenuItem(owner._parent[newName], menu_obj[i], counter);
				} else {
					var item_targ = addMenuItem(menuRoot, menu_obj[i], counter);
				}
				counter++;
				item_targ._x = 3;
				item_targ._y = columnY;
				totalHeight += item_targ._height;
				if (item_targ.label_txt.textHeight>largestH) {
					largestH = item_targ.label_txt.textHeight;
				}
				if (item_targ.label_txt.textWidth>largestW) {
					largestW = item_targ.label_txt.textWidth;
				}
				columnY += item_targ.bg_mc._height-1;
				if (menu_obj[i].isBranch) {
					item_targ.ID = i;
					item_targ.hasChildren = true;
					var temp_array = new Array();
					for (var j in menu_obj[i]) {
						temp_array.push(menu_obj[i][j]);
					}
					temp_array.shift();
					attachMenu("sub_"+i, temp_array, item_targ, "right", "none");
					item_targ.onRelease = function() {
						this._parent["sub_"+this.ID]._visible = true;
					};
				}
			}
		}
		counter = 0;
		// Adjust all for widest	
		for (var j in menu_obj) {
			drawBox(largestH+10, largestW+50, menuRoot["item_"+counter].bg_mc, 0xA0BBDC, 3, 0xCCD7E7, 75);
			drawTriangle(10, 5, menuRoot["item_"+counter].arrow_mc, 0x000000, 1, 0x000000, 100);
			menuRoot["item_"+counter].arrow_mc._x = largestW+35;
			menuRoot["item_"+counter].arrow_mc._y = 7;
			counter++;
			if (menuRoot["sub_"+j]) {
				menuRoot["sub_"+j]._x = largestW+50;
			}
		}
		drawBox(totalHeight+4, largestW+56, menuRoot.bgGrey_mc, 0xBABABA, 1, 0xEBEBEB, 100);
		menuRoot._visible = false;
		if (xPos == "left") {
			menuRoot._x = owner._x-menuRoot._width;
		} else if (xPos == "right") {
			menuRoot._x = owner._x+owner._width;
		} else if (xPos == "none") {
			menuRoot._x = owner._x;
		}
		if (yPos == "above") {
			menuRoot._y = owner._y-totalHeight;
		} else if (yPos == "below") {
			menuRoot._y = owner._y+owner._height;
		} else if (yPos == "none") {
			menuRoot._y = owner._y;
		}
	}
	/* Add Menu Item */
	///////////////////
	private function addMenuItem(targ, obj, id) {
		var menuItem = targ.createEmptyMovieClip("item_"+id, id+50);
		menuItem.createTextField("label_txt", 20, 20, 5, 5, 5);
		menuItem.createEmptyMovieClip("bg_mc", 10, {_x:0, _y:0});
		menuItem.label_txt.text = obj.label;
		menuItem.label_txt.autoSize = "left";
		var textFmt = new TextFormat();
		textFmt.font = "_sans";
		menuItem.label_txt.setTextFormat(textFmt);
		drawBox(menuItem.label_txt.textHeight+10, menuItem.label_txt.textWidth+50, menuItem.bg_mc, 0xA0BBDC, 3, 0xCCD7E7, 75);
		menuItem.bg_mc._alpha = 0;
		menuItem.onRollOver = function() {
			this.bg_mc._alpha = 75;
		};
		menuItem.onRollOut = function() {
			this.bg_mc._alpha = 0;
		};
		menuItem.onPress = function() {
			if (!menuItem.isBranch) {
				this.bg_mc._alpha = 0;
				this.onRelease();
				_local.hideMenu(this._parent);
			}
		};
		obj.target = menuItem;
		if (obj.isBranch) {
			menuItem.createEmptyMovieClip("arrow_mc", 30, {_x:0, _y:0});
			drawTriangle(10, 5, menuItem.arrow_mc, 0x000000, 1, 0x000000, 100);
			menuItem.isBranch = obj.isBranch;
		}
		return menuItem;
	}
	/* Show Menu */
	///////////////
	private function showMenu(targ) {
		targ.swapDepths(targ._parent.getNextHighestDepth());
		targ._visible = true;
	}
	/* Hide Menu */
	///////////////
	private function hideMenu(targ) {
		if (targ._name.substr(0, 3) == "sub") {
			hideMenu(targ._parent);
		}
		targ.bg_mc._alpha = 0;
		targ._visible = false;
	}
	/* Add Node */
	//////////////
	private function addNode(parent_obj, obj_name, label_txt, isBranch) {
		parent_obj[obj_name] = new Object();
		parent_obj[obj_name].label = label_txt;
		if (isBranch) {
			parent_obj[obj_name].isBranch = true;
		} else {
			parent_obj[obj_name].isBranch = false;
		}
		return parent_obj[obj_name];
	}
	/////////////////////////////////////////////////////////////////////////////////////
	/* Pop Up Menu Functions                                                           */
	/////////////////////////////////////////////////////////////////////////////////////
	/* Save Shared Object */
	////////////////////////
	private function saveSO(so_name, var_data) {
		var flashamp_so:SharedObject = SharedObject.getLocal(so_name);
		if (typeof (var_data) == "object") {
			var counter = 0;
			for (var i in var_data) {
				if (typeof (i) == "string" && i == var_data[i]) {
					flashamp_so.data[counter] = var_data[i];
					counter++;
				} else {
					flashamp_so.data[i] = var_data[i];
				}
			}
		} else {
			flashamp_so.data.def = var_data;
		}
		flashamp_so.flush();
	}
	/* Open Shared Object */
	////////////////////////
	private function openSO(so_name, var_name) {
		var flashamp_so:SharedObject = SharedObject.getLocal(so_name);
		if (var_name) {
			return flashamp_so.data[var_name];
		} else {
			return flashamp_so.data.def;
		}
	}
	/* Delete Shared Object */
	////////////////////////
	private function deleteSO(so_name) {
		var flashamp_so:SharedObject = SharedObject.getLocal(so_name);
		flashamp_so.clear();
	}
}
