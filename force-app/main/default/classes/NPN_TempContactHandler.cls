/**
 *  @name NPN_TempContactHandler
 *  @description   Handler class for TempContactTrigger
                    Created for SDS-741
 */
public without sharing class NPN_TempContactHandler {

    public static boolean flag = true;

    /**
     * @name    afterUpdate
     * @param   triggerNewMap
     * @param   triggerOldMap
     */
    public static void afterUpdate(Map<Id, Temporary_Contact__c> triggerNewMap, Map<Id, Temporary_Contact__c> triggerOldMap) {
        if(flag) {
            flag = false;
            NPN_TempContactHelper.processTempContacts(triggerNewMap);
        }
    }
}