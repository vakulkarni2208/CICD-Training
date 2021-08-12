@IsTest(SeeAllData=true) 
private class Eval_Approval_test {
    
    /* This is a basic test which simulates the primary positive case for the 
Conversion method of a Lead. 
    
    private static testMethod void evalTest() {
        
        // create a Lead
        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry', GRID_Software_Evaluation_PAK__c='121',GRID_Software_Evaluation__c ='Approved' );
        
        insert lead;                
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
    }
*/    
    
    private static testMethod void evalTests() {
        
        List<Lead> leads = new List<Lead>();
        for(integer i=1; i<3; i++) {
            integer j = i - 1;
            Lead ld = new Lead();
            ld.FirstName = 'Test';
            ld.LastName = 'Lead ' + i;
            ld.Company = 'Test Account ' + i;
            ld.No_Sales_Call__c = false;
            ld.No_Sales_Email__c = false;
            ld.MKTO_Assigned__c = false;
            ld.Status = 'Prospect';
            ld.GRID_Software_Evaluation_PAK__c =string.valueOf(j);
            ld.GRID_Software_Evaluation__c ='';
            leads.add(ld);  
        }
        insert leads;
        
        for(Lead ld: Leads) {
            ld.Status = 'Marketing Qualified';   
            ld.GRID_Software_Evaluation__c ='Approved';
        }
        update leads;            
        
        
    }   
    
    
    
}