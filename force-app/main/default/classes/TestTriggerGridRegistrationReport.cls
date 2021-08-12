/**************************************************************************************************
* Name       : TestTriggerGridRegistrationReport
* Purpose    : Test class for TriggerGridRegistrationReport Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/4/2017        | Final Draft
*Perficient         | 1.0        | 2/1/2018        | Added more test cases.
*NVIDIA|AkhileshG   | 2.0        | 8/01/2018       | Change to use PAK_ID instead of Renewed PAK ID.
**************************************************************************************************/
@isTest
public class TestTriggerGridRegistrationReport {
    final static String NAME = 'TestTriggerGridRegistrationReport';
    final static String NAME2 = 'Test2TriggerGridRegistrationReport';
    final static String TEST_PAK_ID1 = 'testSerial111';
    final static String TEST_PAK_ID2 = 'testSerial222';
    final static String EMAIL1 = 'TestTriggerGridRegistrationReport1@test.com';
    final static String EMAIL2 = 'TestTriggerGridRegistrationReport2@test.com';

    @TestSetup
    public static void setup(){
        RMA_IDM_Visibility__c genVis = new RMA_IDM_Visibility__c(
                                        Name='General Article', 
                                        Default__c = true,
                                        Permission_Set_Name__c='General_Article_Visibility_for_All_Customers');
        insert genVis;
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        //Account creation
        Account acc = new Account(Name =NAME);
        insert acc;
        
        //Entitlement creation with PakId
        Entitlement ent = new Entitlement(Name ='Test Entitlement',StartDate = startDate,EndDate = endDate,PAK_ID__c = TEST_PAK_ID1,AccountId = acc.Id);
        insert ent;
    }

