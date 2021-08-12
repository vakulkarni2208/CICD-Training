/*
    Test Class for controller class EDU_DR_Report_ctlr
    2020.12.14-PJENA-SDS-2748-EDU Lead Form Enhancements
        Show Pending, Approved, Rejected Edu Lead Registrations
    Note: With the addition of Queable Apex, creation of Account gives System.CalloutException: You have uncommitted work pending
            So using the Account/Contact/Partner User instead of creating them as part of test class.
            Test User Email = nvpartnerone@yahoo.com
 */
 
@isTest(SeeAllData=true)
private class EDU_DR_Report_ctlr_test {
    private static string testPartnerUserEmail = 'nvpartnerone@yahoo.com'; //Imp: Change it to a NVIDIA alias in future to avoid person dependency
    private static User testPartnerUser{get;set;}

    private static list<EDU_DR_Report_ctlr.EDU_Lead_Wrapper> lstPending;
    private static list<EDU_DR_Report_ctlr.EDU_Lead_Wrapper> lstApproved;
    private static list<EDU_DR_Report_ctlr.EDU_Lead_Wrapper> lstRejected;
    private static EDU_DR_Report_ctlr ctlr;

    //Note: Hard Coded as the product options has to be specific, RTID, PSID are already in production so will not change
    private static string EDU_LEAD_RT_ID =  '0121W000000DytGQAS';//'EDU Lead Registration'
    private static string PP_EDU_LEAD_PSID = '0PS1W000000TMVUWA4'; //PP : EDU Lead Registration
    private static string Deal_Type = 'Server';
    private static string Primary_Product = 'Quadro RTX6000';    

    static testMethod void testEDUDRReportCtlr() {
        
            Test.startTest();
            testPartnerUser = [Select Id From User Where usertype = 'PowerPartner' and IsActive=true and Email = :testPartnerUserEmail limit 1];
            
            Lead oEduLead1, oEduLead2, oEduLead3;
            list<lead> lstEduLeads = new list<lead>();
        
            system.runAs(testPartnerUser){
                oEduLead1 = new Lead(Company = 'DRCustomerOne', Street = COMM_Constants.ADDRESS_STREET, City = COMM_Constants.ADDRESS_CITY, State = COMM_Constants.ADDRESS_STATE,  Country = COMM_Constants.ADDRESS_COUNTRY, 
                                    CountryCode= COMM_Constants.ADDRESS_US_ISO2, PostalCode = COMM_Constants.ADDRESS_ZIP, 
                                    FirstName = 'DRCustUsrFName1', LastName = 'DRCustUsrLName1', Title = 'CEO', Email = 'drf1l1cust1@customerone.com', Phone = '555-555-5551', Industry = 'Other', RecordTypeId = EDU_LEAD_RT_ID,
                                    DR_Deal_Type__c = Deal_Type, DR_Product__c = Primary_Product, DR_SKU_Quantity__c = 1, 
                                    DR_Is_Submitted__c = true, Status = 'In Review');
                
                oEduLead2 = new Lead(Company = 'DRCustomerOne', Street = COMM_Constants.ADDRESS_STREET, City = COMM_Constants.ADDRESS_CITY, State = COMM_Constants.ADDRESS_STATE,  Country = COMM_Constants.ADDRESS_COUNTRY, 
                                    CountryCode= COMM_Constants.ADDRESS_US_ISO2, PostalCode = COMM_Constants.ADDRESS_ZIP, 
                                    FirstName = 'DRCustUsrFName2', LastName = 'DRCustUsrLName2', Title = 'CEO', Email = 'drf1l1cust2@customerone.com', Phone = '555-555-5552', Industry = 'Other', RecordTypeId = EDU_LEAD_RT_ID,
                                    DR_Deal_Type__c = Deal_Type, DR_Product__c = Primary_Product, DR_SKU_Quantity__c = 1, 
                                    DR_Is_Submitted__c = true, DR_Is_Approved__c = true, Status = 'Approved');
                
                /*oEduLead3 = new Lead(Company = 'DRCustomerOne', Street = COMM_Constants.ADDRESS_STREET, City = COMM_Constants.ADDRESS_CITY, State = COMM_Constants.ADDRESS_STATE,  Country = COMM_Constants.ADDRESS_COUNTRY, 
                                    CountryCode= COMM_Constants.ADDRESS_US_ISO2, PostalCode = COMM_Constants.ADDRESS_ZIP, 
                                    FirstName = 'DRCustUsrFName3', LastName = 'DRCustUsrLName3', Title = 'CEO', Email = 'drf1l1cust3@customerone.com', Phone = '555-555-5553', Industry = 'Other', RecordTypeId = EDU_LEAD_RT_ID,
                                    DR_Deal_Type__c = Deal_Type, DR_Product__c = Primary_Product, DR_SKU_Quantity__c = 1, 
                                    DR_Is_Submitted__c = true, DR_Is_Approved__c = false, DR_Is_Denied__c = true, Status = 'Rejected');*/

                lstEduLeads.add(oEduLead1);
                lstEduLeads.add(oEduLead2);
                //lstEduLeads.add(oEduLead3);
                
                insert lstEduLeads;

                PageReference EDUDRRep = new PageReference('/apex/EDU_DR_Report');
                Test.setCurrentPage(EDUDRRep);                                    
                lstPending = EDU_DR_Report_ctlr.loadPendingEduLeads();
                lstApproved = EDU_DR_Report_ctlr.loadApprovedEduLeads();
                lstRejected = EDU_DR_Report_ctlr.loadRejectedEduLeads();
            }
            
        Test.stopTest();
    }

}