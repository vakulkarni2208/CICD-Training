/*
	2017.05.09 - Opp Reg : Alt Partner Owner
	Invocable method to add Alt Partner Owner to the Public Group "DR_Partner_Owner__c"
				Doing it through the Flow entangles it into MIXED DML issue
	
	2017.11.29 - PJENA - Deal Registration - Code Cleanup - ready to be deleted

*/

public class CRM_DR_AddAltPartnerOwnerToPG {
	
	@InvocableMethod(label='addAltPartnerOwnerToPG' description='Adds Alt PartnerOwner (DR_Partner_Owner__c) To PG (OPPORTUNITY REG : ALT SUBMITTER)')
    public static void addAltPartnerOwnerToPG(list<Id> lstOppIds){
    	
    }
}