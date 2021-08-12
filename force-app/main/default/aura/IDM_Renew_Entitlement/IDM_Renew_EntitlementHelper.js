({
	renew : function(component, event, helper) {
        var action = component.get("c.RenewEntitlement");
        var id = component.get("v.recordId");
        action.setParam("Id", id);
        action.setCallback(this, function(a){
            var state = a.getState();
            console.log('state-->'+state);
            if (state == "SUCCESS") {
                /*
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/',
                        "isredirect" :false
                    });
                    urlEvent.fire(); 
                    */
                component.set("v.showSuccMessage",true);
            }else{
                component.set("v.showErrMessage",true);
            }
            component.set("v.showConfirmDialog",false);
        });
        $A.enqueueAction(action);        
	}
})