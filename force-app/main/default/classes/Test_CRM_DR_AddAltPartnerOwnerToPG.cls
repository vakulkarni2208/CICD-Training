/*
	2017.05.09 - Opp Reg : Alt Partner Owner
		Test class for Invocable method to add Alt Partner Owner to the Public Group "DR_Partner_Owner__c" .Doing it through the Flow entangles it into MIXED DML issue
	2017.11.29 - PJENA - Deal Registration - Code Cleanup - ready to be deleted
 */
@isTest(SeeAllData=false)
private class Test_CRM_DR_AddAltPartnerOwnerToPG {

    static testMethod void addAltPartnerOwnerToPG() {
    	list<Id> lstOppIds = new list<Id>();
    	CRM_DR_AddAltPartnerOwnerToPG.addAltPartnerOwnerToPG(lstOppIds);
    	
    }
}