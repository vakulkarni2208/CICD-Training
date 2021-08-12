({
	renew : function(component, event, helper) {
		helper.renew(component, event, helper);
	},
    //confirm : function(component, event, helper) {
		/*var result = confirm("Press a button!"); 
        window.alert(''+result);
        if (result == true) {
            window.alert('its true');
        }
        else {
            var closePanel = $A.get("e.force:closeQuickAction");
			closePanel.fire();
        } */
	//},
    close : function(){
        var closePanel = $A.get("e.force:closeQuickAction");
		closePanel.fire();
    }
})