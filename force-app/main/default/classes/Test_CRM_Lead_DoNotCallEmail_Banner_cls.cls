/*
    Test class for controller class CRM_Lead_DoNotCallEmail_Banner_cls and CRM_Contact_DoNotCallEmail_Banner
 */
@isTest(SeeAllData=false)
private class Test_CRM_Lead_DoNotCallEmail_Banner_cls {
    
    //Check if the No_Sales_Call__c or No_Sales_Email__c is checked for the Lead, the message is not blank
    static testMethod void testLeadWithNoSalesCall() {
       
        //Get the Enterprise Customer Lead RT Map
        //-----------------------------------------------------------------------------------------------------
        map<string, Id> map_ENTERPRISE_CUSTOMER_LEAD_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD);
        //-----------------------------------------------------------------------------------------------------
        
        //Create Enterprise Customer Lead with No_Sales_Call__c = true
        //-----------------------------------------------------------------------------------------------------
        Lead ECLNoSalesCall1 = new Lead(LastName='ECLNoSalesCall1', Company = 'Enterprise1', Email = 'testeclnosales1@nv.com', No_Sales_Call__c = true, RecordTypeId = map_ENTERPRISE_CUSTOMER_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD));
        insert ECLNoSalesCall1;
        //-----------------------------------------------------------------------------------------------------
        
        Test.startTest();
            PageReference pageRef = new PageReference('/apex/CRM_Lead_DoNotCallEmail_Banner');
            Test.setCurrentPageReference(pageRef);
            ApexPages.Standardcontroller stdCon = new Apexpages.Standardcontroller(ECLNoSalesCall1);
            
            CRM_Lead_DoNotCallEmail_Banner_cls extnCtlr = new CRM_Lead_DoNotCallEmail_Banner_cls(stdCon);
            system.debug('***showMessage : ' + extnCtlr.showMessage);
            system.assert(extnCtlr.showMessage == true);
             
        Test.stopTest();
        
    }
    
    //Check if the No_Sales_Call__c or No_Sales_Email__c is checked for the Contact, the message is not blank
    static testMethod void testContactWithNoSalesCall() {
    
        //Get Account and Contact Record Types
        //-----------------------------------------------------------------------------------------------------
        map<string, Id> map_CUSTOMER_ACCOUNT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_CUSTOMER);
        map<string, Id> map_CUSTOMER_CONTACT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_SALES_CONTACT);
        //-----------------------------------------------------------------------------------------------------
        
        //Create a Customer Account
        //-----------------------------------------------------------------------------------------------------
        Account accEC1 = new Account(name='EC1', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NV_CUSTOMER));
        Database.insert(accEC1);
        //-----------------------------------------------------------------------------------------------------
            
        //Create a Sales Contact with No_Sales_Call__c = true
        //-----------------------------------------------------------------------------------------------------
        Contact conSC1 = new Contact(LastName='SC1LWithNoSalesCall', AccountId = accEC1.Id, No_Sales_Call__c = true, RecordTypeId = map_CUSTOMER_CONTACT_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT));
        Database.insert(conSC1);
        //-----------------------------------------------------------------------------------------------------
                
        Test.startTest();
            PageReference pageRef = new PageReference('/apex/CRM_Contact_DoNotCallEmail_Banner');
            Test.setCurrentPageReference(pageRef);
            ApexPages.Standardcontroller stdCon = new Apexpages.Standardcontroller(conSC1);
            
            CRM_Contact_DoNotCallEmail_Banner_cls extnCtlr = new CRM_Contact_DoNotCallEmail_Banner_cls(stdCon);
            system.debug('***showMessage : ' + extnCtlr.showMessage);
            system.assert(extnCtlr.showMessage == true);
        Test.stopTest();
    }
    
    //Check if the Lead is Pre-MQL Record type and it shows the message
    static testMethod void testPreMQLLeadMsg() {
       
        //Get the Enterprise Customer Lead RT Map
        //-----------------------------------------------------------------------------------------------------
        map<string, Id> map_PREMQL_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, COMM_Constants.LEAD_RT_PREMQL_LEAD);
        //-----------------------------------------------------------------------------------------------------
        
        //Create Enterprise Customer Lead with No_Sales_Call__c = true
        //-----------------------------------------------------------------------------------------------------
        Lead PreMQLLead = new Lead(LastName='PreMQL1', Company = 'PreMQL1', Email = 'premql1@nv.com', RecordTypeId = map_PREMQL_RT.get(COMM_Constants.LEAD_RT_PREMQL_LEAD));
        insert PreMQLLead;
        //-----------------------------------------------------------------------------------------------------
                
        Test.startTest();
            PageReference pageRef = new PageReference('/apex/CRM_Lead_DoNotCallEmail_Banner');
            Test.setCurrentPageReference(pageRef);
            ApexPages.Standardcontroller stdCon = new Apexpages.Standardcontroller(PreMQLLead);
            
            CRM_Lead_DoNotCallEmail_Banner_cls extnCtlr = new CRM_Lead_DoNotCallEmail_Banner_cls(stdCon);
            system.debug('***showMessage : ' + extnCtlr.showMessage);
            system.assert(extnCtlr.showMessage == true);
             
        Test.stopTest();
    }
    
}