({
	init : function(component, event, helper) {
		var pageReference = component.get("v.pageReference");
		component.set("v.recordId", pageReference.state.c__oppId);
		component.set("v.oppId", pageReference.state.c__oppId);
        
		var oppId=component.get("v.oppId");
		//alert(component.get("v.recordId"));
		
		var action=component.get("c.getNV_Ticket");
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state==='SUCCESS' || state==='DRAFT'){
                var responseValue = response.getReturnValue();
                component.set("v.newNVTicket", responseValue);
			}
        });
		$A.enqueueAction(action);
    },

    createCase : function(component, event, helper) {
        event.preventDefault();
        var toastMessageAction = component.get('c.showToast');
        var actionSpinnerOFF = component.get('c.hideSpinner');
        var newNVTicket = component.get("v.newNVTicket");
        var oppId=component.get("v.oppId");
        //alert(newNVTicket.Bug_no_in_NVBug_Not_in_SFDC__c);    
        if(newNVTicket.Bug_no_in_NVBug_Not_in_SFDC__c==null || newNVTicket.Bug_no_in_NVBug_Not_in_SFDC__c=='' || newNVTicket.Bug_no_in_NVBug_Not_in_SFDC__c=== undefined || isNaN(newNVTicket.Bug_no_in_NVBug_Not_in_SFDC__c)){
            component.set("v.message", 'Please enter numeric NVBug number.');
            $A.enqueueAction(actionSpinnerOFF);
            $A.enqueueAction(toastMessageAction);
            return;
        }
        var actionSpinnerON = component.get('c.showSpinner');
        $A.enqueueAction(actionSpinnerON);
        var action = component.get("c.createWinDesignSupportRequestFromOpportunity");
        action.setParams({"nvTicket": newNVTicket,"strOpptyId":oppId});
        action.setCallback(this, function(response) {
               var state = response.getState();
                if (state==='SUCCESS' || state==='DRAFT') {
                    
                    //alert("success");
                    var responseValue = response.getReturnValue();
					//alert(responseValue);
                    if(responseValue==null){
                        component.set("v.message", 'NVBug not found.');
                        $A.enqueueAction(actionSpinnerOFF);
                        $A.enqueueAction(toastMessageAction);
                        return;
                    }
                    else if(responseValue=='NVBug number can not be blank and should be numeric'){
                        component.set("v.message", responseValue);
                        $A.enqueueAction(actionSpinnerOFF);
                        $A.enqueueAction(toastMessageAction);
                        return;
                    }
                	component.set("v.caseId", responseValue);
                    var caseId = component.get("v.caseId");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": caseId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                    $A.enqueueAction(actionSpinnerOFF);
                    var closetab = component.get('c.closeFocusedTab');
                    $A.enqueueAction(closetab);
                    var workspaceAPI = component.find("workspace");
                    var tabURL = '#/sObject/'+ caseId + '/view';
                    workspaceAPI.openTab({
                        url: tabURL,
                        focus: true
                    }).then(function(response) {
                        workspaceAPI.focusTab({tabId : response});
                    });
                }
               else{
       				$A.enqueueAction(actionSpinnerOFF);
                    component.set("v.message", 'Unable to find NVBug. Please check NVBug number or raise Get Help.');
       				$A.enqueueAction(toastMessageAction);                                      
                }
            });
		$A.enqueueAction(action); 
    },
    
    showToast : function(component, event, helper) {
        var strMessage = component.get("v.message");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Opearation Failed",
            "message": strMessage
        });
        toastEvent.fire(); 
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