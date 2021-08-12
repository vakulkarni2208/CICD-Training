trigger AnnouncementTrigger on Announcement__c (after insert, after update) {
    if(trigger.isInsert && trigger.isAfter){
        AnnouncementTriggerHelper.afterInsert(trigger.new);
    }
    if(trigger.isUpdate && trigger.isAfter){
        AnnouncementTriggerHelper.afterUpdate(trigger.new, trigger.oldMap);
    }
}