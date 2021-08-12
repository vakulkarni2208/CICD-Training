trigger Platform_Event_Tracker_tgr on Platform_Event_Tracker__e (after insert) {
    list<Platform_Event_Tracker_Processor__c> lstEventProcHelper = new list<Platform_Event_Tracker_Processor__c>();
    for (Platform_Event_Tracker__e event : trigger.new){
        lstEventProcHelper.add(new Platform_Event_Tracker_Processor__c(RecordId__c = event.RecordId__c, ObjectName__c = event.ObjectName__c, EventName__c = event.EventName__c));
        //EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
    }
    database.insert(lstEventProcHelper, false);
}