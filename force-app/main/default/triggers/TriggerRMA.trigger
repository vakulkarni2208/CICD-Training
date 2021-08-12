/**************************************************************************************************
* Name       : TriggerRMA
* Purpose    : Trigger for RMA__c object
***************************************************************************************************
* Author            | Version   | Created Date    	| Description
***************************************************************************************************
*Perficient         | 1.0       | 12/05/2017       	| Initial Draft
*Akhilesh Gupta		| 2.0		| 12/11/2019		| Updated code to use TriggerHandler framework.
**************************************************************************************************/
trigger TriggerRMA on RMA__c (before insert, after insert , before update, after update) {
	TriggerRMAHelper helper = new TriggerRMAHelper(); 
    helper.execute();
    /*
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            TriggerRMAHelper.AfterUpdate(trigger.old, trigger.oldMap, trigger.new, trigger.newMap );
        }
        if(Trigger.isInsert){
            TriggerRMAHelper.AfterInsert(trigger.new);
        }
    }*/
}