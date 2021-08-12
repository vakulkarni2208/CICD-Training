/*
    2016.08.24 Test Class for batchable and schedulable class CRM_OCR_Sync_Batch
    Functionality to test: 
        The job needs to sync all Opportunity record's Primary Contact and Primary Customer Contact Role from Primary Opportunity Contact Role related list (only if there is a mismatch)
        It is configurable to only consider the records from a specific date (e.g., the Primary OCRs whose last modified date is 1/1/2010) and the batc size

 */
@isTest(SeeAllData=false)
private class Test_CRM_OCR_Sync_Batch {

    static testMethod void testChngOfOCRAndOpptyCustomPrimaryContactUpdateCRMOCRSyncBatch() {
        //setup Custom Settings CRM : OCR : Settings: It sets the Default Contact Role to "Sales Contact" along with msg, batc size etc
        //--------------------------------------------
        Test_COMM_Factory.set_CRM_OCR_Settings();
        //--------------------------------------------
        
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Opportunity'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account, Contact
        Account partnerAcc;
        Contact partnerContact, newOpportunityPrimaryContact;
       
        
        //Create a Partner Account with Billing Country
        partnerAcc = Test_COMM_Factory.createAccountWithBillingAddress('PartnerAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //Create a Partner Contact 
        partnerContact = Test_COMM_Factory.createContactWithMailingAddress('LPartner1', 'FParnter1', partnerAcc.Id, 'crmocrsyncschedlr1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        system.debug('***partnerAcc: ' + partnerContact);

        //Create the 100s GRID Partner Opporunity : This also sets Primary Contact and Role in the factory method; it also creates a Opporrunity Contact Role per the Process Builder
        integer iBatchSize = integer.valueOf(OCR_Settings__c.getOrgDefaults().Job_Batch_Size__c);
        list<Opportunity> lstOpps = Test_COMM_Factory.createMassOpportunityWithOCR(iBatchSize, partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, null, partnerContact.Id, COMM_Constants.OCR_DEFAULT_SALES_CONTACT);
        
        
        //Check if it creates a Opportuninty Contact Role
        list<OpportunityContactRole> lstOCR = [ Select ContactId, OpportunityId, Role, IsPrimary 
                                                From OpportunityContactRole 
                                                Where OpportunityId = :lstOpps and IsPrimary = true];
        //system.debug('***lstOCR: ' + lstOCR);
        system.assert(lstOCR.size() == iBatchSize);
        system.assert(lstOCR[0].ContactId == partnerContact.Id);
        
        //set all Opportunity Contact Roles to non-primary
        for (OpportunityContactRole ocr : lstOCR){
            ocr.IsPrimary = false;
        }
        update lstOCR;
        
        //Create a new Partner Contact to be set from the Opportunity Contact Role related list record 
        newOpportunityPrimaryContact = Test_COMM_Factory.createContactWithMailingAddress('LNewPartner1', 'FNewParnter1', partnerAcc.Id, 'newprimarycontact@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT),COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        //set the Contact Role with new contact as their Primary Contact
        //------------------------------------------------------------------------
        list<OpportunityContactRole> lstOCRNew = new list<OpportunityContactRole>();
        
        for(Opportunity opp : lstOpps){
            lstOCRNew.add(new OpportunityContactRole(OpportunityId = opp.Id, ContactId = newOpportunityPrimaryContact.Id, IsPrimary = true, Role = COMM_Constants.OCR_DEFAULT_SALES_CONTACT));
        }
        if(!lstOCRNew.isEmpty()){
            insert lstOCRNew;
        }
        //------------------------------------------------------------------------
        
        Test.startTest();
            //Execute the batch job
            CRM_OCR_Sync_Batch batchCls = new CRM_OCR_Sync_Batch();
            Database.executeBatch(batchCls);
            
            //Verify the job has not run yet
            lstOpps = [ Select DR_Customer_Contact__c, Primary_Contact_Role__c
                                            From Opportunity
                                            Where Id = :lstOpps];
            system.assert(lstOpps[0].DR_Customer_Contact__c != newOpportunityPrimaryContact.Id);
        Test.stopTest();
        
        //Now that the scheduled job has executed after Test.stopTest(),   fetch the Opportunity record and check if the Primary_Contact_Role__c has been updated
        lstOpps = [ Select DR_Customer_Contact__c, Primary_Contact_Role__c
                                            From Opportunity
                                            Where Id = :lstOpps];
        system.assert(lstOpps[0].DR_Customer_Contact__c == newOpportunityPrimaryContact.Id);
    }

}