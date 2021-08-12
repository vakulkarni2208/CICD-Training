/*
	2016.08.30 - pjena
	Controller class for CRM_OPP_ContactRole_Banner vf to show banner in the Opportunity record if there is no DR_Customer_Contact__c and Primary_Contact_Role__c

*/
public class CRM_OPP_ContactRole_Banner_cls {
    public boolean showMessage{get;set;}
    public string message{get;set;}
    
    public CRM_OPP_ContactRole_Banner_cls(ApexPages.StandardController sc){
    	Id recordId = sc.getId();
    	
    	if (recordId != null){
    		 
    		 list<Opportunity> lstOpps = [Select DR_Customer_Contact__c, Primary_Contact_Role__c 
    		 						From Opportunity 
    		 						Where Id = :recordId 
    		 							And (DR_Customer_Contact__c != null And Primary_Contact_Role__c != null)];
    		 
    		 if (lstOpps.isEmpty()){
    		 	showMessage = true;
    		 	message = OCR_Settings__c.getOrgDefaults().OCR_Msg__c;
    		 }
    	}
    }
}