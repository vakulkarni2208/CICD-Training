({
	openModel: function(component, event, helper) {
     	// for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    handleComponentEvent : function(cmp, event) {
        var isOpenAtt = event.getParam("isOpenAtt");

        // set the handler attributes based on event data
        cmp.set("v.isOpen", isOpenAtt);        
    },
})