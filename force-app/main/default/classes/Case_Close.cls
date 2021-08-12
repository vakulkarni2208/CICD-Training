/*
Class Name : Case_Close
Description : This class is controller for Case_Close_VF which is overriden button for Close case for Community users
Version    Created by     Description
---------  -----------    --------------------------------------
1.0        Nilesh Adkar    SDS 1402 Community Case Close Button

*/
global class Case_Close{
static string strCaseId {get;set;}

public Case_Close(ApexPages.StandardController controller) {
    strCaseId = ApexPages.currentPage().getParameters().get('id');
    system.debug('**constructor**'+ strCaseId);
}

@RemoteAction
@AuraEnabled
global static boolean closeCase(string strCaseId, boolean isPageLoad ){
    //strCaseId = ApexPages.currentPage().getParameters().get('id');
    system.debug('**method**'+ strCaseId);
    Case objCase = [Select status,Incident_status__c from Case where id= :strCaseId];
    if(objCase!=null && objCase.Status != 'Closed'){
        objCase = new Case(id=strCaseId ,Status='Closed',Incident_status__c= 'Closed',Incident_Substatus__c= 'Customer Closure');
        if(isPageLoad )
            return false;
        update objCase;
        return false;
    }
    else
        return true;
    /*PageReference pageRef = new PageReference('/'+strCaseId );
    pageRef.setRedirect(true);
    return pageRef ; */
}
   
}