/**
 *  @name           : NPN_QPB_Stmt_Notification_Batch
 *  @author         : rkamble
 *  @description    : 
    2021.04.26  Created for SDS-2978. This is a schedular class for NPN_QPB_Stmt_Notification_Batch, which runs hourly to notify the partner about the new/ updated QPB Statements.
 *  CRON EXPRESSION : {0 0 * * * ?}

    //script
        NPN_QPB_Stmt_Notification_Batch sch = new NPN_QPB_Stmt_Notification_Batch();
        string cronexp='0 0 * * * ?';
        System.schedule('NPN_QPB_Stmt_Notification_Batch',cronexp,sch);
 */


global class NPN_QPB_Stmt_Notification_Batch implements Database.Batchable<sObject>, System.Schedulable {

    String queryString ='';
    String cronExpression='0 0 * * * ?';
    String batchName ='NPN_QPB_Stmt_Notification_Batch';
    Integer batchSize = 5;
    
    // Constructor
    public NPN_QPB_Stmt_Notification_Batch(){
        
        queryString = 'SELECT Id,Account_Name__c,Account__c,Attachment_Uploaded__c,Comments__c,Fiscal_Year__c,FY_QTR__c,LastModifiedDate,Name,Notified__c,Quarter__c,Region__c,Status__c,Type__c FROM QPB_Statement__c  WHERE Attachment_Uploaded__c = TRUE AND Notified__c = FALSE AND Status__c = \'Active\'';
    }

     global void execute(SchedulableContext sc) {

        NPN_QPB_Stmt_Notification_Batch batchName = new NPN_QPB_Stmt_Notification_Batch();
        Database.executeBatch(batchName,batchSize);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<QPB_Statement__c> scope){
        
        Set<Id> qpbStmtIdSet = new Set<Id>();
        List<QPB_Statement__c> qpbStmtListForUpdate = new List<QPB_Statement__c>();
        
        for(QPB_Statement__c qpbObj : scope) {
            
            qpbStmtIdSet.add(qpbObj.Id);
            qpbObj.Notified__c = TRUE;
            qpbStmtListForUpdate.add(qpbObj);
        }
        
        if(!qpbStmtIdSet.isEmpty()){
            NPN_QPB_Statement_Util_cls.notifyPartnersForStmt(qpbStmtIdSet);
            
            update qpbStmtListForUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc){

        List<AsyncApexJob> existingJob = [SELECT Id,JobType,Status FROM AsyncApexJob WHERE ApexClass.Name ='NPN_QPB_Stmt_Notification_Batch' AND JobType ='ScheduledApex' AND Status ='Queued'];

        if(existingJob.isEmpty()) {
            NPN_QPB_Stmt_Notification_Batch sch = new NPN_QPB_Stmt_Notification_Batch();
            String cronexp = String.isNotBlank(cronExpression) ? cronExpression : '0 0 * * * ?';
            System.schedule('NPN_QPB_Stmt_Notification_Batch',cronexp,sch);
        }
    }
}