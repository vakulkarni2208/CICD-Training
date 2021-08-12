({
	init : function(component, event, helper) {
		component.set('v.columns', [
            {label: 'Entitlement Name', fieldName: 'Name', type: 'text', editable: false },
            {label: 'Status', fieldName: 'Entitlement_Status__c', type: 'text',  editable: false },
            {label: 'Environment Profile Name', fieldName: 'Environment_Profile_Name__c', type: 'text',  editable: false }
        ]);
        var envProfileId = component.get("v.recordId");
		var action=component.get('c.getEntitlementList');
        action.setParams({"envProfileId":envProfileId});
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state=='SUCCESS' || state=='DRAFT'){
                var responseValue = response.getReturnValue();
                component.set('v.data', responseValue);
            }
    	});
        $A.enqueueAction(action);
	},
    addRows : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRowsList" ,event.getParam('selectedRows') );
    },
    Link : function(component, event, helper){
        var selectedEntitlements = component.get("v.selectedRowsList");
        var envProfileId = component.get("v.recordId");
        var action = component.get("c.linkEnvironmentProfileToEntitlements");
        action.setParams({"envProfileId":envProfileId,"lstEntitlements":selectedEntitlements});
        action.setCallback(this,function(response){
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }

})