/* This class have all common utility methods for Service Cloud functionalities 
* Akhilesh: 05/05/2019: Add common function to update Recent Activity on the Case:  "UpdateRecentActivityOnCase".
* Akhilesh: 06/30/2019: Added FindProductLinesForCustomer, checkPortalAccess functions for AddUser functionality.
* Akhilesh: 25/07/2019: Added getRWAProdFamily, getRWAFeaturesMap to generate ProductFamily dynamicaly for RWA page.
* Akhilesh: 30/07/2019: Updated getRWAProdFamily function to return 3 Character (SLN) string.
* Akhilesh: 02/20/2020: Updated UpdateRecentActivityOnCase function to use Constants generated from "Service Cloud Settings" metadata.
* Akhilesh: 02/26/2020: Moved functions getSLASettings,getMilestoneSettings to ESP_Utility class.
*/
    
public class ServiceCloudUtils {
	
	/* Deprecated: Please use ESP_Utitlity.LogErrors instead */
    public static void LogErrors(String ErrorCode, String ErrorDesc) {
        Service_Cloud_Error_Log__c sl = new Service_Cloud_Error_Log__c();
        sl.Error_Code__c = ErrorCode;
        sl.Error_Description__c = ErrorDesc;
        
        insert sl;
    }
    //public static map<Id, set<String>> caseIdToEmailMap = new map<Id, set<String>>();
    /*Funtions to get Entitlement Process name for Support Level */
    //public static map<String, ProdCategoryToRWAFeatureMap__mdt> RWAFeaturesMapping = null;
    public static void getRWAFeaturesMap(){
        RWAFeaturesSettingList = [SELECT Id, MasterLabel, DeveloperName, Product_Line__c
                                    , Support_Portal_Access__c, Show_NGC_Container_Registry__c, Licensing_Portal_Access__c
                                    FROM ProdCategoryToRWAFeatureMap__mdt];
        //if(RWAFeaturesMapping == null){
            //RWAFeaturesMapping = new map<String, ProdCategoryToRWAFeatureMap__mdt>();
            //for(ProdCategoryToRWAFeatureMap__mdt setting : [SELECT Id, MasterLabel, DeveloperName, Product_Category__c, Product_Family__c
            //                                  , Support_Portal_Access__c, Show_NGC_Container_Registry__c, Licensing_Portal_Access__c
            //                                  FROM ProdCategoryToRWAFeatureMap__mdt]){
            //    RWAFeaturesMapping.put(setting.MasterLabel, setting);
            //}
        //}
        //return RWAFeaturesMapping;
    }
    
    //This function is used in AddUserHelper, returns 3 character string based on ProductLines
    //Configuration is stored in custom metadata ProdCategoryToRWAFeatureMap__mdt
    public static list<ProdCategoryToRWAFeatureMap__mdt> RWAFeaturesSettingList = null;
    public static String getRWAProdFamily(set<String> ProductLineList){
        String RWAProdFamily = '';
        if(RWAFeaturesSettingList == null)
            getRWAFeaturesMap();
        
        system.debug('20190723: ProductLineList '+ ProductLineList);
        system.debug('20190723: RWAFeaturesSettingList '+ RWAFeaturesSettingList);
        //set<String> featureSet = new set<String>();
        boolean supportPortalAccess   = false;
        boolean showContainerRegistry = false;
        boolean licensingPortalAccess = false;
        
        if(!RWAFeaturesSettingList.isEmpty()) {
            for(ProdCategoryToRWAFeatureMap__mdt setting : RWAFeaturesSettingList) {
                if(ProductLineList.contains(setting.Product_Line__c)) {
                    if(setting.Support_Portal_Access__c) 
                        supportPortalAccess   = true;//featureSet.add('S');
                    //if(setting.Licensing_Portal_Access__c) 
                        //licensingPortalAccess = true;//featureSet.add('L');
                    if(setting.Show_NGC_Container_Registry__c) 
                        showContainerRegistry = true;//featureSet.add('N');
                }
            }
        }
        
        RWAProdFamily  = (supportPortalAccess)   ? 'S' : 'X';
        RWAProdFamily += (licensingPortalAccess) ? 'L' : 'X';
        RWAProdFamily += (showContainerRegistry) ? 'N' : 'X';
        
        //system.debug('20190723: featureSet '+ featureSet);
        //if(!featureSet.isEmpty()) {
        //    for(String s : featureSet)
         //       RWAProdFamily += s;
        //}
        
        return RWAProdFamily;
    }
    
    //This function is used in AddUserHelper to decide portal options based on Product Line.
    public static set<String> checkPortalAccess(set<String> productLines) {
        set<String> portalList = new set<string>();
        if(!productLines.isEmpty()) {
            portalList.add(ESP_Constants.SUPPORT_PORTAL);
            if(productlines.contains('Grid'))
                portalList.add(ESP_Constants.LICENSING_PORTAL);
        }
        return portalList;
    }
    
    //This function used in AddUserHelper. It returns list of ProductLines based on AccountId
    public static set<String> FindProductLinesForCustomer(Id AccountId) {
        set<String> prodLineSet = new set<String>();
        
        //get Entiltemet ID from Account ID
        list<Entitlement> entList = [SELECT Id, Product_Family__c, Service_Product__r.Product_Line__c 
                                     from Entitlement 
                                     where AccountId =: AccountId and Status =: 'Active' and PAK_ID__c != ''];
        
        //get Prodctfamily from Entilemet
        System.debug('4456: '+ entList);
        for(Entitlement ent : entList){
            prodLineSet.add(ent.Service_Product__r.Product_Line__c);
        }
        System.debug('4456: '+ prodLineSet);
        return prodLineSet;
    }
    
