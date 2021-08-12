/*
    Test class for controller class CRM_DR_TerminateDeal_cls
    2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
    2017.06.21 - Test class retrofit during MDF v1/v2 code cleanup
    2017.08.23 - Restrict Partners Closing Out Opportunity Regs - Code clean up
    2017.10.19 - 2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
        -Remove Termination capability from partners
    
    2017.11.29 - PJENA - Deal Registration - only allow Deal Registration types to be terminated
    
    2019.03.11 - PJENA - SDS-774 - Remove Partner Opportunity Record Types
 */
 
@isTest(SeeAllData=false)
private class Test_CRM_DR_TerminateDeal_cls {
    
    private static final string OPPTY_RT_ENTERPRISESALESOPPTY = 'Enterprise Sales Opportunity';
    private static final string ProdName = 'DGX Station V100-32GB';
    private static final string ProdCode = 'DGXDLStation32GB';
    private static final string ProdFamily = 'DGX Station Product Family';
    private static final string PriceBookName = 'OppReg Price Book';
    private static final string BaseSKU = '920-22587-2511';
    private static final string Term = '12';
    private static final string NPNVAR_SAPCustomerNumber = '0000800112';
    private static final string PEC_SAPCustomerNumber = '000900112';
    
    
    //SalesOps Admin terminates the deal after Opp Reg submission by partner
    static testMethod void testTerminateDeal_AuthorizedAndValid() {
        
        //setEnterpriseOpptyInfra(string ProdName, string ProdFamily, string ProdCode, boolean isDealEnabled, string PriceBookName, decimal StandardPrice, decimal CustomPrice, string BaseSKU, string Term
        map<string, Object> mapOpptyInfa = Test_COMM_Factory.setEnterpriseOpptyInfra(ProdName, ProdCode, ProdFamily,true, PriceBookName, 1000, 1500, BaseSKU, Term);
        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
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
            
           SOQ_QuoteCreation_Settings__c objSOQCS = new SOQ_QuoteCreation_Settings__c(Approved_Quote_Template_Id__c=Quotetemplate.id, Default_Template_Id__c=Quotetemplate1.id, Quote_Type_c__c = 'Quote', BATCHJOB_OppCreationCutOffDateTime__c=dt, Initial_Status__c = 'Draft', RecordTypeId__c=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Initial Enterprise Sales Quote').getRecordTypeId());
           insert objSOQCS;
            //Create the Enterprise Opportunity with Deal Registration
            //createDealRegOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
            System.debug('Limits.getLimitQueries()- '+ Limits.getLimitQueries());
            System.debug('Limits.getQueries()- '+ Limits.getQueries());
            enterpriseSalesOppty = Test_COMM_Factory.createDealRegOpportunity('Enterprise Sales Oppty1', mapRTNameId.get(OPPTY_RT_ENTERPRISESALESOPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), pricebookentryRecord.PriceBook2Id, customerAccount.Id, partnerAccount.Id);
            System.debug('Limits.getQueries()- '+ Limits.getQueries());        
            
            Test.startTest();
                //set Deal Reg fields in Enterprise Opportunity
                Test_COMM_Factory.setDealRegFieldsInOpportunity(enterpriseSalesOppty.Id, customerAccount.Id, partnerAccount.Id);
                System.debug('Limits.getQueries()- '+ Limits.getQueries());
                //Add Opportunity Line Items
                OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = enterpriseSalesOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
                insert oli;
                System.debug('Limits.getQueries()- '+ Limits.getQueries());
            
                //Terminate the Deal
                //---------------------------------------------------------
                PageReference pageRefTerminateDeal = new PageReference('/apex/CRM_DR_TerminateDeal');
                Test.setCurrentPage(pageRefTerminateDeal);
                ApexPages.currentPage().getParameters().put('Id', enterpriseSalesOppty.Id);
                    
                //Set the reasonForTermination contoller member and call the terminateDeal controller method
                CRM_DR_TerminateDeal_cls terminateDealCtlr = new CRM_DR_TerminateDeal_cls(stdCon);
                terminateDealCtlr.reasonForTermination = 'Terminated From Test class';
                pageRefTerminateDeal = terminateDealCtlr.terminateDeal();
                //---------------------------------------------------------
                System.debug('Limits.getQueries()--> InSTT '+ Limits.getQueries());    
                    
                Opportunity enterpriseSalesOpptyQry = [Select DR_Reason_For_Termination__c, DR_Is_Terminated__c, DR_Deal_Status__c From Opportunity Where id = :enterpriseSalesOppty.Id];
                System.debug('Limits.getQueries()--> InSTT '+ Limits.getQueries());    
                system.debug('***enterpriseSalesOpptyQry: ' + enterpriseSalesOpptyQry);
                system.assert(enterpriseSalesOpptyQry.DR_Is_Terminated__c == true);
            Test.stopTest();
        }
    }
    
}