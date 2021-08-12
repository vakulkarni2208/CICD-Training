/*
	Change List:
	2019.02.12 - Paresh: Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
    2019.03.05 - Paresh: Licensing 2.0 Code clean up (new RWA page will be used for the registration)
	2019.06.21 - Akhilesh: Merged Lic 2.0 code with current changes.
    2019.07.11 - Akhilesh: Commented code not required.
*/

({
	myAction : function(component, event, helper) {
		helper.myAction(component, event, helper);
	/*	
	helper.getCountries(component, event, helper);
	helper.getUserName(component);
        helper.populateStates1(component, event, helper);
        helper.populateStates2(component, event, helper);

        // Get record id from Url 
        var sPageURL = decodeURIComponent(window.location); //You get the whole decoded URL of the page.
        var sURLVarString = sPageURL.split('?'); //Split by & so that you get the key value pairs separately in a list
        if(sURLVarString.length > 0){
            var sURLVariables = sURLVarString[sURLVarString.length-1].split('&'); //Split by & so that you get the key value pairs separately in a list
            if(sURLVariables.length > 0){
                var sParameterName;
                var paramObj = new Object();
                var i;                
                for (i = 0; i < sURLVariables.length; i++) {
                    sParameterName = sURLVariables[i].split('='); //to split the key from the value.
                    paramObj[sParameterName[0]] = sParameterName[1];
                }       
                if(!$A.util.isEmpty(paramObj['addUser'])){        
                    component.set("v.containerAdminRequired", false);
                }
            }
        }
	*/
    },
/*
    Submit : function(component, event, helper){
        helper.submitRegistration(component, event, helper);
    },
    populateStates1 : function(component, event, helper){
        helper.populateStates1(component, event, helper);
    },
    populateStates2 : function(component, event, helper){
        helper.populateStates2(component, event, helper);
    },
    redirect : function(component, event, helper){
        helper.redirect(component, event, helper);
    }
*/
})