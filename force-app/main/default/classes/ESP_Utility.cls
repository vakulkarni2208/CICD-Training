/* 
Description: This class have all common utility methods for Service Cloud functionalities.

01-Sep-2019:    Akhilesh:   Created.
01-Sep-2019:    Akhilesh:   Added Function "FindProductLinesForCustomer".
03-Sep-2019:    Akhilesh:   Added Function "LogErrors".
03-Sep-2019:    Akhilesh:   Added Function "getL1L2OwnerRoles", used in CaseTriggerHelper.
20-Oct-2019:    Akhilesh:   Added Function "getServiceCloudSetting", returns Service Cloud Settings.
14-Feb-2020:	Akhilesh:	Updated Function "getServiceCloudSetting"
21-Feb-2020: 	Akhilesh:   Added Function "getCustomerProfiles"
26-Feb-2020: 	Akhilesh:   Removed Funtions getCustomerProfiles, getServiceCloudSetting, getAgentProfiles, getInternalUserTypes
IMPORTANT:					Added New Variable "ESPConstants" to support new Constants Framework
							Moved functions from ServiceCloudUtils: getSLASettings, getMilestoneSettings, getMilestoneAlertSettings

*/
public class ESP_Utility {
	
	/* This variable instanciates Constant values from Custom Metadata (Service Cloud Settings)
	   This variable should be used for all constant values across all service cloud code
	*/	
	public static final ESP_Constants ESPConstants = ESP_Constants.getInstance();
	
	//IMPORTANT: Below variable is deprecated. Please use ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c instead.
	//public static final string CONST_24X7SUPPORT = '24x7 Escalated Remote';
    
    
	
	/// This functions are Deprecated, Use "ESP_Utility.ESPConstants.ServiceCloudSettings" instead
	/*private static Service_Cloud_Settings__mdt serviceCloudSetting = NULL;
    public static Service_Cloud_Settings__mdt getServiceCloudSetting(){
        if(serviceCloudSetting == null)
            serviceCloudSetting = [SELECT Id, MasterLabel, DeveloperName, TAM_Queue__c, Placeholder_Entitlement_Name__c
            						, Customer_Profile_Names__c, Agent_Profile_Names__c, Internal_User_Types__c
                                        	FROM Service_Cloud_Settings__mdt];
        return serviceCloudSetting;
    } 
    /*public static Set<string> CUSTOMER_PROFILES = NULL;
    public static Set<string> getCustomerProfiles() {
    	if(CUSTOMER_PROFILES == NULL) {
    		CUSTOMER_PROFILES = new Set<string>();
    		String profiles = getServiceCloudSetting().Customer_Profile_Names__c;
	    	if(!string.isEmpty(profiles))
	    		CUSTOMER_PROFILES.addAll(profiles.split(','));
    	}
    	return CUSTOMER_PROFILES;
    }
    public static Set<string> AGENT_PROFILES = NULL;
    public static Set<string> getAgentProfiles() {
    	if(AGENT_PROFILES == NULL) {
    		AGENT_PROFILES = new Set<string>();
    		String profiles = getServiceCloudSetting().Agent_Profile_Names__c;
	    	if(!string.isEmpty(profiles))
	    		AGENT_PROFILES.addAll(profiles.split(','));
    	}
    	return AGENT_PROFILES;
    }
    public static Set<string> INTERNAL_USERTYPES = NULL;
    public static Set<string> getInternalUserTypes() {
    	if(INTERNAL_USERTYPES == NULL) {
    		INTERNAL_USERTYPES = new Set<string>();
    		String userTypes = getServiceCloudSetting().Internal_User_Types__c;
	    	if(!string.isEmpty(userTypes))
	    		INTERNAL_USERTYPES.addAll(userTypes.split(','));
    	}
    	return INTERNAL_USERTYPES;
    } */
    /*End: Functions to get Service Cloud Settings */
    
    
    /*private static map<String, Id> slaProcessToSupportLevelMapping = new map<string, Id>();
    public static Service_Cloud_Settings__mdt getSLAProcessMap(){
    	if(slaProcessToSupportLevelMapping == null) {
    		list<SlaProcess> EntProcessList = [SELECT Id, Name FROM SlaProcess WHERE name =: slaSetting.Entitlement_Process_Name__c];
	        Id slaProcessId = (EntProcessList.isEmpty()) ? NULL : EntProcessList[0].Id;
    	}
    } */
    