    public static map<Id, String> caseIdToEmailMap = new map<Id, String>();
    public static void UpdateRecentActivityOnCase(map<Id, String> caseIdMap, Id userId, String sourceObject) {
        caseIdToEmailMap = caseIdMap;
        UpdateRecentActivityOnCase(caseIdMap.keySet(), userId, sourceObject);
    }
    public static void UpdateRecentActivityOnCase(set<Id> caseIds, Id userId, String sourceObject) {
        list<Case> lstCase = new list<Case>();
        
        system.debug('User ID 2222 = ' + userId);
        //if(userId == )
        List<User> userList =[SELECT Email, UserType, Profile.Name FROM User where Id=:userId ];
        String userType = ''; //find user typ
        String lastActivityUserEmail = ''; //find this
        if(!userList.isEmpty()){
            User userDetails = userList[0];
            system.debug('UserDetails 1122:'+ userDetails);
            
            //ESP_Constants espConstants = ESP_Constants.getInstance();
            if(ESP_Utility.ESPConstants.CUSTOMER_PROFILES.CONTAINS(userDetails.Profile.Name))
                userType = 'Customer';
            else if(ESP_Utility.ESPConstants.AGENT_PROFILES.CONTAINS(userDetails.Profile.Name))
                userType = 'Agent';
            else if(ESP_Utility.ESPConstants.INTERNAL_USERTYPES.CONTAINS(userDetails.UserType))
                userType = 'Internal';
            if(userDetails != null)
                lastActivityUserEmail = userDetails.Email;
        }
        for(Id caseId : caseIds){
            if(!caseIdToEmailMap.isEmpty())
                lastActivityUserEmail = caseIdToEmailMap.get(caseId);
            Case caseObj = new Case(Id = caseId, 
                                Last_Activity_By_User__c = userId,
                                Last_Activity_Type__c = ESP_Constants.OBJECT_TO_ACTIVITY_TYPE_MAP.get(sourceObject),
                                Last_Activity_Date__c = system.now(),
                                Last_Activity_User_Type__c = userType,
                                Last_Activity_User_Email__c = lastActivityUserEmail
                                );
            lstCase.add(caseObj);
        }
        update lstCase;
    }
    
    //public static User SYSTEM_USER;
    public static map<String, String> UserSettingMap = null;
    public static Id getSystemUserId() {
        if(UserSettingMap == null){ 
        // UserSettingMap = [SELECT Id FROM User where LastName =: 'System'];
           UserSettingMap = new map<String, String>();      
           for(User_Setting__mdt UserSetting : [SELECT Id, MasterLabel, DeveloperName, User_Id__c 
                                                FROM User_Setting__mdt]){
                UserSettingMap.put(UserSetting.MasterLabel, UserSetting.User_Id__c);
           }
        }
        return UserSettingMap.get('System');
        //  return SYSTEM_USER.Id;
        //return '0051W000004PuhWQAS'; //NULL
    } 
    //public static final string CONST_24X7SUPPORT = '24x7 Escalated Remote';
    
    /*Deprecated: Funtions to get Entitlement Process name for Support Level */
    /*public static map<String, SLA_Settings__mdt> slaSettingsMap = null;
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
    }*/
    
    /*Deprecated: Funtions to get Time for each Milestone Based on Severity.*/
    /*public static map<String, Milestone_Time_Setting__mdt> milestoneSettingsMap = null;
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
    } */ 
       /*public static map<String, Milestone_Setting__mdt> milestoneSettingsMap = null;
       public static map<String, Milestone_Setting__mdt> getMilestoneSettings(String key){
        //if(milestoneSettingsMap == null){
            System.debug('123456 inside getMilestoneSetting' +key);
            milestoneSettingsMap = new map<String, Milestone_Setting__mdt>();
            for(Milestone_Setting__mdt milestoneSetting : [SELECT Id, MasterLabel, DeveloperName, Milestone_Name__c, Severity__c, Time__c, Identifier__c 
                                                        FROM Milestone_Setting__mdt where Identifier__c =: key]){
                String key1 = milestoneSetting.Milestone_Name__c + '-' + milestoneSetting.Severity__c;
                System.debug('Key = ' +key1 +'Milestone Name = ' +milestoneSetting.Milestone_Name__c);
                System.debug('Sevrity' + milestoneSetting.Severity__c);
                milestoneSettingsMap.put(key1, milestoneSetting);
            }
        
        return milestoneSettingsMap;
    }
    public static Milestone_Setting__mdt getMilestoneSetting(String MilestoneName, String Severity){
        String key = MilestoneName + '-' + Severity;
        System.debug('Helo' +key);
        System.debug('MilestoneSettingMap = ' +milestoneSettingsMap);
        //if(milestoneSettingsMap == null)
            getMilestoneSettings(key);
        
        return milestoneSettingsMap.get(key);
    }    */
    
    /*Deprecated: Funtions to get Alert Message for each Milestone Violation */
    /*public static map<String, Milestone_Alert_Setting__mdt> milestoneAlertSettingsMap = null;
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
    } */
}