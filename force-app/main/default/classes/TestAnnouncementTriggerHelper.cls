/**************************************************************************************************
* Name       : TestAnnouncementTriggerHelper
* Purpose    : Test class for AnnouncementTrigger on Announcement__c object
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | Jan 2018        | Final Draft
*Perficient         | 2.0        | 3/14/2018       | Fix failure for using Opportunity in Contract
*Akhilesh Gupta     | 3.0        | 08/15/2018      | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 4.0        | 08/18/2018      | Use Common utility functions.
Note: Need to remove commented code in next cleanup
**************************************************************************************************/
@isTest
private class TestAnnouncementTriggerHelper
{
    public static final String NAME = 'TestAnnouncementTriggerHelper';
    @TestSetup
    static void setup(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName = 'New_Customer_Account'];
        
        Product2 product2 = new Product2(Name ='GRID K1', Family='GRID Hardware');
        insert product2;
        
        List<Account> acctList = new List<Account>();
        //Account acct1 = new Account(Name = NAME, RecordTypeId=rt.Id);
        Account acct1 = Test_COMM_Factory.getAccount(NAME);
        acct1.RecordTypeId = rt.Id;
        acctList.add(acct1);
        //Account acct2 = new Account(Name = NAME+'2', RecordTypeId=rt.Id);
        Account acct2 = Test_COMM_Factory.getAccount(NAME);
        acct2.RecordTypeId = rt.Id;
        acctList.add(acct2);
        insert acctList;
        
        List<Opportunity> opptList = new List<Opportunity>();
        for(Account acct : acctList){
            //Opportunity objTestOpportunity = new Opportunity();
            Opportunity objTestOpportunity  = Test_COMM_Factory.getOpportunity(NAME, acct.Id);
            /*objTestOpportunity.Name = NAME;
            objTestOpportunity.StageName = 'Discovery';
            objTestOpportunity.AccountId = acct.Id;
            objTestOpportunity.CloseDate = Date.today();*/
            opptList.add(objTestOpportunity);
        }
        insert opptList;

        List<Contract> contractList = new List<Contract>();
            for(Integer i=0;i<acctList.size();i++){
            Account acct = acctList[i];
            Contract contract       = Test_COMM_Factory.getContract(acct.Id);
            // Contract ctract = new Contract();
           /* ctract.AccountId = acct.Id;
            ctract.Status ='Draft';
            ctract.StartDate = startDate; */
            //ctract.SBQQ__Opportunity__c=opptList[i].Id;
            contractList.add(contract);
        }
        insert contractList;
        

        for(Contract ctract: contractList){
            ctract.Status = 'Activated';
        }
        update contractList;
        
        List<SBQQ__Subscription__c> sbscpList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c subscription1 = Test_COMM_Factory.getSubscription(acct1.Id, product2.Id, contractList[0].Id);
        subscription1.Hardware_Serial_Number__c = 'testSerial111';
       /* SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acct1.Id, SBQQ__Product__c =product2.Id,
             SBQQ__Contract__c = contractList[0].Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='testSerial111'
             ); */
             
             
        SBQQ__Subscription__c subscription2 = Test_COMM_Factory.getSubscription(acct2.Id, product2.Id, contractList[1].Id);
        subscription2.Hardware_Serial_Number__c = 'testSerial111';
        /*SBQQ__Subscription__c subscription2 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acct2.Id, SBQQ__Product__c =product2.Id,
             SBQQ__Contract__c = contractList[1].Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='testSerial222'
             );*/
        sbscpList.add(subscription1);
        sbscpList.add(subscription2);
        insert sbscpList;
        
        List<Entitlement> entList = new List<Entitlement>();
        Entitlement ent1 = new Entitlement(Name ='Test Entitlement1',Subscription__c=sbscpList[0].id,Service_product__c =product2.id,StartDate = startDate,EndDate = endDate,PAK_ID__c = 'testSerial111',AccountId = acct1.Id);
        entList.add(ent1);
        Entitlement ent2 = new Entitlement(Name ='Test Entitlement2',Subscription__c=sbscpList[1].id,Service_product__c = product2.id,StartDate = startDate,EndDate = endDate,PAK_ID__c = 'testSerial222',AccountId = acct2.Id);
        entList.add(ent2);
        insert entList;
        
        Announcement__c annc = Test_COMM_Factory.getAnnouncement('Test Announcement1',null);
        annc.Access_Level__c = 'Generic';
        insert annc;
        
    }

    @isTest
    static void test_create()
    {
        Announcement__c annc = Test_COMM_Factory.getAnnouncement('Test Announcement2',null);
        //Announcement__c annc = new Announcement__c(Name = 'Test Announcement2');
        annc.Access_Level__c = 'Generic';
        Test.startTest();
        insert annc;
        Product2 product2 = new Product2(Name ='GRID K1', Family='GRID Hardware');
        insert product2;        
        annc = Test_COMM_Factory.getAnnouncement('Test Announcement3',null);
        //Announcement__c annc = new Announcement__c(Name = 'Test Announcement2');
        annc.Access_Level__c = 'Product Specific';
        annc.Product__c = product2.id;
        insert annc;
        Test.stopTest();

        List<CustomerAnnouncement__c> juncList = [SELECT Id 
                                                  FROM CustomerAnnouncement__c 
                                                  WHERE Announcement__c = :annc.Id];
        System.assertEquals(2, juncList.size());
    }

    @isTest
    static void test_archive()
    {
        Announcement__c annc = [SELECT Id FROM Announcement__c WHERE Name = 'Test Announcement1'];
        List<CustomerAnnouncement__c> juncList = [SELECT Id 
                                                  FROM CustomerAnnouncement__c 
                                                  WHERE Announcement__c = :annc.Id];
        System.assertEquals(2, juncList.size());
        annc.Access_Level__c = 'Archived';
        Test.startTest();
        update annc;
        Test.stopTest();
        juncList = [SELECT Id FROM CustomerAnnouncement__c WHERE Announcement__c = :annc.Id];
        System.assertEquals(0, juncList.size());
    }
}