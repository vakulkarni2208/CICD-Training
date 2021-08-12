/**
    Test class for Test_Opportunity_tgr_cls
    If the Lead Owner is a Partner and The Lead's Product Type is Tesla, the converted Opportunity's Record Type should be 'Tesla Partner Opportunity'
    If the Lead Owner is a Partner and The Lead's Product Type is GRID, the converted Opportunity's Record Type should be 'GRID Partner Opportunity'
    If the Lead Owner is a Partner and The Lead's Product Type is Quadro, the converted Opportunity's Record Type should be 'Quadro Partner Opportunity'
    
    If the Lead Owner is a Internal and The Lead's Product Type is Tesla, the converted Opportunity's Record Type should be 'Tesla Sales Opportunity'
    If the Lead Owner is a Internal and The Lead's Product Type is GRID, the converted Opportunity's Record Type should be 'Quadro Sales Opportunity' //GRID Sales Oppty is not yet rolled out in Production
    If the Lead Owner is a Internal and The Lead's Product Type is Quadro, the converted Opportunity's Record Type should be 'Quadro Sales Opportunity'
    
    2016.04.28 - PJENA - Test class for Opporunity_tgr_cls setForecastCategoryName(trigger.new)
    
    2016.08.24 Before Insert trigger invocation: Set Primary Customer Contact Role from the Converted Lead based on the LeadId For Contact
    
    2016.09.12-Before Update invocation for setting Region/Sub-Region/Territory in case of new or Existing Opportunities
    
    2017.07.18 - CPQ Rollout adjustment (Sys Admin user running the test class having profile default for Opportunity being "SW & Service Renewals" causing the OCR validation rule caught up in the test method "testLeadConversion_Oppty_RecType")
    
    2017.08.23 - Restrict Partners Closing Out Opportunity Regs
    
    2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
    
    2018.02.05 - Remove the following logics which does not have any relevance now
                 GEO Area logic, 
                 Setting legacy audit fields, Cloned Opportunity Created Date Bug Fix
                 setForecastCategoryName
            
    2020.02.14: @Manideep - Tegra Embedded Registrations Expirations

 */
@isTest(SeeAllData=false)
private class Test_Opportunity_tgr_cls {

