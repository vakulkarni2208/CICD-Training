/*
	Change list:
	2016.05.28 - Remove the isContactMarkedAsDealRegUser() function - as it is Open for all Enterprise type Partners
				- Updated getSalesOpsApprover method to have semicolon separated Countries instead of commas as some country names have comma (') in them
	2016.12.14 - Opp Registration TAM - interim change
	
	2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
	
	2017.05.09 - Opp Reg : Alt Partner Owner
	
	2017.06.05 - Bug Fix - Opp Reg : Alt Partner Owner - use DR_Partner_Owner__c.CreatedBy when CreatedBy.Contact (User) is inactive
	
	2017.08.23 - Restrict Partners Closing Out Opportunity Regs 
		Remove Claim Submission related functions
		
	2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
		-Remove Termination capability from partners
	
	2017.12.19 - DGX Station Jumpstart validation - if Tesla Partner Deal with Program Type = DGX Station Jump Start, DGX Station Product Amount should be NON-ZERO
	
	2017.11.29 - PJENA - Deal Registration - Code Cleanup - Ready to be deleted
	
*/
global class CRM_DR_Utility {
	//consutructor
	public CRM_DR_Utility(){}
}