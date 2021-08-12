/*
	Batchable and Schedulable Apex
	
	The job needs to process all Partner Attribute records in the beginning of a Fiscal Year to create NPN Revenue Records for that FY if it is not already present
	
	In order to make fail proof, instead of processing on the first day of FY, it can refer to a look table (NPNRevTrgtAuto_Job_Tracker__c), if there in no successful run found, it will try to process it again.
	
	[
	CRM_NPNRevTrgtAuto_Batch p = new CRM_NPNRevTrgtAuto_Batch();
	DateTime currDT = DateTime.now().addMinutes(1);
	String sch = '0 0 6 ? 1 2#5 *'; //to run on every 5th Monday of the month of January. Its the closest but if the FY start date is in Feb, then the sch string needs to be changed. Its good for FY 2021,
	system.debug('sch: ' + sch);
	system.schedule('Exec of CRM_NPNRevTrgtAuto_Batch', sch, p);
	]
	
	Note: If you need to rerun the job for a FY, delete the record specific to that year in "NPNRevTrgtAuto Job Tracker" object/Tab
	
	2021.01.31 	Rajat	SDS-2724 Added Sub Program in the logic.

*/
public class CRM_NPNRevTrgtAuto_Batch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable{
	
	public string errorDetails; //captures the error details
	public boolean isError; //capture if there is any error ever
	public string strCurrentFY;
	
	//constructor
	public CRM_NPNRevTrgtAuto_Batch(){
		system.debug('---------Entering Batch Apex Constructor-------------------');
		//calculate the current fiscal year
		strCurrentFY = CRM_NPN_Revenue_Target_Common.getFiscalYear(system.today());
		system.debug('***strCurrentFY = ' + strCurrentFY);
		system.debug('---------Exiting Batch Apex Constructor-------------------');
	}

	public Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('---------Entering Batch Job start method-------------------');
		//get all the Parter Attribute records not having a NPN Revenue Target record for current FY
		return Database.getQueryLocator([	Select Id, Partner_Program_Name__c, Partner_Sub_Program__c, Partner_Competency__c, Program_Level__c, Account_Name__r.BillingCountry 
											From Partner_Attribute__c 
											Where Id Not in (Select Partner_Attribute__c From NPN_Revenue_Targets__c Where  Year__c = :strCurrentFY)
										]);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('---------Entering Batch Job execute method-------------------');
		//Collect all the Partner Attribute Ids and Extended Partner Attributes
		if (scope != null && !scope.isEmpty()){
			try{
				list<Partner_Attribute__c> lstPA = (List<Partner_Attribute__c>) scope;
				
				system.debug('***Parter Attributes in this batch: ' + lstPA);
				
				//prepare the PartnerAttributeExt list
				list<CRM_NPN_Revenue_Target_Common.PartnerAttributeExt> lstPartnerAttributeExt = new list<CRM_NPN_Revenue_Target_Common.PartnerAttributeExt>();
				for (Partner_Attribute__c pa : lstPA){
					lstPartnerAttributeExt.add(new CRM_NPN_Revenue_Target_Common.PartnerAttributeExt(pa.Id, pa.Partner_Program_Name__c, pa.Partner_Sub_Program__c, pa.Partner_Competency__c, pa.Program_Level__c, pa.Account_Name__r.BillingCountry));
				}
				
				//Calll the createRevenueTargets with the list of Partner Attributes having no Revenue Targets
				system.debug('***Calls CRM_NPN_Revenue_Target_Common.createRevenueTargets() with lstPartnerAttributeExt = ' + lstPartnerAttributeExt + ' Fiscal Year = ' + strCurrentFY);
				CRM_NPN_Revenue_Target_Common.createRevenueTargets(lstPartnerAttributeExt, strCurrentFY);
			} catch(Exception ex){
				system.debug('***exception: ' + ex);
				isError = true;
				errorDetails += '***Error Message: ' + ex.getMessage() + '***StackTrace' + ex.getStackTraceString();
			}
			
		}
		system.debug('---------Exiting Batch Job execute method-------------------');
	}

	public void finish(Database.BatchableContext BC){
		system.debug('---------Entering Batch Job finish method-------------------');
		
		//Send email or confirmation and update the tracker
		NPNRevTrgtAuto_Job_Tracker__c processDetails = new NPNRevTrgtAuto_Job_Tracker__c();
		processDetails.FY__c = strCurrentFY;
		if (isError == null || isError == false) {
			processDetails.Error__c = false;
		} else{
			processDetails.Error__c = true;
		}
		processDetails.DetailedInfo__c = '*** EXECUTED ON: ' + System.Now() + ', BY ' + userinfo.getUserName() + '| Error Details: ' + errorDetails ;
		system.debug('***In CRM_NPNRevTrgtAuto_Batch.finish method with info: ' + processDetails);
		database.insert(processDetails);
		
		system.debug('---------Exiting Batch Job finish method-------------------');
	}

	//Schedulable interface method implementation. 
	//When you schedule the class CRM_NPNRevTrgtAuto_Batch to run at a specific internal, it will run the this execute method which in turn will call the batch apex methods
	public void execute(SchedulableContext SC){
		system.debug('---------Scheduler module for Batch Job Starts for FY ' + strCurrentFY + '-------------------');

		//Check if there is a successful processig in NPNRevTrgtAuto Job Tracker object
		list<NPNRevTrgtAuto_Job_Tracker__c> lstJobTracker = [	Select Error__c 
																From NPNRevTrgtAuto_Job_Tracker__c 
																Where FY__c = :strCurrentFY 
																	And Error__c = false];
		if (lstJobTracker == null || lstJobTracker.isEmpty()){
			system.debug('---------Scheduled Batch Job Starts-------------------');
			//make sure that it calls the Batch Apex Job only when today's data is the first day of the Fiscal Year
			CRM_NPNRevTrgtAuto_Batch NPNRevTargetBatch = new CRM_NPNRevTrgtAuto_Batch();
			database.executeBatch(NPNRevTargetBatch);
			system.debug('---------Scheduled Batch Job Ends-------------------');
		} else{
			system.debug('---------NPNRevTrgtAuto Job Tracker object had a successful run for the FY : ' + strCurrentFY + ' , so the batch job did not run again -------------------');
		}
		system.debug('---------Scheduler module for Batch Job Ends for FY ' + strCurrentFY + '-------------------');
		
	}

}