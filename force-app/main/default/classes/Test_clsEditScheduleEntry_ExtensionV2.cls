/*
	2017.10.19 - 2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
		-Rewrote the test class
 	@Manideep: 1/18/2018 - This code is updated by commenting out unwanted logic as part of Opportunity RecordType Cleanup.
	
	2021.01.25-PJENA-SOQ-74-Remove unsused field references.
		Moving it to very light wight by making SeeAllData = true as the custom opportunity mgmt will go away soon with Design Win standard implementation
*/
@isTest(SeeAllData=true)
private class Test_clsEditScheduleEntry_ExtensionV2 {

    static testMethod void testForTegraEbedded(){
		//get the opportunt, oli, SE for a Tegra Embedded Partner Opportunity (COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY)
		list<Opportunity> lstOpp = [	Select Id, Name,RecordTypeId, AccountId, RecordType.Name,
											(Select Id, Opportunity__c From Schedule_Entries__r)
										From   Opportunity
										Where  RecordType.Name = :COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY
											And No_of_Schedule_Entries__c > 0
											And Amount > 0
										Limit 1];
		list<Schedule_Entry__c> lstSE = lstOpp[0].Schedule_Entries__r;
		Test.startTest();
			ApexPages.StandardController stdController = new ApexPages.StandardController(lstSE[0]);
        	clsEditScheduleEntry_ExtensionV2 obj = new clsEditScheduleEntry_ExtensionV2(stdController);
        	obj.redirect();
		Test.stopTest();
    }
    
}