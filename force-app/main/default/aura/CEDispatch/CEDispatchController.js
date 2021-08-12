({
	init : function(component, event, helper) {
		component.set('v.rmacolumns', [
            {label: 'RMA Number', fieldName: 'linkName', type: 'url',typeAttributes: {label:{fieldName:'Name'},target: '_blank'}},
            {label: 'RMA Item Number', fieldName: 'linkName', type: 'url',typeAttributes: {label:{fieldName:'SAP_RMA_Number__c'},target: '_blank'}},
            {label: 'RMA Part Number', fieldName: 'NVIDIA_Part_Number__c', type: 'text',  editable: false },
            {label: 'Return Part Description', fieldName: 'NVIDIA_Part_Description__c', type: 'text',  editable: false},
            {label: 'RMA Status', fieldName: 'RMA_Status__c', type: 'text',  editable: false},
            {label: 'CE Dispatch Requested', fieldName: 'Request_CE_Dispatch__c', type: 'boolean',  editable: false},
            {label: 'Scheduled Date and Time for Installation', fieldName: 'Scheduled_Date_and_Time_for_Installation__c', type: 'date', typeAttributes: { day: 'numeric',  month: 'numeric', year: 'numeric',  hour: '2-digit',  minute: '2-digit', second: '2-digit', hour12: true},  editable: true},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { day: 'numeric',  month: 'numeric', year: 'numeric',  hour: '2-digit',  minute: '2-digit', second: '2-digit', hour12: true},  editable: false },
            {label: 'Tracking Number', fieldName: 'Tracking_Number_Formula__c', type: 'url',  editable: false,typeAttributes: {label: { fieldName: 'Tracking_Number__c' }, target: '_blank'}}
        ]);
        var pageReference = component.get("v.pageReference");
		component.set("v.caseId", pageReference.state.c__caseId);
		var caseId=component.get("v.caseId");
		var action=component.get("c.getRMAs");
        action.setParams({"strCaseId":caseId});
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state=='SUCCESS' || state=='DRAFT'){
                var responseValue = response.getReturnValue();
				responseValue.forEach(function(record){
                    //alert(record.Crm_Complaint_Number__c);
                    if(record.Crm_Complaint_Number__c!== undefined)
                    	record.linkName = '/'+record.Id;//'https://nvcrm--sfdcstage1.my.salesforce.com/'+
                });              
                component.set('v.rmaData', responseValue);
            }
    	});
        $A.enqueueAction(action);    
		action=component.get("c.getEmailTemplates");
        action.setCallback(this,function(response){
        	var state = response.getState();
            if(state=='SUCCESS' || state=='DRAFT'){
                var responseValue = response.getReturnValue();
                component.set('v.EmailTemplates', responseValue);
                var emailTemplates = component.get("v.EmailTemplates");
                var items = [];
                //alert(emailTemplates.length);
                for (var i = 0; i < emailTemplates.length; i++) {
                    //alert(emailTemplates[i].Name);
                    var item = {
                        "label": emailTemplates[i].APXTConga4__Name__c,
                        "value": emailTemplates[i].Id
                    };
                    items.push(item);
                }
            	component.set("v.options", items);
            }
    	});
        $A.enqueueAction(action);            
	},
    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        component.set("v.emailTemplateId",selectedOptionValue);
        //alert("Option selected with value: '" + selectedOptionValue + "'");
    },    
    addrmaRows : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedrmaList" ,event.getParam('selectedRows') );
    },
    Initiate_Dispatch : function(component, event, helper){
        var selectedrmas = component.get("v.selectedrmaList");
        var strURL='';
        var selectedEmailTemplate = component.get("v.emailTemplateId");
        if(selectedrmas==null || selectedEmailTemplate =='' || selectedEmailTemplate === undefined || (selectedrmas!=null && selectedrmas.length==0)){
            alert('Please select RMA.');
			return;            
        }
        if(selectedEmailTemplate==null || selectedEmailTemplate =='' || selectedEmailTemplate === undefined){
            alert('Please select email template.');
			return;            
        }

        for (var i = 0; i < selectedrmas.length; i++){
            if((selectedrmas[i].Scheduled_Date_and_Time_for_Installation__c==null || selectedrmas[i].Scheduled_Date_and_Time_for_Installation__c=='' 
                || selectedrmas[i].Scheduled_Date_and_Time_for_Installation__c=== undefined) && selectedrmas[i].Request_CE_Dispatch__c == true){    
                var ans = confirm("Warning : You have not entered 'Scheduled Date and Time for Installation' for " + selectedrmas[i].Name + ". Proceed ?");
                if(ans==true)
                    break;
                else
            		return;
        	}
    	}   
		var action = component.get("c.initiateDispatch");
        action.setParams({"lstRMAs":selectedrmas,"strEmailTemplateId":selectedEmailTemplate});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state==='SUCCESS' || state==='DRAFT') {
                strURL=response.getReturnValue();
                component.find("navigationService").navigate({type: "standard__webPage", 
                                                      attributes: {url: strURL} 
													});
            }
            else{
                alert("Failed : " + response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },

    
    handleCancel : function(component, event, helper){
	var closetab = component.get('c.closeFocusedTab');
    $A.enqueueAction(closetab);        
    var recordId=component.get("v.caseId");    
    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
    },
    
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            //alert(focusedTabId);
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }           
})