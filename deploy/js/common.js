<!--
	///////////////////////////
	// Show/Hide Layers Page //
	///////////////////////////
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
	/////////////////
	// Reload Page //
	/////////////////
	function MM_reloadPage(init) {  //reloads the window if Nav4 resized
	  if (init==true) with (navigator) {
		  if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
	    	document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage;
		  }
	  } else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
	}
	//Redirect
	function selfDirect(URLStr) {
		self.location = URLStr; 
	}
	///////////////////////
	//Delete confirmation//
	///////////////////////
	// - Delete Multiple
	function confirmSubmit(form, table, client) {
		var agree=confirm("Are you sure you want to delete records "+form.selectedIDs+"?");
		var delID = form.selectedIDs;
		if (agree) {
			parent.location = 'delete.cfm?id=' + delID + '&table=' + table + '&client=' + client;
		} else {
			return false ;
		}
	}
	// - Delete Single
	function confirmSubmit2(delID, name, table, client){
		var agree=confirm("Are you sure you want to delete "+name+"?");
		if (agree) {
			parent.location = 'delete.cfm?id=' + delID + '&table=' + table + '&client=' + client;
		} else {
			return false ;
		}
	}
	//View Client Details
	function viewClient(target) {
		self.location = '../detail/client_detail.cfm?id=' + target + '&sort=Client';
	}
	// View Project Details
	function viewProject(target) {
		self.location = '../detail/project.cfm?id=' + target + '&sort=Priority';
	}
	// View User Details
	function viewUser(target) {
		self.location = '../detail/user.cfm?id=' + target;
	}
	//View Task Details
	function viewTask(target) {
		self.location = '../detail/task.cfm?id=' + target;
	}
	/////////
	// Edit//
	/////////
	function edit(type, target){
		self.location = type+'.cfm?id='+ target;
	}
    //////////
	// Form //
	//////////
	function MM_updateButtons(form, formStr, selectedItems) {
		if (selectedItems == 1) {		
			var checkboxCount = form.checkboxes.length;
			for (i = 0; i < checkboxCount; i++) {
				var checkbox = form.checkboxes[i];
				var temp = eval(formStr+'.check'+checkbox.mName+'.checked');
				if(temp){
					eval(formStr+'.myGlobal.value = '+ checkbox.mName);									
				}
			}
			eval(formStr+'.view_btn.disabled = false');
			eval(formStr+'.edit_btn.disabled = false');
		} else {
			eval(formStr+'.view_btn.disabled = true');
			eval(formStr+'.edit_btn.disabled = true');
		}
		if (selectedItems >= 1) {
			eval(formStr+'.delete_btn.disabled = false');
		} else {
			eval(formStr+'.delete_btn.disabled = true');
		}
	}
	// Remove item from array ( 0-based )	
	function MM_removeNthArrayItem(array, n) {
		var lhs = new Array();		
		if (n > 0){
			lhs = array.slice(0, n);
		}
		var rhs = new Array();		
		if (n < array.length){
			rhs = array.slice(n + 1);
		}
		var result = lhs.concat(rhs);		
		return result;
	}
	// Check for string inside array
	function MM_arrayContainsString(array, item) {
		if (array == null){
			return false;
		}
		var count = array.length;
		for (i = 0; i < count; i++) {
			if (array[i] == item)
				return true;
		}		
		return false;
	}
	// Remove string from within array
	function MM_removeStringFromArray(array, item) {
		if (array == null){
			return null;
		}
		var count = array.length;
		for (i = 0; i < count; i++) {
			if (array[i] == item)
				return MM_removeNthArrayItem(array, i);
		}		
		return array;
	}
	// Select single item
	function MM_toggleItem(form, formStr,itemName, itemID) {
		if (form.selectedItems == null) {
			form.selectedItems = new Array();
			form.selectedIDs = new Array();
		}
		if (MM_arrayContainsString(form.selectedItems, itemName)) {
			form.selectedItems = MM_removeStringFromArray(form.selectedItems, itemName);
			form.selectedIDs = MM_removeStringFromArray(form.selectedIDs, itemID);
			eval(formStr+'.'+itemName+'.checked = false;');
		} else {
			form.selectedItems[form.selectedItems.length] = itemName;
			form.selectedIDs[form.selectedIDs.length] = itemID;
			eval(formStr+'.'+itemName+'.checked = true;');
		}				
		MM_updateButtons(form, formStr, form.selectedItems.length);
	}
	// Select all items
	function MM_selectAllItems(form, formStr) {
		form.selectedItems = new Array();
		form.selectedIDs = new Array();
		if (form.checkboxes) {
			var checkboxCount = form.checkboxes.length;
			for (i = 0; i < checkboxCount; i++) {
				var checkbox = form.checkboxes[i];
				form.selectedItems[form.selectedItems.length] = checkbox.mName;
				form.selectedIDs[form.selectedIDs.length] = checkbox.mName;
				eval(formStr+'.check'+checkbox.mName+'.checked = true;');
			}
		}		
		MM_updateButtons(form, formStr, form.selectedItems.length);		
	}
	// Deselect all items	
	function MM_deselectAllItems(form, formStr) {
		form.selectedItems = new Array();
		form.selectedIDs = new Array();
		if (form.checkboxes) {
			var checkboxCount = form.checkboxes.length;
			for (i = 0; i < checkboxCount; i++) {
				var checkbox = form.checkboxes[i];
				eval(formStr+'.check'+checkbox.mName+'.checked = false;');
			}
		}		
		MM_updateButtons(form, formStr, form.selectedItems.length);		
	}	
	// If all items are selected, deselect all. Otherwise select all.
	function MM_toggleSelectedItems(form, formStr) {
		if (!form.selectedItems){
			form.selectedItems = new Array();
		}
		if (form.checkboxes) {
			if (form.selectedItems.length == form.checkboxes.length){
				eval(formStr+'.check_all.checked = false;');
				MM_deselectAllItems(form, formStr);
			}else{
				eval(formStr+'.check_all.checked = true;');
				MM_selectAllItems(form, formStr);
			}
		}
	}
	// Create checkbox
	function MMCheckbox(name) {
		this.mName = name;
	}
//-->