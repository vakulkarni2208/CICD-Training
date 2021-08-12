/*
** Class:  UnitTests_TegraAuto_OppAndProducts
** Created by OpFocus on 3/24/2011
** Description: Unit tests for the TegraAuto_OppAndProducts_Controller class
* @Manideep - 5/8/2019 - This Test Class used by the Record Types 'Tegra Auto and Emb Opportunity', 'Tegra Auto OEM Opportunity', 'Tegra Auto Tier 1 Opportunity' and 'Tegra Embedded Opportunity'. All these
                          RecordTypes are Retired. So commented out this class as part of Opportunity RecordType Cleanup.
*/  
@isTest
private class UnitTests_TegraAuto_OppAndProducts {

/*
 * @Manideep - Opportunity RecordType Cleanup 
 
    static testMethod void test_BadParams() {

        PageReference pgRef = new PageReference('/apex/TegraAuto_OppAndProducts');
        pgRef.getParameters().put('id', '006bad id');
        Test.setCurrentPage(pgRef);

        TegraAuto_OppAndProducts_Controller ctl = new TegraAuto_OppAndProducts_Controller();
        ctl.InitPage();
        
        System.assert(ctl.pageError, 'Invoked page with no arguments');
        
        ctl.cancel();
    }

    static testMethod void test_WithAccountID() {
        
        string strAccName = 'UnitTests_TegraAuto_OppAndProducts_test_WithAccountID';
        Account acct = new Account(Name = strAccName, Automotive_Startup__c = 'No');
        insert acct;
    
        PageReference pgRef = new PageReference('/apex/TegraAuto_OppAndProducts');
        pgRef.getParameters().put('id', acct.id);
        Test.setCurrentPage(pgRef);

        TegraAuto_OppAndProducts_Controller ctl = new TegraAuto_OppAndProducts_Controller();
        ctl.InitPage();
        
        ctl.cancel();
    }
    static testMethod void test_ThePage() {
        
        string strAccName = 'UnitTests_TegraAuto_OppAndProducts_test_ThePage';
        Account acct = new Account(Name = strAccName, Automotive_Startup__c = 'No');
        insert acct;
        
        Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();

        PageReference pgRef = new PageReference('/apex/TegraAuto_OppAndProducts');
        pgRef.getParameters().put('AccountId', acct.Id);
        pgRef.getParameters().put('RecordType', myRTMap.get('Opportunity/ Tegra Embedded Opportunity'));
        Test.setCurrentPage(pgRef);

        TegraAuto_OppAndProducts_Controller ctl = new TegraAuto_OppAndProducts_Controller();
        ctl.InitPage();
        
        ctl.startingQuarter = ctl.lstPossibleQuarters[0].getValue();
        ctl.pickStartingQuarter();

        System.assertEquals(null, ctl.opp.id, 'New opp should have no Id');
        System.assertEquals(Utils.getRecordTypeId('Opportunity/ Tegra Embedded Opportunity'), ctl.opp.RecordTypeId, 'Record Type');
        System.assertEquals(1, ctl.lstOLIHelpers.size(), 'Should have 1 empty OLI Helper');
        System.assertEquals(Utils.getFiscalQuarterForDate(Date.today()), ctl.lstQuarters[0], 'Initial FQ');
        
        ctl.opp.Name = 'Unit Test Opp';
        ctl.opp.AccountId = [select id from Account where name = 'Test Account' limit 1].id;
        ctl.opp.Type = 'Existing Business';
        ctl.opp.CloseDate = Date.today().addDays(14);
        ctl.opp.StageName = 'Prospecting';
        ctl.opp.Probability = 50;
        ctl.opp.Industry__c = 'Testing';
        ctl.opp.GEO_Area__c = 'NALA';
        ctl.opp.Prefered_Partner__c = 'DELL';
        ctl.opp.Additional_Partners__c = '1';
        ctl.opp.Critical_Priority_1_Software_Apps__c = 'AMBER';
        ctl.opp.Critical_Priority_2_Software_Apps__c = 'AMR';

        ctl.changeStageName();
        
        // Get a Product Family
        List<SelectOption> lstProductFamiliesSelectOptions = ctl.lstProductFamilies;
        System.assert(0 < lstProductFamiliesSelectOptions.size(), 'Product Family Select Options');
        
        // Populate an OLIHelper
        TegraAuto_OppAndProducts_Controller.OLIHelper olih = ctl.lstOLIHelpers[0];
        olih.family = lstProductFamiliesSelectOptions[1].getValue(); 
        olih.pbeId = olih.pbesForFamily[0].getValue();

        System.assertEquals(olih.pbesForFamily[0].getLabel(), olih.productName, 'productName');
        //System.assert(0 < olih.asp, 'asp');
        //System.assertEquals(0, olih.totalUnits, 'total Units with no SEH units specified');
        //System.assertEquals(0, olih.totalPrice, 'total Price with no SEH units specified');
        //System.assertEquals(1, olih.lstSEHs.size(), 'lstSEHs.size()');
        
        TegraAuto_OppAndProducts_Controller.ScheduleEntryHelper seh = olih.lstSEHs[0];  
        seh.units = 10;
        seh.asp = 1;    

        System.assertEquals(10, olih.totalUnits, 'total Units with 10 SEH units specified');
        //System.assertEquals(10 * olih.asp, olih.totalPrice, 'total Price with 10 SEH units specified');
        //System.assertEquals(10 * olih.asp, seh.revenue, 'SEH revenue with 10 SEH units specified');
        System.assert(seh.isEditable, 'SEH isEditable');
    
        // Add an OLIHelper, and then delete it
        ctl.addProduct();
        System.assertEquals(2, ctl.lstOLIHelpers.size(), 'After adding an OLI Helper');
        ctl.deleteProductIndex = '1';
        ctl.deleteProduct();
        System.assertEquals(1, ctl.lstOLIHelpers.size(), 'After deleting an OLI Helper');

        // Add some quarters
        ctl.addNextQuarter();
        ctl.addPreviousQuarter();
        System.assertEquals(3, ctl.lstQuarters.size(), 'After adding 2 quarters');
        System.assertEquals(3, ctl.lstSEHsByQuarter.size(), 'List of Schedule Entry Helpers after adding 2 quarters');
        System.assertEquals(Utils.getFiscalQuarterForDate(Date.today()),ctl.lstSEHsByQuarter[1].quarter, 'Schedule Entry Helper list after adding 2 quarters');
        
        System.assert(ctl.userIsAdmin, 'User running tests should be an admin');
        
        // Save the Opp
        ctl.save();
                
        Opportunity opp = [SELECT id, Amount FROM Opportunity WHERE id = :ctl.opp.id];
        //System.assertEquals(10 * olih.asp, opp.Amount, 'Saved Opp Amount');
        
        OpportunityLineItem oli = [SELECT Id, Product_Name__c, pricebookEntryId, ASP__c, Quantity, TotalPrice
                                   FROM OpportunityLineItem
                                   WHERE OpportunityId =:opp.id];
                
        System.assertEquals(olih.productName, oli.Product_Name__c, 'oli.Product_Name__c');
        System.assertEquals(olih.pbeId, oli.PricebookEntryId, 'oli.PricebookEntryId');
        //System.assertEquals(olih.asp, oli.ASP__c, 'oli.ASP__c');
        System.assertEquals(olih.totalPrice, oli.TotalPrice);
        
        // When we added 2 more quarters, their Units & ASP were populated from the existing quarter,
        // so we should now have 3 identical quarters
        System.assertEquals(3, [SELECT count() FROM Schedule_Entry__c WHERE Opportunity__c = :opp.id] );
        
        Schedule_Entry__c se = [SELECT Id, Opportunity_Type__c, OLI_Id__c, Product_Name__c, Display_Quarter__c, Quantity__c, Revenue__c
					            FROM Schedule_Entry__c
					            WHERE Opportunity__c = :opp.id 
					            limit 1];
        
        System.assertEquals('Tegra Auto/Emb Sales Opportunity', se.Opportunity_Type__c, 'se.Opportunity_Type__c');
        System.assertEquals(oli.id, se.OLI_Id__c, 'se.OLI_Id__c');
        System.assertEquals(olih.productName, se.Product_Name__c, 'se.Product_Name__c');
        System.assertEquals(seh.quarter, se.Display_Quarter__c, 'se.Display_Quarter__c');
        System.assertEquals(10, se.Quantity__c, 'se.Quantity__c');
        System.assertEquals(oli.TotalPrice / 3, se.Revenue__c, 'se.Revenue__c');

        // Get the controller to load the opp
        PageReference pgRef2 = new PageReference('/apex/TegraAuto_OppAndProducts');
        pgRef2.getParameters().put('AccountId', acct.Id);
        pgRef2.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pgRef2);

        TegraAuto_OppAndProducts_Controller ctl2 = new TegraAuto_OppAndProducts_Controller();
        ctl2.InitPage();
        ctl2.startingQuarter = ctl.lstPossibleQuarters[0].getValue();
        ctl2.pickStartingQuarter();
        
        System.assertEquals(opp.id, ctl2.opp.id, 'Initialized page with existing opp');
        
        ctl2.lstOLIHelpers.clear();
        System.assertEquals(0, ctl2.lstOLIHelpers.size(), 'Cleared lstOLIHelpers');
       
        ctl2.save();
       
        TegraAuto_OppAndProducts_Controller ctl3 = new TegraAuto_OppAndProducts_Controller();
        ctl3.InitPage();
        System.assertEquals(opp.id, ctl3.opp.id, 'Initialized page with existing opp');
                    
        // Test when StageName = 'Closed'
        ctl3.opp.StageName = 'Closed';
        Id newPricebookId =  [select id  from   Pricebook2 where  name = 'Tegra Auto/Emb Price Book' limit 1].id;       
      
        // Create comments on Status change
        String strStatusLastStep = 'Prospecting';
        ctl3.opp.Status_Next_Step__c = 'Qualification';
        
        // Create comments on Description change
        String strPreviousDescription = 'Test Description 1';
        ctl3.opp.Description = 'Test Description 2';
         
        // Create comments on Blocking Issues change
        String strPreviousBlockingIssues = 'Test Blocking Issues 1';
        ctl3.opp.Blocking_Issues__c = 'Test Blocking Issues 2';
                  
        // Create comments on Competetion change
        String strPreviousCompetition = 'Test Competition 1';
        ctl3.opp.competitionold__c = 'Test Competition 2';
         
        // Create comments on Reason for Closed Lost/Other change
        String strPreviousReason= 'Test Reason for Closed 1';
        ctl3.opp.Reason_for_Close__c = 'Test Reason for Closed 2';

        // Create comments on Reason for Closed Lost/Other change
        String strPreviousClosedLostOtherComments = 'Test Reason for Closed Comments 1';
        ctl3.opp.Closed_Lost_Comments__c = 'Test Reason for Closed Comments 2';

        // Create comments on Amount change
        Integer iPreviousAmount = 100;
        ctl3.opp.Amount = 200;
        
        // Create comments on Reason for Approval change
        String strPreviousReasonForApproval = 'Test Reason For Approval 1';
        ctl3.opp.Reason_for_Approval__c = 'Test Reason For Approval 2';

        // Create comments on Conditions of Approval / Feedback change
        String strPreviousConditionsOfApproval = 'Test Conditions of Approval / Feedback 1';
        ctl3.opp.Conditions_of_Approval__c = 'Test Conditions of Approval / Feedback 2';
            
    }
*/    
}