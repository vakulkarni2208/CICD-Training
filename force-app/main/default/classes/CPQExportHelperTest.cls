/**
 *  ================================================================================================
 *   Version    Date              Comment
 *  ================================================================================================
 *   v1.0      Feb-14-2016       - Test class to test handling of error responses of callout
 *                               - Tests if CPQ Export Log object record is created as required
 *                               - Tests if order that are successful are updated with Submitted to SAP as true
 */
@isTest
private class CPQExportHelperTest {
    
    @TestSetup
    static void createTestData() {
        
        // Create two accounts
        Account objAccount = createAccount();
        createAccount();
        // Create three contacts
        Contact con1 = createContact();
        Contact con2 = createContact();
        Contact con3 = createContact();
        list<Contact> listContact = new list<Contact>();
        listContact.add(con1);
        listContact.add(con2);
        listContact.add(con3);
        insert listContact;
        // Create Price Book
        Id pbId = CreatePriceBook();
        list<Opportunity> listOpp = new list<Opportunity>();
        listOpp.add(createOpportunity(objAccount.Id, pbId));
        listOpp.add(createOpportunity(objAccount.Id, pbId));
        listOpp.add(createOpportunity(objAccount.Id, pbId));
        listOpp.add(createOpportunity(objAccount.Id, pbId));
        insert listOpp;
        list<SBQQ__Quote__c> lstQuote = new list<SBQQ__Quote__c>();
        for(Opportunity opp : listOpp) {
            lstQuote.add(createQuote(opp.Id));
        }
        insert lstQuote;
    }
    
    private static string getRand(string prepend){
        return prepend + Math.roundToLong(Math.random() * 999) ;
    }
    
    /**
     * Method to create Account test data
     */
    public static Account createAccount(){
    
        Account objAccount = new Account();
        objAccount.Name = getRand('Test');
        insert objAccount;
        return objAccount;
    }

    /**
     * Method to create Contact test data
     */
    public static Contact createContact(){
        Contact objContact = new Contact();
        objContact.LastName = getRand('Test');
        return objContact;
    }
    
    public static Opportunity createOpportunity(Id acctId, Id pbId) {
        
        Opportunity opp = new Opportunity();
        opp.Name = getRand('Test Opp');
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.AccountId = acctId;
        opp.Pricebook2Id = pbId;
        return opp;
        
    }
    
    public static SBQQ__Quote__c createQuote(Id oppId) {
            
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Primary__c = True;
        quote.SBQQ__Type__c = 'Quote';
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__StartDate__c = Date.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
        return quote;
        
    }
    
    public static Id CreatePriceBook() {

        PriceBook2 pb = new PriceBook2();
        pb.Name = getRand('Test Price Book');
        pb.Description = 'Test Price Book';

        return pb.Id;
    } 
    
    /**
     * Method to create Order test data
     */
    public static Order createOrder(Id accId, Id quoteId, Boolean isInsert){
        Order objOrder = new Order();
        objOrder.Name = getRand('Test');
        objOrder.AccountId = accId;
        objOrder.SBQQ__Quote__c = quoteId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = System.Date.Today();
        objOrder.PO_Date__c = System.Date.Today();
        objOrder.Purchase_Order_Number__c = '12345';
        objOrder.Sales_Organization__c = '2100';
        return objOrder;
    }

    /**
     * Method to test method AccountErrors
     */
    @isTest static void test_AccountErrors() {
 
        // query acc and pass accLst and errorMsg
        List<Account> lstAccs = [Select Id From Account];
        list<SBQQ__Quote__c> lstQuote = [select id from SBQQ__Quote__c ];
        System.Test.startTest();
            list<Order> lstOrder = new list<Order>();
            for(SBQQ__Quote__c quote : lstQuote) {
                lstOrder.add(createOrder(lstAccs[0].Id, quote.Id, true));
            }
            // Create four orders
            insert lstOrder;
            CPQExportHelper.AccountErrors(lstAccs, 'Account Export has failed');
        System.Test.stopTest();

        // assert if CPQ_Export_Log__c is created as required
        List<CPQ_Export_Log__c> lstExportLog = [Select Message__c, Object__c, Record_Count__c, Result__c From CPQ_Export_Log__c];
        System.Assert(lstExportLog.size()<>0,'Log record not inserted for failed record');
        System.Assert(lstExportLog.size()==1,'Log list size returned is not 1');
        System.Assert(lstExportLog[0].Result__c=='Failure');
        System.Assert(lstExportLog[0].Message__c=='Account Export has failed');
        System.Assert(lstExportLog[0].Object__c=='Account');
        System.Assert(lstExportLog[0].Record_Count__c==lstAccs.size());
    }

