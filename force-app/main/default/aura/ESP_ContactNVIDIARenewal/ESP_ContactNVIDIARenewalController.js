({
    submitQuery : function(component, event, helper) {
		var subject=component.get("v.Subject");
		var description=component.get("v.Description");
        var action=component.get("c.ESPContactNVIDIARenewalsButton");
        var toastMessageAction = component.get('c.showToast');
        action.setParams({"strSubject":subject,"strDescription":description});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state==='SUCCESS' || state==='DRAFT') {
                var responseValue = response.getReturnValue();
                if(responseValue == 'Success'){
                    component.set("v.message", 'Thanks for your request, Renewals team will  be in touch with you shortly.');
                    component.set("v.title", '');
                    $A.enqueueAction(toastMessageAction);
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/s/"
                    });
                    urlEvent.fire();                    
                }
                else
                {
                    component.set("v.title", 'Operation failed');
                    component.set("v.message", 'Unable to send message. System error.');
                    $A.enqueueAction(toastMessageAction);
                }
            }
            else{
                    component.set("v.title", 'Operation failed');
                    component.set("v.message", 'Unable to send message. System error.');
                    $A.enqueueAction(toastMessageAction);
            }
        }); 
		$A.enqueueAction(action);    
	},
    
    showToast : function(component, event, helper) {
        var strMessage = component.get("v.message");
        var strTitle = component.get("v.title");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": strTitle,
            "message": strMessage
        });
        toastEvent.fire(); 
    }
})