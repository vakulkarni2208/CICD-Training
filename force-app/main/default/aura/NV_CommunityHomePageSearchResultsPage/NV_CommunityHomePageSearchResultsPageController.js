({
	myAction : function(component, event, helper) {
		
	},
    
    doInit: function(component, event, helper) {
        console.log("Search Text: " + component.get("v.searchText"));
        var action = component.get("c.search");
        action.setParams({ searchWord : component.get("v.searchText") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.searchResults",response.getReturnValue());
                console.log(response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action); 
    },
    
    closeModal: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
       // component.set("v.isOpen", false);
    	var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "isOpenAtt" : false });
        cmpEvent.fire();
     }
})