/*
	2016.07.22 - pjena
	Controller class for CRM_Lead_DoNotCallEmail_Banner vf to show banner in the Lead record
	It pulls the No_Sales_Call__c, No_Sales_Email__c information of the Lead record and shows the message if any of them is checked
	
	2016.09.01 - PJENA - Combine DoNot Call/Email message with Pre-MQL Lead message
	
	2018.07.26 - PJENA - JIRA#SDS-550 - Add Alert on Enterprise Customer Lead Layout
						- Lead status must be Sales Qualified to click ‘Convert’ and complete conversion process.
*/
public class CRM_Lead_DoNotCallEmail_Banner_cls {
    public boolean showMessage{get;set;}
    public list<string> lstMsgs {get;set;}
    
    public CRM_Lead_DoNotCallEmail_Banner_cls(ApexPages.StandardController sc){
    	Id recordId = sc.getId();
    	lstMsgs = new list<string>();
    	if (recordId != null){
    		 
    		 list<Lead> lstLeads = [Select No_Sales_Call__c, No_Sales_Email__c, RecordType.Name 
    		 						From Lead 
    		 						Where Id = :recordId ];
    		 
    		 if (!lstLeads.isEmpty()){
    		 	if (lstLeads[0].RecordType.Name == COMM_Constants.LEAD_RT_PREMQL_LEAD){
    		 		showMessage = true;
    		 		lstMsgs.add(CRM_DoNotCallEmail_Settings__c.getOrgDefaults().Pre_MQL_Lead_View_Msg__c);
    		 	}
    		 	
    		 	if (lstLeads[0].No_Sales_Call__c == true || lstLeads[0].No_Sales_Email__c == true ){
    		 		showMessage = true;
    		 		lstMsgs.add(CRM_DoNotCallEmail_Settings__c.getOrgDefaults().Lead_MSG__c);
    		 	}
    		 	
    		 	//2018.07.26 - PJENA - JIRA#SDS-550 - Add Alert on Enterprise Customer Lead Layout
    		 	if (lstLeads[0].RecordType.Name == COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD){
    		 		showMessage = true;
    		 		lstMsgs.add(CRM_DoNotCallEmail_Settings__c.getOrgDefaults().ECL_SQL_Conversion_Alert__c);
    		 	}
    		 	
    		 }
    	}
    }
}