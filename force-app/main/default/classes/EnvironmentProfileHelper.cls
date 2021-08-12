/*
Class name : EnvironmentProfileHelper 
Description : This class provides Helper Methods for Environment Profile Object. Some methods are called 
from Lightning component Link Entitlements to Environment Profile.
Vesrion    Modified Date    Modified By          Description
-----------------------------------------------------------------------------------------------------------------------------------
1.0        30-Jan-20        Nilesh Adkar        Created. SDS-1982 Service Cloud: Link Customer Entitlements to Environment Profile

*/
public class EnvironmentProfileHelper {

// Displays the list of entitlements on select entitlement lightning action (Link Entitlements)
    @AuraEnabled
    public static List < Entitlement > getEntitlementList(Id envProfileId) {
        Id accId = [select Account__c from Environment_Profile__c where id =: envProfileId].Account__c;
        List < Entitlement > lstEntitlements = [select id, name, Entitlement_status__c, environment_profile__c, Environment_Profile_Name__c from Entitlement where AccountId =: accId];
        return lstEntitlements;
    }
    
// Gets selected Entitlements and associates Env profile to each.
    @AuraEnabled
    public static void linkEnvironmentProfileToEntitlements(Id envProfileId, List < Entitlement > lstEntitlements) {
        System.debug('**' + envProfileId);
        System.debug('**--Entitlement--' + lstEntitlements);
        for (Entitlement tmpEntitlements: lstEntitlements) {
            tmpEntitlements.environment_profile__c = envProfileId;
        }

        update lstEntitlements;
    }
}