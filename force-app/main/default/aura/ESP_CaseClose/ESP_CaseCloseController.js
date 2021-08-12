({	init : function(component, event, helper) {
		var caseId=component.get("v.recordId");
		//alert(component.get("v.recordId"));
		
		var action=component.get("c.closeCase");
    	action.setParams({"strCaseId":caseId,"isPageLoad":true});
        action.setCallback(this,function(response){
            
        	var state = response.getState();
            if(state==='SUCCESS' || state==='DRAFT'){
                var responseValue = response.getReturnValue();
                //alert(responseValue);
                component.set("v.isCaseClosedFlag", responseValue);
            }
		});
		$A.enqueueAction(action);
  
	},
	closeCommunityCase : function(component, event, helper) {
		var caseId=component.get("v.recordId");
        //alert(caseId);
        if(confirm('You are about to close this support case, Please Confirm?')){
            var action=component.get("c.closeCase");
            action.setParams({"strCaseId":caseId,"isPageLoad":false});
            action.setCallback(this, function(response) {
                var state = response.getState();
				var caseId=component.get("v.recordId");
                if (state==='SUCCESS' || state==='DRAFT') {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": caseId,
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
                else{
                  alert("Failed");
                }
            }); 
        }
		$A.enqueueAction(action);    
	}
})