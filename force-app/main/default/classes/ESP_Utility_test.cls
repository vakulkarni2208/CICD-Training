/**
 * A Utility Class for Service Cloud
 * 09/20/2019 - Akhilesh Gupta - Created: 
 * 02/20/2020 - Akhilesh Gupta - Updated class to add coverage for getCustomerProfiles function.
 * 02/26/2020 - Akhilesh Gupta - Updated class for ESPConstant and ServiceCloudUtils code change for new constants framework.
 **/
 
 @isTest
public with sharing class ESP_Utility_test {
    
    final static String NAME = 'ESP_Utility_test';
    
    @isTest
    static void test_ESP_Utility() {
    	//User u1 = [select Id from User where LastName =: NAME+'1'];
    	RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];
    	
    	Test.startTest();
        
        Account acc		 = Test_COMM_Factory.getAccount(NAME);
        acc.RecordTypeId = rt.Id;
        insert acc;
        
        Entitlement Ent = Test_COMM_Factory.getEntitlement(Name, acc.id);
        insert Ent;
        
        ESP_Utility.FindProductLinesForCustomer(acc.Id);
        ESP_Utility.LogErrors('ErrorCode', 'ErrorDesc');
        ESP_Utility.getL1L2OwnerRoles();
        //ESP_Utility.getServiceCloudSetting(); Deprecated this function. Use "ESP_Utility.ESPConstants.ServiceCloudSettings" instead
        ESP_Utility.getSLASetting(ESP_Utility.ESPConstants.SLA_24X7SUPPORT);//Name);
        ESP_Utility.getMilestoneSetting('MilestoneName', 'Severity');
        ESP_Utility.getMilestoneAlertSetting('MilestoneStatus');
        //ESP_Utility.getCustomerProfiles();
        //ESP_Utility.getAgentProfiles();
        //ESP_Utility.getInternalUserTypes();
        
        //Temporary testCode for other classes:
        ServiceCloudConstants scc = new ServiceCloudConstants();
        //ESP_Constants EC = new ESP_Constants();
        ESP_Constants espConstants = ESP_Constants.getInstance();
        
        //TestCode for ServiceCloudUtils
        set<String> productLines = new set<String>{'DGX','Grid'};
        ServiceCloudUtils.getRWAProdFamily(productLines);
        ServiceCloudUtils.checkPortalAccess(productLines);
        ServiceCloudUtils.FindProductLinesForCustomer(acc.Id);
        //ServiceCloudUtils.getSLASetting(Name);
        //ServiceCloudUtils.getMilestoneSetting('MilestoneName', 'Severity');
        //ServiceCloudUtils.getMilestoneAlertSetting('MilestoneStatus');
        ServiceCloudUtils.LogErrors('ErrorCode', 'ErrorDesc');
        //ServiceCloudUtils.getRWAFeaturesMap();
        
        
        RecordType crt 	= [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c 			= Test_COMM_Factory.getCase(acc.Id, crt.Id);
        c.Severity__c 	= 'S1:_Catastrophic';
        c.Origin 		= 'Web';
        c.EntitlementId = Ent.Id;
        insert c;
        
        ServiceCloudUtils.UpdateRecentActivityOnCase(new map<Id, String>{c.Id => 'akhileshg@nvidia.com'}, userInfo.getUserId(), 'CaseComment');
        
        Test.stopTest();
    }
    
    //@TestSetup
    //static void setup() {
    	/*Profile agentProfile 	= [select id from profile  where name =: ESP_Constants.AGENT_PROFILES.keys()[0]];
        //UserRole nvAgentRole 	= [SELECT Id FROM UserRole where Name =: NV_AGENT_ROLE];
        //UserRole ncrAgentRole = [SELECT Id FROM UserRole where Name =: NCR_AGENT_ROLE];
        
        List<User> userList = new List<User>();
        User u1 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'1', null);
        
        userList.add(u1);
        
        insert userList;*/
    //}
}