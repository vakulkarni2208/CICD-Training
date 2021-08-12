/**************************************************************************************************
* Name       : TriggerEntitlementHelper
* Purpose    : Helper class for TriggerEntitlement Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
* Perficient        | 1.0        | 12/13/2017      | Initial Draft
* Akhilesh Gupta	| 2.0		| 12/11/2019		| Updated code to use TriggerHandler framework. 
**************************************************************************************************/
trigger TriggerEntitlement on Entitlement (after update,after Insert, before Insert, before Update) {
    if(!TriggerEntitlementHelper.DISABLE_TRIGGER) {
    	TriggerEntitlementHelper helper = new TriggerEntitlementHelper();
    	helper.execute();
    }
    /*if(Trigger.isAfter){
        if(Trigger.isUpdate){
            TriggerEntitlementHelper.RemoveUpdatePermissionSet(trigger.oldMap,trigger.New);
        }
        if(Trigger.isUpdate || Trigger.isInsert){
            TriggerEntitlementHelper.AddAnnouncement(trigger.oldMap,trigger.New);
        }
    }
    if(Trigger.isBefore){
       // if(trigger.isInsert){
            TriggerEntitlementHelper.UpdateEntilementProcess(trigger.New);
        //}
    }
    */
}