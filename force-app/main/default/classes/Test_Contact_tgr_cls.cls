/**
    Test Methods for Contact_tgr_cls (for the trigger Contact_tgr)
    
    ChangeLists:
    1. 2017.08.01 - Before Insert/Update: "Country/State Picklist Enablement" in the method checkCustomCountryandStateforMKTO().
    
    2. 2017.11.05 - PJENA - Override updates to Contact's FirstName, LastName, EMAIL by MKTO User
 */
@isTest(SeeAllData=false)
private class Test_Contact_tgr_cls {

    //2015.09.02
    //Test class for Contact's Mailing/Other Region, Sub-Region, Territory
    static testMethod void testContactRegionSubRegionAndTerritory() {
    
        //Clean up all the Contact and Country Records if any
        //-----------------------------------------------------------------------------------------------------
        list<Contact> lstAllCon = [Select Name From Contact];
        if (!lstAllCon.isEmpty()){
            Database.delete(lstAllCon, false);
        }
        
        list<Country_List__c> lstAllCountryList = [Select Name From Country_List__c];
        if (!lstAllCountryList.isEmpty()){
            Database.delete(lstAllCountryList, false);
        }
        //-----------------------------------------------------------------------------------------------------
        
        //prep Country_List__c records
        //-----------------------------------------------------------------------------------------------------
        list<Country_List__c> lstCountryList = new list<Country_List__c>();
        Country_List__c testCountry1 = new Country_List__c(name='United States', ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA',  Territory__c = 'LA');
        Country_List__c testCountry2 = new Country_List__c(name='United Kingdom', ISO_Code__c = 'GB', Region__c = 'EMEAI', Sub_Region__c = 'NE',  Territory__c = 'UK_NORDICS');
        lstCountryList.add(testCountry1);
        lstCountryList.add(testCountry2);
        Database.insert(lstCountryList, false);
        //-----------------------------------------------------------------------------------------------------
        
        //Get Account and Contact Record Types
        //-----------------------------------------------------------------------------------------------------
        map<string, Id> map_CUSTOMER_ACCOUNT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_CUSTOMER);
        map<string, Id> map_CUSTOMER_CONTACT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_SALES_CONTACT);
        //-----------------------------------------------------------------------------------------------------
        
