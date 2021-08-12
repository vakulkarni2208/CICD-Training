/******************************************************************************************************
* Name       : Test_ESP_TriggerEntitlementHelper
* Purpose    : Test class for TriggerEntitlement(AddAnnouncement() and getAnnoucementsToAddByAccount()) 
              on Entitlement object
*******************************************************************************************************
* Author            | Version    | Created Date    | Description
*******************************************************************************************************
*Perficient         | 1.0        | Jun 2018        | Test class for AddAnnouncement() and 
                                                    getAnnoucementsToAddByAccount() Methods
*Akhilesh Gupta     | 2.0        | 08/15/2018      | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 3.0        | 08/18/2018      | Use Common utility functions.
Note: Need to remove commented code in next cleanup
*******************************************************************************************************/

@isTest
private class Test_ESP_TriggerEntitlementHelper 
{
    Public Static final String NAME='TestEntitlementHelper';
    /** 
     * setup method will initialize the data required for the test method to execute
     * To create Entitlement, we need to create Account, Product, Opportunity,Contract, Subscription
     * After creating above mentioned records we will create Entitlement
    **/
    @TestSetup
    static void setup() {
        Integer entitleCount, recCount;
        Date startDate 	= Date.today().addDays(2);//date.newInstance(System.now().year(), System.now().month(), System.now().day()+2);
        Date endDate 	= Date.today().addDays(7);//date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        RecordType recType = [Select Id from RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];
        
        list<Product2> ProductList 			= new list<Product2>();
        list<Account> AccList				= new list<Account>();
        //list<CustomerAnnouncement__c> CustAnnounceList = new list<CustomerAnnouncement__C>();
        
        for(recCount = 1; recCount <= 2; recCount++) {
            //Product2 item 	= new Product2(Name	= 'GRID K00'+recCount, Family = 'GRID Hardware');
            Product2 product 	= Test_COMM_Factory.getProduct('GRID K00'+recCount);
            product.Family 		= 'GRID Hardware';
            ProductList.add(product);
            
            //Account Acct		= new Account(Name  = NAME+'00'+recCount, RecordTypeId = recType.Id);
            Account acc 		= Test_COMM_Factory.getAccount(NAME+'00'+recCount);
            acc.RecordTypeId 	= recType.Id;
            AccList.add(acc);
        }
        
        insert ProductList;
        insert AccList;
        
        list<Announcement__c> announceList	= new list<Announcement__c>();
        for(recCount = 0; recCount < ProductList.size(); recCount++) {
        	Announcement__c announce 	= Test_COMM_Factory.getAnnouncement('Test Announcement 101'+recCount, ProductList[recCount].Id);
            announce.Access_Level__c 	= 'Product Specific';
            announceList.add(announce);
        }
        insert announceList;
        
        list<Opportunity> opptList = new list<Opportunity>();        
        for(Account acc: AccList){
        	Opportunity opp	= Test_COMM_Factory.getOpportunity(NAME, acc.Id);
            opp.CloseDate 	= endDate;
            opptList.add(opp);
        }
        insert opptList;
        
        list<Contract> contractList = new list<Contract>();
        for(recCount = 0; recCount < AccList.size(); recCount++) {
            Account acc 		= AccList[recCount];
            
            Contract contract 	= Test_COMM_Factory.getContract(acc.Id);
        	contract.StartDate 	= startDate;
            //contract.SBQQ__Opportunity__c = opptList[recCount].Id;
            contractList.add(contract);
        }
        insert contractList;
        
        for(Contract ctract: contractList){
            ctract.Status = 'Activated';
        }
        update contractList;
        
        list<SBQQ__Subscription__c> sbscpList = new list<SBQQ__Subscription__c>();
        for(recCount = 1; recCount <= 4; recCount++) {
        	SBQQ__Subscription__c subscription;
            if(math.mod(recCount, 2) == 0) {
            	subscription = Test_COMM_Factory.getSubscription(AccList[0].Id, ProductList[0].Id, contractList[0].Id);
            	//subscription.Hardware_Serial_Number__c ='Serial10'+recCount
                
                //SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c (
                //										SBQQ__Account__c 	= AccList[0].Id, 
                //										SBQQ__Product__c 	= ProductList[0].Id,
                //     									SBQQ__Contract__c 	= contractList[0].Id , 
                //     									SBQQ__Quantity__c =5,
                //sbscpList.add(subscription1);  
            } else {
            	subscription = Test_COMM_Factory.getSubscription(AccList[1].Id, ProductList[1].Id, contractList[1].Id);
            	//subscription.Hardware_Serial_Number__c ='Serial10'+recCount;
            }
            subscription.Hardware_Serial_Number__c ='Serial10'+recCount;
                
            sbscpList.add(subscription);
        }
        insert sbscpList;
    }
    /**
     * test_createAnnoucement Method will fetch the created Entitlement and update the Start date
     * Which will make the Entitlement staus as Active and will execute the TriggerEntitlement
     * And call AddAnnouncement method which will create CustomerAnnouncement__c records.
     * we will assert the total number of CustomerAnnouncement__c records created.
     **/   
    
