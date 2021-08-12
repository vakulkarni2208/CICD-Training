/**
    2018.11.25 - Test class for CRM_AddPBMsAsOpptyTeamMember_Batch
    
 */
@isTest(SeeAllData=false)
private class Test_CRM_AddPBMsAsOpptyTeamMember_Batch {
    private static final string OPPTY_RT_ENTERPRISESALESOPPTY = 'Enterprise Sales Opportunity';
    private static final string ProdName = 'DGX Station V100-32GB';
    private static final string ProdCode = 'DGXDLStation32GB';
    private static final string ProdFamily = 'DGX Station Product Family';
    private static final string PriceBookName = 'OppReg Price Book';
    private static final string BaseSKU = '920-22587-2511';
    private static final string Term = '12';
    
    static testMethod void myUnitTest() {
        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);        
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        // TO DO: implement unit test
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
        
        
        //set up the custom settings
        CRM_AddPBMsAsOpptyTeamMember_Settings__c oCSSettings = new CRM_AddPBMsAsOpptyTeamMember_Settings__c();
        oCSSettings.Name = 'CRM :AddPBMsAsOpptyTeamMember : Settings';
        oCSSettings.BATCH_SIZE__c = 10;
        oCSSettings.ENABLE_SCHDULED_JOB__c = true;
        oCSSettings.LKBK_TIME__c = 15;
        oCSSettings.RECUR__c = 10;
        oCSSettings.Team_Role__c = 'Channel Manager (PBM)';

        if (Test.isRunningTest()){
            insert oCSSettings;
        }
   
    
        
        system.runAs(currUser){
            //Create the Enterprise Opportunity with Deal Registration
            //createDealRegOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
            DateTime dt = DateTime.now();
            SBQQ__QuoteTemplate__c Quotetemplate = new SBQQ__QuoteTemplate__c (name ='Approved Quote - Initial Sale');
            insert Quotetemplate;
            SBQQ__QuoteTemplate__c Quotetemplate1 = new SBQQ__QuoteTemplate__c (name ='Budgetary Quote - Initial Sale');
            insert Quotetemplate1;
            SOQ_QuoteCreation_Settings__c objSOQCS = new SOQ_QuoteCreation_Settings__c(Approved_Quote_Template_Id__c=Quotetemplate.id, Default_Template_Id__c=Quotetemplate1.id, Quote_Type_c__c = 'Quote', BATCHJOB_OppCreationCutOffDateTime__c=dt, Initial_Status__c = 'Draft', RecordTypeId__c=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Initial Enterprise Sales Quote').getRecordTypeId());
            insert objSOQCS;
            enterpriseSalesOppty = Test_COMM_Factory.createDealRegOpportunity('Enterprise Sales Oppty1', mapRTNameId.get(OPPTY_RT_ENTERPRISESALESOPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), pricebookentryRecord.PriceBook2Id, customerAccount.Id, partnerAccount.Id);
                    
        }
        
        list<Opportunity> lstOppReg = new list<Opportunity>();
        lstOppReg.add(enterpriseSalesOppty);
        
        system.runAs(currUser){
            Test.startTest();
            
            //set Deal Reg fields in Enterprise Opportunity
            Test_COMM_Factory.setDealRegFieldsInOpportunity(enterpriseSalesOppty.Id, customerAccount.Id, partnerAccount.Id);
        
            //Add Opportunity Line Items
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = enterpriseSalesOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
            insert oli;
            
            string CRON_EXP = '0 5 * ? * *';
            
            // Schedule the test job
            String jobId = System.schedule('Test_CRM_AddPBMsAsOpptyTeamMember_Batch',  CRON_EXP ,  new CRM_AddPBMsAsOpptyTeamMember_Batch());

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);

            
            Test.stopTest();
        }
        
        
    }
}