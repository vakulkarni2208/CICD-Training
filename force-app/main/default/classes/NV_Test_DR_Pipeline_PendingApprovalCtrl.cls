/*
    201.11.29 - Deal Registration - Test Class for NV_DR_Pipeline_PendingApprovalController
    
 */
@isTest(SeeAllData=false)
private class NV_Test_DR_Pipeline_PendingApprovalCtrl{
    
    private static map<string, Country_List__c> mapCountryList{get;set;}
    private static map<string, Id> mapProfNameId{get;set;}
    private static map<string, Id> mapRTNameId{get;set;}
    private static Account partnerAcc{get;set;}
    private static Contact partnerContact1{get;set;}
    private static Contact partnerContact2{get;set;}
    private static User partnerUser1{get;set;}
    /*
     static testMethod void myUnitTest3() {
        
        Test.startTest();
            //Create infrastructure - to allow parnters to create a deal reg record
            //---------------------------------------------------------------------------
            genericMock fakeResp = new genericMock(200,  'Complete', '{"StatusCode": "200","Status": "Success","Message": "Success : Found Records","Data": {"Type": "NPN Account Registry","Name": "Solution Advisor J1","Id": "001n000000Sozo4AAB"}}',null);
            System.Test.setMock(HttpCalloutMock.class, fakeResp);            
            createDRInfrastructure();
        Test.stopTest();
     }
     */
    
