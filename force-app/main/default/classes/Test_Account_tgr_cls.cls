@isTest(SeeAllData=false)
private class Test_Account_tgr_cls {

    static testMethod void insertSAPR3Customer() {
    
        map<string, Id> map_CUSTOMER_ACCOUNT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER);
        List<Account> lstAccounts = new List<Account>();
        Account a1 = new Account(name='SAP R3 Customer1', AccountSource = 'SAP R3', SAP_Customer_Number__c='1 ', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER) );
        Account a2 = new Account(name='SAP R3 Customer2', AccountSource = 'SAP R3', SAP_Customer_Number__c='  ', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER) );
        Account a3 = new Account(name='SAP R3 Customer3', AccountSource = 'SAP R3', SAP_Customer_Number__c='3 ', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER) );
        Account a4 = new Account(name='SAP R3 Customer4', AccountSource = 'SAP R3', SAP_Customer_Number__c='4 ', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER) );
        Account a5 = new Account(name='SAP R3 Customer5', AccountSource = 'SAP R3', SAP_Customer_Number__c='5 ', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER) );

        lstAccounts.add(a1);
        lstAccounts.add(a2);
        lstAccounts.add(a3);
        lstAccounts.add(a4);
        lstAccounts.add(a5);
        
        database.insert(lstAccounts, false);
        
        list<Account> lstNewAccounts = [select name from Account where name = 'SAP R3 Customer2'];
        system.assert(lstNewAccounts.size() == 1);
        
    }
    
    //2015.09.02
    //Test class for Account's Billing/Shipping Region, Sub-Region, Territory
    static testMethod void testAccountRegionSubRegionAndTerritory() {
        //Clean up all the Account and Country Records if any
        //-----------------------------------------------------------------------------------------------------
        list<Account> lstAllAcc = [Select Name From Account];
        if (!lstAllAcc.isEmpty()){
            Database.delete(lstAllAcc, false);
        }
        
        list<Country_List__c> lstAllCountryList = [Select Name From Country_List__c];
        if (!lstAllCountryList.isEmpty()){
            Database.delete(lstAllCountryList, false);
        }
        //-----------------------------------------------------------------------------------------------------
        
        //prep Country_List__c records
        //-----------------------------------------------------------------------------------------------------
        list<Country_List__c> lstCountryList = new list<Country_List__c>();
        Country_List__c testCountry1 = new Country_List__c(name='United States', ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA',  Territory__c = 'LA');
        Country_List__c testCountry2 = new Country_List__c(name='United Kingdom', ISO_Code__c = 'GB', Region__c = 'EMEAI', Sub_Region__c = 'NE',  Territory__c = 'UK_NORDICS');
        lstCountryList.add(testCountry1);
        lstCountryList.add(testCountry2);
        Database.insert(lstCountryList, false);
        
        map<string, Id> map_CUSTOMER_ACCOUNT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER);
        //-----------------------------------------------------------------------------------------------------
        
        Test.startTest();
        
            List<Account> lstAccounts = new List<Account>();
            Account a1 = new Account(name='a1', BillingCountry='United States', ShippingCountry = 'United Kingdom', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER));
            Account a2 = new Account(name='a2', BillingCountry='United Kingdom', ShippingCountry = 'United States', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER));
            lstAccounts.add(a1);
            lstAccounts.add(a2);
            Database.insert(lstAccounts);
        
            list<Account> lstNewAccounts = [Select name,    BillingCountry, Billing_Region__c, Billing_Sub_Region__c, Billing_Territory__c,
                                                            ShippingCountry, Shipping_Region__c, Shipping_Sub_Region__c, Shipping_Territory__c  
                                            From Account 
                                            Where Id =:lstAccounts];
            system.assert(lstNewAccounts.size() == 2);
            system.debug('***lstNewAccounts in Test Method: ' + lstNewAccounts);
            
            a1.BillingCountry = 'United Kingdom';
            update a1;
            /*
            for (Account newAcc : lstNewAccounts){
                if (newAcc.BillingCountryCode == 'US'){
                    system.assert(newAcc.Billing_Region__c == 'NALA');
                    system.assert(newAcc.Billing_Sub_Region__c == 'LA');
                    system.assert(newAcc.Billing_Territory__c == 'LA');
                } 
                
                if (newAcc.BillingCountry == 'United Kingdom'){
                    system.assert(newAcc.Billing_Region__c == 'EMEAI');
                    system.assert(newAcc.Billing_Sub_Region__c == 'NE');
                    system.assert(newAcc.Billing_Territory__c == 'UK_NORDICS');
                }
                
                if (newAcc.ShippingCountryCode == 'GB'){
                    system.assert(newAcc.Shipping_Region__c == 'EMEAI');
                    system.assert(newAcc.Shipping_Sub_Region__c == 'NE');
                    system.assert(newAcc.Shipping_Territory__c == 'UK_NORDICS');
                } 
                
                if (newAcc.ShippingCountry == 'United States'){
                    system.assert(newAcc.Shipping_Region__c == 'NALA');
                    system.assert(newAcc.Shipping_Sub_Region__c == 'LA');
                    system.assert(newAcc.Shipping_Territory__c == 'LA');
                }
            }
            */
        Test.stopTest();
     }
     
     // This method covers code coverage for TAM logic in "Account_trg", "Account_tgr_cls" and "CRM_TAM_Utility"
     private static testMethod void accTrgTAMMethod() {
        
        List<String> strPrfLst = new List<String>{'Sales Profile'};
        Map<String, Id> profileMap = Test_COMM_Factory.getProfsByName(strPrfLst);
        Id RoleId = [Select Id From UserRole where Name = 'Sales Rep - Tesla/Quadro/GRID'].Id;
        
        // Create Users to populate for Territory Mappings
        List<User> usrLst = new List<User>();
        
        // to avoid Mixed-DML error 
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr) {
           Test.startTest();
           usrLst = Test_COMM_Factory.createUsers(9, profileMap.get(strPrfLst[0]));
           Test.stopTest(); 
        }
        system.debug('usrLst---->'+usrLst);
        
        // Create Country List records.
        Country_List__c ctryLst = new Country_List__c();
        ctryLst.Name = 'United States';
        ctryLst.ISO_Code__c = 'US';
        ctryLst.Region__c = 'NALA'; 
        insert ctryLst;
        
        List<Country_List__c> ctryRecLst = [Select Id, Name from Country_List__c limit 1];
        
        // Create Territory Mappings
        List<Territory_Mapping__c> tmList = new List<Territory_Mapping__c>();
        for(Integer i=0; i<9; i++) {
            Territory_Mapping__c tm = new Territory_Mapping__c();
            tm.Name = 'Test Map'+i;
            tm.Territory_Account_Manager__c = usrLst[i].Id;
            tmList.add(tm);
        }
        insert tmList;
        
        // populate field values for Territory Mappings
        for(Integer i=1; i<9; i++) {
            // populate nulls in Region and Country for covering error message 
            tmList[0].Region__c = '';
            tmList[0].Country__c = ctryRecLst[0].Id;
            // populate State, City and Industry
            tmList[2].Region__c = 'NALA';
            tmList[2].Country__c = ctryRecLst[0].Id;
            tmList[2].State__c = 'California';
            tmList[2].City__c = 'San Jose';
            tmList[2].Industry__c = 'Higher Ed/Research';
            // populate State and City 
            tmList[3].Region__c = 'NALA';
            tmList[3].Country__c = ctryRecLst[0].Id;
            tmList[3].State__c = 'California';
            tmList[3].City__c = 'San Jose';
            // populate State and Industry
            tmList[4].Region__c = 'NALA';
            tmList[4].Country__c = ctryRecLst[0].Id;
            tmList[4].State__c = 'California';
            tmList[4].Industry__c = 'Higher Ed/Research';
            // populate City and Industry
            tmList[5].Region__c = 'NALA';
            tmList[5].Country__c = ctryRecLst[0].Id;
            tmList[5].City__c = 'San Jose';
            tmList[5].Industry__c = 'Higher Ed/Research';
            // populate only State
            tmList[6].Region__c = 'NALA';
            tmList[6].Country__c = ctryRecLst[0].Id;
            tmList[6].State__c = 'California';
            // populate only City
            tmList[7].Region__c = 'NALA';
            tmList[7].Country__c = ctryRecLst[0].Id;
            tmList[7].City__c = 'San Jose';
            // populate only Industry
            tmList[8].Region__c = 'NALA';
            tmList[8].Country__c = ctryRecLst[0].Id;
            tmList[8].Industry__c = 'Higher Ed/Research'; 
        } 
        update tmList; 
        system.debug('tmList----->'+tmList);  
        
        RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
        List<Account> acctsList = new List<Account>();
        List<Account_Tag__c> acctagList = new List<Account_Tag__c>();
        
        /*
        for(integer i=0; i<=169; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account'+i;
            acc.RecordTypeId = RT.Id;
            acc.Billing_Region__c = 'NALA';
            acc.BillingCountry = 'United States';
            acctsList.add(acc);
        }
        for(integer i=170; i<=171; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account'+i;
            acc.RecordTypeId = RT.Id;
            acc.Billing_Region__c = '';
            acc.BillingCountry = '';
            acctsList.add(acc);
        }
        insert acctsList;
        */
        
        for(integer i=0; i<=17; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account'+i;
            acc.RecordTypeId = RT.Id;
            acc.Billing_Region__c = 'NALA';
            acc.BillingCountry = 'United States';
            acctsList.add(acc);
        }
        for(integer i=18; i<=20; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account'+i;
            acc.RecordTypeId = RT.Id;
            acc.Billing_Region__c = '';
            acc.BillingCountry = '';
            acctsList.add(acc);
        }
        insert acctsList;
        
        for(integer i=0; i<21; i++) {
            Account_Tag__c atg = new Account_Tag__c();
            atg.AccountID__c = acctsList[i].Id;
            atg.Tag__c = COMM_Constants.Account_TAG_1;
            acctagList.add(atg);
        }
        
        // to cover not qualified Accounts condition
        for(integer i=0; i<1; i++) {
            Account_Tag__c atg = new Account_Tag__c();
            atg.AccountID__c = acctsList[i].Id;
            atg.Tag__c = COMM_Constants.Account_TAG_2;
            acctagList.add(atg);
        }
        
        insert acctagList;  
    
        List<Account> acctsLst = [Select Id, Name, OwnerId, Billing_Region__c, BillingCountry, BillingState,
                                  BillingCity, Industry from Account where RecordTypeId =:RT.Id];
    
        // Accounts with values in only Region and Country
        for(integer i=1; i<2; i++) {
            acctsLst[i].BillingState = '';
            acctsLst[i].BillingCity = '';
            acctsLst[i].Industry = ''; 
        } 
    
        // Accounts with value in Industry 
        for(integer i=2; i<3; i++) {
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = 'San Jose';
            acctsLst[i].Industry = 'Higher Ed/Research'; 
        }
    
        for(integer i=3; i<4; i++) {
           acctsLst[i].BillingState = 'California';
           acctsLst[i].BillingCity = 'San Test';
           acctsLst[i].Industry = 'Higher Ed/Research';
        }
    
        for(integer i=4; i<5; i++) {
            //acctsLst[i].BillingState = 'Calibro';
            acctsLst[i].BillingCity = 'San Jose'; 
            acctsLst[i].Industry = 'Higher Ed/Research';
        }
    
        for(integer i=5; i<6; i++) {
           //acctsLst[i].BillingState = 'Calibro';
           acctsLst[i].BillingCity = 'San Test';
           acctsLst[i].Industry = 'Higher Ed/Research'; 
        }
    
        for(integer i=6; i<7; i++) {
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = 'San Jose'; 
            acctsLst[i].Industry = 'IT Services';
        }  
    
        for(integer i=7; i<8; i++) {
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = 'San Test'; 
            acctsLst[i].Industry = 'IT Services';
        }
    
        // Accounts with null in Industry
        for(integer i=8; i<9; i++) {  
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = 'San Jose'; 
            acctsLst[i].Industry = ''; 
        }
    
        for(integer i=9; i<10; i++) {
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = 'San Test'; 
            acctsLst[i].Industry = ''; 
        }
    
        // Accounts with null in City and Industry 
        for(integer i=10; i<11; i++) {  
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = ''; 
            acctsLst[i].Industry = ''; 
        }
    
        // Accounts with null in City and not in Industry
        for(integer i=11; i<12; i++) {  
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = ''; 
            acctsLst[i].Industry = 'Higher Ed/Research'; 
        }
    
        for(integer i=12; i<13; i++) {  
            acctsLst[i].BillingState = 'California';
            acctsLst[i].BillingCity = ''; 
            acctsLst[i].Industry = 'IT Services'; 
        }
    
        // Accounts with null in State
        for(integer i=13; i<14; i++) {  
            acctsLst[i].BillingState = '';
            acctsLst[i].BillingCity = 'San Jose'; 
            acctsLst[i].Industry = 'Higher Ed/Research'; 
        }
    
        for(integer i=14; i<15; i++) {  
            acctsLst[i].BillingState = '';
            acctsLst[i].BillingCity = 'San Jose'; 
            acctsLst[i].Industry = 'IT Services'; 
        }
    
        // Accounts with nulls in State and City
        for(integer i=15; i<16; i++) {  
            acctsLst[i].BillingState = '';
            acctsLst[i].BillingCity = ''; 
            acctsLst[i].Industry = 'Higher Ed/Research'; 
        }
    
        for(integer i=16; i<17; i++) {  
            acctsLst[i].BillingState = '';
            acctsLst[i].BillingCity = ''; 
            acctsLst[i].Industry = 'IT Services'; 
        }
     
        update acctsLst;
     }
    
    final static String NAME = 'Test_Account_tgr_cls';
    final static String AGENT_PROFILE_NAME  = 'Service Cloud Generic User';
    @TestSetup
    static void setup() {
        Profile agentProfile    = [select id from profile  where name =: AGENT_PROFILE_NAME];
        //UserRole nvAgentRole  = [SELECT Id FROM UserRole where Name =: NV_AGENT_ROLE];
        //UserRole ncrAgentRole     = [SELECT Id FROM UserRole where Name =: NCR_AGENT_ROLE];
        
        List<User> userList = new List<User>();
        //User u1 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'1', ncrAgentRole.Id);
        //User u2 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'2', ncrAgentRole.Id);
        //User u3 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'3', nvAgentRole.Id);
        User u4 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'4', null);
        User u5 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'5', null);
        
        //userList.add(u1);
        //userList.add(u2);
        //userList.add(u3);
        userList.add(u4);
        userList.add(u5);
        
        insert userList;
    }
    
    @isTest
    static void test_Service_Processes() {
    
        User u4 = [select Id from User where LastName =: NAME+'4'];
        User u5 = [select Id from User where LastName =: NAME+'5'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        //1.Account Create - Account Name, Support level, Designated Eng, 
        Account acct                = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId           = rt.Id;
        acct.Designated_Engineer__c = u4.Id;
        //acct.Support_Level__c     = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        acct.Automotive_Startup__c  = 'No';
        insert acct;
        
        //Create product
        Product2 product        = Test_COMM_Factory.getProduct('Test Product');
        product.Product_Type__c = 'Software';
        product.Product_Line__c = 'Grid';
        product.ProductCode     = 'PRD001';
        product.IsActive        = true;
        product.Support_level__c= ESP_Utility.ESPConstants.SLA_24X7SUPPORT;
        insert product;
        
        //Create SAP Order
        SAP_Order__c ord    = new SAP_Order__c();
        ord.Order_Type__c   = 'ZOR';
        ord.Start_Date__c   = date.today();
        ord.End_Date__c     = date.today().addYears(3);
        ord.SAP_PAK_ID__c   = '12345';
        ord.Quantity__c     = 3;
        ord.Renewed_PAK_ID__c = 'PAK234';
        ord.Sold_To_Partner__c = 'SAPAcc001';
        //ord.Sold_To_Partner_Lookup__c = acc.Id;
        ord.SAP_Sales_Order_Number__c = '111';
        ord.Hardware_Serial_Number__c = 'Serial111';
        SAPOrder_tgr_cls.skipTriggerActions = true;
        //ord.SAP_Account__c    = 'SAPAcc001';
        ord.SFDC_Account__c = acct.Id;
        ord.Product_SKU__c  = 'PRD001';
        ord.Product__c      = product.Id;
        insert ord;
        
        //Create Entitlement - 
        Entitlement Ent                 = Test_COMM_Factory.getEntitlement(Name, acct.Id);
        Ent.Hardware_Serial_Number__c   = 'Serial111';
        Ent.PAK_ID__c                   = '12345';
        Ent.Service_product__c          = product.Id;
        Ent.EndDate                     = Date.today().addDays(10);
        Ent.StartDate                   = Date.today().addDays(-1);
        Ent.SAP_Order__c                = ord.id;
        //Ent.Subscription__c           = subscription1.Id;        
        insert Ent;
        
        
        /*acct.Support_Level__c = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        update acct;
        
        //Entitlement create- Entitlement Process Name, Account
        Entitlement Ent2 = new Entitlement();
        Ent2.AccountId = acct.Id;
        Ent2.Name = NAME+'Ent2';
        insert Ent2;*/
        
        //case create - Account*, Entitlement*, Case owner, incident status, case origin*, status*, subject , description, sevrity* 
        acct.Support_Level__c       = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        update acct;
        
        RecordType crt  = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c          = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        c.Severity__c   = 'S1:_Catastrophic';
        c.Origin        = 'Web';
        c.EntitlementId = Ent.Id;
        insert c;
        
        Account_tgr_cls.skipCaseUpdate = false;
        acct.Technical_Account_Manager_TAM__c       = u4.Id;
        update acct;
        
        Case c2             = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        c2.Severity__c  = 'S1:_Catastrophic';
        c2.Origin       = 'Web';
        c2.EntitlementId = Ent.Id;
        insert c2;
        
        acct.Support_Level__c = NULL;
        update acct;
        Test.stopTest();
    }
}