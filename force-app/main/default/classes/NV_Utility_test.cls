/**
 * Test Class for NV_Utility class.
 * Created: 10/20/2019 - Akhilesh Gupta 
 *
 */
@isTest
public with sharing class NV_Utility_test {
    final static String NAME = 'NV_Utility_test';
    
    @TestSetup
    static void setup() {}
    
    @isTest
    static void test_NV_Utility() {
    	Test.startTest();
	        NV_Utility.getPublicGroupsOrQueueIdByDevName('TAM_Queue');
	        NV_Utility.getPublicGroupOrQueueIdByName('TAM Queue');
	        NV_Utility.getbatchJobSetting('ESP_SyncSAPOrderToEntitlement_BAT');
        Test.stopTest();
    }
}