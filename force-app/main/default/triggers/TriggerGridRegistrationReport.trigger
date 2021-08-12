trigger TriggerGridRegistrationReport on Grid_Registration_Report__c (before insert) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            TriggerGridRegistrationReportHelper.GridInsertUpdates(Trigger.New, Trigger.newMap);
        }  
    }
}