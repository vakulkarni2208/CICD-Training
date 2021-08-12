/**
    2019.07.03 - PJENA - Test class for ESP_CreateEntFromSubscr_Sch that created/sync Entitlements from SBQQ_Subscription__c
    Note: Run it with svcDeploy user as it has access to CPQ objects
 */
 
 
@isTest(SeeAllData=false)
private class Test_ESP_CreateEntFromSubscr_Sch {
    
    public static final string accName = 'TESTCUSTOMER20190703001';
    
    static testMethod void createEntitlement() {
        Test.startTest();
            string CRON_EXP = '0 1 * ? * *';
                
             // Schedule the test job
            String jobId = System.schedule('Test_ESP_CreateEntFromSubscr_Sch',  CRON_EXP,  new ESP_CreateEntFromSubscr_Sch());
    
             // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    
            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);
    
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    
    
    @testsetup
    public static void setup(){
        
        //set the custom settings values
        ESP_CreateEntFromSubscr_Settings__c oCSSettings = new ESP_CreateEntFromSubscr_Settings__c();
        oCSSettings.Name = 'ESP : CreateEntFromSubscr : Settings';
        oCSSettings.BATCH_SIZE__c = 10;
        oCSSettings.ENABLE_SCHDULED_JOB__c = true;
        oCSSettings.LKBK_TIME__c = 15;
        oCSSettings.RECUR__c = 10;
        insert oCSSettings;

        //Account creation
        Account acc = Test_COMM_Factory.getAccount(accName);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = :COMM_Constants.SOBJECT_ACCOUNT AND  Name = :COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
        acc.RecordTypeId = rt.Id;
        insert acc;
                
        //Contract creation
        Contract contract = Test_COMM_Factory.getContract(acc.Id);
        insert contract;
        
        //Activate contract
        contract.Status = 'Activated';
        update contract;
        
        //Product creation
        Product2 product = Test_COMM_Factory.getProduct('Test Product');
        insert product;
        
        //Subscription creation
        SBQQ__Subscription__c subscription1 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription1.Hardware_Serial_Number__c = 'Serial111';
        insert subscription1;
        
        //create subscription and entitlement manually
        SBQQ__Subscription__c subscription2 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription2.Hardware_Serial_Number__c = 'Serial111';
        insert subscription2;
        
        list<Entitlement> lstEnt2 = [Select Id From Entitlement where Subscription__c = :subscription2.Id];
        if (lstEnt2 == null || lstEnt2.isEmpty()){
            Entitlement ent2 = new Entitlement(name='TestEnt', AccountId = acc.Id, Subscription__c =  subscription2.Id, Hardware_Serial_Number__c=subscription2.Hardware_Serial_Number__c );
            insert ent2;
        }
        
    }
}