    @isTest
    public static void GRIDInsertTests_happyPath(){
        //Grid_Registration_Report__c creation with PakId
        List<Grid_Registration_Report__c> lstGrid = new List<Grid_Registration_Report__c>();
        for (Integer i=0;i<200;i++){
            Grid_Registration_Report__c grid = generateRrid(TEST_PAK_ID1, 'test37838'+String.valueOf(i)+'@test.com');
            lstGrid.add(grid);
        }
        
        Test.startTest();
        insert lstGrid;
        Test.stopTest();
        Map<Id,Contact> lstContact = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c  FROM Contact WHERE is_GRID_Contact__c =:true]);
        List<User> lstUser = [SELECT Id,username,contactId FROM User WHERE contactId =:lstContact.keySet()];
        
        System.assertEquals(200,lstContact.size());
        System.assertEquals(200,lstUser.size());
        List<Service_Cloud_Error_Log__c> errList = [SELECT Id FROM Service_Cloud_Error_Log__c]; 
        System.assertEquals(0,errList.size());
    }

    //Two records with sam email each with valid PAK_ID, only one insert, and report 1 error.
    @isTest
    public static void GRIDInsertTests_twoDuplicatedSameTime(){
        //Grid_Registration_Report__c creation with PakId
        List<Grid_Registration_Report__c> lstGrid = new List<Grid_Registration_Report__c>();
        
        Grid_Registration_Report__c grid1 = generateRrid(TEST_PAK_ID1, EMAIL1);
        Grid_Registration_Report__c grid2 = generateRrid(TEST_PAK_ID2, EMAIL1);
        lstGrid.add(grid1);
        lstGrid.add(grid2);
        
        Test.startTest();
        insert lstGrid;
        Test.stopTest();
        Map<Id,Contact> lstContact = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c  FROM Contact WHERE is_GRID_Contact__c =:true]);
        List<User> lstUser = [SELECT Id,username,contactId FROM User WHERE contactId =:lstContact.keySet()];
        
        System.assertEquals(1,lstContact.size());
        System.assertEquals(1,lstUser.size());
        List<Service_Cloud_Error_Log__c> errList = [SELECT Id FROM Service_Cloud_Error_Log__c]; 
        System.assertEquals(1,errList.size());     
    }

    //The contact already exists, update contact, and user generated
    @isTest
    public static void GRIDInsertTests_OnlyContactExists(){
    
        Account acct = [SELECT Id FROM Account WHERE Name=:NAME];
        Contact cont = new Contact(AccountId = acct.Id, Email=EMAIL1);
        cont.FirstName='firstName';
        cont.LastName='lastName';
        insert cont;
        
        Grid_Registration_Report__c grid = generateRrid(TEST_PAK_ID1, EMAIL1);
        
        Test.startTest();
        insert grid;
        Test.stopTest();
        Map<Id,Contact> lstContact = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c  FROM Contact WHERE is_GRID_Contact__c =:true]);
        List<User> lstUser = [SELECT Id,username,contactId FROM User WHERE contactId =:lstContact.keySet()];
        
        System.assertEquals(1,lstContact.size());
        System.assertEquals(1,lstUser.size());       
        List<Service_Cloud_Error_Log__c> errList = [SELECT Id FROM Service_Cloud_Error_Log__c]; 
        System.assertEquals(0,errList.size());
    }

    //The contact already exists, but not same account, so they are not same
    @isTest
    public static void GRIDInsertTests_ContactExists_notSame(){
    
        Account acct = [SELECT Id FROM Account WHERE Name=:NAME];
        Contact cont = new Contact(AccountId = acct.Id, Email=EMAIL1);
        cont.FirstName='firstName';
        cont.LastName='lastName';
        insert cont;
        
        //Account creation
        Account acct2 = new Account(Name =NAME2);
        insert acct2;
        
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        //Entitlement creation with PakId
        Entitlement ent = new Entitlement(Name ='Test Entitlement',StartDate = startDate,EndDate = endDate,PAK_ID__c = TEST_PAK_ID2,AccountId = acct2.Id);
        insert ent;
        Grid_Registration_Report__c grid = generateRrid(TEST_PAK_ID2, EMAIL1);
        Test.startTest();
        insert grid;
        Test.stopTest();
        Map<Id,Contact> lstContact = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c  FROM Contact WHERE is_GRID_Contact__c =:true]);
        List<User> lstUser = [SELECT Id,username,contactId FROM User WHERE contactId =:lstContact.keySet()];
        
        System.assertEquals(1,lstContact.size());
        System.assertEquals(1,lstUser.size());       
        List<Service_Cloud_Error_Log__c> errList = [SELECT Id FROM Service_Cloud_Error_Log__c]; 
        System.assertEquals(0,errList.size());
    }

    //Contact/User already exists, and it is same, just update.
    @isTest
    public static void GRIDInsertTests_ContactExists_same(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        //Account creation
        Account acc = new Account(Name =NAME2);
        insert acc;
        
        //Entitlement creation with PakId
        Entitlement ent = new Entitlement(Name ='Test Entitlement',StartDate = startDate,EndDate = endDate,PAK_ID__c = TEST_PAK_ID2,AccountId = acc.Id);
        insert ent;

        System.runAs(new User(Id=UserInfo.getUserId())){
        
            String ProfileId = [SELECT Id FROM Profile WHERE Name =:System.Label.Profile_for_DGX_Registration].Id;
            Contact con = new Contact(AccountId = acc.Id, Email='TestTriggerGridRegistrationReport1@test.com');
            con.FirstName='firstName';
            con.LastName='lastName';
            insert con;
            User u = new User(ContactId = con.Id, 
                            UserName=con.Email,
                            ProfileId = ProfileId,
                            FirstName = con.firstName,
                            LastName = con.lastName,
                            Email = con.email,                        
                            CompanyName = con.CompanyName__c,
                            Alias = 'testABC',
                            is_Created__c = true,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US');
            insert u;
        }
        
        Test.startTest();
        Grid_Registration_Report__c grid2 = generateRrid(TEST_PAK_ID2, EMAIL1);
        insert grid2;
        Test.stopTest();
        Map<Id,Contact> lstContact = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c  FROM Contact WHERE is_GRID_Contact__c =:true]);
        List<User> lstUser = [SELECT Id,username,contactId FROM User WHERE contactId =:lstContact.keySet()];
        
        System.assertEquals(1,lstContact.size());
        System.assertEquals(1,lstUser.size());       
        List<Service_Cloud_Error_Log__c> errList = [SELECT Id FROM Service_Cloud_Error_Log__c]; 
        //System.assertEquals(0,errList.size());
    }

    //User already exists, and it is not same Account, report error
    @isTest
    public static void GRIDInsertTests_UserExists_notSame(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        //Account creation
        Account acc = new Account(Name =NAME2);
        insert acc;
        
        //Entitlement creation with PakId
        Entitlement ent = new Entitlement
            (Name ='Test Entitlement',
             StartDate = startDate,
             EndDate = endDate,
             PAK_ID__c = TEST_PAK_ID2,
             AccountId = acc.Id);
        insert ent;
        System.runAs(new User(Id=UserInfo.getUserId())){
            String ProfileId = [SELECT Id FROM Profile WHERE Name =:System.Label.Profile_for_DGX_Registration].Id;
            Contact con = new Contact(AccountId = acc.Id, Email='TestTriggerGridRegistrationReport1@test.com');
            con.FirstName='firstName';
            con.LastName='lastName';
            insert con;
            User u = new User(ContactId = con.Id, 
                            UserName=con.Email,
                            ProfileId = ProfileId,
                            FirstName = con.firstName,
                            LastName = con.lastName,
                            Email = con.email,                        
                            CompanyName = con.CompanyName__c,
                            Alias = 'testABC',
                            is_Created__c = true,
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US');
            insert u;
        }
        
        Test.startTest();
        Grid_Registration_Report__c grid2 = generateRrid(TEST_PAK_ID1, EMAIL1);
        insert grid2;
        Test.stopTest();
        Map<Id,Contact> lstContact = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c  FROM Contact]);
        List<User> lstUser = [SELECT Id,username,contactId FROM User WHERE contactId =:lstContact.keySet()];
        
        System.assertEquals(1,lstContact.size());
        System.assertEquals(1,lstUser.size());       
        List<Service_Cloud_Error_Log__c> errList = [SELECT Id FROM Service_Cloud_Error_Log__c]; 
        System.assertEquals(1,errList.size());
    }

    static Grid_Registration_Report__c generateRrid(String pakId, String email){
        Grid_Registration_Report__c grid2 = new Grid_Registration_Report__c();
        grid2.Pak_Id__c = pakId;
        grid2.FirstName__c='testName';
        grid2.Last_Name__c ='testName';
        grid2.Email_Address__c = email;
        grid2.Street1__c='Street3';
        grid2.Street2__c='Street4';
        grid2.City__c='Hangzhou';
        grid2.State__c='Zhejiang';
        grid2.Country__c='China';
        grid2.Postal_Code__c='15213'; 
        grid2.Phone__c = '9255555555';
        return grid2;
    }
}