    static testMethod void testLeadConversion_Oppty_RecType(){
    
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        map<String, Id> map_PartnerLead_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, '');
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);

        //Check if the Account is a partner account 
        system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------
        
        //2017.07.18 - CPQ Rollout adjustment (Sys Admin user running the test class having profile default for Opportunity being "SW & Service Renewals" causing the OCR validation rule caught up)
        //setup Custom Settings CRM : OCR : Settings: It sets the Default Contact Role to "Sales Contact"
        //--------------------------------------------
        Test_COMM_Factory.set_CRM_OCR_Settings();
        //-------------------------------------------- 
        //End       
        
        //Create a Partner Contact 
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test', 'test1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
        //Check if the partner contact is created
        system.assertNotEquals(partnerContact.Id, null);
        system.assertNotEquals(partnerContact.RecordType.Name, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
  
        //---------------------------------------------
        
        
        //Create a Partner User with profile named 'Tesla Partner Portal Profile(Generic)'
        //---------------------------------------------
        User partnerUser = Test_COMM_Factory.createUser(partnerContact.Id, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
        list<user> lstPU = [Select IsPortalEnabled, UserType From User Where id = :partnerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstPU[0].IsPortalEnabled == true);
        //---------------------------------------------
        
        
        
        //Create lead with Partner user being the owner
        //---------------------------------------------
        list<lead> lstPartnerLeads = new list<lead>();
        Lead LTeslaPtnr, LGridPtnr, LQuadroPtnr, LOthersPtnr;
        system.runAs(lstPU[0]){
            //create leads (Last Name, Company, Lead Status, Lead Source, Record Type = Partner Lead)
            LTeslaPtnr = new Lead(LastName = 'LastName1', Company='AJPartnerMotors' + Test_COMM_Factory.getRandomNumber(), Email = 'powner1@ajmotors.com', Status = 'Open (new lead)', Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_TESLA);
            lstPartnerLeads.add(LTeslaPtnr);
            lstPartnerLeads = Test_COMM_Factory.createLeads(lstPartnerLeads, map_PartnerLead_RT.get(COMM_Constants.LEAD_RT_PARTNER_LEAD));
        }
        //---------------------------------------------
        
        //Create lead with Internal user being the owner
        //---------------------------------------------
        list<lead> lstInternalLeads = new list<lead>();
        Lead LTeslaInternal, LGridInternal, LQuadroInternal, LOthersInternal;
        User loggedOnUser = new User (Id = userInfo.getUserId());
        system.runAs(loggedOnUser){
            //create leads (Last Name, Company, Lead Status, Lead Source, Record Type = Partner Lead)
            LTeslaInternal = new Lead(LastName = 'LastName1', Company='AJInternalMotors' + Test_COMM_Factory.getRandomNumber(), Email = 'iowner1@ajmotors.com', Status = 'Open (new lead)', Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_TESLA);
            lstInternalLeads.add(LTeslaInternal);
            lstInternalLeads = Test_COMM_Factory.createLeads(lstInternalLeads, map_PartnerLead_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD));
        }
        //---------------------------------------------
        
        //Build Custom Settings Lead Product Type and Partner Opportunity Record Type map. Used in Opportunity Trigger to set the Partner Opportunity Record Type based on its Lead Product Type
        //---------------------------------------------
        Test_COMM_Factory.setCSLeadProductType_OpportunityRecordType();
        //---------------------------------------------
        
        
        //Convert the Lead to awake Opportunity BeforeInsert Trigger
        //---------------------------------------------
        Test.startTest();
            //Create a Lead through the Partner User to make the user as lead owner
            list<Database.LeadConvert> lstLeadToBeConverted = new List<Database.LeadConvert>();
            Database.LeadConvert oLC;
            
            LeadStatus convertStatus = [Select MasterLabel From LeadStatus Where IsConverted = true LIMIT 1];
            system.debug('***convertStatus: ' + convertStatus);
            
            for (Lead oTBCLead : lstPartnerLeads){
                oLC = new Database.LeadConvert();
                oLC.setLeadId(oTBCLead.Id);
                //oLC.setConvertedStatus(convertStatus.MasterLabel);
                oLC.setConvertedStatus('Sales Qualified');
                oLC.setOwnerId(userInfo.getUserId());
                lstLeadToBeConverted.add(oLC);
            }
            
            for (Lead oTBCLead : lstInternalLeads){
                oLC = new Database.LeadConvert();
                oLC.setLeadId(oTBCLead.Id);
                //oLC.setConvertedStatus(convertStatus.MasterLabel);
                oLC.setConvertedStatus('Sales Qualified');
                oLC.setOwnerId(userInfo.getUserId());
                lstLeadToBeConverted.add(oLC);
            }
            
            if (!lstLeadToBeConverted.isEmpty()){
                list<Database.LeadConvertResult> lstLCR = Database.convertLead(lstLeadToBeConverted);
                
                string strLeadIds = '';
                List<Lead> lstAllLeads = [Select Lead_Id_For_Opportunity__c From Lead Where Id = :lstPartnerLeads OR Id = :lstInternalLeads];
                for (Lead ld : lstAllLeads){
                    strLeadIds += ',\'' + ld.Lead_Id_For_Opportunity__c + '\'';
                }
                strLeadIds = strLeadIds.substringAfter(',');
                
                string strOptySQL = 'Select RecordType.Name, Lead_Id_For_Opportunity__c From Opportunity Where Lead_Id_For_Opportunity__c in (' + strLeadIds + ')';
                list<Opportunity> lstOpptysFromLeadConvert = Database.query(strOptySQL);
                
                map<string, string> mapOpptyLeadIdRecName = new map<string, string>();
                for (Opportunity oppty : lstOpptysFromLeadConvert){
                    mapOpptyLeadIdRecName.put(oppty.Lead_Id_For_Opportunity__c, oppty.RecordType.Name);
                }
                
                system.debug('***mapOpptyLeadIdRecName: ' + mapOpptyLeadIdRecName);
                
            }
             
        Test.stopTest();
        //---------------------------------------------
    }
    
          
    //2016.08.24 Before Insert trigger invocation: Set Primary Customer Contact Role from the Converted Lead based on the LeadId For Contact
    static testMethod void testSetPrimaryContactAndRoleFromConvertedLead() {
        
        //Build Custom Settings Lead Product Type and Partner Opportunity Record Type map. Used in Opportunity Trigger to set the Partner Opportunity Record Type based on its Lead Product Type
        //---------------------------------------------
        Test_COMM_Factory.setCSLeadProductType_OpportunityRecordType();
        //---------------------------------------------
        
        //setup Custom Settings CRM : OCR : Settings: It sets the Default Contact Role to "Sales Contact"
        //--------------------------------------------
        Test_COMM_Factory.set_CRM_OCR_Settings();
        //--------------------------------------------
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Lead'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //Create Tesla product type lead with Internal user being the owner
        //---------------------------------------------
        list<lead> lstInternalLeads = new list<lead>();
        Lead LTeslaInternal;
       
        LTeslaInternal = new Lead(LastName = 'LastName1', Company='AJMotors', Email = 'internalajmotors1@ajmotors.com', Status = 'Open (new lead)', Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_TESLA);
        lstInternalLeads.add(LTeslaInternal);
    
        lstInternalLeads = Test_COMM_Factory.createLeads(lstInternalLeads, mapRTNameId.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD));
        
        //---------------------------------------------
        
        //Convert the Lead
        //-------------------------------------------------------------------------------------
        Test.startTest();
            list<Database.LeadConvert> lstLeadToBeConverted = new List<Database.LeadConvert>();
            Database.LeadConvert oLC;
                
            LeadStatus convertStatus = [Select MasterLabel From LeadStatus Where IsConverted = true LIMIT 1];
            
            for (Lead oTBCLead : lstInternalLeads){
                oLC = new Database.LeadConvert();
                oLC.setLeadId(oTBCLead.Id);
                //oLC.setConvertedStatus(convertStatus.MasterLabel);
                oLC.setConvertedStatus('Sales Qualified');
                oLC.setOwnerId(userInfo.getUserId());
                lstLeadToBeConverted.add(oLC);
            }
                
            if (!lstLeadToBeConverted.isEmpty()){
                list<Database.LeadConvertResult> lstLCR = Database.convertLead(lstLeadToBeConverted);
                
                string strLeadIds = '';
                List<Lead> lstAllLeads = [Select Lead_Id_For_Opportunity__c From Lead Where Id = :lstInternalLeads];
                for (Lead ld : lstAllLeads){
                    strLeadIds += ',\'' + ld.Lead_Id_For_Opportunity__c + '\'';
                }
                strLeadIds = strLeadIds.substringAfter(',');
                    
                string strOptySQL = 'Select DR_Customer_Contact__c, Primary_Contact_Role__c From Opportunity Where Lead_Id_For_Opportunity__c in (' + strLeadIds + ')';
                list<Opportunity> lstOpptysFromLeadConvert = Database.query(strOptySQL);
                system.debug('***lstOpptysFromLeadConvert: ' + lstOpptysFromLeadConvert);
                system.assert(lstOpptysFromLeadConvert[0].DR_Customer_Contact__c != null);
                system.assert(lstOpptysFromLeadConvert[0].Primary_Contact_Role__c == COMM_Constants.OCR_DEFAULT_SALES_CONTACT);
                
                list<OpportunityContactRole> lstOCR = [ Select ContactId, OpportunityId, Role, IsPrimary 
                                                        From OpportunityContactRole 
                                                        Where OpportunityId = :lstOpptysFromLeadConvert];
                system.debug('***lstOCR: ' + lstOCR);
                system.assert(lstOCR[0].ContactId == lstOpptysFromLeadConvert[0].DR_Customer_Contact__c);
                system.assert(lstOCR[0].OpportunityId == lstOpptysFromLeadConvert[0].Id);
                system.assert(lstOCR[0].Role == COMM_Constants.OCR_DEFAULT_SALES_CONTACT);
                system.assert(lstOCR[0].IsPrimary == true);
            }
        Test.stopTest();
        //-------------------------------------------------------------------------------------
    }
    
    //2016.08.24 Before Update trigger invocation: Set Primary Contact and its Role from the Opportunity Contact Role related list if these fields are not getting set.
    static testMethod void testSetPrimaryContactAndRoleFromOpptyContactRoleRelatedList(){
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
        
        /*
        //Create the GRID Partner Opporunity : This also sets Primary Contact and Role in the factory method; it also creates a Opporrunity Contact Role per the Process Builder
        Opportunity gridPartnerOppty = Test_COMM_Factory.createOpportunity('Grid Partner Oppty1', partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_GRID_PARTER_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, null);
        */
        
        /*
         * Create the GRID Partner Opporunity : This also sets Primary Contact and Role in the factory method; it also creates a Opporrunity Contact Role per the Process Builder
         * 2/14/2020: @Manideep: commented out the above gridPartnerOppty creation and replaced that with 'Tegra Embedded Partner Opportunity' because as GRID record type is already got deleted this method is failing
        */
        Opportunity gridPartnerOppty = Test_COMM_Factory.createOpportunity('Grid Partner Oppty1', partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, null);
                
        //Check if it creates a Opportuninty Contact Role
        list<OpportunityContactRole> lstOCR = [ Select ContactId, OpportunityId, Role, IsPrimary 
                                                        From OpportunityContactRole 
                                                        Where OpportunityId = :gridPartnerOppty.Id];
        system.debug('***lstOCR: ' + lstOCR);
        system.assert(lstOCR[0].ContactId != null);
        system.assert(lstOCR[0].OpportunityId == gridPartnerOppty.Id);
        system.assert(lstOCR[0].Role == COMM_Constants.OCR_DEFAULT_SALES_CONTACT);
        system.assert(lstOCR[0].IsPrimary == true);
        
        Test.startTest();
            //set the Primary Contact and Role of the Opporrunity to null
            gridPartnerOppty.DR_Customer_Contact__c = null;
            gridPartnerOppty.Primary_Contact_Role__c = null;
            update gridPartnerOppty;
            
            //check the same Primary Contact and Role gets copied from its Opportunity Contact Role
            list<Opportunity> lstOpps = [Select DR_Customer_Contact__c, Primary_Contact_Role__c From Opportunity Where Id = :gridPartnerOppty.Id];
            
            system.assert(lstOCR[0].ContactId == lstOpps[0].DR_Customer_Contact__c);
            system.assert(lstOCR[0].Role == lstOpps[0].Primary_Contact_Role__c);
            
        Test.stopTest();
    } 
    
    //2016.09.12-Before Update invocation for setting Region/Sub-Region/Territory in case of new or Existing Opportunities
    private static testMethod void testSetRegionSubRegionTerritoryForOpps(){
        //setup Custom Settings CRM : OCR : Settings: It sets the Default Contact Role to "Sales Contact"
        //--------------------------------------------
        Test_COMM_Factory.set_CRM_OCR_Settings();
        //--------------------------------------------
        
        //Set up Country_List
        //------------------------------------------------------
        list<Country_List__c> lstAllCountryList = [Select Name From Country_List__c];
        if (!lstAllCountryList.isEmpty()){
            Database.delete(lstAllCountryList, false);
        }
        
        //prep Country_List__c records
        list<Country_List__c> lstCountryList = new list<Country_List__c>();
        Country_List__c testCountry1 = new Country_List__c(name='United States', ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA',  Territory__c = 'LA');
        Country_List__c testCountry2 = new Country_List__c(name='United Kingdom', ISO_Code__c = 'GB', Region__c = 'EMEAI', Sub_Region__c = 'NE',  Territory__c = 'UK_NORDICS');
        lstCountryList.add(testCountry1);
        lstCountryList.add(testCountry2);
        Database.insert(lstCountryList, false);
        //------------------------------------------------------
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Opportunity'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account
        Account partnerAcc;
        
        //Create a Partner Account with Billing Country
        partnerAcc = Test_COMM_Factory.createAccountWithBillingAddress('PartnerAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NV_PPA), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        system.debug('***partnerAcc: ' + partnerAcc);
        
        /*
        //Create the GRID Partner Opporunity
        Opportunity gridPartnerOppty = Test_COMM_Factory.createOpportunity('Grid Partner Oppty1', partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_GRID_PARTER_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, null);
        */
        
        /*
         * Create the GRID Partner Opporunity
         * 2/14/2020: @Manideep: commented out the above gridPartnerOppty creation and replaced that with 'Tegra Embedded Partner Opportunity' because as GRID record type is already got deleted this method is failing
        */
        Opportunity gridPartnerOppty = Test_COMM_Factory.createOpportunity('Grid Partner Oppty1', partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, null);
        
        list<Opportunity> lstOpps = [Select Country__c, Opportunity_Country__c, Opportunity_Country__r.Name, Region__c, Sub_Region__c, Territory__c From Opportunity Where Id = :gridPartnerOppty.Id];
        
        system.debug('***lstOpps: ' + lstOpps);
        
        system.assert(lstOpps[0].Country__c == lstOpps[0].Opportunity_Country__r.Name); //Opportunity Country gets copied from Account Billing Country
        system.assert(lstOpps[0].Region__c == 'NALA');
        system.assert(lstOpps[0].Sub_Region__c == 'LA');
        system.assert(lstOpps[0].Territory__c == 'LA');
        
        Test.startTest();
            //Change the Opportunity Country to UK
            lstOpps[0].Opportunity_Country__c = testCountry2.Id;
            update lstOpps[0];
            
            //check the Region/Sub-Region/Territory
            list<Opportunity> lstOppsQry = [Select Country__c, Opportunity_Country__c, Region__c, Sub_Region__c, Territory__c From Opportunity Where Id = :gridPartnerOppty.Id];
            system.debug('***lstOppsQry: ' + lstOppsQry);
            system.assert(lstOppsQry[0].Region__c == 'EMEAI');
            system.assert(lstOppsQry[0].Sub_Region__c == 'NE');
            system.assert(lstOppsQry[0].Territory__c == 'UK_NORDICS');
            
        Test.stopTest();
    }
    
    /*
     * 02/14/2020 - Before Insert Scenario for 'Tegra Embedded Partner Expiraitons'.
     * This test method covers code coverage for 'tegraEmbdPartnerOpptyRegExpInsert()' in the 'Opportuntiy_tgr_cls' class.
     * This test method covers code coverage for 'tegraEmbdPartnerOpptyRegExpUpdate()' in the 'Opportuntiy_tgr_cls' class.
    */
    private static testMethod void testTriggerContexttegraEmbdPartnerExpiration() {
       
      //Create Partner Users
      Id Pid = [Select Id from Profile where Name = 'Sales Profile - Tegra Embedded'].Id;
      Id RoleId = [Select Id From UserRole where Name = 'Sales Europe Manager - Tegra Auto/Emb'].Id;
        
      List<User> Users = new List<User>();
      User u;
  
      u = new User(FirstName = 'test', LastName = 'user 1', email = 'tusr1@example.com', Username = 'tusr1@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                   EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
      Users.add(u); 
      u = new User(FirstName = 'test', LastName = 'default Owner', email = 'testdefaultowner@nvidia.com', Username = 'testdefaultowner@nvidia.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                   EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
      Users.add(u);
            
      User usr = [Select Id from User where Id = :UserInfo.getUserId()];
      system.runAs(usr) {
       insert Users;
      }         
    
      List<User> UserList = [Select Id, Name from User where CreatedDate = Today AND ProfileId = :Pid AND UserRoleId = :RoleId ORDER BY email ASC];
    
      // Create Custom Setting to define various reminder timelines, Default Owner, Send email as, cc users in Notifications etc.,
      list<Tegra_Embedded_Registration_Expirations__c> tegEmbRegExpList = new list<Tegra_Embedded_Registration_Expirations__c>(); 
      Tegra_Embedded_Registration_Expirations__c terExp = new Tegra_Embedded_Registration_Expirations__c(Default_Threshold_for_all_Partners__c = 60, First_Reminder__c = 14, Second_Reminder__c = 5, Third_Reminder__c = 0, 
                                                                                                         Default_Oppty_Owner_Email_Id__c = 'testdefaultowner@nvidia.com',
                                                                                                         Default_Cc_Email_Ids__c = 'testdefaultowner@nvidia.com', OWD_Sender_Email_Address__c = 'no_reply@nvidia.com', 
                                                                                                         Opportunity_Detail_Link_for_Partner_User__c = 'https://stid.nvidia.com/sfdcContent/index.html?retURL=/',
                                                                                                         Opportunity_Stages_to_Exclude__c = 'Closed Won;Closed Lost;Closed - Program Canceled;');                                                                                                                                                                                                                                                                
      tegEmbRegExpList.add(terExp);
      insert tegEmbRegExpList; // Create Custom Setting values 
                                                                                                         
      list<Opportunity> tEmdOpplst = new list<Opportunity>();  // list for Opportunities
            
      // Fetch the Opportunity Record Type 'Tegra Embedded Partner Opportunity' by Name 
      map<string, Id> map_tEmbd_Opportunity_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_OPPORTUNITY, COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
       
      // Create Partner Account, Contact and User
      map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
      map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
      map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC); 
        
      // Create Partner Account (string Name, string RecordTypeId, Boolean isPartner, Boolean isCustomerPortal)
      Account partnerAccount = Test_COMM_Factory.createAccount('TegraEmb_Regstr_Expirations_trg_Test_Acc_1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);    
    
      //Create a Partner Contact     
      Contact partnerContact = Test_COMM_Factory.createContact('TegraEmb_Regstr_Expirations_trg_Test_PC_1', 'TestPC1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
      
      //Create a Partner User     
      User partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
      list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id =:partnerUser.Id AND IsPortalEnabled = TRUE]; 
            
      // Create records for the Custom object 'Tegra Embedded Regstr Expiration by Partner'
      list<Tegra_Embd_Regstr_Expiration_by_Partners__c> tembRegExpbyPartnerList = new list<Tegra_Embd_Regstr_Expiration_by_Partners__c>();
    
      Account pAct = [Select Id, Name, RecordTypeId, RecordType.Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where Id =:partnerAccount.Id];
      pAct.BillingStreet = '1234 Test Street';
      pAct.BillingCity = 'Santa Clara';
      pAct.BillingState = 'California';
      pAct.BillingCountry = 'United States';
      pAct.BillingPostalCode = '12345';
      update pAct;
       
      // Create Tegra Embedded Registration Expiration by Partner
      Tegra_Embd_Regstr_Expiration_by_Partners__c tep = new Tegra_Embd_Regstr_Expiration_by_Partners__c();
      tep.Partner_Sales_Rep_Company__c = pAct.Id;
      tep.Default_Threshold_Limit_for_Partner__c = 60;
      tep.Expire_Registration__c = True;
      insert tep;  // Create records in Custom Object
    
      // login as Partner User and Create the Opportunity    
      system.runAs(partnerUser) {   
        // Create a single Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'trg_Context_Test_Tegra_Embd_Opp_1';
        opp.AccountId = partnerAccount.Id;
        opp.StageName = 'Prospect';
        opp.RecordTypeId = map_tEmbd_Opportunity_RT.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
        opp.DR_Partner_Sales_Rep_Company__c = partnerAccount.Id;
        opp.DR_SalesOps_Approver__c = partnerUser.Id; 
        opp.LastModifiedDate_by_Partner__c = (Date.Today() - 46);
        opp.CloseDate = system.today() + 10;
        opp.Region__c = 'EMEA';
        insert opp;
      }
       
      list<Opportunity> oppLst = [SELECT Id, Name, OwnerId, StageName, LastModifiedDate_by_Partner__c, Opportunity_Expired__c  
                                  FROM Opportunity 
                                  WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
                                   
      // Validate the Before Insert logic in 'tegraEmbdPartnerOpptyRegExpInsert()' of the 'Opportuntiy_tgr_cls' class.
      system.assertEquals(oppLst[0].LastModifiedDate_by_Partner__c, Date.Today()); 
      
      Test.StartTest();
       
      // Populate the 'LastModifiedDate_by_Partner__c' field as System User
      for(Opportunity tegOpp: oppLst) {
          tegOpp.LastModifiedDate_by_Partner__c = (system.today() - 46);
      }
      update oppLst; 
       
      list<Opportunity> oppLst2 = [SELECT Id, LastModifiedDate_by_Partner__c, Opportunity_Expired__c 
                                   FROM Opportunity 
                                   WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
       
      // Validate the Before 'Update' logic in 'tegraEmbdPartnerOpptyRegExpUpdate()' of the 'Opportuntiy_tgr_cls' class.
      system.assertEquals(oppLst2[0].LastModifiedDate_by_Partner__c, (Date.Today() - 46)); 
      system.assertEquals(oppLst2[0].Opportunity_Expired__c, false); 
      
      // Update the Opportunity Stage to 'Closed Lost'
      for(Opportunity tegOpp: oppLst) {
          tegOpp.StageName = 'Closed Lost';
      }
      update oppLst;
      
      list<Opportunity> oppLst3 = [SELECT Id, OwnerId, LastModifiedDate_by_Partner__c 
                                   FROM Opportunity 
                                   WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
                                   
      // Validate the Before 'Update' logic in 'tegraEmbdPartnerOpptyRegExpUpdate()' of the 'Opportuntiy_tgr_cls' class.
      system.assertEquals(oppLst3[0].LastModifiedDate_by_Partner__c, Null);
      system.assertEquals(oppLst3[0].OwnerId, partnerUser.Id); 
      
      // Update the Opportunity as 'Expired' and transfer the Ownership to internal User
      for(Opportunity tegOpp: oppLst) {
          tegOpp.Opportunity_Expired__c = true;
          tegOpp.OwnerId = UserInfo.getUserId();
      }
      update oppLst;  
      
      list<Opportunity> oppLst4 = [SELECT Id, OwnerId, LastModifiedDate_by_Partner__c 
                                   FROM Opportunity 
                                   WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];        
      
      // Validate the Before 'Update' logic in 'tegraEmbdPartnerOpptyRegExpUpdate()' of the 'Opportuntiy_tgr_cls' class.
      system.assertEquals(oppLst4[0].OwnerId, UserInfo.getUserId()); 
      system.assertEquals(oppLst4[0].LastModifiedDate_by_Partner__c, Null);
      
      // Update the Opportunity and populate the 'LastModifiedDate_by_Partner__c' and transfer the Owner to a Partner User
      for(Opportunity tegOpp: oppLst) {
          tegOpp.OwnerId = partnerUser.Id;
      }
      update oppLst;
            
      list<Opportunity> oppLst5 = [SELECT Id, OwnerId, LastModifiedDate_by_Partner__c, Opportunity_Expired__c 
                                   FROM Opportunity 
                                   WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];     
      
      // Validate the Before 'Update' logic in 'tegraEmbdPartnerOpptyRegExpUpdate()' of the 'Opportuntiy_tgr_cls' class.
      system.assertEquals(oppLst5[0].OwnerId, partnerUser.Id); 
      system.assertEquals(oppLst5[0].LastModifiedDate_by_Partner__c, Date.Today());
      system.assertEquals(oppLst5[0].Opportunity_Expired__c, false);  
            
      // Update the Current User to a Interal user
      for(Opportunity tegOpp: oppLst) {
          tegOpp.OwnerId = UserInfo.getUserId();
      } 
      update oppLst;
      
      // Update the 'LastModifiedDate_by_Partner__c' and 'Opportunity_Expired__c'
      for(Opportunity tegOpp: oppLst) {
          tegOpp.LastModifiedDate_by_Partner__c = (Date.Today() - 55);
          tegOpp.Opportunity_Expired__c = True;
          tegOpp.Opportunity_Expiration_Date__c = Date.Today();
      } 
      update oppLst;
      
      // Update and transfer the owner to a Partner User
      for(Opportunity tegOpp: oppLst) {
          tegOpp.OwnerId = partnerUser.Id;
      }
      update oppLst;
      
      // login as Partner User and update the Opportunity
      system.runAs(partnerUser) {
        update oppLst; 
      }
      
      list<Opportunity> oppLst6 = [SELECT Id, OwnerId, LastModifiedDate_by_Partner__c, Opportunity_Expired__c, Opportunity_Expiration_Date__c 
                                   FROM Opportunity 
                                   WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
                                   
      // Validate the Before 'Update' logic in 'tegraEmbdPartnerOpptyRegExpUpdate()' of the 'Opportuntiy_tgr_cls' class.
      system.assertEquals(oppLst6[0].OwnerId, partnerUser.Id); 
      system.assertEquals(oppLst6[0].LastModifiedDate_by_Partner__c, Date.Today());
      system.assertEquals(oppLst6[0].Opportunity_Expired__c, false);
      system.assertEquals(oppLst6[0].Opportunity_Expiration_Date__c, Null); 
            
      Test.StopTest();        
            
    }

}