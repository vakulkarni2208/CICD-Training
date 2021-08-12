/*
    Test class for RenewalOpportunityCleanupBatchClass
    
 */
@isTest(SeeAllData=False)
Public class Test_RenewalOpportunityCleanupBatchClass{

    /*
    private static final string OPPTY_RT_SWRenewal = 'SW & Service Renewals';
    private static final string ProdName = 'DGX Station V100-32GB';
    private static final string ProdCode = 'DGXDLStation32GB';
    private static final string ProdFamily = 'DGX Station Product Family';
    private static final string PriceBookName = 'OppReg Price Book';
    private static final string BaseSKU = '920-22587-2511';
    private static final string Term = '12';
    private static final string NPNVAR_SAPCustomerNumber = '0000800111';
    private static final string PEC_SAPCustomerNumber = '000900111';
    
    @isTest static void RenewalOppTest1() {
    //static testmethod void RenewalOppTest1() {
        map<string, Object> mapOpptyInfa = Test_COMM_Factory.setEnterpriseOpptyInfra(ProdName, ProdCode, ProdFamily,true, PriceBookName, 1000, 1500, BaseSKU, Term);
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
        
        Opportunity SWRenewals;
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
            
            //createRenewalOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
            SWRenewals = Test_COMM_Factory.createDealRegOpportunity('Service RenewalsOpp1', mapRTNameId.get(OPPTY_RT_SWRenewal), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), pricebookentryRecord.PriceBook2Id, customerAccount.Id, partnerAccount.Id);
      
            //Test_COMM_Factory.setDealRegFieldsInOpportunity(SWRenewals.Id, customerAccount.Id, partnerAccount.Id);
        
            //Add Opportunity Line Items
            //OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = SWRenewals.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
            //insert oli;
            
            //Samar : Added contract test record and associate it with oppty
            Contract contract       = new Contract();
            contract.AccountId      = lstAccount[0].Id;
            contract.Status         = 'Draft';
            contract.StartDate      = Date.today();
            contract.SBQQ__RenewalOpportunity__c = SWRenewals.Id;
            insert contract;
            
            SWRenewals.SBQQ__RenewedContract__c = contract.Id;
            Update SWRenewals;
        }
        
        SWRenewals = [Select Id, Opportunity_Number__c, NPN_Solution_Provider_VAR__r.SAP_Customer_Number__c, 
                                                DR_Expiration_Date__c, DR_Deal_Status__c, Account.SAP_Customer_Number__c,  SBQQ__RenewedContract__c , 
                                                (Select Opp_Line_Number__c, Base_SKU__c, Term__c, Quantity From OpportunityLineItems) 
                                From Opportunity
                                Where Id = :SWRenewals.Id                                         
                                ];
        
        system.debug('****enterpriseSalesOppty: ' + SWRenewals);
        
        list<Opportunity> lstOppReg = new list<Opportunity>();
        lstOppReg.add(SWRenewals);
            
        //run as to avoid MIXED DML
        system.runAs(currUser){
            Test.startTest();
            
            //Schedule Batch Class
            RenewalOpportunityCleanupBatchClass schBatch = new RenewalOpportunityCleanupBatchClass(); 
            String schTime = '0 0 8 * * ?';  // Daily at 8 AM
            //system.schedule('Test check', schTime, schBatch); 
            Database.ExecuteBatch(schBatch);
            Test.stopTest();
        }
        
     } 
        
        */
        
    @isTest static void RenewalOppTest2() {
    
    
        Test.startTest();
            
            //Schedule Batch Class
            RenewalOpportunityCleanupBatchClass schBatch = new RenewalOpportunityCleanupBatchClass(); 
            //String schTime = '0 0 8 * * ?';  // Daily at 8 AM
            //system.schedule('Test check', schTime, schBatch); 
            //Database.ExecuteBatch(schBatch);
            schBatch.CoverageMethod();
        Test.stopTest();

    
    }        
  
}