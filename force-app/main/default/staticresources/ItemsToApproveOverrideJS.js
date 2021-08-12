function addLoadEvent(func) {  
	var oldonload = window.onload;  
	if (typeof window.onload != 'function') {    
		window.onload = func;  
	} 
	else {    
	    window.onload = function() {      
		if (oldonload) {        
			oldonload();      
		}      
		func();    
	    }  
	}
}
function PageLoaded() {  
	var itemsToApproveTitle = document.getElementById("PendingProcessWorkitemsList_title"); 
	if(itemsToApproveTitle != null) {   
		var hasInnerText = (document.getElementsByTagName("body")[0].innerText != undefined) ? true : false; 
		var titleText =''; 
		if(!hasInnerText){ 
			titleText = itemsToApproveTitle.textContent; 
		} 
		else { 
			titleText = itemsToApproveTitle.innerText; 
		}  
		if(titleText == "Items to Approve") {  
		    var columnHeaders = document.getElementsByTagName('th');  
		    for(var i = 0; i < columnHeaders.length; ++i) { 
			if(columnHeaders[i].className == "actionColumn") {  
				columnHeaders[i].style.display = "none";  
				break; 
			}  
		   } 
		   var actionColumnCells = document.getElementsByTagName('td');  
		   for(var j = 0; j < actionColumnCells.length; ++j) {  
			if(actionColumnCells[j].className == "actionColumn") {  
				actionColumnCells[j].style.display = "none";  
			}  
		   } 
		} 
	}   
	var e = document.getElementById("fcf");  
	if(e != null) {    
		var selectedView = e.options[e.selectedIndex].text;     
		if(selectedView == "Items To Approve") {  
			var btnList1 = document.getElementsByName("reassign");    
			if(btnList1.length > 0) {   
				var btnReassign = btnList1[0];   
				btnReassign.style.visibility = "hidden"; 
			}  
			var btnList2 = document.getElementsByName("approve");    
			if(btnList2.length > 0) {   
				var btnApprove = btnList2[0];   
				btnApprove.style.visibility = "hidden"; 
			}
			var columnHeaders = document.getElementsByTagName('th'); 
			for(var i = 0; i < columnHeaders.length; ++i) {    
				if(columnHeaders[i].className == "actionColumn") {        
				    columnHeaders[i].style.display = "none";       
				    break;    
				}   
			}  
			var actionColumnCells = document.getElementsByTagName('td'); 
			for(var j = 0; j < actionColumnCells.length; ++j) {  
				if(actionColumnCells[j].className == "actionColumn") {  
					actionColumnCells[j].style.display = "none";  
				}   
			} 
		}  
	}
        /* Show Manage All button -- requested by Finance has their inbox pending approval list is huge
        var btnList = document.getElementsByName("manageAll"); 
	var btnManageAll = btnList[0]; 
	btnManageAll.style.visibility = "hidden";            
	*/
}  
addLoadEvent(PageLoaded);
var hasInnerText = (document.getElementsByTagName("body")[0].innerText != undefined) ? true : false; 
var headerH2Element =''; 
var headers = document.getElementsByTagName('h2');  
for(var i = 0; i < headers.length; ++i) { 
	var titleText =''; 
	if(!hasInnerText){ 
		titleText = headers[i].textContent; 
	} 
	else { 
		titleText = headers[i].innerText; 
	}  
	if(titleText == "Items to Approve - Override") {
	   headerH2Element = headers[i];
	   break;
	}
}
if(headerH2Element != null) {
   var parentDiv1 = headerH2Element.parentNode;
   var parentDiv2 = parentDiv1.parentNode; 
   parentDiv2.style.display = "none";  
}
console.log('ItemsToApproveOverrideJS - Static resource loaded successfully');