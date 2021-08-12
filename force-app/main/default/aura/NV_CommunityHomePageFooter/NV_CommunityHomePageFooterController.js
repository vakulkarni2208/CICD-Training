({
	openActionWindow : function(component, event, helper) {
		 window.open("https://www.nvidia.com/en-us/preferences/email-signup/");
	}
    
 
})
({
  
    init : function(component, event, helper) {
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    component.set('v.today', today.getFullYear()); 
 }
})