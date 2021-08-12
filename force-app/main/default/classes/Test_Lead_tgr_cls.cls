/*
1. New NPN Community Lead
    - If Company is not matching with existing account, Account is created with Record Type: NPN Community Account
    - If no matching contact is found, convert the lead and create a customer user sending the new password details
    - Set 2 Permission Sets to new user that got create (PP_NV_CONTACTS_BOX, PP_QPP_HOME_TAB) - Cannot be tested
    - Add user to the Public Group named "Community Content" - Cannot be tested
2. Existing NPN Community Lead
    - If Lead is already a Contact (matching email address and account), reset password
3. New EMEAI Training Lead
    - If no matching contact is found, convert the lead and create a customer user sending the new password details
    - Set 2 Permission Sets to new user that got create (PP_NV_CONTACTS_BOX, PP_QPP_HOME_TAB) - Cannot be tested
    - Add user to the Public Group named "EMEAI Training Users" - Cannot be tested
4. Existing EMEAI Training Lead
    - If Lead is already a Contact (matching email address and account), reset password 
5. 2015.06.22. Added test method checkLeadRegionSubRegionTerritory for Lead Region__c, Sub_Region__c, Territory

6. 2016.07.27 - After Insert : Leadspace Integration - Add Leads to Campaigns based on the LeadSource and Lead_Origin__c

7. 2017.08.01 - Before Insert/Update: "Country/State Picklist Enablement" in the method checkCustomCountryandStateforMKTO().

8. 2017.08.10 - @Manideep - Before Insert/Update: 'Pre-MQL Alerts for Marketo' in the method 

Note: We will not be able to test the Permission Set and Group Member assignment as this will error out when executed from test method run throwing MIXED DML exception
    Work Around: In the Lead_tg_cls, the permission set and group memner assignment is executed only when it is not executed from test context. 
    
9. 2018.03.27 - PJENA - Duplicate Rule bypass for method checkExistingNPNLeadPWDReset

10. 2019.05.28 - Manideep - SDS-1116 - Old Account RecordType Cleanup (NV Customer Account, NV Marketing Partner Portal, MDF Account, EMEAI Training Account)

11. 2019.07.31 - Manideep - SDS-1560 - Exempt Sales Ops from the Automotive Lead Conversion Validation Rules.

12. 2020.02.28 - @Manideep - SDS-2009 - Deleted existing test methods checkNewNPNLeadInsert(), checkExistingNPNLeadPWDReset() 

13. 2020.07.17 : Rajat     - SDS-2527: Added test methods checkNewNPNLeadInsert(), checkExistingNPNLeadPWDReset()  for Community Level Automation

14. 2021.01.03 : @Manideep - SDS-2795: Deleted the existing test methods below,
                                         * Send_MKTO_PreMQL_Alerts_LSID_Rule1_Test()
                                         * Send_MKTO_PreMQL_Alerts_LSID_Rule1_GNAcc_Test() 
                                         * Send_MKTO_PreMQL_Alerts_LSID_Rule2_Test()
                                         * Send_MKTO_PreMQL_Alerts_LSID_Rule3_LHAcc_Test()
                                         * Send_MKTO_PreMQL_Alerts_LSID_Rule3_NMAcc_Test

 */
@isTest(SeeAllData=false)
private class Test_Lead_tgr_cls {

