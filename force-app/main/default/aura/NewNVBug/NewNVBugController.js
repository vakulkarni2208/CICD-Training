({
	init : function(component, event, helper) {
		var pageReference = component.get("v.pageReference");
		component.set("v.recordId", pageReference.state.c__caseId);
		component.set("v.caseId", pageReference.state.c__caseId);
        
		var caseId=component.get("v.caseId");
		//alert(component.get("v.recordId"));
		
		var action=component.get("c.getPrepopulatedNVBug");
        action.setParams({"strCaseId":caseId});
        action.setCallback(this,function(response){
            
        	var state = response.getState();
            if(state==='SUCCESS' || state==='DRAFT'){
                var responseValue = response.getReturnValue();
                component.set("v.newNVBug", responseValue);
                var newBug = component.get("v.newNVBug");
                component.set("v.refreshFlag", true);
                if(newBug.Product_Category__c=='CUDA'||newBug.Product_Category__c=='GRID'){
                    component.set("v.isGridCudaFlag", true);
                }
            }
		});
		$A.enqueueAction(action);
	},
    handleOnSuccess : function(component, event, helper) {
        var newBug = component.get("v.newNVBug");
        //alert(newBug.Product_Category__c);
        if(newBug.Product_Category__c=='CUDA'||newBug.Product_Category__c=='GRID'){
            component.set("v.isGridCudaFlag", true);
        }

    },
    saveBug1 : function(component, event, helper) {
        event.preventDefault();
        var newBug = component.get("v.newNVBug");
        //alert(newBug.NVBug_Template__c);    
        if(newBug.NVBug_Template__c==null || newBug.NVBug_Template__c=='' || newBug.NVBug_Template__c=== undefined){
            alert( 'Please select NVBug template.');
            return;
        }
        if((newBug.Synopsis__c==null || newBug.Synopsis__c=='' || newBug.Synopsis__c=== undefined)|| newBug.Synopsis__c.length>200){
            alert( 'Synopsis should not be blank or more than 200 characters.');
            return;
        }
        var actionSpinnerON = component.get('c.showSpinner');
        $A.enqueueAction(actionSpinnerON);
        var action = component.get("c.saveNewNVBug");
        action.setParams({"newNVBug": newBug});
        action.setCallback(this, function(response) {
               var state = response.getState();
                if (state==='SUCCESS' || state==='DRAFT') {
                    
                    //alert("success");
                    var responseValue = response.getReturnValue();
                	component.set("v.newNVBug", responseValue);
                    var nvBug = component.get("v.newNVBug");
                    var bugId = nvBug.Id;
                    //alert(bugId);
                    
                    var callOutaction = component.get("c.saveBug");
                    callOutaction.setParams({"newnvbug": nvBug});
                    callOutaction.setCallback(this, function(response) {
                        var nvTicketaction = component.get("c.createNV_Ticket");
                        nvTicketaction.setParams({"nvbg": nvBug});
                        nvTicketaction.setCallback(this, function(response) {
                        });
                        
                        if (state==='SUCCESS' || state==='DRAFT'){
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": bugId,
                                "slideDevName": "detail"
                        	});
                            navEvt.fire();
                            var actionSpinnerOFF = component.get('c.hideSpinner');
                            $A.enqueueAction(actionSpinnerOFF);
                            var closetab = component.get('c.closeFocusedTab');
                            $A.enqueueAction(closetab);
                            var workspaceAPI = component.find("workspace");
                            var tabURL = '#/sObject/'+ bugId + '/view';
                            workspaceAPI.openTab({
                                url: tabURL,
                                focus: true
                            }).then(function(response) {
                                workspaceAPI.focusTab({tabId : response});
                            });
                        } 
                        else{
                            var actionSpinnerOFF = component.get('c.hideSpinner');
                            $A.enqueueAction(actionSpinnerOFF);
	                        alert("Failed to Create Bug in NVBug.");
                        }
                    });    
                    $A.enqueueAction(callOutaction);
                    
                }
               else{
                    var actionSpinnerOFF = component.get('c.hideSpinner');
       				$A.enqueueAction(actionSpinnerOFF);
                    alert("Failed to Save Bug in Salesforce.");
                }
            });
		$A.enqueueAction(action); 
    },
    handleCancel : function(component, event, helper){
	var closetab = component.get('c.closeFocusedTab');
    $A.enqueueAction(closetab);        
    var recordId =component.get("v.recordId");
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