    //This function used in AddUserHelper. It returns list of ProductLines based on AccountId
    public static set<String> FindProductLinesForCustomer(Id AccountId) {
        set<String> prodLineSet = new set<String>();
        
        //get Entiltemet ID from Account ID
        list<Entitlement> entList = [SELECT Id, Product_Family__c, Service_Product__r.Product_Line__c from Entitlement where AccountId =: AccountId and Status =: 'Active'];
        
        //get Prodctfamily from Entitlement
        System.debug('4456: '+ entList);
        for(Entitlement ent : entList){
            prodLineSet.add(ent.Service_Product__r.Product_Line__c);
        }
        
        System.debug('4456: '+ prodLineSet);
        return prodLineSet;
    }
    
    public static void LogErrors(String ErrorCode, String ErrorDesc) {
        Service_Cloud_Error_Log__c sl = new Service_Cloud_Error_Log__c();
        sl.Error_Code__c = ErrorCode;
        sl.Error_Description__c = ErrorDesc;
        
        insert sl;
    }
    
    private static set<string> L1L2OwnerRoles = null;
    public static set<String> getL1L2OwnerRoles() {
        if(L1L2OwnerRoles == null){
            L1L2OwnerRoles = new set<string>();
            L1L2OwnerRoles.addAll(Label.ServiceCloud_L1_L2_Owner_Roles.split(','));
        }
        return L1L2OwnerRoles;
    }
    
    /*Funtions to get Entitlement Process name for Support Level */
    public static map<String, SLA_Settings__mdt> slaSettingsMap = null;
    public static map<String, SLA_Settings__mdt> getSLASettings(){
        if(slaSettingsMap == null){
            slaSettingsMap = new map<String, SLA_Settings__mdt>();
            for(SLA_Settings__mdt slaSetting : [SELECT Id, MasterLabel, DeveloperName, Entitlement_Process_Name__c 
                                                FROM SLA_Settings__mdt]){
                slaSettingsMap.put(slaSetting.MasterLabel, slaSetting);
            }
        }
        return slaSettingsMap;
    }
    
    public static SLA_Settings__mdt getSLASetting(String Name){
        if(slaSettingsMap == null)
            getSLASettings();
        
        return slaSettingsMap.get(Name);
    }
    
    /*Function to get Time for each Milestone Based on Severity.*/
    public static map<String, Milestone_Time_Setting__mdt> milestoneSettingsMap = null;
    public static map<String, Milestone_Time_Setting__mdt> getMilestoneSettings(){
        if(milestoneSettingsMap == null){
            milestoneSettingsMap = new map<String, Milestone_Time_Setting__mdt>();
            for(Milestone_Time_Setting__mdt milestoneSetting : [SELECT Id, MasterLabel, DeveloperName, Milestone_Name__c, Severity__c, Time__c 
                                                        FROM Milestone_Time_Setting__mdt]){
                String key = milestoneSetting.Milestone_Name__c + '-' + milestoneSetting.Severity__c;
                //System.debug('Key' +key +'Milestone Name' +milestoneSetting.Milestone_Name__c);
                //System.debug('Sevrity' + milestoneSetting.Severity__c);
                milestoneSettingsMap.put(key, milestoneSetting);
            }
        }
        return milestoneSettingsMap;
    }
    public static Milestone_Time_Setting__mdt getMilestoneSetting(String MilestoneName, String Severity){
        String key = MilestoneName + '-' + Severity;
        System.debug('Milestone Name = ' +MilestoneName);
        System.debug('Sevrity = ' +Severity);
        //if(milestoneSettingsMap == null)
            getMilestoneSettings();
        System.debug('keySet = ' +milestoneSettingsMap.keySet());
        return milestoneSettingsMap.get(key);
    }
    
    /*Funtions to get Alert Message for each Milestone Violation */
    public static map<String, Milestone_Alert_Setting__mdt> milestoneAlertSettingsMap = null;
    public static map<String, Milestone_Alert_Setting__mdt> getMilestoneAlertSettings(){
        if(milestoneAlertSettingsMap == null){
            milestoneAlertSettingsMap = new map<String, Milestone_Alert_Setting__mdt>();
            for(Milestone_Alert_Setting__mdt milestoneAlertSetting : [SELECT Id, MasterLabel, DeveloperName, SLA_Text__c 
                                                        FROM Milestone_Alert_Setting__mdt]){
                milestoneAlertSettingsMap.put(milestoneAlertSetting.MasterLabel, milestoneAlertSetting);
            }
        }
        return milestoneAlertSettingsMap;
    }
    public static Milestone_Alert_Setting__mdt getMilestoneAlertSetting(String MilestoneStatus){
        if(milestoneAlertSettingsMap == null)
            getMilestoneAlertSettings();
        
        return milestoneAlertSettingsMap.get(MilestoneStatus);
    }
}