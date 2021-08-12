/*
	Controller class for CRM_DR_SubmitDealFoExtension page
	
	Change List:
	2016.12.14 - Opp Registration TAM - interim change
	
	2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
	
	2017.06.05 - Bug Fix - Opp Reg : Alt Partner Owner - use DR_Partner_Owner__c.CreatedBy when CreatedBy.Contact (User) is inactive
	
	2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
				updated the class with "without sharing", calling from the test class does not override the sharing; as the partner has Read access it cannot update the record after the ownership changes
	
	2017.10.19 - 2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
		- Remove extension logic so it can be cleaned up later
	
	2017.11.29 - PJENA - Deal Registration - Code Cleanup - ready to be deleted

*/
public without sharing class CRM_DR_SubmitDealFoExtension_cls {
	//constructor
	public CRM_DR_SubmitDealFoExtension_cls(){}
}