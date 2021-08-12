/*
	Controller class for CRM_DR_SubmitDealForApproval vf page used as button click
	Change list:
	2016.12.14 - Opp Registration TAM - interim change
	
	2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
	
	2017.06.05 - Bug Fix - Opp Reg : Alt Partner Owner - use DR_Partner_Owner__c.CreatedBy when CreatedBy.Contact (User) is inactive
	
	2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
				updated the class with "without sharing", calling from the test class does not override the sharing; as the partner has Read access it cannot update the record after the ownership changes
	
	2017.11.29 - PJENA - Deal Registration - Code Cleanup - ready to be deleted
	
*/
public without sharing class CRM_DR_SubmitDealForApproval_cls {
	//constructor
	public CRM_DR_SubmitDealForApproval_cls(){}
}