/*
	Test class for methods in CRM_DR_Utility class. 
	Some of the methods in CRM_DR_Utility class is called from Controller methods, so the controller test methods will have the code coverate for those methods. 
	
	2016.12.14 - Opp Registration TAM - interim change
	
	2017.06.05 - Bug Fix - Opp Reg : Alt Partner Owner - use DR_Partner_Owner__c.CreatedBy when CreatedBy.Contact (User) is inactive
	
	2017.08.23 - Restrict Partners Closing Out Opportunity Regs - Code clean up and added some extra
	2017.08.23 - new test classes for covering IsDealSubmitted_WS,IsDealApproved_WS,IsDealTerminated_WS, IsRequiredFieldsFilled_WS methods 
	
	2017.11.29 - PJENA - Deal Registration - Code Cleanup - Ready to be deleted
	
*/

@isTest(SeeAllData=false)
private class Test_CRM_DR_Utility {
	static testMethod void testmethod1(){
		CRM_DR_Utility oCRM_DR_Utility = new CRM_DR_Utility();
	} 
}