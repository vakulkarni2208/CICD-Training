/*
 * Created Date: 3/15/2017
 * Created By: Manideep
 * Description: This Test class maintains Code Coverage for "TAM_Batch" class.
*/
@isTest
private class TAM_Batch_Test {
	 
  // This method covers code coverage for "TAM_Batch" and "TAM_Utility_Class" as well
  private static testMethod void testMethod1() {
  	
  	// fetch all the Users created in setup method above.
  	List<User> usrLst2 = [Select Id from User];
  	
  	// Create Country List records.
    Country_List__c ctryLst = new Country_List__c();
    ctryLst.Name = 'United States';
    ctryLst.ISO_Code__c = 'US';
    ctryLst.Region__c = 'NALA'; 
    insert ctryLst;
    
    List<Country_List__c> ctryRecLst = [Select Id, Name from Country_List__c limit 1];
  	
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
        tmList2[1].Country__c = ctryRecLst[0].Id;
        // populate State, City and Industry
        tmList2[2].Region__c = 'NALA';
        tmList2[2].Country__c = ctryRecLst[0].Id;
        tmList2[2].State__c = 'California';
        tmList2[2].City__c = 'San Jose';
        tmList2[2].Industry__c = 'Higher Ed/Research';
        // populate State and City 
        tmList2[3].Region__c = 'NALA';
        tmList2[3].Country__c = ctryRecLst[0].Id;
        tmList2[3].State__c = 'California';
        tmList2[3].City__c = 'San Jose';
        // populate State and Industry
        tmList2[4].Region__c = 'NALA';
        tmList2[4].Country__c = ctryRecLst[0].Id;
        tmList2[4].State__c = 'California';
        tmList2[4].Industry__c = 'Higher Ed/Research';
        // populate City and Industry
        tmList2[5].Region__c = 'NALA';
        tmList2[5].Country__c = ctryRecLst[0].Id;
        tmList2[5].City__c = 'San Jose';
        tmList2[5].Industry__c = 'Higher Ed/Research';
        // populate only State
        tmList2[6].Region__c = 'NALA';
        tmList2[6].Country__c = ctryRecLst[0].Id;
        tmList2[6].State__c = 'California';
        // populate only City
        tmList2[7].Region__c = 'NALA';
        tmList2[7].Country__c = ctryRecLst[0].Id;
        tmList2[7].City__c = 'San Jose';
        // populate only Industry
        tmList2[8].Region__c = 'NALA';
        tmList2[8].Country__c = ctryRecLst[0].Id;
        tmList2[8].Industry__c = 'Higher Ed/Research'; 
    } 
    update tmList2; 
  	
  	RecordType RT = [Select Id, Name from RecordType where Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];

    // Create new Accounts for Batch class to process
    List<Account> acctsList2 = new List<Account>();
    List<Account_Tag__c> acctagList2 = new List<Account_Tag__c>();
    
    for(integer i=10; i<=19; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = '';
        acc.BillingCity = '';
        acc.Industry = ''; 
        acctsList2.add(acc);
    }
    for(integer i=20; i<=29; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'San Jose';
        acc.Industry = 'Higher Ed/Research'; 
        acctsList2.add(acc);
    }
    for(integer i=30; i<=39; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'San Test';
        acc.Industry = 'Higher Ed/Research'; 
        acctsList2.add(acc);
    }
    for(integer i=40; i<=49; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        //acc.BillingState = 'Calibro';
        acc.BillingCity = 'San Jose';
        acc.Industry = 'Higher Ed/Research'; 
        acctsList2.add(acc);
    }
    for(integer i=50; i<=59; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        //acc.BillingState = 'Calibro';
        acc.BillingCity = 'San Test';
        acc.Industry = 'Higher Ed/Research'; 
        acctsList2.add(acc);
    }
    for(integer i=60; i<=69; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'San Jose';
        acc.Industry = 'IT Services'; 
        acctsList2.add(acc);
    }
    for(integer i=70; i<=79; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'San Test';
        acc.Industry = 'IT Services'; 
        acctsList2.add(acc);
    }
    for(integer i=80; i<=89; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'San Jose';
        acc.Industry = ''; 
        acctsList2.add(acc);
    }
    for(integer i=90; i<=99; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = 'San Test';
        acc.Industry = ''; 
        acctsList2.add(acc);
    }
    for(integer i=100; i<=109; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = '';
        acc.Industry = ''; 
        acctsList2.add(acc);
    }
    for(integer i=110; i<=119; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = '';
        acc.Industry = 'Higher Ed/Research'; 
        acctsList2.add(acc);
    }
    for(integer i=120; i<=129; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingCity = '';
        acc.Industry = 'IT Services'; 
        acctsList2.add(acc);
    }
    for(integer i=130; i<=139; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = '';
        acc.BillingCity = 'San Jose';
        acc.Industry = 'Higher Ed/Research'; 
        acctsList2.add(acc);
    }
    for(integer i=140; i<=149; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = '';
        acc.BillingCity = 'San Jose';
        acc.Industry = 'IT Services'; 
        acctsList2.add(acc);
    }
    for(integer i=150; i<=159; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = '';
        acc.BillingCity = '';
        acc.Industry = 'Higher Ed/Research'; 
        acctsList2.add(acc);
    }
    for(integer i=160; i<=169; i++) {
        Account acc = new Account();
        acc.Name = 'Test Account'+i;
        acc.RecordTypeId = RT.Id;
        acc.Billing_Region__c = 'NALA';
        acc.BillingCountry = 'United States';
        acc.BillingState = '';
        acc.BillingCity = '';
        acc.Industry = 'IT Services'; 
        acctsList2.add(acc);
    }
    
    insert acctsList2;
    
    for(integer i=0; i<=159; i++) {
        Account_Tag__c atg = new Account_Tag__c();
        atg.AccountID__c = acctsList2[i].Id;
        atg.Tag__c = COMM_Constants.Account_TAG_1;
        acctagList2.add(atg);
    }
    
    // to cover not qualified Accounts condition
    for(integer i=0; i<=9; i++) {
        Account_Tag__c atg = new Account_Tag__c();
        atg.AccountID__c = acctsList2[i].Id;
        atg.Tag__c = COMM_Constants.Account_TAG_2;
        acctagList2.add(atg);
    }
    
    insert acctagList2;
    
    /*
    // invoke batch class
    TAM_Batch tmbatch = new TAM_Batch();
    Id batchJobId = Database.executeBatch(tmbatch);
    */
    
    Test.StartTest();
    TAM_Batch schBatch = new TAM_Batch(); 
    String schTime = '0 0 23 * * ?';
    system.schedule('Test check', schTime, schBatch); 
    Test.stopTest();
    
  }  
    
}