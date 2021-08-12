({
	doInit : function(component, event, helper) {
		//helper.getCountries(component, event, helper);
        helper.getUserType(component,event, helper);
        helper.initLabels(component,event, helper);
    },
    Cancel : function(component, event, helper) {
        helper.Cancel(component, event, helper);
	},
    SendMail : function(component, event, helper) {
		helper.SendMail(component, event, helper);
	},
    handleChange : function(component, event, helper) {
		helper.handleChange(component, event, helper);
	},
    Redirect : function(component, event, helper) {
		helper.Redirect(component, event, helper);
	}
})