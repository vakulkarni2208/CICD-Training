@isTest
public class SAPOrderTriggerTest {
    
    static testMethod void TestQuoteIsCreated() {
        
        Test.startTest();
        
        QuoteGeneratorHelperTest.CreateTestOrders();

        Test.stopTest();

        integer rows = [SELECT COUNT() FROM SAP_Order__c ];

        System.assertEquals(4, rows, '4 orders created');        

    }
    
    

}