    /**
     * Method to test method ContactErrors
     */
    @isTest static void test_ContactErrors() {
        // query Contact and pass contactLst and errorMsg
        List<Contact> lstContacts = [Select Id From Contact];
        List<Account> lstAccs = [Select Id From Account];
        list<SBQQ__Quote__c> lstQuote = [select id from SBQQ__Quote__c ];
        System.Test.startTest();
            list<Order> lstOrder = new list<Order>();
            for(SBQQ__Quote__c quote : lstQuote) {
                lstOrder.add(createOrder(lstAccs[0].Id, quote.Id, true));
            }
            // Create four orders
            insert lstOrder;
            CPQExportHelper.ContactErrors(lstContacts, 'Contact Export has failed');
        System.Test.stopTest();

        // assert if CPQ_Export_Log__c is created as required
        List<CPQ_Export_Log__c> lstExportLog = [Select Message__c, Object__c, Record_Count__c, Result__c From CPQ_Export_Log__c];
        System.Assert(lstExportLog.size()<>0,'Log record not inserted for failed record');
        System.Assert(lstExportLog.size()==1,'Log list size returned is not 1');
        System.Assert(lstExportLog[0].Result__c=='Failure');
        System.Assert(lstExportLog[0].Message__c=='Contact Export has failed');
        System.Assert(lstExportLog[0].Object__c=='Contact');
        System.Assert(lstExportLog[0].Record_Count__c==lstContacts.size());
    }

    /**
     * Method to test method OrderErrors
     */
    @isTest static void test_OrderErrors() {
        // query Order and pass OrderLst and errorMsg
        List<Order> lstOrders = [Select Id From Order];
        List<Account> lstAccs = [Select Id From Account];
        list<SBQQ__Quote__c> lstQuote = [select id from SBQQ__Quote__c ];
        System.Test.startTest();
            list<Order> lstOrder = new list<Order>();
            for(SBQQ__Quote__c quote : lstQuote) {
                lstOrder.add(createOrder(lstAccs[0].Id, quote.Id, true));
            }
            // Create four orders
            insert lstOrder;
            CPQExportHelper.OrderErrors(lstOrders, 'Order Export has failed');
        System.Test.stopTest();

        // assert if CPQ_Export_Log__c is created as required
        List<CPQ_Export_Log__c> lstExportLog = [Select Message__c, Object__c, Record_Count__c, Result__c From CPQ_Export_Log__c];
        System.Assert(lstExportLog.size()<>0,'Log record not inserted for failed record');
        System.Assert(lstExportLog.size()==1,'Log list size returned is not 1');
        System.Assert(lstExportLog[0].Result__c=='Failure');
        System.Assert(lstExportLog[0].Message__c=='Order Export has failed');
        System.Assert(lstExportLog[0].Object__c=='Order');
        System.Assert(lstExportLog[0].Record_Count__c==lstOrders.size());
    }

    /**
     * Method to test method AccountSuccess
     */
    @isTest static void test_AccountSuccess() {

        // query acc and pass accLst and errorMsg
        List<Account> lstAccs = [Select Id From Account];
        list<SBQQ__Quote__c> lstQuote = [select id from SBQQ__Quote__c ];
        System.Test.startTest();
            list<Order> lstOrder = new list<Order>();
            for(SBQQ__Quote__c quote : lstQuote) {
                lstOrder.add(createOrder(lstAccs[0].Id, quote.Id, true));
            }
            // Create four orders
            insert lstOrder;
            CPQExportHelper.AccountSuccess(lstAccs);
        System.Test.stopTest();

        // assert if CPQ_Export_Log__c is created as required
        List<CPQ_Export_Log__c> lstExportLog = [Select Message__c, Object__c, Record_Count__c, Result__c From CPQ_Export_Log__c];
        System.Assert(lstExportLog.size()<>0,'Log record not inserted for failed record');
        System.Assert(lstExportLog.size()==1,'Log list size returned is not 1');
        System.Assert(lstExportLog[0].Result__c=='Success');
        System.Assert(lstExportLog[0].Message__c==null);
        System.Assert(lstExportLog[0].Object__c=='Account');
        System.Assert(lstExportLog[0].Record_Count__c==lstAccs.size());
    }

