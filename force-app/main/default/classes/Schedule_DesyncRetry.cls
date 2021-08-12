/*
 *  This is a schedulable job that attempts to 
 *	- deactivate (and sync) the IDM DGX/GRID Users via an external callout
 *	- sync the RMA record (Custom record - RMA__c) via an external callout
 *  Batch execution is in a lot size of 10
 *  Akhilesh Gupta     | 04/07/2019      | Remove Code related to RMA Retry Job
 */  
global class Schedule_DesyncRetry implements Schedulable {
	global void execute(SchedulableContext SC) {
		IDM_User_Deactivation_Sync IDMUserSync = new IDM_User_Deactivation_Sync();
		Database.executeBatch(IDMUserSync,10);
		//RMA_Retry M = new RMA_Retry(); 
		//Database.executeBatch(M,10);
	}
}