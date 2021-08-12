/*
 * Created Date: 3/13/2017
 * Created By: Manideep
 * Description: This Test class maintains Code Coverage for "CRM_TAM_Utility" Service class.
 
 * 6/7/2019 : Manideep : Fixed the time-out, too many query-rows, etc., errors as it is failing in PROD and deployed as part of Old Opportunity Record Type Cleanup.
*/
@isTest
private class CRM_TAM_Utility_Test {
   
  @testSetup static void acctsSetup() {
    
    List<String> strPrfLst = new List<String>{'Sales Profile'};
    Map<String, Id> profileMap = Test_COMM_Factory.getProfsByName(strPrfLst);
    Id RoleId = [Select Id From UserRole where Name = 'Sales Rep - Tesla/Quadro/GRID'].Id;
    
    // Create Users to populate for Territory Mappings
    List<User> usrLst = new List<User>();
    
    // to avoid Mixed-DML error 
    User usr = [Select id from User where Id = :UserInfo.getUserId()];
    System.RunAs(usr) {
       //Test.startTest();
       usrLst = Test_COMM_Factory.createUsers(9, profileMap.get(strPrfLst[0]));
       //Test.stopTest();   
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
        /*
        // populate Region and Country
        tmList[1].Region__c = 'NALA';
        tmList[1].Country__c = ctryRec.Id;
        */
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
    
    for(integer i=0; i<=10; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.Automotive_Startup__c = 'No';
        acctsList.add(acc);
    }
    for(integer i=11; i<=25; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = '';
        acc.BillingCountry = '';
        acc.Automotive_Startup__c = 'No';
        acctsList.add(acc);
    }
    
    insert acctsList;
    
    /*
    for(integer i=0; i<171; i++) {
        Account_Tag__c atg = new Account_Tag__c();
        atg.AccountID__c = acctsList[i].Id;
        atg.Tag__c = COMM_Constants.Account_TAG_1;
        acctagList.add(atg);
    }
    
    // to cover not qualified Accounts condition
    for(integer i=0; i<9; i++) {
        Account_Tag__c atg = new Account_Tag__c();
        atg.AccountID__c = acctsList[i].Id;
        atg.Tag__c = COMM_Constants.Account_TAG_2;
        acctagList.add(atg);
    }
    */
      
    // to cover not qualified Accounts condition
    for(integer i=0; i<2; i++) {
        Account_Tag__c atg = new Account_Tag__c();
        atg.AccountID__c = acctsList[i].Id;
        atg.Tag__c = COMM_Constants.Account_TAG_2;
        acctagList.add(atg);
    }
    
    for(integer i=2; i<=25; i++) {
        Account_Tag__c atg = new Account_Tag__c();
        atg.AccountID__c = acctsList[i].Id;
        atg.Tag__c = COMM_Constants.Account_TAG_1;
        acctagList.add(atg);
    }    
    
    Test.startTest();
    insert acctagList;
    Test.stopTest();
     
  }
  
  // This method covers code coverage for "CRM_TAM_Utility"
  private static testMethod void TAMUtilityServiceClassMethod1() {
    
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    List<Account> acctsLst = [Select Id, Name, OwnerId, Billing_Region__c, BillingCountry, BillingState,
                               BillingCity, Industry from Account where RecordTypeId =:RT.Id];
    
    // Accounts with values in only Region and Country
    for(integer i=0; i<1; i++) {
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = '';
        acctsLst[i].Industry = ''; 
    } 
    
    // Accounts with value in Industry 
    for(integer i=1; i<2; i++) {
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
        acctsLst[i].BillingState = 'Calibro';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = 'Higher Ed/Research';
    }
    
    for(integer i=5; i<6; i++) {
        acctsLst[i].BillingState = 'Calibro';
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
    
    // Accounts with value in City only
    for(integer i=10; i<11; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = ''; 
    }    
    
    // Accounts with null in City and Industry 
    for(integer i=11; i<12; i++) {  
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = ''; 
    }
    
    // Accounts with null in City and not in Industry
    for(integer i=12; i<13; i++) {  
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=13; i<14; i++) {  
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'IT Services'; 
    }
    
    // Accounts with null in State
    for(integer i=14; i<15; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=15; i<16; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = 'IT Services'; 
    }
    
    // Accounts with nulls in State and City
    for(integer i=16; i<17; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=18; i<19; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'IT Services'; 
    }
    
    List<TAMSObjectRecTemplate> listAllTSRT = new List<TAMSObjectRecTemplate>();
    for(Account acc: acctsLst) {
        TAMSObjectRecTemplate TSRT = new TAMSObjectRecTemplate();
        TSRT.Id = acc.Id; 
        TSRT.Region = acc.Billing_Region__c;
        TSRT.Country = acc.BillingCountry;
        TSRT.State = acc.BillingState;
        TSRT.City = acc.BillingCity;
        TSRT.Industry = acc.Industry;
        listAllTSRT.add(TSRT);
    }
    listAllTSRT = CRM_TAM_Utility.getTAMs(listAllTSRT);
            
  }
  
  // This method covers code coverage for "CRM_TAM_Utility"
  private static testMethod void TAMUtilityServiceClassMethod2() {
    
    List<Territory_Mapping__c> mappingstoDelete = [Select Id, Name from Territory_Mapping__c];
    delete mappingstoDelete;
    
    // fetch all the Users created in setup method above.
    List<User> usrLst2 = [Select Id from User WHERE CreatedDate = Today];
    
    // fetch Country Lists
    List<Country_List__c> ctryLst2 = [Select Id, Name from Country_List__c];
    
    // Create Territory Mappings
    List<Territory_Mapping__c> tmList2 = new List<Territory_Mapping__c>();
    for(Integer i=0; i<9; i++) {
        Territory_Mapping__c tm = new Territory_Mapping__c();
        tm.Name = 'Test Map'+i;
        tm.Territory_Account_Manager__c = usrLst2[i].Id;
        tmList2.add(tm);
    }
    insert tmList2;
    
    // populate field values for Territory Mappings
    for(Integer i=1; i<9; i++) { 
        // populate Region and Country
        tmList2[1].Region__c = 'NALA';
        tmList2[1].Country__c = ctryLst2[0].Id;
        // populate State, City and Industry
        tmList2[2].Region__c = 'NALA';
        tmList2[2].Country__c = ctryLst2[0].Id;
        tmList2[2].State__c = 'California';
        tmList2[2].City__c = 'San Jose';
        tmList2[2].Industry__c = 'Higher Ed/Research';
        // populate State and City 
        tmList2[3].Region__c = 'NALA';
        tmList2[3].Country__c = ctryLst2[0].Id;
        tmList2[3].State__c = 'California';
        tmList2[3].City__c = 'San Jose';
        // populate State and Industry
        tmList2[4].Region__c = 'NALA';
        tmList2[4].Country__c = ctryLst2[0].Id;
        tmList2[4].State__c = 'California';
        tmList2[4].Industry__c = 'Higher Ed/Research';
        // populate City and Industry
        tmList2[5].Region__c = 'NALA';
        tmList2[5].Country__c = ctryLst2[0].Id;
        tmList2[5].City__c = 'San Jose';
        tmList2[5].Industry__c = 'Higher Ed/Research';
        // populate only State
        tmList2[6].Region__c = 'NALA';
        tmList2[6].Country__c = ctryLst2[0].Id;
        tmList2[6].State__c = 'California';
        // populate only City
        tmList2[7].Region__c = 'NALA';
        tmList2[7].Country__c = ctryLst2[0].Id;
        tmList2[7].City__c = 'San Jose';
        // populate only Industry
        tmList2[8].Region__c = 'NALA';
        tmList2[8].Country__c = ctryLst2[0].Id;
        tmList2[8].Industry__c = 'Higher Ed/Research'; 
    } 
    update tmList2; 
    
    RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
    List<Account> acctsLst = [Select Id, Name, OwnerId, Billing_Region__c, BillingCountry, BillingState,
                               BillingCity, Industry from Account where RecordTypeId =:RT.Id];
    
    // Accounts with values in only Region and Country
    for(integer i=9; i<10; i++) {
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = '';
        acctsLst[i].Industry = ''; 
    } 
    
    // Accounts with value in Industry 
    for(integer i=10; i<11; i++) {
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = 'San Jose';
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=11; i<12; i++) {
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = 'San Test';
        acctsLst[i].Industry = 'Higher Ed/Research';
    }
    
    for(integer i=12; i<13; i++) {
        acctsLst[i].BillingState = 'Calibro';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = 'Higher Ed/Research';
    }
    
    for(integer i=13; i<14; i++) {
        acctsLst[i].BillingState = 'Calibro';
        acctsLst[i].BillingCity = 'San Test';
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=14; i<15; i++) {
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = 'IT Services';
    } 
    
    for(integer i=15; i<16; i++) {
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = 'San Test'; 
        acctsLst[i].Industry = 'IT Services';
    }
    
    // Accounts with null in Industry
    for(integer i=16; i<17; i++) {  
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = ''; 
    }
    
    for(integer i=17; i<18; i++) {
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = 'San Test'; 
        acctsLst[i].Industry = ''; 
    }
    
    // Accounts with null in City and Industry 
    for(integer i=18; i<19; i++) {  
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = ''; 
    }
    
    // Accounts with null in City and not in Industry
    for(integer i=19; i<20; i++) {  
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=20; i<21; i++) {  
        acctsLst[i].BillingState = 'California';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'IT Services'; 
    }
    
    // Accounts with null in State
    for(integer i=22; i<23; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=23; i<24; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = 'San Jose'; 
        acctsLst[i].Industry = 'IT Services'; 
    }
    
    // Accounts with nulls in State and City
    for(integer i=24; i<25; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'Higher Ed/Research'; 
    }
    
    for(integer i=25; i<26; i++) {  
        acctsLst[i].BillingState = '';
        acctsLst[i].BillingCity = ''; 
        acctsLst[i].Industry = 'IT Services'; 
    }
    
    List<TAMSObjectRecTemplate> listAllTSRT = new List<TAMSObjectRecTemplate>();
    for(Account acc: acctsLst) {
        TAMSObjectRecTemplate TSRT = new TAMSObjectRecTemplate();
        TSRT.Id = acc.Id; 
        TSRT.Region = acc.Billing_Region__c;
        TSRT.Country = acc.BillingCountry;
        TSRT.State = acc.BillingState;
        TSRT.City = acc.BillingCity;
        TSRT.Industry = acc.Industry;
        listAllTSRT.add(TSRT);
    }
    listAllTSRT = CRM_TAM_Utility.getTAMs(listAllTSRT);
            
  }
    
}