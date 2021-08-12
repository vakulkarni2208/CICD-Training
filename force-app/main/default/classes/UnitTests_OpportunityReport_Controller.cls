/*
** Class:  UnitTests_OpportunityReport_Controller
** Created by OpFocus on 04/22/2011
** Description: Unit tests for the OpportunityReport_Controller

2016.08.24: Retrofitting of Opportunity creation with Primary Contact and Contact Role to avoid being caught up with validation rule 
 			that blocks opportunity record creation/update when the Probability is 40% (or any percent that could be changed later) without a primary contact and role
			-- Changed the probability to 10% to circumvent the validation rule

* @Manideep: 5/8/2019 - This code is commented as its not being used and in the process of Opportunity RecordType Cleanup.
*/	
@isTest
private class UnitTests_OpportunityReport_Controller { 

/*
    static testMethod void myUnitTest() {
        	
    	string strAccName = 'UnitTests_OpportunityReport_Controller';
        Account acct = new Account(Name=strAccName);
        acct.Automotive_Startup__c = 'No';
        insert acct;
        
        Map<String, Id> allRTMap = Utils.GetAllRecordTypeIdsByName(); 
    	
    	Opportunity oppQuadro = new Opportunity(AccountId = acct.id);
    	//oppQuadro.RecordTypeId = allRTMap.get('Quadro Sales Opportunity');
   		oppQuadro.Name = 'Unit Test Opp';
		oppQuadro.Type = 'Existing Business';
		oppQuadro.CloseDate = Date.today().addDays(14);
		oppQuadro.StageName = 'Prospecting';
		//oppQuadro.Probability = 50;
		oppQuadro.Probability = 10;
		oppQuadro.What_generated_this_Opportunity__c = 'Inbound Call';
		oppQuadro.Fermi_Adoption_Status__c = 'Not yet adopted Fermi';
		//oppQuadro.Industry__c = 'Testing';
		oppQuadro.Industry__c = 'Other';
		oppQuadro.GEO_Area__c = 'NALA';
		oppQuadro.Quadro_Opportunity_Solution__c = 'Medical';
		oppQuadro.Solution_VAR__c = '1';
		oppQuadro.Prefered_Partner__c = 'DELL';
		oppQuadro.Additional_Partners__c = '1';
		insert oppQuadro;
		
		PricebookEntry pbe = 
		  [select id, Name, UnitPrice
		   from   PricebookEntry
		   where  Product2.Family like 'Quadro%'
		   and    IsActive = true
		   limit 1];
		
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId = oppQuadro.id;
		oli.PricebookEntryId = pbe.id;
		oli.ASP__c = pbe.UnitPrice;
		oli.Quantity = 1;
		oli.TotalPrice = pbe.UnitPrice;
		insert oli;
		
		Schedule_Entry__c se = new Schedule_Entry__c();
		se.Opportunity__c = oppQuadro.id;
		se.Display_Quarter__c = 'Q4-2011';
		se.OLI_Id__c = oli.id;
		se.Opportunity_Type__c = 'Quadro Sales Opportunity';
		se.Quantity__c = 1;
		insert se;
		
		
		List<Opportunity> lstOpps = [select id from Opportunity where id = :oppQuadro.id];
    	
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(lstOpps);
        OpportunityReport_Controller ctl = new OpportunityReport_Controller(stdController);
        
       	ctl.selectListView();

		// The controller includes code that says, "If we're running in a unit test, then
		// fetch up to 10 Quadro opps.
		ctl.format = 'browser';
		ctl.repeatData = false;
		ctl.runReport();

		System.assert(!ctl.pageError, 'pageError');
		System.assert(!ctl.renderAsCsv, 'renderAsCsv');
		
		ctl.format = 'csv';
		ctl.repeatData = true;
		ctl.runReport();

		System.assert(!ctl.pageError, 'pageError');
		System.assert(ctl.renderAsCsv, 'renderAsCsv');
    }
*/    
}