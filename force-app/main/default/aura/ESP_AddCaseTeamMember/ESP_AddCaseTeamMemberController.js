({
    init : function(component, event, helper) {
        var caseId=component.get("v.recordId");
        component.set("v.caseId", caseId);
        //alert(component.get("v.caseId"));
		var action=component.get("c.getContactLookup");
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state==='SUCCESS' || state==='DRAFT'){
                var responseValue = response.getReturnValue();
                var cse = responseValue;
                cse.Community_Contact__c=null;
                component.set("v.newCase", responseValue);
            }
		});
		$A.enqueueAction(action);
        action=component.get("c.getCaseTeamMembers");
        action.setParams({"strCaseId":caseId});
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state==='SUCCESS' || state==='DRAFT'){
                var responseValue = response.getReturnValue();                
                component.set("v.caseTeamMembers", responseValue);
                var pills = component.get("v.caseTeamMembers");
                //alert(pills.length);
                var count = pills.length;
                for (var i = 0; i < count; i++) {
                    //alert(pills[i].Name_Formula__c);
                        pills.push({
                        type: 'icon',
                        name: pills[i].MemberId,
                        label: pills[i].Member.Name
                        //iconName: varIconName
                    });
                }
                pills.splice(0,count);
                //alert(pills.length);
                component.set('v.caseTeamMembers', pills);
            }
		});
		$A.enqueueAction(action);
        //component.set('v.caseTeamMembers', pills);
	},
    
    showToast : function(component, event, helper) {
        var strMessage = component.get("v.message");
        var strTitle = component.get("v.title");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": strTitle,
            "message": strMessage
        });
        toastEvent.fire(); 
    },
    
	submitQuery : function(component, event, helper) {
		var caseId=component.get("v.recordId");
        //alert(caseId);
        var caseObj = component.get("v.newCase");
        var contactId = caseObj.Community_Contact__c;
        //alert(contactId);
        var action=component.get("c.addCommunityCaseTeamMember");
        var toastMessageAction = component.get('c.showToast');
        action.setParams({"strCaseId":caseId,"strContactId":contactId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state==='SUCCESS' || state==='DRAFT') {
                var responseValue = response.getReturnValue();
                //alert(responseValue);
                if(responseValue == 'Success'){
                    component.set("v.message", 'Team Member added to Case.');
                    component.set("v.title", '');
                    $A.enqueueAction(toastMessageAction);
                    /*var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/case/" + caseId
                    });
                    urlEvent.fire();*/
					action=component.get("c.init");
					$A.enqueueAction(action);                    
                }
                else if(responseValue == 'No Record')
                {
                    component.set("v.title", 'Operation failed');
                    component.set("v.message", 'Unable to add Team member. No User/Contact found.');
                    $A.enqueueAction(toastMessageAction);
                }
                else if(responseValue=='Duplicate')
                {
                    component.set("v.title", 'Operation failed');
                    component.set("v.message", 'Unable to add Team member. Member Already added.');
                    $A.enqueueAction(toastMessageAction);
                }

            }
            else{
                    component.set("v.title", 'Operation failed');
                    component.set("v.message", 'Unable to add Team member. System error.');
                    $A.enqueueAction(toastMessageAction);
            }
        }); 
		$A.enqueueAction(action);    
	},    
    
    handleItemRemove: function (component, event) {
        //alert('in remove');
        var caseId=component.get("v.caseId");
        //alert(caseId);
        var contactId = event.getParam("item").name;
        //alert(contactId + ' pill was removed!');
        // Remove the pill from view
        var items = component.get("v.caseTeamMembers");
        var item = event.getParam("index");
        //alert(JSON.stringify(items));
        items.splice(item, 1);
        component.set('v.caseTeamMembers', items);
        var action=component.get("c.removeCaseTeamMember");
        action.setParams({"strContactId":contactId,"strCaseId":caseId});
        action.setCallback(this,function(response){
            //alert('success');
        	var state = response.getState();
            if(state==='SUCCESS' || state==='DRAFT'){
                //alert('success');
                //var responseValue = response.getReturnValue();
                //component.set("v.newCase", responseValue);
                var toastMessageAction = component.get('c.showToast');
                component.set("v.message", 'Team Member removed from Case Team.');
                component.set("v.title", '');
                $A.enqueueAction(toastMessageAction);
            }
		});
		$A.enqueueAction(action);
    }
})