/*
    2016.08.24 Test Class for  Apex Controller CRM_OPP_ContactRole_Banner_cls.cls
*/
 
@isTest(SeeAllData=false)
private class Test_CRM_OPP_ContactRole_Banner_cls {
    
    //Create Opporunity with Contact Role, Delete the contact role
    static testMethod void testCRM_OPP_ContactRole_Banner_cls(){
        //setup Custom Settings CRM : OCR : Settings: It sets the Default Contact Role to "Sales Contact"
        //--------------------------------------------
        Test_COMM_Factory.set_CRM_OCR_Settings();
        //--------------------------------------------
        
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Opportunity'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account
        Account partnerAcc;
        
        //Create a Partner Account with Billing Country
        partnerAcc = Test_COMM_Factory.createAccountWithBillingAddress('PartnerAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NV_PPA), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //Create the GRID Partner Opporunity : This also sets Primary Contact and Role in the factory method; it also creates a Opporrunity Contact Role per the Process Builder
        Opportunity gridPartnerOppty = Test_COMM_Factory.createOpportunity('Grid Partner Oppty1', partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, null);
        
        //Delete the contact roles
        list<OpportunityContactRole> lstOCR = [ Select ContactId, OpportunityId, Role, IsPrimary 
                                                        From OpportunityContactRole 
                                                        Where OpportunityId = :gridPartnerOppty.Id];
        
        delete lstOCR;
        
        Test.startTest();
            //set the Primary Contact and Role of the Opporrunity to null
            gridPartnerOppty.DR_Customer_Contact__c = null;
            gridPartnerOppty.Primary_Contact_Role__c = null;
            update gridPartnerOppty;
            
            
            PageReference pageRef = new PageReference('/apex/CRM_OPP_ContactRole_Banner');
            Test.setCurrentPageReference(pageRef);
            ApexPages.Standardcontroller stdCon = new Apexpages.Standardcontroller(gridPartnerOppty);
            
            CRM_OPP_ContactRole_Banner_cls extnCtlr = new CRM_OPP_ContactRole_Banner_cls(stdCon);
            system.debug('***showMessage : ' + extnCtlr.showMessage);
            system.assert(extnCtlr.showMessage == true);
            
        Test.stopTest();
    } 
}