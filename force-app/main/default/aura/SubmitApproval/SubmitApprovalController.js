({
	   
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuote");
        action.setParams({"quoteId": component.get("v.recordId")});
 		// Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.quote", response.getReturnValue());
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        var recordId = component.get('v.recordId');
        //var pageReference = component.get("v.pageReference");
		//component.set("v.recordId", pageReference.state.recordId);
      
    window.location.href = '/apex/submitQuote?id='+recordId;
    
    },
    
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
 
   likenClose: function(component, event, helper) {
      // Display alert message on the click on the "Like and Close" button from Model Footer 
      // and set set the "isOpen" attribute to "False for close the model Box.
window.location.href = '/apex/submitQuote?id='+v.recordId;
    
       alert('thanks for like Us :)');
      component.set("v.isOpen", false);
   },
    
    recordLoaded: function(component, event, helper) {
    if(!component.get("v.disabled")) {
        helper.showInfo(component);
        component.set("v.disabled", true);
    }
	},
    fireToastEvent : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "It works!",
            "type": "success"
        });
        toastEvent.fire();
    },
})