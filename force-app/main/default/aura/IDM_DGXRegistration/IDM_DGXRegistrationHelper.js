/*
	Change List:
	2019.02.12 - Paresh: 	Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
	2019.06.21 - Akhilesh: 	Merged Lic 2.0 code with current changes.
    2019.07.09 - Akhilesh:  Added LicType and ProductFamily parameters to send in redirect URL.
    ?? Can we use same var rwaFullURL? Reason for Alert?
*/

({	
    myAction : function(component, event, helper) {
        
        //Redirection logic
        var getParameterString = decodeURIComponent(window.location.search.substring(0)); //gives ?a=1&b=2 from www.google.com/pages?a=1&b=2
		var rwaBaseURL = $A.get("$Label.c.ServiceCloud_UserRegistrationURL");
        if(getParameterString == '')
            getParameterString = getParameterString + '?LicType=COMMERCIAL&ProductFamily=SXN';
        else 
            getParameterString = getParameterString + '&LicType=COMMERCIAL&ProductFamily=SXN';
        var rwaFullURL = rwaBaseURL + getParameterString;// + '&LicType=COMMERCIAL&ProductFamily=SXN';
        rwaFullURL = rwaFullURL.replace("sNo", "PAKID");
        component.set("v.redirectionURL", rwaFullURL);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
      		"url": rwaFullURL
    	});
        //alert('ParameterString' + getParameterString);
        alert('You will be redirected to ' + rwaFullURL);
        /*window.setTimeout(
            $A.getCallback(function() {
            	window.open(rwaFullURL,'_top');
            }), 1000
        );*/
        //window.location.href = rwaFullURL;
        window.open(rwaFullURL,'_top');
        /* Old code: Commented to use common string "rwaFullURL"
    	 * urlEvent.setParams({
      		"url": rwaBaseURL + getParameterString + '&LicType=COMMERCIAL&ProductFamily=DGX'
    	});
        alert('You will be redirected to ' + rwaBaseURL + getParameterString + '&LicType=COMMERCIAL&ProductFamily=DGX');
        */
    	//urlEvent.fire();
        //$A.enqueueAction(action1);
    },
})
/*
 * //window.open(rwaFullURL,'_top');
*		//window.location.href = rwaFullURL;
        //https://davidwalsh.name/query-string-javascript
({	
    myAction : function(component, event, helper) {
        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };
        
        var email=getUrlParameter('email');
        var sNo=getUrlParameter('sNo');
        var firstname=getUrlParameter('firstname');
        var lastname=getUrlParameter('lastname');
        var CompanyName__c=getUrlParameter('CompanyName');
        var Mailingstreet=getUrlParameter('street1');
        var Mailing_Street_2__c=getUrlParameter('street2');
        var Phone=getUrlParameter('Phone');
        var Mailingcity=getUrlParameter('City');
        var Mailingstate=getUrlParameter('State');
        var MailingPostalCode=getUrlParameter('PostalCode');
        var IDM_CountryCode__c=getUrlParameter('Country');
        
        component.set("v.contact1.firstname",firstname);
        component.set("v.contact1.lastname",lastname);
        component.set("v.contact1.Mailingstreet",Mailingstreet);
        component.set("v.contact1.Mailing_Street_2__c",Mailing_Street_2__c);
        
        component.set("v.contact1.Mailingcity",Mailingcity);
        component.set("v.contact1.Mailingstate",Mailingstate);
        component.set("v.contact1.MailingPostalCode",MailingPostalCode);
        component.set("v.contact1.email",email);
        component.set("v.contact1.CompanyName__c",CompanyName__c);
        component.set("v.sNo",sNo);
        component.set("v.contact1.Phone",Phone);
        var action1 = component.get("c.getStates");
        var opts = [];
        action1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var stateValues = response.getReturnValue();
                if (stateValues != undefined){
                    component.set("v.stateMapping", stateValues);
                }
            }
        });
        $A.enqueueAction(action1);
    },
    populateStates1 : function(component, event, helper) {
        var stateMap = component.get("v.stateMapping");
        var country1 = component.get("v.contact1.IDM_CountryCode__c");
        var countryMap = component.get("v.options");
        var country2Name='';
        if(country1 === "US" || country1 === "CA"){
            component.set("v.state1Required",true);
        }else{
            component.set("v.state1Required",false);
        }
        for(var name in countryMap){
            if(countryMap[name].value == country1){
                country2Name = countryMap[name].label;
            }
        }
        var stateopts = [];
        for(var state in stateMap){
            if(stateMap[state] == country2Name){
                stateopts.push({
                    class: "optionClass",
                    label: state,
                    value: state
                });
            }
        }
        component.set("v.states1",stateopts);
        component.set("v.contact1.MailingCountry",country2Name);
    },
    populateStates2 : function(component, event, helper) {
        var stateMap = component.get("v.stateMapping");
        var country2 = component.get("v.contact2.IDM_CountryCode__c");
        var countryMap = component.get("v.options");
        var country2Name='';
        for(var name in countryMap){
            if(countryMap[name].value == country2){
                country2Name = countryMap[name].label;
            }
        }
        var stateopts = [];
        for(var state in stateMap){
            if(stateMap[state] == country2Name){
                stateopts.push({
                    class: "optionClass",
                    label: state,
                    value: state
                });
            }
        }
        component.set("v.states2",stateopts);
        component.set("v.contact2.MailingCountry",country2Name);
    },
    getCountries : function(component, event, helper) {
        
        var action1 = component.get("c.getCountries");
        var opts = [];
        action1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var allValues = response.getReturnValue();
                console.log('allValues-->'+JSON.stringify(allValues));
                if (allValues != undefined){
                    for(var p in allValues){
                        opts.push({
                            class: "optionClass",
                            label: p,
                            value: allValues[p]
                        });
                        component.set("v.options", opts);
                    }
                }
            }
        });
        $A.enqueueAction(action1);      
        
    },
    submitRegistration : function(component, event, helper) {
        var action = component.get("c.submitRegistration");
        var showError = false;
        var alreadyExist = false;
        var errorMessages = new Array();
        var contact1 = component.get("v.contact1");
        var contact2 = component.get("v.contact2");
        
        var email = component.get("v.contact1.email");
        var sNo = component.get("v.sNo");
        var sNo1 = component.get("v.sNo1");
        var sNo2 = component.get("v.sNo2");
        
        var contactemail1 = component.get("v.contact1.email");
        var confirmemail1 = component.get("v.confirmemail1");
        
        var contactemail2 = component.get("v.contact2.email");
        var confirmemail2 = component.get("v.confirmemail2");
        var country1 = component.get("v.contact1.IDM_CountryCode__c");
        var country2 = component.get("v.contact2.IDM_CountryCode__c");
        
        var getCountryName = function getCountryName(countryCode){
            var country2Name='';
            var countryMap = component.get("v.options");
            for(var name in countryMap){
                if(countryMap[name].value == countryCode){
                    country2Name = countryMap[name].label;
                }
            }
            return country2Name;
        };
        component.set("v.contact1.MailingCountry",getCountryName(country1));
        component.set("v.contact2.MailingCountry",getCountryName(country2));
        if(component.get("v.contact1.CompanyName__c") !=null){
            component.set("v.contact2.CompanyName__c",component.get("v.contact1.CompanyName__c"));
        }
        if(component.get("v.contact1.firstname")== null || component.get("v.contact1.firstname").length ==0){
            showError = true;
            errorMessages.push("FirstName for Primary contact is required");
        }
        if(component.get("v.contact1.lastname")== null || component.get("v.contact1.lastname").length ==0){
            showError = true;
            errorMessages.push("LastName for Primary contact is required");
        }
        if(component.get("v.contact1.email") == null || component.get("v.contact1.email").length ==0){
            showError = true;
            errorMessages.push("Email for Primary contact is required");
        }
        if(component.get("v.contact1.CompanyName__c") == null || component.get("v.contact1.CompanyName__c").length ==0){
            showError = true;
            errorMessages.push("CompanyName for Primary contact is required");
        }
        if(component.get("v.contact1.Mailingstreet") == null || component.get("v.contact1.Mailingstreet").length ==0){
            showError = true;
            errorMessages.push("Street1 for Primary contact is required");
        }
        if(component.get("v.contact1.Mailingcity") == null || component.get("v.contact1.Mailingcity").length ==0){
            showError = true;
            errorMessages.push("City for Primary contact is required");
        }
        if(component.get("v.contact1.MailingPostalCode") == null || component.get("v.contact1.MailingPostalCode").length ==0){
            showError = true;
            errorMessages.push("PostalCode for Primary contact is required");
        }
        if(component.get("v.contact1.Phone") == null || component.get("v.contact1.Phone").length ==0){
            showError = true;
            errorMessages.push("Phone for Primary contact is required");
        }
        if(component.get("v.containerAdminRequired") && (component.get("v.firstName") == null || component.get("v.firstName").length ==0)){
            showError = true;
            errorMessages.push("DGX Container Registry Administrator - FirstName is required");
        }
        if(component.get("v.containerAdminRequired") && (component.get("v.lastName") == null || component.get("v.lastName").length ==0)){
            showError = true;
            errorMessages.push("DGX Container Registry Administrator - LastName is required");
        }
        if(component.get("v.containerAdminRequired") && (component.get("v.email") == null || component.get("v.email").length ==0)){
            showError = true;
            errorMessages.push("DGX Container Registry Administrator - Email is required");
        }
        if(component.get("v.containerAdminRequired") && (component.get("v.company") == null || component.get("v.company").length ==0)){
            showError = true;
            errorMessages.push("DGX Container Registry Administrator - Company Name is required");
        }
        if(component.get("v.containerAdminRequired") && (component.get("v.phone") == null || component.get("v.phone").length ==0)){
            showError = true;
            errorMessages.push("DGX Container Registry Administrator - Phone Number is required");
        }
        if((sNo == null || sNo.length === 0) && (sNo1 == null || sNo1.length === 0) && (sNo2 == null || sNo2.length === 0)){
            showError = true;
            errorMessages.push("Hardware Serial Number / PAKID is required");
        }
        if(contactemail1 == null || confirmemail1 == null || (contactemail1.trim() != confirmemail1.trim())){
            showError = true;
            errorMessages.push("Email for contact1 is not confirmed correctly");
        }
        if(contactemail2 != null && confirmemail2 != null && contactemail2 != confirmemail2){
            showError = true;
            errorMessages.push("Email for contact2 is not confirmed correctly");
        }
        if(showError){
            component.set("v.showError", showError);
            component.set("v.errorMessages", errorMessages);
            return;
        }
        action.setParam("con1", contact1);
        action.setParam("con2", contact2);
        action.setParam("sNo", sNo);
        action.setParam("sNo1", component.get("v.sNo1"));
        action.setParam("sNo2", component.get("v.sNo2"));
        action.setParam("sNo3", component.get("v.sNo3"));
        action.setParam("salesOrder", component.get("v.salesOrder"));
        action.setParam("firstName", component.get("v.firstName"));
        action.setParam("lastName", component.get("v.lastName"));
        action.setParam("email", component.get("v.email"));
        action.setParam("company", component.get("v.company"));
        action.setParam("phone", component.get("v.phone"));
        console.log('Before callback');
        action.setCallback(this, function(a){
            var state = a.getState();
            var errMsg = 'It appears that there is an error with your registration process. Please contact us utilizing the link above to assist with your registration.';
           
            if (state === "SUCCESS") {
                var rtnValue = a.getReturnValue();
                console.log("rtnValue-->"+rtnValue);
                if (rtnValue === "SUCCESS") {
                    //var path = window.location.pathname;
                    //window.location = path.substring(0,path.lastIndexOf("/"));
                    component.set("v.isSuccess", true);
                }else if(rtnValue === "Administrator Error"){
                    showError = true;
                    errorMessages.push("User Registration Successful.DGX Administrator Registration has failed.");
                    component.set("v.showError", showError);
                    component.set("v.errorMessages", errorMessages);
                }
                /*else if(rtnValue === "Exist"){
                    //showError = true;
                    alreadyExist = true;
                    //var email = component.get("v.email");
                    //var s = "<a href=\"abc\">login</a>" + email;
                    //errorMessages.push(s);
                    //component.set("v.showError", showError);
                    component.set("v.alreadyExist", alreadyExist);
                    component.set("v.errorMessages", errorMessages);
                } /*
                else {
                    showError = true;
                    var res = rtnValue.split(":");
                    if(rtnValue !='ERROR') {
                        if(res[0] === "Exist") {
                            errorMessages.push(res[1]);
                        }
                        else{
                            errorMessages.push(rtnValue);
                        }
                    }
                    //if(rtnValue !='ERROR')
                    //    errorMessages.push(rtnValue);
                    //errorMessages.push("Registration Failed. Contact Administrator.");
                    component.set("v.showError", showError);
                    component.set("v.errorMessages", errorMessages);
                }
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        showError = true;
                        errorMessages.push(errMsg + " Error message: " + errors[0].message);
                    }
                } else {
                    showError = true;
                    errorMessages.push(errMsg + "Error message: " + errors[0].message);
                }
                component.set("v.showError", showError);
                component.set("v.errorMessages", errorMessages);
            }
        });
        $A.enqueueAction(action);                         
    },
    
    getUserName: function(cmp){
        var action = cmp.get("c.getUserName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.Name", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    redirect: function(component, event, helper){
        window.location = $A.get("$Label.c.DGX_New_User_Redirect_URL");
    }
})
*/