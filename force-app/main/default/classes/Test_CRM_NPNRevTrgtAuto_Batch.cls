/*
    Test class for Schedulable and Batachable CRM_NPNRevTrgtAuto_Batch class
*/
 
@isTest(SeeAllData=false)
private class Test_CRM_NPNRevTrgtAuto_Batch {
    private static string BILLING_COUNTRY_US = 'United States'; 
    private static string BILLING_COUNTRY_CA = 'Canada'; 
    private static decimal THRESHOLD_COMMIT_EL = 100;
    private static decimal THRESHOLD_COMMIT_PREF = 100;
    private static string ACCOUNT_RT_NPN_ACCOUNT_REGISTRY = 'NPN Account Registry';
    private static string PORTAL_COMPETENCY_AC = 'Accelerated Computing';
    private static string PA_PROGRAM_SP = 'Solution Provider';
    private static string PA_LEVEL_ELITE = 'Elite';
    private static string PA_LEVEL_PREF = 'Preferred';

    
    //test for scheduling methods
    static testMethod void testSchedule_CRM_NPNRevTrgtAuto_Batch() {
        
        map<string, Id> mapRTNameId = new map<string, Id>();
        list<RecordType> lstRecTypes = [Select Name From RecordType Where SobjectType = 'Account' And Name = :ACCOUNT_RT_NPN_ACCOUNT_REGISTRY];
        for (RecordType rt : lstRecTypes){
            mapRTNameId.put(rt.Name, rt.Id);
        }

        //Create a NPN Account Registry type of Account
        list<Account> lstNPNAccounts = new list<Account>();
        Account accNPNRegUS = new Account(name = 'NPNAccountRegistryUS', RecordTypeId = mapRTNameId.get(ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = 'street1', BillingCity = 'Santa Clara', BillingState = 'California', BillingCountry = BILLING_COUNTRY_US, BillingPostalCode = '95050', NPN_Program_Signed_Date__c = system.today() );
        Account accNPNRegCA = new Account(name = 'NPNAccountRegistryCA', RecordTypeId = mapRTNameId.get(ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = 'street1', BillingCity = 'Santa Clara', BillingState = 'British Columbia', BillingCountry = BILLING_COUNTRY_CA, BillingPostalCode = '95050', NPN_Program_Signed_Date__c = system.today() );
        lstNPNAccounts.add(accNPNRegUS);
        lstNPNAccounts.add(accNPNRegCA);
        insert lstNPNAccounts;
        
        
        //Create Country_List__c
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = BILLING_COUNTRY_US, ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA', Territory__c = 'LA'); 
        Country_List__c countryCA = new Country_List__c(name = BILLING_COUNTRY_CA, ISO_Code__c = 'CA', Region__c = 'NALA', Sub_Region__c = 'LA', Territory__c = 'LA'); 
        lstCountry.add(countryUS);
        lstCountry.add(countryCA);
        insert lstCountry;
        
        //Create NPN_Revenue_Commitment_Master__c
        list<NPN_Revenue_Commitment_Master__c> lstRevCommitMstr = new list<NPN_Revenue_Commitment_Master__c>();
        NPN_Revenue_Commitment_Master__c RevCommitMstrUSACEL = new NPN_Revenue_Commitment_Master__c(Program__c = PA_PROGRAM_SP, Competency__c = PORTAL_COMPETENCY_AC, Level__c = PA_LEVEL_ELITE, Country__c = countryUS.Id, Threshold__c = THRESHOLD_COMMIT_EL);
        NPN_Revenue_Commitment_Master__c RevCommitMstrCAACPREF = new NPN_Revenue_Commitment_Master__c(Program__c = PA_PROGRAM_SP, Competency__c = PORTAL_COMPETENCY_AC, Level__c = PA_LEVEL_PREF, Country__c = countryCA.Id, Threshold__c = THRESHOLD_COMMIT_PREF);
        lstRevCommitMstr.add(RevCommitMstrUSACEL);
        lstRevCommitMstr.add(RevCommitMstrCAACPREF);
        insert lstRevCommitMstr;
        
        //Create custom settings data
        NPN_Revenue_Target_Automation_Settings__c csNPNSettings = new NPN_Revenue_Target_Automation_Settings__c();
        csNPNSettings.No_Match_No_Revenue_Target__c = true;
        insert csNPNSettings;
        
        //Create a Partner Attribute record
        list<Partner_Attribute__c> lstPA = new list<Partner_Attribute__c>();
        Partner_Attribute__c paAccNPNRegUS = new Partner_Attribute__c(Account_Name__c = accNPNRegUS.Id, Partner_Program_Name__c = PA_PROGRAM_SP, Partner_Competency__c = PORTAL_COMPETENCY_AC, Program_Level__c = PA_LEVEL_ELITE );
        Partner_Attribute__c paAccNPNRegCA = new Partner_Attribute__c(Account_Name__c = accNPNRegCA.Id, Partner_Program_Name__c = PA_PROGRAM_SP, Partner_Competency__c = PORTAL_COMPETENCY_AC, Program_Level__c = PA_LEVEL_PREF );
        lstPA.add(paAccNPNRegUS);
        insert lstPA;
        
        //delete the Revenue Targets that gets created by Partner Attribute trigger
        list<NPN_Revenue_Targets__c> lstRevTrgts = [Select Id From NPN_Revenue_Targets__c Where Partner_Attribute__c = :lstPA];
        delete lstRevTrgts;
        
        //Start the actual test for scheduling
        Test.startTest();
            
            //Create the Schedule to run after 5 seconds
            DateTime currDT = DateTime.now().addSeconds(5);
            integer sec = currDT.second();
            integer min = currDT.minute();
            string CRON_EXP = sec + ' ' + min + ' ' + '* ? * *'; 

            // Schedule the test job
            String jobId = System.schedule('Test CRM_NPNRevTrgtAuto_Batch',  CRON_EXP ,  new CRM_NPNRevTrgtAuto_Batch());

            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);

            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }


    //test for actual batch methods
    static testMethod void testBatch_CRM_NPNRevTrgtAuto_Batch() {
    
        list<string> lstSObjects = new list<string>{'Account'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);

        //Create a NPN Account Registry type of Account
        list<Account> lstNPNAccounts = new list<Account>();
        for (integer i = 0; i < 10; i++){
            Account accNPNRegUS = new Account(name = 'NPNAccountRegistryUS'+i, RecordTypeId = mapRTNameId.get(ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = 'street1', BillingCity = 'Santa Clara', BillingState = 'California', BillingCountry = BILLING_COUNTRY_US, BillingPostalCode = '95050', NPN_Program_Signed_Date__c = system.today() );
            lstNPNAccounts.add(accNPNRegUS);
        }
        insert lstNPNAccounts;
        
        
        //Create Country_List__c
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = BILLING_COUNTRY_US, ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA', Territory__c = 'LA'); 
        lstCountry.add(countryUS);
        insert lstCountry;
        
        //Create NPN_Revenue_Commitment_Master__c
        list<NPN_Revenue_Commitment_Master__c> lstRevCommitMstr = new list<NPN_Revenue_Commitment_Master__c>();
        NPN_Revenue_Commitment_Master__c RevCommitMstrUSACEL = new NPN_Revenue_Commitment_Master__c(Program__c = PA_PROGRAM_SP, Competency__c = PORTAL_COMPETENCY_AC, Level__c = PA_LEVEL_ELITE, Country__c = lstCountry[0].Id, Threshold__c = THRESHOLD_COMMIT_EL);
        lstRevCommitMstr.add(RevCommitMstrUSACEL);
        insert lstRevCommitMstr;
        
        //Create a Partner Attribute record
        list<Partner_Attribute__c> lstPA = new list<Partner_Attribute__c>();
        for (integer i = 0; i < 10; i++){
            Partner_Attribute__c paAccNPNRegUS = new Partner_Attribute__c(Account_Name__c = lstNPNAccounts[i].Id, Partner_Program_Name__c = PA_PROGRAM_SP, Partner_Competency__c = PORTAL_COMPETENCY_AC, Program_Level__c = PA_LEVEL_ELITE );
            lstPA.add(paAccNPNRegUS);
        }
        insert lstPA;
        
        //delete the Revenue Targets that gets created by Partner Attribute trigger
        list<NPN_Revenue_Targets__c> lstRevTrgts = [Select Id From NPN_Revenue_Targets__c Where Partner_Attribute__c = :lstPA];
        delete lstRevTrgts;
        
        
        //Start the actual test for batch class
        Test.startTest();
            CRM_NPNRevTrgtAuto_Batch batchCls = new CRM_NPNRevTrgtAuto_Batch();
            Database.executeBatch(batchCls);
        Test.stopTest();
        
        list<NPN_Revenue_Targets__c> lstRevTrgtsAfterStop = [Select Year__c, Minimum_Annual_Sales_Commitment__c From NPN_Revenue_Targets__c Where Partner_Attribute__c = :lstPA];
        system.debug('***lstRevTrgtsAfterStop: ' + lstRevTrgtsAfterStop);
        system.assert(lstRevTrgtsAfterStop.size() == 10);
        system.assert(lstRevTrgtsAfterStop[0].Minimum_Annual_Sales_Commitment__c == THRESHOLD_COMMIT_EL);
    }
}