    /*
        This method inserts 2 NPN leads with Company Name not existing in the SFDC Org
        Test Conditions performed:
        //1. Check for the new Account Creation and only one gets created
        //2. Check for 2 contacts creation for the same Account
        //3. Check for new NPN Community user creation
    */
    static testMethod void checkNewNPNLeadInsert() {
        
        //create NPN Community Lead
        Lead l1 = new Lead(LastName = 'JenaTrainNPN1', Email = 'pjnpn1@testnpn1.com', Lead_Orgin__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Company='TEST-NPN1');
        Lead l2 = new Lead(LastName = 'JenaTrainNPN2', Email = 'pjnpn2@testnpn1.com', Lead_Orgin__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Company='TEST-NPN1');
        list<lead> lstLeads = new list<lead>();
        lstLeads.add(l1);
        lstLeads.add(l2);
        insert lstLeads;
        
        string CON_DEFAULT_CONTENT_TYPE_NPN = COMM_Constants.CON_DEFAULT_CONTENT_TYPE_NPN;
        
        test.startTest();
            //1. Check for the new Account Creation and only one gets created and Accout's record type is "NPN Community Account"
            List<Account> lstNewAccountCreated = [Select Name, RecordType.Name From Account Where Name = 'TEST-NPN1'];
            system.assertEquals(lstNewAccountCreated.size(), 1);
            system.assertEquals(lstNewAccountCreated[0].RecordType.Name , COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY);
            
            
            //2. Check for 2 contact creation
            map<Id, Contact> mapContacts = new map<Id, Contact>([Select Name, Lead_Origin_Contact__c, AccountId, Portal_User_Content_Type__c, RecordType.Name From Contact Where Contact.AccountId = :lstNewAccountCreated[0].Id]);
            system.assertEquals(mapContacts.keyset().size(), 2);
            list<Contact> lstContact = mapContacts.values();
            system.assertEquals(lstContact[0].RecordType.Name, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
            
            //Check for Default Content type to be of NVEP
            for (Contact con : lstContact){
                system.assert(con.Portal_User_Content_Type__c == CON_DEFAULT_CONTENT_TYPE_NPN);
                system.assert(con.Lead_Origin_Contact__c == COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM);
            }
            
            //3. Check for new NPN Community user creation
            list<User> lstNPNUsers = [Select username, email,Profile.Name From User Where ContactId = :mapContacts.keyset()];
            system.assert(lstNPNUsers.size() == 2);
            //system.assertEquals(lstNPNUsers[0].userName.contains(Comm_Constants.USRNAME_EXTN_NPN_COMM));
            system.assertEquals(lstNPNUsers[0].Profile.Name, COMM_Constants.PROF_CP_QPP_GENERIC);
            
            //test the lead is converted and not deleted
            list<lead> lstConvertedLeads = [Select Email from Lead Where id = :lstLeads and IsConverted = true];
            system.assertEquals(lstConvertedLeads.size(), lstLeads.size());
        test.stopTest();
        
    }
    
    /*
        This method inserts 2 NPN leads with Company Name not existing in the SFDC Org
        It inserts one more lead with same email and Company as that of one of the previous Leads
        Test Conditions performed:
        //1. Check for no new Account Creation for the last Lead insert
        //2. Check for no new Contact creation for the last Lead insert
        //3. Check for no new NPN Community user creation for the last lead insert as only the password gets reset
    */
    //2018.03.27 - PJENA - Duplicate Rule bypass
    static testMethod void checkExistingNPNLeadPWDReset() {
        
        //create NPN Community Lead
        Lead l1 = new Lead(LastName = 'JenaTrainNPN1', Email = 'pjnpn1@testnpn1.com', Lead_Orgin__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Company='TEST-NPN1');
        Lead l2 = new Lead(LastName = 'JenaTrainNPN2', Email = 'pjnpn2@testnpn1.com', Lead_Orgin__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Company='TEST-NPN1');
        list<lead> lstLeads = new list<lead>();
        lstLeads.add(l1);
        lstLeads.add(l2);
        insert lstLeads;
        
        test.startTest();
            
            //2018.03.27 - PJENA - Duplicate Rule bypass
            Lead l1Updated;
            try{
            //Insert NPN Lead with same email and Company name
            l1Updated = new Lead(LastName = 'JenaTrainNPN1_UPD', Email = 'pjnpn1@testnpn1.com', Lead_Orgin__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Company='TEST-NPN1');
            insert l1Updated;
            }catch(Exception ex){
            
            }
            //End: 2018.03.27 - PJENA - Duplicate Rule bypass
            
            //1. Check for no new account creation
            List<Account> lstNewAccountCreated = [Select Name From Account Where Name = 'TEST-NPN1'];
            system.assertEquals(lstNewAccountCreated.size(), 1);
            
            //2. Check for no new Contact creation and Default Content Type
            map<Id, Contact> mapContacts = new map<Id, Contact>([Select Name, AccountId From Contact Where Contact.AccountId = :lstNewAccountCreated[0].Id]);
            system.assertEquals(mapContacts.keyset().size(), 2);
            
            //3. Check for no new NPN Community user creation
            list<User> lstNPNUsers = [Select username, email From User Where ContactId = :mapContacts.keyset()];
            system.assert(lstNPNUsers.size() == 2);
            
            //4. Check for the lead (with existing email address and contact/user account) gets deleted
            list<Lead> lstLeadsToBeDeleted = [Select Name From Lead Where Id = :l1Updated.Id];
            system.assertEquals(lstLeadsToBeDeleted.size(), 0);
        test.stopTest();
        
    }   
    //2015.06.22 - check Lead's Region__c, Sub_Region__c, Territory based on Lead's Country value
    static testMethod void checkLeadRegionSubRegionTerritory() {
    
        //Clean up all the Leads and Country Records if any
        list<Lead> lstAllLead = [Select Name From Lead];
        if (!lstAllLead.isEmpty()){
            Database.delete(lstAllLead, false);
        }
        
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
        
        //map<string, Id> map_TESLA_SALES_LEAD_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, COMM_Constants.LEAD_RT_TESLA_SALES_LEAD);
        map<string, Id> map_TESLA_SALES_LEAD_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD);
        
        Test.startTest();
            List<Lead> lstLeads = new List<Lead>();
            //Lead L1 = new Lead(LastName='L1', Company = 'Comp1', CountryCode = 'US', RecordTypeId = map_TESLA_SALES_LEAD_RT.get(COMM_Constants.LEAD_RT_TESLA_SALES_LEAD));
            /*
            Lead L1 = new Lead(LastName='L1', Company = 'Comp1', Country = 'United States', RecordTypeId = map_TESLA_SALES_LEAD_RT.get(COMM_Constants.LEAD_RT_TESLA_SALES_LEAD));
            Lead L2 = new Lead(LastName='L2', Company = 'Comp1', Country = 'United Kingdom', RecordTypeId = map_TESLA_SALES_LEAD_RT.get(COMM_Constants.LEAD_RT_TESLA_SALES_LEAD));
            */
            Lead L1 = new Lead(LastName='L1', Company = 'Comp1', Country = 'United States', RecordTypeId = map_TESLA_SALES_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD)); 
            Lead L2 = new Lead(LastName='L2', Company = 'Comp1', Country = 'United Kingdom', RecordTypeId = map_TESLA_SALES_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD));
            lstLeads.add(L1);
            lstLeads.add(L2);
            Database.insert(lstLeads);
            /*
            list<Lead> lstNewLeads = [  Select name, Country, CountryCode, Region__c, Sub_Region__c, Territory__c  
                                        From Lead 
                                        Where Id = :lstLeads ];
            */
            list<Lead> lstNewLeads = [  Select name, Country, Region__c, Sub_Region__c, Territory__c  
                                        From Lead 
                                        Where Id = :lstLeads ];
            system.assert(lstNewLeads.size() == 2);

            /*
            for (Lead newLead : lstNewLeads){
                if (newLead.CountryCode == 'US'){
                    system.assert(newLead.Region__c == 'NALA');
                    system.assert(newLead.Sub_Region__c == 'LA');
                    system.assert(newLead.Territory__c == 'LA');
                } else if (newLead.Country == 'United Kingdom'){
                    system.assert(newLead.Region__c == 'EMEAI');
                    system.assert(newLead.Sub_Region__c == 'NE');
                    system.assert(newLead.Territory__c == 'UK_NORDICS');
                }
            }
            */
        Test.stopTest();
    }
    
    //2015.09.02 - Test method to test copy of Product Type to Product Type 2 field
    static testMethod void checkSetProductType2FromProductType(){
    
        //Get the Enterprise Customer Lead RT Map
        map<string, Id> map_ENTERPRISE_CUSTOMER_LEAD_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD);
        
        //Insert GRID, TESLA, QUADRO Product Type Leads
        List<Lead> lstLeads = new List<Lead>();
        Lead LGrid = new Lead(LastName='ELGrid1', Company = 'Enterprise1', Email = 'testgl1@nv.com', Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_GRID, RecordTypeId = map_ENTERPRISE_CUSTOMER_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD));
        Lead LQuadro = new Lead(LastName='ELQuadro1', Company = 'Enterprise1', Email = 'testql1@nv.com', Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO, RecordTypeId = map_ENTERPRISE_CUSTOMER_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD));
        Lead LTesla = new Lead(LastName='ELTesla1', Company = 'Enterprise1', Email = 'testtl1@nv.com', Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_TESLA, RecordTypeId = map_ENTERPRISE_CUSTOMER_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD));
        lstLeads.add(LGrid);
        lstLeads.add(LQuadro);
        lstLeads.add(LTesla);
        Database.insert(lstLeads);
        
        Test.startTest();
            //Check the Product tyep and Produc Type 2 field value
            list<Lead> lstNewLeads = [Select Product_Type__c, Product_Type_2__c From Lead Where Id = :lstLeads];
            for (Lead lead : lstNewLeads){
                system.assert(lead.Product_Type__c == lead.Product_Type_2__c);
            }
                                            
            //update a Lead's Product Type and check if reflects in Product_Type_2 
            LGrid.Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO;
            update LGrid;
            
            list<Lead> lstUpdatedLead = [Select Product_Type__c, Product_Type_2__c From Lead Where Id = :LGrid.Id];
            system.assert(lstUpdatedLead[0].Product_Type_2__c.containsIgnoreCase(COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO));
            
        Test.stopTest();
    }
    
    //2016.07.27 - After Insert : Leadspace Integration - Add Leads to Campaigns based on the LeadSource and Lead_Origin__c - Test method for addLSLeadsToCampaign method 
    static testMethod void testAddLSLeadsToCampaign(){
        
        //Constants
        string strLeadSource = 'Leadspace';
        string strLeadOrigin = 'DGX Profile';
        
        
       //Create a Campaign. Needs Marketing User Feature Licenses, so make sure the running user has this license
        //------------------------------------------------------------------------
        User currUser = [Select Id, UserPermissionsMarketingUser From User Where username = :UserInfo.getUserName()];
        if (currUser.UserPermissionsMarketingUser != true){
            system.runAs(currUser){
                currUser.UserPermissionsMarketingUser = true;
                update currUser;
            }
        }
        
        Campaign campaign1 = new Campaign(name = 'LS Campaign - DGX', Status = 'Planned');
        insert campaign1;
        
        system.debug('***campaign1: ' + campaign1);
        //------------------------------------------------------------------------
        
        //Create the custom settings records ""Leadspace : Campaign Mappings"
        //------------------------------------------------------------------------
        list<Leadspace_Campaign_Mappings__c> lstLSCampaignMappings = [Select Lead_Origin__c, LeadSource__c, CampaignId__c, IsActive__c From Leadspace_Campaign_Mappings__c];
            
        if (!lstLSCampaignMappings.isEmpty()) database.delete(lstLSCampaignMappings);
            
        if (lstLSCampaignMappings.isEmpty()){
            Leadspace_Campaign_Mappings__c lsCampaign;
                
            //create a Leadspace Campaing Mapping record
            lsCampaign = new Leadspace_Campaign_Mappings__c();
            lsCampaign.Name = 'Mapping1';
            lsCampaign.LeadSource__c = strLeadSource;
            lsCampaign.Lead_Origin__c = strLeadOrigin;
            lsCampaign.CampaignId__c = campaign1.Id;
            lsCampaign.IsActive__c = true;
            
            lstLSCampaignMappings.add(lsCampaign);
                
            insert lstLSCampaignMappings;
        }
        //------------------------------------------------------------------------
        
        Test.startTest();
            //Create the Leads with LeadSource and LeadOrigin matching with the Mappings
            //------------------------------------------------------------------------
            //Get the Enterprise Customer Lead RT Map
            map<string, Id> map_ENTERPRISE_CUSTOMER_LEAD_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD);
        
            //Leads
            List<Lead> lstLeads = new List<Lead>();
            Lead lead1 = new Lead(LastName='lslead1', Company = 'LS', Email = 'lslead1@ls.com', RecordTypeId = map_ENTERPRISE_CUSTOMER_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD), LeadSource = strLeadSource, Lead_Orgin__c = strLeadOrigin);
            Lead lead2 = new Lead(LastName='lslead2', Company = 'LS', Email = 'lslead2@ls.com', RecordTypeId = map_ENTERPRISE_CUSTOMER_LEAD_RT.get(COMM_Constants.LEAD_RT_ENTERPRISE_CUSTOMER_LEAD), LeadSource = strLeadSource, Lead_Orgin__c = strLeadOrigin);
        
            lstLeads.add(lead1);
            lstLeads.add(lead2);
    
            Database.insert(lstLeads);
            //------------------------------------------------------------------------
            
            //Check if the Campaign has those leads as Campaign Members
            //------------------------------------------------------------------------
            List<CampaignMember> lstCampaignMember = [Select LeadId From CampaignMember Where CampaignId = :campaign1.Id and LeadId = :lstLeads];
            system.assert(lstCampaignMember.size() == 2);
            //------------------------------------------------------------------------
            
        Test.stopTest();
    }
    
    //2017.07.16 - Before Insert/Update: "Country/State picklist enablement" issue handling for Country and State picklist fields.            
    static testMethod void checkCustomCountryandStateforMKTO() {
      
      /*
      Test.StartTest();
       system.runAs(new User(Id = UserInfo.getUserId())) {
         
         Profile prf = [Select Id, Name from Profile WHERE Name = 'Marketo User Profile'];
         UserRole r = new UserRole(DeveloperName = 'MyCustomRole1', Name = 'My Role 1');
         insert r;
          
         User u = new User(ProfileId=prf.Id, LastName='TUser', Email='tuser001@nvidia.com', Username='tuser001@nvidia.com',
                           CompanyName='Test', Title='test', Alias='alz',TimeZoneSidKey='America/Los_Angeles',
                           EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',UserRoleId = r.Id);
         insert u;
       }    
      Test.StopTest();
      */
      
      //Only the users in this Custom Setting are allowed to execute the logic 
      MKTO_Country_State_Config__c mcs = new MKTO_Country_State_Config__c();
      mcs.Name = 'MKTO User';
      //mcs.UserName__c = 'tuser001@nvidia.com;';
      mcs.UserName__c = UserInfo.getUsername();
      insert mcs;
      
      //User usr = [Select id, Name from User WHERE UserName = 'tuser001@nvidia.com'];
      User usr = new User(Id = UserInfo.getUserId());
      
      system.runAs(usr) {
        
          //create Countries in CountryList object.
          List<Country_List__c> clList = new List<Country_List__c>();
          Country_List__c cl = new Country_List__c();
          cl.Name = 'United States';
          cl.ISO_Code__c = 'US';
          cl.Region__c = 'NALA';
          cl.Sub_Region__c = 'LA';
          cl.Territory__c = 'LA';
          clList.add(cl);
          
          Country_List__c cl2 = new Country_List__c();
          cl2.Name = 'India';
          cl2.ISO_Code__c = 'IN';
          cl2.Region__c = 'EMEAI';
          cl2.Sub_Region__c = '';
          cl2.Territory__c = 'SOUTH ASIA';
          clList.add(cl2);
          
          Country_List__c cl3 = new Country_List__c();
          cl3.Name = 'Canada';
          cl3.ISO_Code__c = 'CA';
          cl3.Region__c = 'NALA';
          cl3.Sub_Region__c = 'NA';
          cl3.Territory__c = 'NA';
          clList.add(cl3);
          
          insert clList;
          
          //Create States in StateList object
          List<State_List__c> stateList = new List<State_List__c>();
          Country_List__c clUS = [Select Id, Name from Country_List__c where Name = 'United States' limit 1];
          State_List__c sl = new State_List__c();
          sl.Country__c = clUS.Id;
          sl.Name = 'California';
          sl.ISO_Code__c = 'CA';
          stateList.add(sl);
          
          Country_List__c clCA = [Select Id, Name from Country_List__c where Name = 'Canada' limit 1];
          State_List__c sl2 = new State_List__c();
          sl2.Country__c = clCA.Id;
          sl2.Name = 'New Brunswick';
          sl2.ISO_Code__c = 'NB';
          stateList.add(sl2);
                  
          insert stateList;
          
          //create Leads
          Lead ld = new Lead();
          ld.FirstName = 'Test';
          ld.Lastname = 'Lead';
          ld.MKTO_Country__c = 'US';
          ld.MKTO_State__c = 'CA';
          ld.Company = 'Test Account';
          insert ld;
          
          Lead lead = [Select Id, Name, Country, State, MKTO_Country__c, MKTO_State__c from Lead WHERE Name = 'Test Lead']; 
          system.assertEquals('United States', lead.Country);
          system.assertEquals('California', lead.State);
          system.assertEquals('United States', lead.MKTO_Country__c);
          system.assertEquals('California', lead.MKTO_State__c);
          
          Lead ld2 = new Lead();
          ld2.FirstName = 'Test';
          ld2.Lastname = 'Lead 2';
          ld2.MKTO_Country__c = 'India';
          ld2.Company = 'Test Account';
          insert ld2;
          
          Lead lead2 = [Select Id, Name, Country, State from Lead WHERE Name = 'Test Lead 2']; 
          system.assertEquals('India', lead2.Country);
          
          //do not pass the Country
          Lead ld3 = new Lead();
          ld3.FirstName = 'Test';
          ld3.Lastname = 'Lead 3';
          ld3.MKTO_Country__c = '';
          ld3.Company = 'Test Account';
          insert ld3;
          
          Lead lead3 = [Select Id, Name, Country, State, MKTO_Country__c, MKTO_State__c from Lead WHERE Name = 'Test Lead 3'];
          system.assertEquals(null, lead3.Country);
          system.assertEquals(null, lead3.State);
          
          //delete the existing Custom Setting value that was created above, so that test the usecase where Country/State field values are changed from UI        
          MKTO_Country_State_Config__c mcsVar = [Select Id, Name, UserName__c FROM MKTO_Country_State_Config__c];
          delete mcsVar;
                  
          Lead lead4 = [Select Id, Name, Country, State from Lead WHERE Name = 'Test Lead']; 
          lead4.Country = 'Canada';
          lead4.State = 'New Brunswick';
          update lead4;
          
          Lead lead5 = [Select Id, Name, Country, State, MKTO_Country__c, MKTO_State__c from Lead WHERE Name = 'Test Lead'];
          system.assertEquals('Canada', lead5.Country);
          system.assertEquals('New Brunswick', lead5.State);
          system.assertEquals('Canada', lead5.MKTO_Country__c);
          system.assertEquals('New Brunswick', lead5.MKTO_State__c);
          
          // Update Lead Country/State fields to blank which should update MKTO_Country/MKTO_State fields to null as well 
          Lead lead5_1 = [Select Id, Name, Country, State from Lead WHERE Name = 'Test Lead']; 
          lead5_1.Country = '';
          lead5_1.State = '';
          update lead5_1;
          
          Lead lead5_2 = [Select Id, Name, Country, State, MKTO_Country__c, MKTO_State__c, Region__c, Sub_Region__c, Territory__c from Lead WHERE Name = 'Test Lead'];
          system.assertEquals(null, lead5_2.MKTO_Country__c);
          system.assertEquals(null, lead5_2.MKTO_State__c);
          system.assertEquals(null, lead5_2.Region__c);
          system.assertEquals(null, lead5_2.Sub_Region__c);
          system.assertEquals(null, lead5_2.Territory__c);
                  
          Lead lead6 = [Select Id, Name, CountryCode, StateCode from Lead WHERE Name = 'Test Lead'];
          lead6.CountryCode = 'US';
          lead6.StateCode = 'CA';
          update lead6;
          
          Lead lead7 = [Select Id, Name, Country, State, MKTO_Country__c, MKTO_State__c, CountryCode, StateCode from Lead WHERE Name = 'Test Lead'];
          system.assertEquals('United States', lead7.MKTO_Country__c);
          system.assertEquals('California', lead7.MKTO_State__c);
          system.assertEquals('United States', lead7.Country);
          system.assertEquals('California', lead7.State);
          
          Lead lead8 = [Select Id, Name, CountryCode, StateCode from Lead WHERE Name = 'Test Lead'];
          lead8.CountryCode = '';
          lead8.StateCode = '';
          update lead8;
          
          Lead lead9 = [Select Id, Name, Country, State, MKTO_Country__c, MKTO_State__c, CountryCode, StateCode from Lead WHERE Name = 'Test Lead'];
          system.assertEquals(null, lead9.MKTO_Country__c);
          system.assertEquals(null, lead9.MKTO_State__c);
          system.assertEquals(null, lead9.Country);
          system.assertEquals(null, lead9.State);
          
          Lead lead10 = new Lead();
          lead10.FirstName = 'Test';
          lead10.Lastname = 'Lead 4';
          lead10.CountryCode = 'US';
          lead10.StateCode = 'CA';
          lead10.Company = 'Test Account';
          insert lead10;
          
          Lead lead11 = [Select Id, Name, MKTO_Country__c, MKTO_State__c from Lead WHERE Name = 'Test Lead 4'];
          system.assertEquals('United States', lead11.MKTO_Country__c);
          system.assertEquals('California', lead11.MKTO_State__c);
         
          Lead lead12 = new Lead();
          lead12.FirstName = 'Test';
          lead12.Lastname = 'Lead 5';
          lead12.Country = 'United States';
          lead12.State = 'California';
          lead12.Company = 'Test Account';
          insert lead12;
          
          Lead lead13 = [Select Id, Name, Country, State, CountryCode, StateCode, MKTO_Country__c, MKTO_State__c from Lead WHERE Name = 'Test Lead 5'];
          system.assertEquals('US', lead13.CountryCode);
          system.assertEquals('CA', lead13.StateCode);
          system.assertEquals('United States', lead13.MKTO_Country__c);
          system.assertEquals('California', lead13.MKTO_State__c);
                  
      }
    
    }
  
  /*
    * 2017.08.16 - @Varun
    * This is for test code coverage of SOEM functionality for leads
   */
  static Account customerAccount ;
    
    static void createSOEMData() {
        map<String, Id> mapPP_CustomerAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY);
        //Customer Accounts are not created automatically, when you create an Customer Portal User, the account will turn to Customer Account automatically.
        customerAccount = Test_COMM_Factory.createAccount('Test Cust Account1', mapPP_CustomerAccount_RT.get(COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY), false, false); 
        map<string, SOEMs_Account_Mapping__c> mapSOEM = SOEMs_Account_Mapping__c.getAll();
        delete mapSOEM.values();
        SOEMs_Account_Mapping__c objSOEM = new SOEMs_Account_Mapping__c(name=customerAccount.Id, account_name__c='Test Cust Account1', Default_Competency__c ='Accelerated Computing', GPU_Genius_Groups__c ='Learning GRID:2965513;', Permissions_Portal_Groups__c='OEM Accelerated Computing Elite;');
        insert objSOEM;
        
        
    }
    
    static testmethod void convertSOEMLeadTest() {
    
        createSOEMData();
        Test.startTest();
            RecordType leadRec = [select id from RecordType where sobjectType='Lead' and developerName='NPN_Web_Onboard_Form'];
            Lead objLead = new Lead();
            objLead.Approved_Competencies__c = 'Accelerated Computing; GPU Virtualization';
            objLead.Approved_Program_Type__c = 'Solution Provider (VAR)';
            objLead.Program_Level__c = 'Elite';
            objLead.lastname = 'Varun Test';
            objLead.email = 'varun@test.com';
            objLead.Company = 'NVD';
            objLead.Country = 'India';
            objLead.recordTypeId = leadRec.id;
            objLead.accountId__c = customerAccount.id;
            insert objLead;
            Lead objAssertLead = [select id, convertedContactId from Lead where id = :objLead.id];
            list<Contact> lstCon = [select id,create_user__c from Contact where accountId = :customerAccount.id];
           /* system.assertequals(lstCon.size(), 1);
            system.assertequals(lstCon[0].id, objAssertLead.convertedContactId);
            system.assertequals(lstCon[0].create_user__c, true);*/
        Test.stopTest();
    }
    
    /*
     * 3/7/2018 - @Manideep
     * This is for test code coverage of Automotive Lead Conversion Required fields Validation method 'automotiveLeadRequireddFieldsValidation()' in 'Lead_tgr_cls' and 'Lead_tgr.trigger'
     * Some fields are missing values for them, so the Validaiton Rule should fire
    */
    public static testMethod void automotiveLeadRequireddFieldsValidationTest() {
        
        Automotive_Opp_Task_Settings__c automotiveOppTaskSettings = new Automotive_Opp_Task_Settings__c();
        automotiveOppTaskSettings.AutomotiveTask_RecordTypeId__c = '012400000009o4r';
        automotiveOppTaskSettings.AutomotiveTask_SA_UserId__c = '00540000003Yjwo';
        automotiveOppTaskSettings.AutomotiveTask_WDWDTask_Subject__c = 'What do they do?';
        automotiveOppTaskSettings.AutomotiveTask_OEMPtnrTask_Subject__c = 'OEM Partnership';
        automotiveOppTaskSettings.AutomotiveTask_SATask_Subject__c = 'Solutions Architect (SA)';
        automotiveOppTaskSettings.AutomotiveTask_StatusTask_Subject__c = 'Auto Status Update';
        automotiveOppTaskSettings.AutomotiveTask_MarketingPICTask_Subject__c = 'Marketing PIC';     
        insert automotiveOppTaskSettings;
        
        RecordType AccRT = [SELECT Id, Name FROM RecordType WHERE Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
        RecordType LeadRT = [SELECT Id, Name FROM RecordType WHERE Name =:COMM_Constants.LEAD_RT_Automotive_LEAD];
        
        //User usr = [Select Id from User Where Name = 'Carlos Garcia-Sierra' AND UserType = 'Standard'];
        
        User usr = [SELECT Id FROM User Where Id =: UserInfo.getUserId()];
        
        system.runAs(usr) {
        
        // Check if the user already has the Permisison Set assigned
        List<PermissionSetAssignment> pSetAssignments = [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment 
                                                         WHERE PermissionSet.Name = 'SALES_LEADS_OPPORTUNITIES_AUTOMOTIVE' AND AssigneeId =: UserInfo.getUserId()];
        
        // if the Permission Set is not assinged already then assign it
        if(pSetAssignments.isEmpty()) {                                                                                                        
           
           // Query for the Automotive Permisison Set that is being used by the Automotive team
           PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SALES_LEADS_OPPORTUNITIES_AUTOMOTIVE' limit 1];       
        
           // Assign the Permisison Set to the User
           PermissionSetAssignment psa = new PermissionSetAssignment();
           psa.AssigneeId = usr.Id;
           psa.PermissionSetId = ps.Id;
           insert psa;
        }    
                               
        Account acc = new Account();
        acc.Name = 'Test Class Account 1';
        acc.RecordTypeId = AccRT.Id;
        acc.BillingStreet = 'test street';
        acc.BillingCity = 'Santa Clara';
        acc.BillingState = 'California';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '95134';
        acc.Automotive_Startup__c = 'No';
        insert acc;
        
        Lead ld = new Lead();
        ld.FirstName = 'Test Class';
        ld.LastName = 'Lead 1';
        ld.RecordTypeId = LeadRT.Id;
        ld.Company = 'Test Class Account 1';
        ld.Status = 'Prospect';
        ld.Region__c = 'NALA';
        ld.Automotive_Segment__c = 'Aftermarket Solutions';
        ld.Auto_BU_Priority__c = 'P1';
        ld.NVIDIA_Hardware_Used_Vehicle_Inference__c = 'GeForce GTX';
        ld.Street = '123 Test Street';
        ld.City = 'San Jose';
        ld.Country = 'United States';
        ld.PostalCode = '94502';
        //ld.Website = 'www.testsite.com';  // this will cause the Validation to fire
        insert ld;
        
        Database.LeadConvert lconv = new Database.LeadConvert();
        lconv.setLeadId(ld.id);
        lconv.setconvertedstatus('Convert to Account');
        lconv.setAccountId(acc.id);
        
        try {
         Database.LeadConvertResult lcr = Database.convertLead(lconv);
         //System.assert(!lcr.isSuccess());
        } catch(exception e) {} 
        
        }
    }
    
    /*
     * 7/31/2019 - @Manideep
     * SDS-1560: Exempt Sales Ops from the Automotive Lead Conversion Validation Rules
     * This is for test code coverage of Automotive Lead Conversion Required fields Validation method 'automotiveLeadRequireddFieldsValidation()' in 'Lead_tgr_cls' and 'Lead_tgr.trigger'
     * Pick a User and assign the permission set 'CRM: ACCOUNT MODIFY ALL' if not already asigned and assign the Custom Permission 'SKIP Automotive Lead Conversion Validation' as well if not. So that the Validation Rule get skipped.
    */
    /*
    public static testMethod void automotiveLeadRequireddFieldsValidationSkipTest() {
        
        Automotive_Opp_Task_Settings__c automotiveOppTaskSettings = new Automotive_Opp_Task_Settings__c();
        automotiveOppTaskSettings.AutomotiveTask_RecordTypeId__c = '012400000009o4r';
        automotiveOppTaskSettings.AutomotiveTask_SA_UserId__c = '00540000003Yjwo';
        automotiveOppTaskSettings.AutomotiveTask_WDWDTask_Subject__c = 'What do they do?';
        automotiveOppTaskSettings.AutomotiveTask_OEMPtnrTask_Subject__c = 'OEM Partnership';
        automotiveOppTaskSettings.AutomotiveTask_SATask_Subject__c = 'Solutions Architect (SA)';
        automotiveOppTaskSettings.AutomotiveTask_StatusTask_Subject__c = 'Auto Status Update';
        automotiveOppTaskSettings.AutomotiveTask_MarketingPICTask_Subject__c = 'Marketing PIC';     
        insert automotiveOppTaskSettings;
        
        RecordType AccRT = [SELECT Id, Name FROM RecordType WHERE Name =:COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
        RecordType LeadRT = [SELECT Id, Name FROM RecordType WHERE Name =:COMM_Constants.LEAD_RT_Automotive_LEAD];
        
        //User usr = [Select Id from User Where Name = 'Deepthi Dayam' AND UserType = 'Standard'];
                
        User usr = [SELECT Id FROM User Where Id =: UserInfo.getUserId()];
        
        system.runAs(usr) {
        
        // Check if the user already has the Permisison Set assigned
        List<PermissionSetAssignment> pSetAssignments = [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment 
                                                         WHERE PermissionSet.Name = 'CRM_ACCOUNT_MODIFY_ALL' AND AssigneeId =: UserInfo.getUserId()];
        
        // if the Permission Set is not assinged already then assign it
        if(pSetAssignments.isEmpty()) {                                                                                                        
           
           // Query for the CMT Teams Permisison Set that is being used by the Automotive team
           PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CRM_ACCOUNT_MODIFY_ALL' limit 1];
           
           //Query the Custom permission
           list<CustomPermission> lstCP = [SELECT Id FROM CustomPermission WHERE DeveloperName =:Label.SKIP_Automotive_Lead_Validation];       
        
           if(!lstCP.isEmpty()) {
               
               // Check if the Custom Permission is already assigned to the Permisison Set
               List<SetupEntityAccess> lstSE = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId IN:lstCP AND ParentId =: ps.Id];
               
               //if not already assigned assign the Custom Permission to the Permisison Set
               if(lstSE.isEmpty()) { 
                  SetupEntityAccess sea = new SetupEntityAccess();
                  sea.SetupEntityId = lstCP[0].Id;
                  sea.ParentId = ps.Id;
                  insert sea;  
               }                 
           }    
           
           // Assign the Permisison Set to the User
           PermissionSetAssignment psa = new PermissionSetAssignment();
           psa.AssigneeId = usr.Id;
           psa.PermissionSetId = ps.Id;
           insert psa;          
        }
                                              
        Account acc = new Account();
        acc.Name = 'Test Class Account 1';
        acc.RecordTypeId = AccRT.Id;
        acc.BillingStreet = 'test street';
        acc.BillingCity = 'Santa Clara';
        acc.BillingState = 'California';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '95134';
        acc.Automotive_Startup__c = 'No';
        insert acc;
        
        Lead ld = new Lead();
        ld.FirstName = 'Test Class';
        ld.LastName = 'Lead 1';
        ld.RecordTypeId = LeadRT.Id;
        ld.Company = 'Test Class Account 1';
        ld.Status = 'Prospect';
        ld.Region__c = 'NALA';
        ld.Auto_BU_Priority__c = 'P1';
        ld.NVIDIA_Hardware_Used_Vehicle_Inference__c = 'GeForce GTX';
        ld.Website = 'www.testsite.com';
        ld.Country = 'United States';
        ld.PostalCode = '524002';
        insert ld;
        
        Database.LeadConvert lconv = new Database.LeadConvert();
        lconv.setLeadId(ld.id);
        lconv.setconvertedstatus('Convert to Account');
        lconv.setAccountId(acc.id);
        
        try {
         Database.LeadConvertResult lcr = Database.convertLead(lconv);
         //System.assert(!lcr.isSuccess());
        } catch(exception e) {} 
        
        }
    }
    */
    
        
}