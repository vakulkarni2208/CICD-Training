/*
    Test class for DR_OPPREG_SAP_SYNC_Batch
    2018.09.30 - pjena - Batch class to to Sync OPP REG data to SAP
    
    
 */
@isTest(SeeAllData=false)
private class Test_DR_OPPREG_SAP_SYNC_Batch {
    
    private static final string OPPTY_RT_ENTERPRISESALESOPPTY = 'Enterprise Sales Opportunity';
    private static final string ProdName = 'DGX Station V100-32GB';
    private static final string ProdCode = 'DGXDLStation32GB';
    private static final string ProdFamily = 'DGX Station Product Family';
    private static final string PriceBookName = 'OppReg Price Book';
    private static final string BaseSKU = '920-22587-2511';
    private static final string Term = '12';
    private static final string NPNVAR_SAPCustomerNumber = '0000800111';
    private static final string PEC_SAPCustomerNumber = '000900111';
    
    static testMethod void syncOppRegWithSAP_success() {
    
        //setEnterpriseOpptyInfra(string ProdName, string ProdFamily, string ProdCode, boolean isDealEnabled, string PriceBookName, decimal StandardPrice, decimal CustomPrice, string BaseSKU, string Term
        map<string, Object> mapOpptyInfa = Test_COMM_Factory.setEnterpriseOpptyInfra(ProdName, ProdCode, ProdFamily,true, PriceBookName, 1000, 1500, BaseSKU, Term);
        
        //get the infra objects back from the map
        Account partnerAccount = mapOpptyInfa.get('partneraccount') != null ? (Account) mapOpptyInfa.get('partneraccount') : new Account();
        Contact partnerContact = mapOpptyInfa.get('partnercontact') != null ? (Contact) mapOpptyInfa.get('partnercontact') : new Contact();
        Account customerAccount = mapOpptyInfa.get('customeraccount') != null ? (Account) mapOpptyInfa.get('customeraccount') : new Account();
        User partnerUser = mapOpptyInfa.get('partneruser') != null ? (User) mapOpptyInfa.get('partneruser') : new User();
        User pbm = mapOpptyInfa.get('pbm') != null ? (User) mapOpptyInfa.get('pbm') : new User();
        User pbmmanager = mapOpptyInfa.get('pbmmanager') != null ? (User) mapOpptyInfa.get('pbmmanager') : new User();
        User salesopsadmin = mapOpptyInfa.get('salesopsadmin') != null ? (User) mapOpptyInfa.get('salesopsadmin') : new User();
        PricebookEntry pricebookentryRecord = mapOpptyInfa.get('pricebookentry') != null ? (pricebookentry) mapOpptyInfa.get('pricebookentry') : new PricebookEntry();
        map<string, Id> mapProfNameId = mapOpptyInfa.get('mapprofnameid') != null ? (map<string, id>) mapOpptyInfa.get('mapprofnameid') : new map<string, Id>();
        map<String, Id> mapRTNameId = mapOpptyInfa.get('maprectypenameid') != null ? (map<string, Id>) mapOpptyInfa.get('maprectypenameid') : new map<string, Id>();
        
        Opportunity enterpriseSalesOppty;
        ApexPages.Standardcontroller stdCon;
        
        User currUser = [Select Id From User where Id = :userinfo.getUserId()];
        
        system.debug('***currUser: ' + currUser);
        
        list<Account> lstAccount = new list<Account>(); 
        system.runAs(currUser){
            customerAccount.SAP_Customer_Number__c = PEC_SAPCustomerNumber;
            partnerAccount.SAP_Customer_Number__c = NPNVAR_SAPCustomerNumber;
            lstAccount.add(customerAccount);
            lstAccount.add(partnerAccount);
            update lstAccount;
            
            DateTime dt = DateTime.now();
           list<SBQQ__QuoteTemplate__c> lstQT = new list<SBQQ__QuoteTemplate__c>();
           SBQQ__QuoteTemplate__c Quotetemplate = new SBQQ__QuoteTemplate__c (name ='Approved Quote - Initial Sale');
            lstQT.add(Quotetemplate);
            SBQQ__QuoteTemplate__c Quotetemplate1 = new SBQQ__QuoteTemplate__c (name ='Budgetary Quote - Initial Sale');
            lstQT.add(Quotetemplate1);
            insert lstQT;
           SOQ_QuoteCreation_Settings__c objSOQCS = new SOQ_QuoteCreation_Settings__c(Approved_Quote_Template_Id__c=Quotetemplate .id, Default_Template_Id__c=Quotetemplate1.id, Quote_Type_c__c = 'Quote', BATCHJOB_OppCreationCutOffDateTime__c=dt, Initial_Status__c = 'Draft', RecordTypeId__c=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Initial Enterprise Sales Quote').getRecordTypeId());
           insert objSOQCS;
            //Create the Enterprise Opportunity with Deal Registration
            //createDealRegOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
            System.debug('Limits.getLimitSoslQueries - '+ Limits.getLimitSoslQueries());
            enterpriseSalesOppty = Test_COMM_Factory.createDealRegOpportunity('Enterprise Sales Oppty1', mapRTNameId.get(OPPTY_RT_ENTERPRISESALESOPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), pricebookentryRecord.PriceBook2Id, customerAccount.Id, partnerAccount.Id);
            
        }
        
        enterpriseSalesOppty = [Select Id, Opportunity_Number__c, NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c, 
                                                DR_Expiration_Date__c, DR_Deal_Status__c, Account.SAP_Customer_Number__c,  
                                                (Select Opp_Line_Number__c, Base_SKU__c, Term__c, Quantity From OpportunityLineItems) 
                                From Opportunity
                                Where Id = :enterpriseSalesOppty.Id                                         
                                ];
        
        system.debug('****enterpriseSalesOppty: ' + enterpriseSalesOppty);
        
        list<Opportunity> lstOppReg = new list<Opportunity>();
        lstOppReg.add(enterpriseSalesOppty);
            
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DR_OppRegSAPSync_Success');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        
        //run as to avoid MIXED DML
        system.runAs(currUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, mock);    
                //set Deal Reg fields in Enterprise Opportunity
                Test_COMM_Factory.setDealRegFieldsInOpportunity(enterpriseSalesOppty.Id, customerAccount.Id, partnerAccount.Id);
            
                //Add Opportunity Line Items
                OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = enterpriseSalesOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
                insert oli;
            
                Database.BatchableContext     bc;
                DR_OPPREG_SAP_SYNC_Batch bClass = new DR_OPPREG_SAP_SYNC_Batch();
                Database.QueryLocator ql = bClass.start(bc);
                bClass.execute(bc, lstOppReg);
                bClass.finish(bc);
      
                list<Opportunity_SAP_Integration_Status__c> lstOppRegSAPSyncStatus = [Select Return_Type__c, Return_Code__c, Return_Message__c From Opportunity_SAP_Integration_Status__c Where OpportunityId__c = :lstOppReg];
                system.debug('***lstOppRegSAPSyncStatus: ' + lstOppRegSAPSyncStatus);
                for (Opportunity_SAP_Integration_Status__c syncStatus : lstOppRegSAPSyncStatus){
                    system.assert(syncStatus.Return_Type__c == 'S');
                }
            Test.stopTest();
        }
        
    }
    
