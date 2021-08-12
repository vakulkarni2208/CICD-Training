({
	SendMail : function(component, event, helper) {
        var path = window.location.pathname;
		var action = component.get("c.sendRegistrationMail");
        var showError = false;
        var errorMessages = new Array();
        var email = component.get("v.email");
        var prodFamily = (component.get("v.dgxselected") == true) ? "DGX" : "GRID";
                
        if(email == null || email.length === 0){
            showError = true;
           // errorMessages.push("Email is required");
                   
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'dismissible',
                duration:'5000',
                message: 'Email is required.',
                type : 'error'
            });
            toastEvent.fire();
        }
        if(showError){
            component.set("v.showError", showError);
            component.set("v.errorMessages", errorMessages);
            return;
        }
        action.setParam("email", component.get("v.email"));
        //window.alert(path.substring(0,path.lastIndexOf("/"))); 
        /*            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'pester',
                        duration:'5000',
                        message: 'format is required ',
                        type : 'success'
                    });
                    toastEvent.fire(); */
        action.setParam("hostName", window.location.hostname
									+path.substring(0,path.lastIndexOf("/")+1));
        action.setParam("prodFamilySelected", prodFamily);
        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var rtnValue = a.getReturnValue();
                if (rtnValue === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissible',
                        duration:'5000',
                        message: 'Thank you. The user has been sent an email with instructions to register.',
                        type : 'success'
                    });
                    toastEvent.fire();
                    //window.location = path.substring(0,path.lastIndexOf("/"));
                }else {
                    showError = true;
                    /*window.alert(path.substring(0,path.lastIndexOf("/"))); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        duration:'5000',
                        message: 'Sending Registration Email Failed ',
                        type : 'success'
                    });
                    toastEvent.fire();*/
                    errorMessages.push("Sending Registration Email Failed. No Active entitlements are available"+
                                       " for your account.");
                    component.set("v.showError", showError);
                    component.set("v.errorMessages", errorMessages);
                }
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        showError = true;
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            duration:'5000',
                            message: 'thanks',
                            type : 'success'
                        });
                        toastEvent.fire();*/
                        errorMessages.push("Error message: " + errors[0].message);
                    }
                } else {
                    showError = true;
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        duration:'5000',
                        message: 'right ',
                        type : 'success'
                    });
                    toastEvent.fire();*/
                    errorMessages.push("Error message: " + errors[0].message);
                }
                component.set("v.showError", showError);
                component.set("v.errorMessages", errorMessages);
            }
        });
        $A.enqueueAction(action);
        
        //WAIT FOR SOMETIME BEFORE REFRESH/REDIRECT.
        window.setTimeout(
            $A.getCallback(function() {
            	window.location = path.substring(0,path.lastIndexOf("/"));
            }), 5000
        );
		//window.location = path.substring(0,path.lastIndexOf("/"));
	},

  /*   getCountries : function(component, event, helper) {
         var action1 = component.get("c.getCountries");
         var opts = [];
         action1.setCallback(this, function(response){
             if(response.getState() === "SUCCESS"){
                 var allValues = response.getReturnValue();
                 if (allValues != undefined){
                     console.log("Inside if");
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
    },*/
    handleChange : function(component, event, helper){
        var radioSelection = component.get("v.radioSelection");
        if(radioSelection =='GRID User')
            component.set("v.gridselected", true);
        	component.set("v.both", false);
            //window.location = $A.get("$Label.c.GRID_New_User_Redirect_URL");
        if(radioSelection =='DGX User'){
            component.set("v.dgxselected", true);
            component.set("v.both", false);
        }
    },
    Cancel : function(component, event, helper){
        var path = window.location.pathname;
        /*window.alert(path.substring(0,path.lastIndexOf("/")));
        var sMsg = 'Hello i am first statement \n';
        sMsg += 'Hello i am Second statement \n Hello i am Third statement';
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            duration:'5000',
            message: sMsg,
            type : 'success'
        });
        toastEvent.fire();*/
		window.location = path.substring(0,path.lastIndexOf("/"));
    },
    Redirect : function(component, event, helper){
        window.location = $A.get("$Label.c.GRID_New_User_Redirect_URL");
    },
    
    getUserType : function(component, event, helper){
        var action = component.get("c.UserType");
        //alert("userType-->");
        action.setCallback(this, function(az){
            var state = az.getState();
            //console.log("userType-->"+state);
            //alert("userType-->"+state);
            if (state === "SUCCESS") {
                var userType = az.getReturnValue();
                //console.log("userType-->"+userType);
                //alert("userType-->"+userType);
                //window.location.href = "/ESPCommunity/s/contact-nvidia-renewals";
                if(userType == null || userType.length ==0 || userType =="ERROR"){
                    //alert("You are not able to add a new user as It appears that there are no active entitlements. Please Contact NVIDIA Renewals Team, if this is not correct or need to renew your Entitlement.");
                    var path = window.location.pathname;
                    //window.location.href = "/contact-nvidia-renewals";
                    //window.location = path.substring(0,path.lastIndexOf("/"));
                    component.set("v.both", false);
                    component.set("v.gridselected", false);
                    component.set("v.dgxselected", false);
                    component.set("v.noEntitlement", true);
                } else if(userType == "NPN"){
                    //alert("Please use NPN Portal to request new user access.");
                    var path = window.location.pathname; 
                    component.set("v.both", false);
                    component.set("v.gridselected", false);
                    component.set("v.dgxselected", false);
                    component.set("v.NPNUser", true);
                    //window.location = path.substring(0,path.lastIndexOf("/"));
                } else if(userType.indexOf("Support Portal") !=-1 && userType.indexOf("Licensing Portal") !=-1){
                    component.set("v.both", true);
                } else if(userType.indexOf("Support Portal") !=-1 && userType.indexOf("Licensing Portal") ===-1){
                    component.set("v.dgxonly", true);
                    component.set("v.dgxselected", true);
                } else if(userType.indexOf("Support Portal") ===-1 && userType.indexOf("Licensing Portal") !=-1){
                    //component.set("v.gridonly", true);
                    component.set("v.both", true);
                }
                
                
                //if(component.get("v.gridonly")){
                //     component.set("v.gridselected", true);
					////window.location = $A.get("$Label.c.GRID_New_User_Redirect_URL");
                //}
            }
        });
        $A.enqueueAction(action);      
    },
    
    initLabels : function(component, event, helper){
        var dgxInstructions = $A.get("$Label.c.Add_DGX_Member_Instructions");
        var gridInstructions = $A.get("$Label.c.Add_GRID_Member_Instructions");
        var dgxInsList = dgxInstructions.split("<br/>");
        var gridInsList = gridInstructions.split("<br/>");
        component.set("v.dgxInstructions", dgxInsList);
        component.set("v.gridInstructions", gridInsList);
    },
    
    showToastMessage : function(messagge, type, isRedirect, redirectURL) {
    	window.setTimeout(
            $A.getCallback(function() {
            	window.location = path.substring(0,path.lastIndexOf("/"));
            }), 5000
        );
    }
})