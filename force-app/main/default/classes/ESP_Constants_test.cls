/**
 * A Utility Class for Service Cloud
 * 09/20/2019 - Akhilesh Gupta - Created: 
 * 02/23/2020 - Akhilesh Gupta - Updated class to add coverage for getCustomerProfiles function.
 **/
	 
@isTest
public with sharing class ESP_Constants_test {
	@isTest
    static void test_ESP_Constants() {
    	Test.startTest();
	        //ESP_Constants EC = new ESP_Constants();
	        ESP_Constants espConstants = ESP_Constants.getInstance();
        Test.stopTest();
    }
}