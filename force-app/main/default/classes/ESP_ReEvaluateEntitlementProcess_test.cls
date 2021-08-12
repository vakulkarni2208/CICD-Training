/**************************************************************************************************
* Name       : ESP_ReEvaluateEntitlementProcess_test
* Purpose    : Test class for ESP_ReEvaluateEntitlementProcess Apex Class 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Akhilesh Gupta     | 1.0        | 04/28/2021      | Created.
**************************************************************************************************/
@isTest
public class ESP_ReEvaluateEntitlementProcess_test {
	final static String NAME = 'TestTriggerEntitlement';
    @isTest
    public static void testESP_ReEvaluateEntitlementProcess(){
        
        Account acc = Test_COMM_Factory.getAccount('Test Account');
        insert acc;
        
        list<Id> accIdSet = new list<Id>();
        accIdSet.add(acc.Id);
        ESP_ReEvaluateEntitlementProcess.reEvaluateEntitlementProcess(accIdSet);
    }
}