    static testMethod void myUnitTest1() {
        
       
            //Create infrastructure - to allow parnters to create a deal reg record
            //---------------------------------------------------------------------------
            
            genericMock fakeResp = new genericMock(200,  'Complete', '{"StatusCode": "200","Status": "Success","Message": "Success : Found Records","Data": {"Type": "NPN Account Registry","Name": "Solution Advisor J1","Id": "001n000000Sozo4AAB"}}',null);
            System.Test.setMock(HttpCalloutMock.class, fakeResp);
            
            createDRInfrastructure();
            //End: Create infrastructure - to allow parnters to create a deal reg record
            //---------------------------------------------------------------------------
            
            partnerContact2 = [Select Email,AccountId From Contact Where Id = :partnerContact2.Id];
            
            Lead oDRLead, oDRLead2;
            Account acc;
            Opportunity opp;
            OpportunityLineItem oli;
            Product2 prod;
            Pricebook2 pb;
            PricebookEntry pbe;
            
        
            //system.runAs(partnerUser1){
            
                oDRLead = new Lead(Company = 'DRCustomerOne', Street = COMM_Constants.ADDRESS_STREET, City = COMM_Constants.ADDRESS_CITY, State = COMM_Constants.ADDRESS_STATE,  Country = COMM_Constants.ADDRESS_COUNTRY, PostalCode = COMM_Constants.ADDRESS_ZIP, 
                            FirstName = 'DRCustUsrFName1', LastName = 'DRCustUsrLName1', Title = 'CEO', Email = 'drf1l1cust1@customerone.com', Phone = '555-555-5555', Industry = 'Other', RecordTypeId = mapRTNameId.get(DR_Settings__c.getOrgDefaults().Lead_RecordTypeName_For_Deal_Reg__c),
                            DR_Additional_Team_Member_Email__c = partnerContact2.Email);
                oDRLead2 = new Lead(Company = 'DRCustomerOne', Street = COMM_Constants.ADDRESS_STREET, City = COMM_Constants.ADDRESS_CITY, State = COMM_Constants.ADDRESS_STATE,  CountryCode = COMM_Constants.ADDRESS_US_ISO2, PostalCode = COMM_Constants.ADDRESS_ZIP, 
                            FirstName = 'DRCustUsrFName1', LastName = 'DRCustUsrLName1', Title = 'CEO', Email = 'drf1l1cust10@customerone.com', Phone = '555-555-5555', Industry = 'Other', RecordTypeId = mapRTNameId.get(DR_Settings__c.getOrgDefaults().Lead_RecordTypeName_For_Deal_Reg__c),
                            DR_Additional_Team_Member_Email__c = partnerContact2.Email);
                insert oDRLead2;
                
                //pb = [select id from Pricebook2 limit 1];
                RecordType rt = [select id from RecordType where name = 'Enterprise Sales Opportunity' and sobjecttype='Opportunity'];                
                pb = new Pricebook2(name='test pricebook', isActive = true);
                insert pb;
                
                prod = new Product2(name='test prod', isActive = true);
                insert prod;
                
                pbe = new PricebookEntry();
                pbe.Pricebook2Id=Test.getStandardPricebookId();
                pbe.Product2Id=prod.id;
                pbe.UnitPrice=3000;
                pbe.UseStandardPrice=false;
                pbe.isActive=true;//Add this line
                //insert pbe;
                //pbe = new PriceBookEntry(product2Id = prod.id, pricebook2Id = pb.id, unitPrice=10, isActive = true);
                insert pbe;
                
                acc = new Account(name='test Account', BillingCity = 'Santa Clara', BillingCountry='United States', BillingStreet = 'test street', BillingPostalCode = '20014', BillingState = 'California', Industry = 'Supercomputing');
                insert acc;
                
                opp =  new Opportunity(AccountId = acc.id, DR_Partner_Sales_Rep_Name__c = partnerUser1.contactId, DR_Lead_Type__c = 'Deal Registration', DR_Is_Approved__c = True, DR_Partner_Sales_Rep_Company__c = partnerContact2.AccountId, name='test varun opp', StageName = 'Prospecting', CloseDate = System.today(), recordTypeId = rt.id, type='Deal Registration', Industry__c = 'Supercomputing', Account_Industry_Override_Reason__c ='test', Lead_Id_For_Opportunity__c = oDRLead2.Id);
                insert opp;
                
                oli = new OpportunityLineItem(OpportunityId = opp.id, quantity = 2, pricebookentryId = pbe.id, TotalPrice=20);
                insert oli;
            
            Test.startTest();
                opp.stageName = 'Closed Won';
                update opp; 
                
            system.runAs(partnerUser1){
                PageReference prDRCreateDR = new PageReference('/apex/DR_CreateDR');
                Test.setCurrentPage(prDRCreateDR);
                
                DR_CreateDR_cls ctlr = new DR_CreateDR_cls();
                ctlr.oDealReg = oDRLead;
                PageReference prSave = ctlr.saveDR();
                system.debug('***ctlr.oDealReg: ' + ctlr.oDealReg);
                
                NV_DR_Pipeline_PendingApprovalController controller = new NV_DR_Pipeline_PendingApprovalController();                
                NV_DR_Pipeline_PendingApprovalController.loadOverallPipeline();
                NV_DR_Pipeline_PendingApprovalController.loadClosedWonPipelineCurrentFQ();
                NV_DR_Pipeline_PendingApprovalController.loadOverallPipelineCurrentFQ();
                NV_DR_Pipeline_PendingApprovalController.loadOverallPipelineClosedWon();
                NV_DR_Pipeline_PendingApprovalController.loadPendingApprovalLeads();
                NV_DR_Pipeline_PendingApprovalController.loadOverallPipelineClosedLost();
            }
            
        Test.stopTest();
        
    }
    
