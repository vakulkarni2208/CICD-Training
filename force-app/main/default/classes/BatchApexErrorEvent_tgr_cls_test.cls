@isTest
public with sharing class BatchApexErrorEvent_tgr_cls_test {
    
    static testMethod void testBatchApexErrorEvent() {
    
        insert new Account(Name = 'Test Account');
        try {
            Test.startTest();
            NV_TestBatchForBatchApexErrorEvent_BAT tb = new NV_TestBatchForBatchApexErrorEvent_BAT();
            Database.executeBatch(tb); 
            Test.getEventBus().deliver();
            Test.stopTest();
        } catch(System.MathException e){}
        
        Test.getEventBus().deliver();
    }
}