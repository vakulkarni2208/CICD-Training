/*
 *  This is a schedulable job that attempts to sync the IDM DGX Users via an external callout
 *  Batch execution is in a lot size of 10
 */  
global class Schedule_Retry implements Schedulable {
   global void execute(SchedulableContext SC) {
      
      IDM_DGX_RETRY dgxRetry = new IDM_DGX_RETRY();
       Database.executeBatch(dgxRetry,10);
   }
}