    static testMethod void syncOppRegWithSAP_failure() {
    
        //setEnterpriseOpptyInfra(string ProdName, string ProdFamily, string ProdCode, boolean isDealEnabled, string PriceBookName, decimal StandardPrice, decimal CustomPrice, string BaseSKU, string Term
        map<string, Object> mapOpptyInfa = Test_COMM_Factory.setEnterpriseOpptyInfra(ProdName, ProdCode, ProdFamily,true, PriceBookName, 1000, 1500, BaseSKU, Term);
        
        //get the infra objects back from the map
        Account partnerAccount = mapOpptyInfa.get('partneraccount') != null ? (Account) mapOpptyInfa.get('partneraccount') : new Account();
        Contact partnerContact = mapOpptyInfa.get('partnercontact') != null ? (Contact) mapOpptyInfa.get('partnercontact') : new Contact();
        Account customerAccount = mapOpptyInfa.get('customeraccount') != null ? (Account) mapOpptyInfa.get('customeraccount') : new Account();
        User partnerUser = mapOpptyInfa.get('partneruser') != null ? (User) mapOpptyInfa.get('partneruser') : new User();
        User pbm = mapOpptyInfa.get('pbm') != null ? (User) mapOpptyInfa.get('pbm') : new User();
        User pbmmanager = mapOpptyInfa.get('pbmmanager') != null ? (User) mapOpptyInfa.get('pbmmanager') : new User();
        User salesopsadmin = mapOpptyInfa.get('salesopsadmin') != null ? (User) mapOpptyInfa.get('salesopsadmin') : new User();
        PricebookEntry pricebookentryRecord = mapOpptyInfa.get('pricebookentry') != null ? (pricebookentry) mapOpptyInfa.get('pricebookentry') : new PricebookEntry();
        map<string, Id> mapProfNameId = mapOpptyInfa.get('mapprofnameid') != null ? (map<string, id>) mapOpptyInfa.get('mapprofnameid') : new map<string, Id>();
        map<String, Id> mapRTNameId = mapOpptyInfa.get('maprectypenameid') != null ? (map<string, Id>) mapOpptyInfa.get('maprectypenameid') : new map<string, Id>();
        
        Opportunity enterpriseSalesOppty;
        ApexPages.Standardcontroller stdCon;
        
        User currUser = [Select Id From User where Id = :userinfo.getUserId()];
        
        system.debug('***currUser: ' + currUser);
        
        list<Account> lstAccount = new list<Account>(); 
        system.runAs(currUser){
            customerAccount.SAP_Customer_Number__c = PEC_SAPCustomerNumber;
            partnerAccount.SAP_Customer_Number__c = NPNVAR_SAPCustomerNumber;
            lstAccount.add(customerAccount);
            lstAccount.add(partnerAccount);
            update lstAccount;
            
            DateTime dt = DateTime.now();
           SBQQ__QuoteTemplate__c Quotetemplate = new SBQQ__QuoteTemplate__c (name ='Approved Quote - Initial Sale');
            insert Quotetemplate;
            SBQQ__QuoteTemplate__c Quotetemplate1 = new SBQQ__QuoteTemplate__c (name ='Budgetary Quote - Initial Sale');
            insert Quotetemplate1;
           SOQ_QuoteCreation_Settings__c objSOQCS = new SOQ_QuoteCreation_Settings__c(Approved_Quote_Template_Id__c=Quotetemplate .id, Default_Template_Id__c=Quotetemplate1.id, Quote_Type_c__c = 'Quote', BATCHJOB_OppCreationCutOffDateTime__c=dt, Initial_Status__c = 'Draft', RecordTypeId__c=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Initial Enterprise Sales Quote').getRecordTypeId());
           insert objSOQCS;
            //Create the Enterprise Opportunity with Deal Registration
            //createDealRegOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
            enterpriseSalesOppty = Test_COMM_Factory.createDealRegOpportunity('Enterprise Sales Oppty2', mapRTNameId.get(OPPTY_RT_ENTERPRISESALESOPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), pricebookentryRecord.PriceBook2Id, customerAccount.Id, partnerAccount.Id);
                    
            
        }
        
        enterpriseSalesOppty = [Select Id, Opportunity_Number__c, NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c, 
                                                DR_Expiration_Date__c, DR_Deal_Status__c, Account.SAP_Customer_Number__c,  
                                                (Select Opp_Line_Number__c, Base_SKU__c, Term__c, Quantity From OpportunityLineItems) 
                                From Opportunity
                                Where Id = :enterpriseSalesOppty.Id                                         
                                ];
        
        system.debug('****enterpriseSalesOppty: ' + enterpriseSalesOppty);
        
        list<Opportunity> lstOppReg = new list<Opportunity>();
        lstOppReg.add(enterpriseSalesOppty);
            
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DR_OppRegSAPSync_Failure');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        
        //run as to avoid MIXED DML
        system.runAs(currUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, mock);
                //set Deal Reg fields in Enterprise Opportunity
                Test_COMM_Factory.setDealRegFieldsInOpportunity(enterpriseSalesOppty.Id, customerAccount.Id, partnerAccount.Id);
            
                //Add Opportunity Line Items
                OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = enterpriseSalesOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
                insert oli;
                Database.BatchableContext     bc;
                DR_OPPREG_SAP_SYNC_Batch bClass = new DR_OPPREG_SAP_SYNC_Batch();
                Database.QueryLocator ql = bClass.start(bc);
                bClass.execute(bc, lstOppReg);
                bClass.finish(bc);
      
                list<Opportunity_SAP_Integration_Status__c> lstOppRegSAPSyncStatus = [Select Return_Type__c, Return_Code__c, Return_Message__c From Opportunity_SAP_Integration_Status__c Where OpportunityId__c = :lstOppReg];
                system.debug('***lstOppRegSAPSyncStatus: ' + lstOppRegSAPSyncStatus);
                for (Opportunity_SAP_Integration_Status__c syncStatus : lstOppRegSAPSyncStatus){
                    system.assert(syncStatus.Return_Type__c == 'E');
                }
            Test.stopTest();
        }
        
    }
    