    static testMethod void myUnitTest2() {
        //Create infrastructure - to allow parnters to create a deal reg record
        //---------------------------------------------------------------------------

        Test.startTest();

            genericMock fakeResp = new genericMock(200,  'Complete', '{"StatusCode": "200","Status": "Success","Message": "Success : Found Records","Data": {"Type": "NPN Account Registry","Name": "Solution Advisor J1","Id": "001n000000Sozo4AAB"}}',null);
            System.Test.setMock(HttpCalloutMock.class, fakeResp);
            
            createDRInfrastructure();
            //genericMock fakeResp = new genericMock(200,  'Complete', '{"StatusCode": "200","Status": "Success","Message": "Success : Found Records","Data": {"Type": "NPN Account Registry","Name": "Solution Advisor J1","Id": "001n000000Sozo4AAB"}}',null);
            //System.Test.setMock(HttpCalloutMock.class, fakeResp);
            //End: Create infrastructure - to allow parnters to create a deal reg record
            //---------------------------------------------------------------------------
            
            partnerContact2 = [Select Email,AccountId From Contact Where Id = :partnerContact2.Id];
            
            Lead oDRLead;
            Account acc;
            Opportunity opp;
            OpportunityLineItem oli;
            Product2 prod;
            Pricebook2 pb;
            PricebookEntry pbe;
        
        
            system.runAs(partnerUser1){
                
                oDRLead = new Lead(DR_Is_Submitted_via_Btn_Click__c=true, DR_ChannelAdmin__c = partnerUser1.id, Company = 'DRCustomerOne', Street = COMM_Constants.ADDRESS_STREET, City = COMM_Constants.ADDRESS_CITY, State = COMM_Constants.ADDRESS_STATE,  Country = COMM_Constants.ADDRESS_COUNTRY, PostalCode = COMM_Constants.ADDRESS_ZIP, 
                            Status='In Review', FirstName = 'DRCustUsrFName1', LastName = 'DRCustUsrLName1', Title = 'CEO', Email = 'drf1l1cust1@customerone.com', Phone = '555-555-5555', Industry = 'Other', RecordTypeId = mapRTNameId.get(DR_Settings__c.getOrgDefaults().Lead_RecordTypeName_For_Deal_Reg__c),
                            DR_Additional_Team_Member_Email__c = partnerContact2.Email);
                //pb = [select id from Pricebook2 limit 1];
                insert oDRLead;
                
                system.debug(oDRLead.DR_Is_Submitted__c);
                Approval.ProcessSubmitRequest req1 = 
                    new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(oDRLead.id);
                req1.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req1);
                List<Id> newWorkItemIds = result.getNewWorkitemIds();
                 Approval.ProcessWorkitemRequest req2 = 
                    new Approval.ProcessWorkitemRequest();
                req2.setComments('Rejecting request.');
                req2.setAction('Reject');
                
                // Use the ID from the newly created item to specify the item to be worked
                req2.setWorkitemId(newWorkItemIds.get(0));
                
                // Submit the request for approval
                Approval.ProcessResult result2 =  Approval.process(req2);
                
                NV_DR_Pipeline_PendingApprovalController.loadRejectedLeads();
            }
            
        Test.stopTest();
        
    }
    
    private static void createDRInfrastructure(){
        //Create Country List record
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = COMM_Constants.ADDRESS_COUNTRY, ISO_Code__c = COMM_Constants.ADDRESS_US_ISO2, ISO_Code_3__c=COMM_Constants.ADDRESS_US_ISO3, Region__c = COMM_Constants.ADDRESS_REGION_NALA, Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, Territory__c = COMM_Constants.ADDRESS_TERRITORY_LA); 
        lstCountry.add(countryUS);
        mapCountryList = Test_COMM_Factory.setCountryList(lstCountry);
        
        //Sets DR : Settings data - Deal Reg related setCSDRSettingsData
        //create custom settings for Deal data
        Test_COMM_Factory.setCSDRSettingsData();
        
        
        //get All Profiles (PROF_PP_VGX_GENERIC = NPN Partner Community(LOGIN), PROF_INT_PARTNER_ADMIN = Sales Profile - Partner Admin)
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN };
        mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Lead'};
        mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account and Contact variable so it is visible down below
        
        
        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;
        
        //Create a Partner Contact 
        partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        partnerContact2 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena22', 'FContact22', partnerAcc.Id, 'drcontactjena22@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        //Create a Partner User with profile named 'GRID VGX Partner Portal Profile(Generic)'
        partnerUser1 = Test_COMM_Factory.createUser(partnerContact1.Id, mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC));
        
        //get hold of the logged on user to flip the context to avoid the MIXD DML issue
        list<User> lstInternalUsersWithPAProf;
        User self = [Select Id From User where id = :UserInfo.getUserId()];
        system.runAs(self){
            //Create Internal User with Partner Admin profile
            lstInternalUsersWithPAProf = Test_COMM_Factory.createUsers(1, mapProfNameId.get(COMM_Constants.PROF_INT_PARTNER_ADMIN));
        }
        
        //create custom setting for Sales Ops Admin: svcDeploy or current user is the SalesOps Admin for both United States and Others
        Test_COMM_Factory.setDRSalesOpsAdmin(lstInternalUsersWithPAProf[0].Username);
    }
}