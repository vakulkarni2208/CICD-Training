trigger TempContactTrigger on Temporary_Contact__c (after update) {   
    
    if(Trigger.isAfter && Trigger.isUpdate){
        NPN_TempContactHandler.afterUpdate(trigger.NewMap, trigger.OldMap);
    }
}