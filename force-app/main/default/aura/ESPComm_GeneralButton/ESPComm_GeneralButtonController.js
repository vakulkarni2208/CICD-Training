({
    navURL : function(component, event, helper) {
        
        //Find the text value of the component with aura:id set to "address"
        var address = component.get("v.custom_link");
        /*var external_link = component.get("v.external_link");
    if(external_link){
        address = 'https://'+address;
    }*/
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": address
        });
        urlEvent.fire();
    }
    
})