    static testMethod void syncOppRegWithSAP_exceptionCoverage() {
    
        //setEnterpriseOpptyInfra(string ProdName, string ProdFamily, string ProdCode, boolean isDealEnabled, string PriceBookName, decimal StandardPrice, decimal CustomPrice, string BaseSKU, string Term
        map<string, Object> mapOpptyInfa = Test_COMM_Factory.setEnterpriseOpptyInfra(ProdName, ProdCode, ProdFamily,true, PriceBookName, 1000, 1500, BaseSKU, Term);
        
        //get the infra objects back from the map
        Account partnerAccount = mapOpptyInfa.get('partneraccount') != null ? (Account) mapOpptyInfa.get('partneraccount') : new Account();
        Contact partnerContact = mapOpptyInfa.get('partnercontact') != null ? (Contact) mapOpptyInfa.get('partnercontact') : new Contact();
        Account customerAccount = mapOpptyInfa.get('customeraccount') != null ? (Account) mapOpptyInfa.get('customeraccount') : new Account();
        User partnerUser = mapOpptyInfa.get('partneruser') != null ? (User) mapOpptyInfa.get('partneruser') : new User();
        User pbm = mapOpptyInfa.get('pbm') != null ? (User) mapOpptyInfa.get('pbm') : new User();
        User pbmmanager = mapOpptyInfa.get('pbmmanager') != null ? (User) mapOpptyInfa.get('pbmmanager') : new User();
        User salesopsadmin = mapOpptyInfa.get('salesopsadmin') != null ? (User) mapOpptyInfa.get('salesopsadmin') : new User();
        PricebookEntry pricebookentryRecord = mapOpptyInfa.get('pricebookentry') != null ? (pricebookentry) mapOpptyInfa.get('pricebookentry') : new PricebookEntry();
        map<string, Id> mapProfNameId = mapOpptyInfa.get('mapprofnameid') != null ? (map<string, id>) mapOpptyInfa.get('mapprofnameid') : new map<string, Id>();
        map<String, Id> mapRTNameId = mapOpptyInfa.get('maprectypenameid') != null ? (map<string, Id>) mapOpptyInfa.get('maprectypenameid') : new map<string, Id>();
        
        Opportunity enterpriseSalesOppty;
        ApexPages.Standardcontroller stdCon;
        
        User currUser = [Select Id From User where Id = :userinfo.getUserId()];
        
        system.debug('***currUser: ' + currUser);
        
        list<Account> lstAccount = new list<Account>(); 
        system.runAs(currUser){
            customerAccount.SAP_Customer_Number__c = PEC_SAPCustomerNumber;
            partnerAccount.SAP_Customer_Number__c = NPNVAR_SAPCustomerNumber;
            lstAccount.add(customerAccount);
            lstAccount.add(partnerAccount);
            update lstAccount;
            
           DateTime dt = DateTime.now();
           SBQQ__QuoteTemplate__c Quotetemplate = new SBQQ__QuoteTemplate__c (name ='Approved Quote - Initial Sale');
            insert Quotetemplate;
            SBQQ__QuoteTemplate__c Quotetemplate1 = new SBQQ__QuoteTemplate__c (name ='Budgetary Quote - Initial Sale');
            insert Quotetemplate1;
           SOQ_QuoteCreation_Settings__c objSOQCS = new SOQ_QuoteCreation_Settings__c(Approved_Quote_Template_Id__c=Quotetemplate .id, Default_Template_Id__c=Quotetemplate1.id, Quote_Type_c__c = 'Quote', BATCHJOB_OppCreationCutOffDateTime__c=dt, Initial_Status__c = 'Draft', RecordTypeId__c=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Initial Enterprise Sales Quote').getRecordTypeId());
           insert objSOQCS;
            //Create the Enterprise Opportunity with Deal Registration
            //createDealRegOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
            enterpriseSalesOppty = Test_COMM_Factory.createDealRegOpportunity('Enterprise Sales Oppty3', mapRTNameId.get(OPPTY_RT_ENTERPRISESALESOPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), pricebookentryRecord.PriceBook2Id, customerAccount.Id, partnerAccount.Id);
                    
            //set Deal Reg fields in Enterprise Opportunity; this will make sure the code in DR_OPPREG_SAP_SYNC_Batch batch execute throws exception
            //Test_COMM_Factory.setDealRegFieldsInOpportunity(enterpriseSalesOppty.Id, customerAccount.Id, partnerAccount.Id);
        
            //Add Opportunity Line Items
            
        }
        
        enterpriseSalesOppty = [Select Id, Opportunity_Number__c, NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c, 
                                                DR_Expiration_Date__c, DR_Deal_Status__c, Account.SAP_Customer_Number__c,  
                                                (Select Opp_Line_Number__c, Base_SKU__c, Term__c, Quantity From OpportunityLineItems) 
                                From Opportunity
                                Where Id = :enterpriseSalesOppty.Id                                         
                                ];
        
        system.debug('****enterpriseSalesOppty: ' + enterpriseSalesOppty);
        
        list<Opportunity> lstOppReg = new list<Opportunity>();
        lstOppReg.add(enterpriseSalesOppty);
            
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DR_OppRegSAPSync_Failure');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        
        //run as to avoid MIXED DML
        system.runAs(currUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, mock);
                OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = enterpriseSalesOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
                insert oli;
                Database.BatchableContext     bc;
                DR_OPPREG_SAP_SYNC_Batch bClass = new DR_OPPREG_SAP_SYNC_Batch();
                Database.QueryLocator ql = bClass.start(bc);
                
                //coverage for DR_OPPREG_SAP_SYNC_Wrapper > Opp_Approver structure
                list<DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER> lstApprovers = new list<DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER>();
                DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER drApprover = new DR_OPPREG_SAP_SYNC_Wrapper.OPP_APPROVER();
                drApprover.Opportunity_Counter = 'Channel Admin Approval';
                drApprover.Name = 'ApproverJohn Smith';
                drApprover.Email_ID = 'johnsmith@nvidia.com';
                drApprover.Approved_On = '20181019';
                drApprover.Approved_At = '045355';
                lstApprovers.add(drApprover);
                
                DR_SAPOppRegIntegration oDRSORI = new DR_SAPOppRegIntegration();
                DR_SAPOppRegIntegration.Header_element oHE = new DR_SAPOppRegIntegration.Header_element();
                DR_SAPOppRegIntegration.OppReg_Response_DT oORR = new DR_SAPOppRegIntegration.OppReg_Response_DT();
                DR_SAPOppRegIntegration.Item_element oIE = new DR_SAPOppRegIntegration.Item_element();
                DR_SAPOppRegIntegration.RETURN_ITEM_element oRIE = new DR_SAPOppRegIntegration.RETURN_ITEM_element();
                DR_SAPOppRegIntegration.Approver_element oAE = new DR_SAPOppRegIntegration.Approver_element();
                DR_SAPOppRegIntegration.OppReg_Request_DT oORRDT = new DR_SAPOppRegIntegration.OppReg_Request_DT();
                
                bClass.execute(bc, lstOppReg);
                bClass.finish(bc);
      
                list<Opportunity_SAP_Integration_Status__c> lstOppRegSAPSyncStatus = [Select Return_Type__c, Return_Code__c, Return_Message__c From Opportunity_SAP_Integration_Status__c Where OpportunityId__c = :lstOppReg];
                system.debug('***lstOppRegSAPSyncStatus: ' + lstOppRegSAPSyncStatus);
                for (Opportunity_SAP_Integration_Status__c syncStatus : lstOppRegSAPSyncStatus){
                    system.assert(syncStatus.Return_Type__c == 'E');
                }
            Test.stopTest();
        }
        
    }
    
