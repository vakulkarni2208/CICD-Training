/*
	2016.07.22 - pjena
	Controller class for CRM_Contact_DoNotCallEmail_Banner vf to show banner in the Contact record
	It pulls the No_Sales_Call__c, No_Sales_Email__c information of the Contact record and shows the message if any of them is checked

*/
public class CRM_Contact_DoNotCallEmail_Banner_cls {
    public boolean showMessage{get;set;}
    public string message{get;set;}
    
    public CRM_Contact_DoNotCallEmail_Banner_cls(ApexPages.StandardController sc){
    	Id recordId = sc.getId();
    	
    	if (recordId != null){
    		 
    		 list<Contact> lstLeads = [Select No_Sales_Call__c, No_Sales_Email__c 
    		 						From Contact 
    		 						Where Id = :recordId 
    		 							And (No_Sales_Call__c = true Or No_Sales_Email__c = true)];
    		 
    		 if (!lstLeads.isEmpty()){
    		 	showMessage = true;
    		 	message = CRM_DoNotCallEmail_Settings__c.getOrgDefaults().Contact_MSG__c;
    		 }
    	}
    }
}