    @isTest
    Static void test_createCustAnnoucement(){
        Date currentDate=date.newInstance(System.now().year(), System.now().month(), System.now().day()-4);
        Set<String> accIdSet=new Set<String>();
        List<Entitlement> ListEntitlement=[SELECT Id,Name,StartDate,EndDate,AccountId,Product__c,Status From Entitlement
                                           WHERE Name LIKE 'Serial10%'];
        List<Entitlement> EntitleList=new List<Entitlement>();
        for(Entitlement Entitle:ListEntitlement){
            Entitle.StartDate= currentDate;
            accIdSet.add(Entitle.AccountId);
            EntitleList.add(Entitle); 
        }
        Test.startTest();
        Update(EntitleList);
        Test.stopTest();
        List<String> accId=new List<String>();
        accId.addAll(accIdSet);
        List<CustomerAnnouncement__c> cusAnnounce=[Select Id from CustomerAnnouncement__c Where Account__c IN :accId];
        System.assertEquals(2, cusAnnounce.size());
    }
    
    @isTest
    Static void testProductChange(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()-7);
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+4);
        List<Id> accountId = new List<Id>();
        List<Entitlement> entitleList=new List<Entitlement>();
        
        Product2 product2 =[SELECT Id, Name , Family FROM Product2 WHERE Name='GRID K002' AND Family='GRID Hardware'];
        Product2 newproduct = Test_COMM_Factory.getProduct('GRID K0012');
        newproduct.Family = 'GRID Hardware';
        //Product2 newProduct = new Product2(Name='GRID K0012',Family='GRID Hardware');
        insert newProduct;
        
        //Create Announcement for newly created Product 
        Announcement__c announce = Test_COMM_Factory.getAnnouncement('Test Announcement 505',newProduct.Id);
        announce.Access_Level__c = 'Product Specific';
        /*Announcement__C announce = new Announcement__C(Name='Test Announcement 505',Access_Level__c='Product Specific', 
                                                       Product__c=newProduct.Id, Content__C='Test Announcement Ignore', 
                                                       Announcement_Type__c='Latest');*/
        insert announce;
        
        SBQQ__Subscription__c sbscList = [SELECT Id, SBQQ__Account__c,SBQQ__Product__c, Hardware_Serial_Number__c 
                                        FROM SBQQ__Subscription__c where Hardware_Serial_Number__c ='Serial101' 
                                        AND SBQQ__Product__c = :product2.Id];
        
        List<Entitlement> lstEntitlement = [SELECT Id,Name,Status,startDate,EndDate 
                                            FROM Entitlement WHERE Name = 'Serial101-'];
        for(Entitlement entit :lstEntitlement){
            entit.startDate = startDate;
            entit.EndDate = EndDate;
        }
        update lstEntitlement;
        
        //Changing product of subscription1 from GRID K002 to GRID K0012
        SBQQ__Subscription__c subscriptionupdate = new SBQQ__Subscription__c (
	            										Id = sbscList.Id, 
	            										SBQQ__Product__c = newProduct.Id
	        										);
        update subscriptionupdate;
        
        lstEntitlement = [SELECT Id,Name,Status,AccountId,Product__c,NVES_Product_Family__c,startDate,EndDate
                          FROM Entitlement WHERE Name ='Serial101-'];
        for(Entitlement entit :lstEntitlement){
            entit.startDate = System.today();
            entit.EndDate = System.today()+7;
            // Changing Product Id in Entitlement from Id(GRID K002) to Id(K0012)
            entit.Product__c=newProduct.Id;
            accountId.add(entit.AccountId);
            entitleList.add(entit);
        }
        Test.startTest();
        update entitleList;
        Test.stopTest();
        List<CustomerAnnouncement__c> cusAnnounce=[Select Id from CustomerAnnouncement__c Where Account__c IN :accountId];
        System.assertEquals(2, cusAnnounce.size());
    }
    
    @isTest
    Static void testAddMultiAnnouncement(){
        Date pastDate=date.newInstance(System.now().year(), System.now().month(), System.now().day()-4);
        Set<String> accIdSet=new Set<String>();
        List<Entitlement> ListEntitlement=[SELECT Id,Name,StartDate,EndDate,AccountId,Product__c,Status From Entitlement
                                           WHERE Name='Serial101-'];
        Announcement__c announce = Test_COMM_Factory.getAnnouncement('Test Announcement 101-A',ListEntitlement[0].Product__c);
        announce.Access_Level__c = 'Product Specific';
        /*Announcement__c announce= new Announcement__c(Name='Test Announcement 101-A',Access_Level__c='Product Specific', 
                                                      Product__c=ListEntitlement[0].Product__c, Content__C='Test Announcement Ignore', 
                                                      Announcement_Type__c='Latest');*/
        
        ListEntitlement[0].StartDate=pastDate;
        Test.startTest();
        Insert announce;
        Update ListEntitlement;
        Test.stopTest();
        List<CustomerAnnouncement__c> cusAnnounce=[Select Id from CustomerAnnouncement__c Where Account__c = :ListEntitlement[0].AccountId];
        System.assertEquals(2, cusAnnounce.size());
    }
    
    @isTest
    Static void testInsertEntitlement(){
        String NAME = 'Test Account for Entitlement71A ';
        Date strtDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()-3);
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName = 'New_Customer_Account'];
        
        Product2 product2 = new Product2(Name ='GRID K9', Family='GRID Hardware');
        Insert product2;
        Announcement__C announce = new Announcement__C(Name='Test Announcement 71A',Access_Level__c='Product Specific', 
                                                       Product__c=product2.Id, Content__C='Test Announcement Ignore', 
                                                       Announcement_Type__c='Latest');
        Insert announce;
        
        Account acct1 = new Account(Name = NAME, RecordTypeId=rt.Id);
        insert acct1;
        Opportunity objTestOpportunity = new Opportunity(Name = NAME,StageName = 'Discovery',AccountId = acct1.Id,
                                                         CloseDate = Date.today());
        Insert objTestOpportunity;		
        
        Contract ctract = new Contract(AccountId = acct1.Id,Status ='Draft',StartDate = strtDate,
        								EndDate = endDate);
                                       //EndDate = endDate,SBQQ__Opportunity__c=objTestOpportunity.Id);
        insert ctract;
        
        ctract.Status = 'Activated';
        update ctract;
        
        SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acct1.Id, SBQQ__Product__c =product2.Id,
             SBQQ__Contract__c = ctract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='testSerial771');
        insert subscription1;
        List<CustomerAnnouncement__c> cusAnnounce=[Select Id from CustomerAnnouncement__c Where 
                                                   Account__c = :acct1.Id];
        System.assertEquals(1, cusAnnounce.size());
    }
}