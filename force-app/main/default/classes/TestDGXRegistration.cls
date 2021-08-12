/**************************************************************************************************
* Name       : TestDGXRegistration
* Purpose    : Test class for DGXRegistrationHelper
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/11/2017      | Initial Draft
*Perficient         | 2.0        | 03/28/2018      | Final Draft
*Akhilesh Gupta     | 3.0        | 08/15/2018      | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 4.0        | 08/18/2018      | Use Common utility functions.
*Akhilesh Gupta     | 5.0        | 08/18/2018      | Licensing 2.0: Updated testcode for new DGXRegistration Page.
Note: Need to remove commented code in next cleanup
**************************************************************************************************/
@isTest
public class TestDGXRegistration {
    //final static String NAME = 'TestTriggerRMAHelper';
    /* 
    @testSetup 
    public static void TestUserCreation(){
        //Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        //Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        DGXCountryCodes__c country = new DGXCountryCodes__c(name='US-AL',State_Name__c='Albama',CountryCode__c='US',
                                                           Country__c='United States');
        insert country;
       
        Account acc = Test_COMM_Factory.getAccount('Test Account');
        //Account acc = new Account(Name ='Test Account');
        insert acc;
        
        //Opportunity creation
        Opportunity oppt    = Test_COMM_Factory.getOpportunity('NAME', acc.Id);
        //Opportunity oppt = new Opportunity();
       /* oppt.Name = 'NAME';
        oppt.StageName = 'Discovery';
        oppt.AccountId = acc.Id;
        oppt.CloseDate = Date.today();/*
        insert oppt;
        
        //Contract creation
        Contract contract       = Test_COMM_Factory.getContract(acc.Id);
        //Contract contract = new Contract();
       /* contract.AccountId = acc.Id;
        contract.Status ='Draft';
        contract.StartDate = startDate;/*
        //contract.SBQQ__Opportunity__c=oppt.Id;
        insert contract;
        
        contract.Status = 'Activated'; 
        update contract;
        
        Product2 product = Test_COMM_Factory.getProduct('Test Product');
        //Product2 product = new Product2(Name ='Test Product', Family='DGX-1 Pascal Product Family');
        insert product;
        
        SBQQ__Subscription__c subscription1 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription1.Hardware_Serial_Number__c = 'Serial111';
        //subscription1.SBQQ__SubscriptionStartDate__c = startDate;
        //subscription1.SBQQ__SubscriptionEndDate__c = endDate;
        /*SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             SBQQ__SubscriptionStartDate__c =StartDate, SBQQ__SubscriptionEndDate__c = EndDate,
             Hardware_Serial_Number__c ='Serial111');/*
        insert subscription1;
        Contact con = Test_COMM_Factory.getContact(acc.Id);
        con.Email = 't4444est@perficient.com';
        //Contact con = new Contact();
       /* con.firstName = 'firstName1';
        con.lastName = 'lastName1';
        con.MailingStreet = 'Street1';
        con.Mailing_Street_2__c = 'Street2';
        con.MailingCity = 'Pittsburgh';
        con.MailingState = 'Punjab';
        con.MailingCountry = 'India';
        con.MailingPostalCode = '15213';
        con.accountId = acc.Id;/*
        insert con;
    } */
    
    //Licensing 2.0: Updated testcode for new DGXRegistration Page.
    @isTest
    public static void TestsubmitRegistration(){
        DGXRegistrationHelper dgxReghelper = new DGXRegistrationHelper();
        /*Entitlement__c ent = [SELECT Id, Entitlement__c FROM Entitlement__c];
        ///DGXRegistrationHelper.RenewEntitlement(ent.Id);
        Contact con     = Test_COMM_Factory.getContact(null);
        con.firstName   = 'firstName1';
        con.lastName    = 'lastName1';
        con.Email       = 't4444est1@test.com';
       /* Contact con = new Contact();
        con.MailingStreet = 'Street1';
        con.Mailing_Street_2__c = 'Street2';
        con.MailingCity = 'Pittsburgh';
        con.MailingState = 'Punjab';
        con.MailingCountry = 'India';
        con.MailingPostalCode = '15213';
        con.Phone='1231231234';/*
        
        Contact con2    = Test_COMM_Factory.getContact(null);
        con2.firstName  = 'firstName2';
        con2.lastName   = 'lastName2';
        con2.Email      = 't5555est2@test.com';
       /*Contact con2 = new Contact();
        con2.MailingStreet = 'Street1';
        con2.Mailing_Street_2__c = 'Street2';
        con2.MailingCity = 'Pittsburgh';
        con2.MailingState = 'Punjab';
        con2.MailingCountry = 'India';
        con2.MailingPostalCode = '15213';
        con2.Phone='1231231234';/*
        
        Test.startTest();
        ///String errorresult = DGXRegistrationHelper.submitRegistration(con,con2,'dummy','','','sNo3','salesOrder',
        ///                                        'name1','name2','test3@test.com','company','4234565435');
        ///String successresult = DGXRegistrationHelper.submitRegistration(con,con2,'Serial111','','','sNo3','salesOrder',
        ///                                        'name1','name2','test3@test.com','company','4234565435');
        ///DGXRegistrationHelper.getCountries();
        ///DGXRegistrationHelper.getStates();
        ///DGXRegistrationHelper.getUserName();
        
        Contact contact1 = [SELECT id, email FROM Contact WHERE Email =: 't4444est1@test.com'];
        system.assert(contact1 !=null);
        Contact contact2 = [SELECT id, email FROM Contact WHERE Email =: 't5555est2@test.com'];
        system.assert(contact2 !=null);
        
        Test.stopTest();
        List<ESP_DGX_Registration_Status__c> lstStatus =[SELECT Id, Email__c FROM ESP_DGX_Registration_Status__c WHERE Email__c = 't4444est1@test.com'];
        system.assert(lstStatus.size() >0);
        List<User> lstUsersTest =  [SELECT id, username, ContactId FROM User WHERE username =:con.Email OR username =:con2.Email];
        system.assert(lstUsersTest.size() ==2);
        ///system.assertEquals('SUCCESS',DGXRegistrationHelper.checkUserCreation('t4444est1@test.com', 't5555est2@test.com'));
        //For Code coverage
        ///DGXRegistrationHelper.submitRegistration(con,con2,'Serial111','','','sNo3','salesOrder',
        ///                                        'name1','name2','test3@test.com','company','4234565435');
        ///con.Email = 't4444est@perficient.com';
        ///DGXRegistrationHelper.submitRegistration(con,con2,'Serial111','','','sNo3','salesOrder',
        ///                                        'name1','name2','test3@test.com','company','4234565435');
        
        ///System.runAs(new User(Id=lstUsersTest[0].Id)){
        ///    String usertype = DGXRegistrationHelper.UserType();
        ///    DGXRegistrationHelper.sendRegistrationMail('test1@test.com',
        ///                                          'https://scdevpro-npncommunity.cs70.force.com/ESPCommunity/s/');
        ///    DGXRegistrationHelper.sendonBoardingMail('test1@test.com',
        ///                                          'https://scdevpro-npncommunity.cs70.force.com/ESPCommunity/s/',
        ///                                            'Serial111','');
        ///}
        */
    }
}