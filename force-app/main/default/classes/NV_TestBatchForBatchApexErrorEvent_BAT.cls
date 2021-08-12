public with sharing class NV_TestBatchForBatchApexErrorEvent_BAT implements Database.Batchable<sObject>, Database.RaisesPlatformEvents {
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM Account';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        Integer i = 1 / 0;
    }

    public void finish(Database.BatchableContext BC){}
}