        Test.startTest();
            //Create a Customer Account
            List<Account> lstAccounts = new List<Account>();
            Account accEC1 = new Account(name='EC1', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NV_CUSTOMER));
            lstAccounts.add(accEC1);
            Database.insert(lstAccounts);
            
            //Create a Sales Contact 
            List<Contact> lstNewContacts = new List<Contact>();
            //Contact conSC1 = new Contact(LastName='SC1LanstName', MailingCountryCode='US', OtherCountryCode = 'GB', AccountId = accEC1.Id, RecordTypeId = map_CUSTOMER_CONTACT_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT));
            Contact conSC1 = new Contact(LastName='SC1LanstName', MailingCountry='United States', OtherCountry = 'United Kingdom', AccountId = accEC1.Id, RecordTypeId = map_CUSTOMER_CONTACT_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT));
            Contact conSC2 = new Contact(LastName='SC2LanstName', MailingCountry='United Kingdom', OtherCountry = 'United States', AccountId = accEC1.Id, RecordTypeId = map_CUSTOMER_CONTACT_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT));
            lstNewContacts.add(conSC1);
            lstNewContacts.add(conSC2);
            Database.insert(lstNewContacts);
            
            /*
            list<Contact> lstContacts = [Select name,   MailingCountry, MailingCountryCode, Mailing_Region__c, Mailing_Sub_Region__c, Mailing_Territory__c,
                                                            OtherCountry, OtherCountryCode, Other_Region__c, Other_Sub_Region__c, Other_Territory__c  
                                            From Contact 
                                            Where Id =:lstNewContacts];
            */
            list<Contact> lstContacts = [Select name,   MailingCountry, Mailing_Region__c, Mailing_Sub_Region__c, Mailing_Territory__c,
                                                            OtherCountry, Other_Region__c, Other_Sub_Region__c, Other_Territory__c  
                                            From Contact 
                                            Where Id =:lstNewContacts];
            system.assert(lstContacts.size() == 2);
            
            conSC1.MailingCountry = 'United Kingdom';
            update conSC1;
            
            /*
            system.debug('***lstContacts in Test Method: ' + lstContacts);
            for (Contact newCon : lstContacts){
                if (newCon.MailingCountryCode == 'US'){
                    system.assert(newCon.Mailing_Region__c == 'NALA');
                    system.assert(newCon.Mailing_Sub_Region__c == 'LA');
                    system.assert(newCon.Mailing_Territory__c == 'LA');
                } 
                
                if (newCon.MailingCountry == 'United Kingdom'){
                    system.assert(newCon.Mailing_Region__c == 'EMEAI');
                    system.assert(newCon.Mailing_Sub_Region__c == 'NE');
                    system.assert(newCon.Mailing_Territory__c == 'UK_NORDICS');
                }
                
                if (newCon.OtherCountryCode == 'GB'){
                    system.assert(newCon.Other_Region__c == 'EMEAI');
                    system.assert(newCon.Other_Sub_Region__c == 'NE');
                    system.assert(newCon.Other_Territory__c == 'UK_NORDICS');
                } 
                
                if (newCon.OtherCountry == 'United States'){
                    system.assert(newCon.Other_Region__c == 'NALA');
                    system.assert(newCon.Other_Sub_Region__c == 'LA');
                    system.assert(newCon.Other_Territory__c == 'LA');
                }
            }
            */
        Test.stopTest();
     }
     
    //2015.09.02 - Test method to test copy of Product Type to Product Type 2 field
    static testMethod void checkSetProductType2FromProductType(){
        
        //Get Account and Contact Record Types
        //-----------------------------------------------------------------------------------------------------
        map<string, Id> map_CUSTOMER_ACCOUNT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_CUSTOMER);
        map<string, Id> map_CUSTOMER_CONTACT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_SALES_CONTACT);
        //-----------------------------------------------------------------------------------------------------
        
        //Create a Customer Account
        //-----------------------------------------------------------------------------------------------------
        List<Account> lstAccounts = new List<Account>();
        Account accEC1 = new Account(name='EC1', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NV_CUSTOMER));
        lstAccounts.add(accEC1);
        Database.insert(lstAccounts);
        //-----------------------------------------------------------------------------------------------------
            
        //Create a Sales Contact 
        //-----------------------------------------------------------------------------------------------------
        List<Contact> lstNewContacts = new List<Contact>();
        Contact conSC1 = new Contact(LastName='SC1LanstName', AccountId = accEC1.Id, Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_GRID, RecordTypeId = map_CUSTOMER_CONTACT_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT));
        Contact conSC2 = new Contact(LastName='SC2LanstName', AccountId = accEC1.Id, Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO, RecordTypeId = map_CUSTOMER_CONTACT_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT));
        Contact conSC3 = new Contact(LastName='SC3LanstName', AccountId = accEC1.Id, Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_TESLA, RecordTypeId = map_CUSTOMER_CONTACT_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT));
        lstNewContacts.add(conSC1);
        lstNewContacts.add(conSC2);
        lstNewContacts.add(conSC3);
        Database.insert(lstNewContacts);
        //-----------------------------------------------------------------------------------------------------
                
        Test.startTest();
            //Check the Product tyep and Produc Type 2 field value
            list<Contact> lstContacts = [Select Product_Type__c, Product_Type_2__c From Contact Where Id = :lstNewContacts];
            for (Contact con : lstContacts){
                system.assert(con.Product_Type__c == con.Product_Type_2__c);
            }
                                            
            //update a Lead's Product Type and check if reflects in Product_Type_2 
            conSC1.Product_Type__c = COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO;
            update conSC1;
            
            list<Contact> lstUpdatedSC1 = [Select Product_Type__c, Product_Type_2__c From Contact Where Id = :conSC1.Id];
            system.assert(lstUpdatedSC1[0].Product_Type_2__c.containsIgnoreCase(COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO));
            
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
          Contact ctc = new Contact();
          ctc.FirstName = 'Test';
          ctc.Lastname = 'Contact';
          ctc.MKTO_Country__c = 'US';
          ctc.MKTO_State__c = 'CA';
          insert ctc;
          
          Contact ctc1 = [Select Id, Name, MailingCountry, MailingState from Contact WHERE Name = 'Test Contact' limit 1]; 
          system.assertEquals('United States', ctc1.MailingCountry);
          system.assertEquals('California', ctc1.MailingState);
          
          Contact ctc2 = new Contact();
          ctc2.FirstName = 'Test';
          ctc2.Lastname = 'Contact 2';
          ctc2.MKTO_Country__c = 'India';
          insert ctc2;
          
          Contact ctc3 = [Select Id, Name, MailingCountry, MailingState from Contact WHERE Name = 'Test Contact 2' limit 1]; 
          system.assertEquals('India', ctc3.MailingCountry);
          
          //do not pass the Country
          Contact ctc4 = new Contact();
          ctc4.FirstName = 'Test';
          ctc4.Lastname = 'Contact 3';
          ctc4.MKTO_Country__c = '';
          insert ctc4;
          
          Contact ctc5 = [Select Id, Name, MailingCountry, MailingState, MKTO_Country__c, MKTO_State__c from Contact WHERE Name = 'Test Contact 3'];
          system.assertEquals(null, ctc5.MailingCountry);
          system.assertEquals(null, ctc5.MailingState);
          
          //delete the Custom Setting that was created above, so that we can test the Country/State fields value change from UI
          delete mcs;
          
          Contact ctc6 = [Select Id, Name, MailingCountry, MailingState from Contact WHERE Name = 'Test Contact']; 
          ctc6.MailingCountry = 'Canada';
          ctc6.MailingState = 'New Brunswick';
          update ctc6;
          
          Contact ctc7 = [Select Id, Name, MailingCountry, MailingState, MKTO_Country__c, MKTO_State__c from Contact WHERE Name = 'Test Contact'];
          system.assertEquals('Canada', ctc7.MKTO_Country__c);
          system.assertEquals('New Brunswick', ctc7.MKTO_State__c);
          
          Contact ctc8 = [Select Id, Name, MailingCountryCode, MailingStateCode from Contact WHERE Name = 'Test Contact'];
          ctc8.MailingCountryCode = 'US';
          ctc8.MailingStateCode = 'CA';
          update ctc8;
          
          Contact ctc9 = [Select Id, Name, MailingCountry, MailingState, MKTO_Country__c, MKTO_State__c from Contact WHERE Name = 'Test Contact'];
          system.assertEquals('United States', ctc9.MKTO_Country__c);
          system.assertEquals('California', ctc9.MKTO_State__c);
          system.assertEquals('United States', ctc9.MailingCountry);
          system.assertEquals('California', ctc9.MailingState);
          
          Contact ctc10 = [Select Id, Name, MailingCountryCode, MailingStateCode from Contact WHERE Name = 'Test Contact'];
          ctc10.MailingCountryCode = '';
          ctc10.MailingStateCode = '';
          update ctc10;
          
          Contact ctc11 = [Select Id, Name, MailingCountry, MailingState, MKTO_Country__c, MKTO_State__c from Contact WHERE Name = 'Test Contact'];
          system.assertEquals(null, ctc11.MKTO_Country__c);
          system.assertEquals(null, ctc11.MKTO_State__c);
          system.assertEquals(null, ctc11.MailingCountry);
          system.assertEquals(null, ctc11.MailingState);
          
          Contact ctc12 = new Contact();
          ctc12.FirstName = 'Test';
          ctc12.Lastname = 'Contact 4';
          ctc12.MailingCountryCode = 'US';
          ctc12.MailingStateCode = 'CA';
          insert ctc12;
          
          Contact ctc13 = [Select Id, Name, MKTO_Country__c, MKTO_State__c from Contact WHERE Name = 'Test Contact 4'];
          system.assertEquals('United States', ctc13.MKTO_Country__c);
          system.assertEquals('California', ctc13.MKTO_State__c);
          
          Contact ctc14 = new Contact();
          ctc14.FirstName = 'Test';
          ctc14.Lastname = 'Contact 5';
          ctc14.MailingCountry = 'United States';
          ctc14.mailingState = 'California';
          insert ctc14;
          
          Contact ctc15 = [Select Id, Name, MailingCountryCode, MailingStateCode, MKTO_Country__c, MKTO_State__c from Contact WHERE Name = 'Test Contact 5'];
          system.assertEquals('US', ctc15.MailingCountryCode);
          system.assertEquals('CA', ctc15.MailingStateCode);
          system.assertEquals('United States', ctc15.MKTO_Country__c);
          system.assertEquals('California', ctc15.MKTO_State__c);
          
      }
    
    }
    
    //2017.11.05 - PJENA - Override updates to Contact's FirstName, LastName, EMAIL by MKTO User
    static testMethod void testOverrideUpdatesByMKTOUser(){
        
         genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        
        
        list<string> lstSObjects = new list<string>{'Account', 'Contact'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        
        //Create NPN Account
        //-----------------------------------------------------------------------------------------------------
        Account accEC1 = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NPNAcc1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));
        //-----------------------------------------------------------------------------------------------------
            
        //Create a partner Contact 
        //-----------------------------------------------------------------------------------------------------
        string conFirstName = 'FPK1';
        string conLastName = 'LJENA1';
        string conEmail = 'mktooverride1@nv.com';
        Contact contact1 = Test_COMM_Factory.createContactWithMailingAddress(conLastName, conFirstName, accEC1.Id, conEmail, mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        //-----------------------------------------------------------------------------------------------------
        
        Test.startTest();
            System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
            //Sets  MKTOContactUpdateOverrideSettings with current user
            //--------------------------------------------------------------
            setMKTOContactUpdateOverrideSettings();
            //--------------------------------------------------------------
        
            
            //Update the Contact and check if the Contact is having old values for First/Last Name, Email
            //--------------------------------------------------------------
            list<Contact> lstContacts = new list<Contact>();
            lstContacts = [Select FirstName, LastName, Email From Contact Where Id = :accEC1.Id];
            if (!lstContacts.isEmpty()){
                lstContacts[0].FirstName = conFirstName + 'updated';
                lstContacts[0].LastName = conLastName + 'updated';
                lstContacts[0].Email =  conEmail + 'updated';
                update lstContacts;
                
                for (Contact con : lstContacts){
                    system.assert(con.FirstName == conFirstName);
                    system.assert(con.LastName == conLastName);
                    system.assert(con.Email == conEmail);
                }
            }
            //--------------------------------------------------------------
        Test.stopTest();
    }
    
    //Sets  MKTOContactUpdateOverrideSettings with current user
    private static void setMKTOContactUpdateOverrideSettings(){
        MKTO_ContactUpdateOverride_Settings__c MKTOContactUpdateOverrideSettings = new MKTO_ContactUpdateOverride_Settings__c();
        MKTOContactUpdateOverrideSettings.Name = 'MKTOContactUpdateOverrideSettings';
        MKTOContactUpdateOverrideSettings.SDFCUserIds__c = userinfo.getUserId();
        if (Test.isRunningTest()){
            insert MKTOContactUpdateOverrideSettings;
        }
    }
    
}