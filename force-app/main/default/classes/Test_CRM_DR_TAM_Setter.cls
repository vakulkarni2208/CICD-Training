/*
	2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
		Test class for the helper class CRM_DR_TAM_Setter. It is used in CRM_DR_SubmitDealForApproval_cls to assign Opportunity Owner based on Account Hierarchy or TAM Matrix or PBM
		
	2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
		Make it Duplicate rule safe
	
	2017.11.29 - PJENA - Deal Registration - Code Cleanup - ready to be deleted
	
 */
@isTest(SeeAllData=false)
private class Test_CRM_DR_TAM_Setter {
    static testMethod void testTAMByTAMMatrix() {
		CRM_DR_TAM_Setter oCRM_DR_TAM_Setter = new CRM_DR_TAM_Setter();
    }
}