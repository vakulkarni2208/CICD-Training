({
	init : function(component, event, helper) {
		component.set('v.filecolumns', [
            {label: 'File Name', fieldName: 'Title', type: 'text', editable: true },
            {type: "button-icon", initialWidth: 34,
             				typeAttributes: {
                             iconName: 'doctype:image',
                             label: '',
                             name: 'selectRecord',
                             title: 'selectRecord',
                             disabled: false,
                             value: 'test',
                              variant:"bare"
                             }},
           
            //{label: '', fieldName: 'File_Link__c', type: 'url',  editable: false, cellAttributes:{iconName: 'doctype:image'}},    
            //{label: 'File URL', fieldName: 'File_Link__c', type: 'url',  editable: false, cellAttributes:{iconName: {fieldName: 'displayIconName'}}},           
            //{label: 'File URL', fieldName: 'File_Link__c', type: 'url',  editable: false, typeAttributes:{iconName: {fieldName: 'displayIconName'}}},
            //{label: 'File Name', fieldName: 'File_Link__c', type: 'url', typeAttributes:{ label: {fieldName: 'Title', editable: true}}},
            {label: 'File Extension', fieldName: 'FileExtension', type: 'text',  editable: false },
            {label: 'File Size (Bytes)', fieldName: 'ContentSize', type: 'number',  editable: false, cellAttributes: { alignment: 'left' }},
            {label: 'Created By', fieldName: 'Created_By_Formula__c', type: 'text',  editable: false },
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { day: 'numeric',  month: 'numeric', year: 'numeric',  hour: '2-digit',  minute: '2-digit', second: '2-digit', hour12: true},  editable: false }
            
           // {label: 'Id', fieldName: 'Id', type: 'Id',  visible: false }
        ]);
        var pageReference = component.get("v.pageReference");
		component.set("v.caseId", pageReference.state.c__caseId);
		component.set("v.NVBugId", pageReference.state.c__NVBugId);
        var bugId=component.get("v.NVBugId");
		var caseId=component.get("v.caseId");
        var recId;
        if(bugId=='')
            recId=caseId;
        else
            recId=bugId;
		var action=component.get("c.getFilesOnCases");
        action.setParams({"strId":recId});
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state=='SUCCESS' || state=='DRAFT'){
                var responseValue = response.getReturnValue();
                responseValue.forEach(function(record){ 
                    record.displayIconName = 'doctype:image';  
                });
                component.set('v.fileData', responseValue);
            }
    	});
        $A.enqueueAction(action); 
		component.set('v.bugcolumns', [
            {label: 'NVBug', fieldName: 'NVBug_URL__c', type: 'url', editable: false,typeAttributes: {label: { fieldName: 'Name'}} },
            {label: 'Synopsis', fieldName: 'Synopsis__c', type: 'text',  editable: false },
            {label: 'Created By', fieldName: 'Created_By_Formula__c', type: 'text',  editable: false },
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { day: 'numeric',  month: 'numeric', year: 'numeric',  hour: '2-digit',  minute: '2-digit', second: '2-digit', hour12: true},  editable: false },
          //  {label: 'NVBug Link', fieldName: 'NVBug_URL__c', type: 'url',  editable: false }
        ]);
		var action1=component.get("c.getNVBugs");
        action1.setParams({"strCaseId":caseId});
        action1.setCallback(this,function(response){
        	var state = response.getState();
            if(state=='SUCCESS' || state=='DRAFT'){
                var responseValue = response.getReturnValue();
                component.set('v.bugData', responseValue);
            }
    	});
        $A.enqueueAction(action1);         
	},
            
    viewRecord : function(component, event, helper) {
        var recId = event.getParam('row').Id;
        var viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
            	"url": "/" + recId
            });
        viewRecordEvent.fire();
    },
            
    addFileRows : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedFileList" ,event.getParam('selectedRows') );
    },
    addBugRows : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedBugList" ,event.getParam('selectedRows') );
    },
	handleFileSave : function(component, event, helper){
		var draftValues = event.getParam('draftValues');
		var action = component.get("c.updateFileNewName");
        action.setParams({"lstCv":draftValues});
        action.setCallback(this,function(response){
            //$A.get("e.force:closeQuickAction").fire();
            //$A.get('e.force:editRecord').fire();
            //init(component, event, helper);
        });
        var a = component.get('c.init');
        $A.enqueueAction(action);       
        $A.enqueueAction(a);
    },
    Link : function(component, event, helper){
        var selectedFiles = component.get("v.selectedFileList");
        var selectedBugs = component.get("v.selectedBugList");
            if(selectedFiles=='' ||selectedFiles=='undefined'||selectedFiles==null){
            	alert('Please select file');
            	return;
            }
            if(selectedBugs=='' ||selectedBugs=='undefined'||selectedBugs==null){
            	alert('Please select NVBug');
            	return;
            }
		for (var i = 0; i < selectedFiles.length; i++){
            if(selectedFiles[i].ContentSize > 209715200){ //209715200   
        		alert('Maximum file size can be 200 MB.');
            	return;
        	}
    	}            
        var action = component.get("c.linkCaseFilesToNVbug");
        action.setParams({"lstCv":selectedFiles,"lstNVbug":selectedBugs});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state==='SUCCESS' || state==='DRAFT') {
                alert(response.getReturnValue());
            	var closetab = component.get('c.closeFocusedTab');
        		$A.enqueueAction(closetab);
            //$A.get("e.force:closeQuickAction").fire();
            //$A.get('e.force:refreshView').fire();
            }
            else{
                alert("Failed : " + response.getReturnValue());
            }
        });
        var a = component.get('c.handleCancel');
        $A.enqueueAction(action);
        $A.enqueueAction(a);
    },
    handleCancel : function(component, event, helper){
	var closetab = component.get('c.closeFocusedTab');
    $A.enqueueAction(closetab);        
    var recordId=component.get("v.NVBugId");
    if(recordId=='')  
    	recordId=component.get("v.caseId");    
    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
    },
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            //alert(focusedTabId);
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
  
 // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }          

})