    static testMethod void syncOppRegWithSAP_schedule() {
    
        //setEnterpriseOpptyInfra(string ProdName, string ProdFamily, string ProdCode, boolean isDealEnabled, string PriceBookName, decimal StandardPrice, decimal CustomPrice, string BaseSKU, string Term
        map<string, Object> mapOpptyInfa = Test_COMM_Factory.setEnterpriseOpptyInfra(ProdName, ProdCode, ProdFamily,true, PriceBookName, 1000, 1500, BaseSKU, Term);
        
        //get the infra objects back from the map
        Account partnerAccount = mapOpptyInfa.get('partneraccount') != null ? (Account) mapOpptyInfa.get('partneraccount') : new Account();
        Contact partnerContact = mapOpptyInfa.get('partnercontact') != null ? (Contact) mapOpptyInfa.get('partnercontact') : new Contact();
        Account customerAccount = mapOpptyInfa.get('customeraccount') != null ? (Account) mapOpptyInfa.get('customeraccount') : new Account();
        User partnerUser = mapOpptyInfa.get('partneruser') != null ? (User) mapOpptyInfa.get('partneruser') : new User();
        User pbm = mapOpptyInfa.get('pbm') != null ? (User) mapOpptyInfa.get('pbm') : new User();
        User pbmmanager = mapOpptyInfa.get('pbmmanager') != null ? (User) mapOpptyInfa.get('pbmmanager') : new User();
        User salesopsadmin = mapOpptyInfa.get('salesopsadmin') != null ? (User) mapOpptyInfa.get('salesopsadmin') : new User();
        PricebookEntry pricebookentryRecord = mapOpptyInfa.get('pricebookentry') != null ? (pricebookentry) mapOpptyInfa.get('pricebookentry') : new PricebookEntry();
        map<string, Id> mapProfNameId = mapOpptyInfa.get('mapprofnameid') != null ? (map<string, id>) mapOpptyInfa.get('mapprofnameid') : new map<string, Id>();
        map<String, Id> mapRTNameId = mapOpptyInfa.get('maprectypenameid') != null ? (map<string, Id>) mapOpptyInfa.get('maprectypenameid') : new map<string, Id>();
        
        Opportunity enterpriseSalesOppty;
        ApexPages.Standardcontroller stdCon;
        
        User currUser = [Select Id From User where Id = :userinfo.getUserId()];
        
        system.debug('***currUser: ' + currUser);
        
        list<Account> lstAccount = new list<Account>(); 
        system.runAs(currUser){
            customerAccount.SAP_Customer_Number__c = PEC_SAPCustomerNumber;
            partnerAccount.SAP_Customer_Number__c = NPNVAR_SAPCustomerNumber;
            lstAccount.add(customerAccount);
            lstAccount.add(partnerAccount);
            update lstAccount;
            
            DateTime dt = DateTime.now();
           SBQQ__QuoteTemplate__c Quotetemplate = new SBQQ__QuoteTemplate__c (name ='Approved Quote - Initial Sale');
            insert Quotetemplate;
            SBQQ__QuoteTemplate__c Quotetemplate1 = new SBQQ__QuoteTemplate__c (name ='Budgetary Quote - Initial Sale');
            insert Quotetemplate1;
           SOQ_QuoteCreation_Settings__c objSOQCS = new SOQ_QuoteCreation_Settings__c(Approved_Quote_Template_Id__c=Quotetemplate .id, Default_Template_Id__c=Quotetemplate1.id, Quote_Type_c__c = 'Quote', BATCHJOB_OppCreationCutOffDateTime__c=dt, Initial_Status__c = 'Draft', RecordTypeId__c=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Initial Enterprise Sales Quote').getRecordTypeId());
           insert objSOQCS;
            //Create the Enterprise Opportunity with Deal Registration
            //createDealRegOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
            enterpriseSalesOppty = Test_COMM_Factory.createDealRegOpportunity('Enterprise Sales Oppty1', mapRTNameId.get(OPPTY_RT_ENTERPRISESALESOPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), pricebookentryRecord.PriceBook2Id, customerAccount.Id, partnerAccount.Id);
                    
            
        }
        
        enterpriseSalesOppty = [Select Id, Opportunity_Number__c, NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c, 
                                                DR_Expiration_Date__c, DR_Deal_Status__c, Account.SAP_Customer_Number__c,  
                                                (Select Opp_Line_Number__c, Base_SKU__c, Term__c, Quantity From OpportunityLineItems) 
                                From Opportunity
                                Where Id = :enterpriseSalesOppty.Id                                         
                                ];
        
        system.debug('****enterpriseSalesOppty: ' + enterpriseSalesOppty);
        
        DR_OPPREG_SAP_SYNC_Batch bClass = new DR_OPPREG_SAP_SYNC_Batch();
        
        
        list<Opportunity> lstOppReg = new list<Opportunity>();
        lstOppReg.add(enterpriseSalesOppty);
            
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DR_OppRegSAPSync_Success');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        
        //run as to avoid MIXED DML
        system.runAs(currUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, mock);
                //set Deal Reg fields in Enterprise Opportunity
                Test_COMM_Factory.setDealRegFieldsInOpportunity(enterpriseSalesOppty.Id, customerAccount.Id, partnerAccount.Id);
            
                //Add Opportunity Line Items
                OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = enterpriseSalesOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
                insert oli;
                DR_OPPREG_SAP_SYNC_Batch p = new DR_OPPREG_SAP_SYNC_Batch();
                Database.BatchableContext     bc;
                Database.QueryLocator ql = p.start(bc);
                DateTime currDT = DateTime.now().addMinutes(2);
                integer sec = currDT.second();
                integer min = currDT.minute();
                string sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
                system.debug('sch: ' + sch);
                system.schedule('Exec of DR_OPPREG_SAP_SYNC_Batch', sch, p);                
            Test.stopTest();
            
            //check the status now as the schedule run is complete after the stopTest method
            list<Opportunity_SAP_Integration_Status__c> lstOppRegSAPSyncStatus = [Select Return_Type__c, Return_Code__c, Return_Message__c From Opportunity_SAP_Integration_Status__c Where OpportunityId__c = :lstOppReg];
            system.debug('***lstOppRegSAPSyncStatus: ' + lstOppRegSAPSyncStatus);
            for (Opportunity_SAP_Integration_Status__c syncStatus : lstOppRegSAPSyncStatus){
                system.assert(syncStatus.Return_Type__c == 'S');
            }
        }
        
    }
}