    /**
     * Method to test method ContactSuccess
     */
    @isTest static void test_ContactSuccess() {

        // query acc and pass accLst and errorMsg
        List<Contact> lstContacts = [Select Id From Contact];
        List<Account> lstAccs = [Select Id From Account];
        list<SBQQ__Quote__c> lstQuote = [select id from SBQQ__Quote__c ];
        System.Test.startTest();
            list<Order> lstOrder = new list<Order>();
            for(SBQQ__Quote__c quote : lstQuote) {
                lstOrder.add(createOrder(lstAccs[0].Id, quote.Id, true));
            }
            // Create four orders
            insert lstOrder;
            CPQExportHelper.ContactSuccess(lstContacts);
        System.Test.stopTest();

        // assert if CPQ_Export_Log__c is created as required
        List<CPQ_Export_Log__c> lstExportLog = [Select Message__c, Object__c, Record_Count__c, Result__c From CPQ_Export_Log__c];
        System.Assert(lstExportLog.size()<>0,'Log record not inserted for failed record');
        System.Assert(lstExportLog.size()==1,'Log list size returned is not 1');
        System.Assert(lstExportLog[0].Result__c=='Success');
        System.Assert(lstExportLog[0].Message__c==null);
        System.Assert(lstExportLog[0].Object__c=='Contact');
        System.Assert(lstExportLog[0].Record_Count__c==lstContacts.size());
    }

    /**
     * Method to test method OrderSuccess
     */
    @isTest static void test_OrderSuccess() {

        // query acc and pass accLst and errorMsg
        //List<Order> lstOrder = [Select Id From Order];
        list<SBQQ__Quote__c> lstQuote = [select id from SBQQ__Quote__c ];
        List<Account> lstAccs = [Select Id From Account];
        System.Test.startTest();
            list<Order> lstOrder = new list<Order>();
            for(SBQQ__Quote__c quote : lstQuote) {
                lstOrder.add(createOrder(lstAccs[0].Id, quote.Id, true));
            }
            // Create four orders
            insert lstOrder;
            CPQExportHelper.OrderSuccess(lstOrder);
        System.Test.stopTest();

        // assert if CPQ_Export_Log__c is created as required
        List<CPQ_Export_Log__c> lstExportLog = [Select Message__c, Object__c, Record_Count__c, Result__c From CPQ_Export_Log__c];
        System.Assert(lstExportLog.size()<>0,'Log record not inserted for failed record');
        System.Assert(lstExportLog.size()==1,'Log list size returned is not 1');
        System.Assert(lstExportLog[0].Result__c=='Success');
        System.Assert(lstExportLog[0].Message__c==null);
        System.Assert(lstExportLog[0].Object__c=='Order');
        System.Assert(lstExportLog[0].Record_Count__c==lstOrder.size());

        for(Order objOrder:[Select Id, Submitted_to_SAP__c From Order]) {
            System.Assert(objOrder.Submitted_to_SAP__c);
        }
    }

    /**
     * Method to test method OrderErrors in bulk (cannot run this test since CPQ will exceed limits)
     
    @isTest static void test_BulkOrderErrors() {

        // query acc
        List<Account> lstAccs = [Select Id From Account];
        
        List<Order> lstOrders = new List<Order>();
        for(Integer i=0;i<200;i++){
            lstOrders.add(createOrder(lstAccs[0].Id, createQuote(createOpportunity(lstAccs[0].Id, CreatePriceBook())), false));

        }
        insert lstOrders;

        // query Order and pass OrderLst and errorMsg
        List<Order> lstOrdersActual = [Select Id From Order];
        System.AssertEquals(lstOrdersActual.size(),204);

        System.Test.startTest();
            CPQExportHelper.OrderErrors(lstOrdersActual, 'Order Export has failed');
        System.Test.stopTest();

        // assert if CPQ_Export_Log__c is created as required
        List<CPQ_Export_Log__c> lstExportLog = [Select Message__c, Object__c, Record_Count__c, Result__c From CPQ_Export_Log__c];
        System.Assert(lstExportLog.size()<>0,'Log record not inserted for failed record');
        System.Assert(lstExportLog.size()==1,'Log list size returned is not 1');
        System.Assert(lstExportLog[0].Result__c=='Failure');
        System.Assert(lstExportLog[0].Message__c=='Order Export has failed');
        System.Assert(lstExportLog[0].Object__c=='Order');
        System.AssertEquals(lstExportLog[0].Record_Count__c,204);
    } */

}