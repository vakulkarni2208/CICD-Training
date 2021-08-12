/*
    2017.10.19 - 2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
        -Rewrote the test class
 * * @Manideep: 1/22/2019 - This code is updated by commenting out unwanted logic as part of Opportunity RecordType Cleanup.
    2021.04.15      Rajat - Test class optimization
*/
@isTest(SeeAllData=false)
private class Test_clsEditOpportunityRecordType_ExtV2 {
    
    /*
     * @Manideep - Opportunity RecordType Cleanup
     
    static testMethod void testForInternalTeslaOpptyByInternalUsers(){
        //Create a Product, Pricebook, PricebookEntry
        PricebookEntry pricebookentryRecord = Test_COMM_Factory.createProductAndSetPrice ('DGX-1/8-GPU', COMM_Constants.PROD_FAMILY_TESLAHW, 'DGX1/8GPU', true, COMM_Constants.PB_TESLA_INTERNAL, 1000, 1500);
        
        //get All Profiles
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_INT_PARTNER_ADMIN };
        map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Opportunity'};
        map<string, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account and Contact variable so it is visible down below
        Account partnerAcc;
        Contact partnerContact;
        
        //Create a Partner Account with Billing Country
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NPNAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //create PA with SP and AC (Id accountId, string programName, string programLevel, string competencyName, Date competencySignedDate)
        Partner_Attribute__c pa = Test_COMM_Factory.createPartnerAttribute(partnerAcc.Id, COMM_Constants.PA_PROGRAM_SP, COMM_Constants.PA_LEVEL_ELITE, COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Date.Today());
        system.debug('***partnerAttribute: ' + pa);
        
        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;
        
        //Create a Partner Contact 
        partnerContact = Test_COMM_Factory.createContactWithMailingAddress('LJena1', 'FContact', partnerAcc.Id, 'contactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        //Set Custom Settings Opportunity Re Engineering Details(ReEngineering Pricebook_Details__c)
        Test_COMM_Factory.set_OpportunityReEngineeringDetailsSettings(COMM_Constants.OPPTY_RT_TESLA_INTERNAL_OPPTY, COMM_Constants.PB_TESLA_INTERNAL, COMM_Constants.PROD_FAMILY_TESLAHW,
                                                                        'Tesla Products', 'Tesla Product Revenue by Quarter', 'Tesla Product', 
                                                                        true, true, true, '', '');
        //set Custom Settings DR_Settings__c
        Test_COMM_Factory.setCSDRSettingsData();
        //Create the Tesla Internal Oppty
        Opportunity teslaInternalOppty = Test_COMM_Factory.createOpportunity('Tesla Internal Opp1', partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_TESLA_INTERNAL_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, pricebookentryRecord.PriceBook2Id);
        
        //Add Opportunity Line Items
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = teslaInternalOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
        insert oli;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(teslaInternalOppty);
            clsEditOpportunityRecordType_ExtensionV2 obj = new clsEditOpportunityRecordType_ExtensionV2(stdController);
            obj.redirect();
        Test.stopTest();
    
    static testMethod void testForNotebookOpportunityByInternalUser(){
        //Create a Product, Pricebook, PricebookEntry
        PricebookEntry pricebookentryRecord = Test_COMM_Factory.createProductAndSetPrice ('DGX-1/8-GPU', COMM_Constants.PROD_FAMILY_TESLAHW, 'DGX1/8GPU', true, Opportunity_ReEngineering_Constants.RT_NOTEBOOK_OPPORTUNITY, 1000, 1500);
        
        //get All Profiles
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_INT_PARTNER_ADMIN };
        map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Opportunity'};
        map<string, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account and Contact variable so it is visible down below
        Account partnerAcc;
        Contact partnerContact;
        
        //Create a Partner Account with Billing Country
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NPNAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //create PA with SP and AC (Id accountId, string programName, string programLevel, string competencyName, Date competencySignedDate)
        Partner_Attribute__c pa = Test_COMM_Factory.createPartnerAttribute(partnerAcc.Id, COMM_Constants.PA_PROGRAM_SP, COMM_Constants.PA_LEVEL_ELITE, COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Date.Today());
        system.debug('***partnerAttribute: ' + pa);
        
        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;
        
        //Create a Partner Contact 
        partnerContact = Test_COMM_Factory.createContactWithMailingAddress('LJena1', 'FContact', partnerAcc.Id, 'contactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        //Set Custom Settings Opportunity Re Engineering Details(ReEngineering Pricebook_Details__c)
        Test_COMM_Factory.set_OpportunityReEngineeringDetailsSettings(COMM_Constants.OPPTY_RT_TESLA_INTERNAL_OPPTY, COMM_Constants.PB_TESLA_INTERNAL, COMM_Constants.PROD_FAMILY_TESLAHW,
                                                                        'Tesla Products', 'Tesla Product Revenue by Quarter', 'Tesla Product', 
                                                                        true, true, true, '', '');
        //set Custom Settings DR_Settings__c
        Test_COMM_Factory.setCSDRSettingsData();
        //Create the Tesla Internal Oppty
        Opportunity noteBookInternalOppty = Test_COMM_Factory.createOpportunity('Tesla Internal Opp1', partnerAcc.Id, mapRTNameId.get(Opportunity_ReEngineering_Constants.RT_NOTEBOOK_OPPORTUNITY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, pricebookentryRecord.PriceBook2Id);
        
        //Add Opportunity Line Items
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = noteBookInternalOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, Monthly_Quantity__c = 4, UnitPrice = pricebookentryRecord.UnitPrice);
        insert oli;
        
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(noteBookInternalOppty);
            clsEditOpportunityRecordType_ExtensionV2 obj = new clsEditOpportunityRecordType_ExtensionV2(stdController);
            obj.redirect();
        Test.stopTest();
    }
       
    static testMethod void testForNonEnterpriseOpp(){
        //Create a Product, Pricebook, PricebookEntry
        PricebookEntry pricebookentryRecord = Test_COMM_Factory.createProductAndSetPrice ('DGX-1/8-GPU', COMM_Constants.PROD_FAMILY_TESLAHW, 'DGX1/8GPU', true, COMM_Constants.PB_TESLA_INTERNAL, 1000, 1500);
        
        //get All Profiles
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_INT_PARTNER_ADMIN };
        map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Opportunity'};
        map<string, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account and Contact variable so it is visible down below
        Account partnerAcc;
        Contact partnerContact;
        
        //Create a Partner Account with Billing Country
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NPNAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //create PA with SP and AC (Id accountId, string programName, string programLevel, string competencyName, Date competencySignedDate)
        Partner_Attribute__c pa = Test_COMM_Factory.createPartnerAttribute(partnerAcc.Id, COMM_Constants.PA_PROGRAM_SP, COMM_Constants.PA_LEVEL_ELITE, COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Date.Today());
        system.debug('***partnerAttribute: ' + pa);
        
        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;
        
        //Create a Partner Contact 
        partnerContact = Test_COMM_Factory.createContactWithMailingAddress('LJena1', 'FContact', partnerAcc.Id, 'contactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        //Set Custom Settings Opportunity Re Engineering Details(ReEngineering Pricebook_Details__c)
        /////////////////
        Test_COMM_Factory.set_OpportunityReEngineeringDetailsSettings(COMM_Constants.OPPTY_RT_TESLA_INTERNAL_OPPTY, COMM_Constants.PB_TESLA_INTERNAL, COMM_Constants.PROD_FAMILY_TESLAHW,
                                                                        'Tesla Products', 'Tesla Product Revenue by Quarter', 'Tesla Product', 
                                                                        true, true, true, '', '');
        ////////////////
        //set Custom Settings DR_Settings__c
        Test_COMM_Factory.setCSDRSettingsData();
        //Create the Tesla Internal Oppty
        Opportunity teslaInternalOppty = Test_COMM_Factory.createOpportunity('Tesla Internal Opp1', partnerAcc.Id, mapRTNameId.get(COMM_Constants.OPPTY_RT_TESLA_INTERNAL_OPPTY), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, pricebookentryRecord.PriceBook2Id);
        
        //Add Opportunity Line Items
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = teslaInternalOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
        insert oli;
        
        Test.startTest();
            ApexPages.StandardController stdController = new ApexPages.StandardController(teslaInternalOppty);
            clsEditOpportunityRecordType_ExtensionV2 obj = new clsEditOpportunityRecordType_ExtensionV2(stdController);
            obj.redirect();
        Test.stopTest();
    }
    */
    
    /*
     * @Manideep - 1/22/2019 - Rewrote the logic for the above commented methods as part of Opportunity RecordType Cleanup.
    */
    static testMethod void testForTegraEmbOppInternalUser() {
        
        genericMock fakeResp = new genericMock(200,'Complete',
        '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
        '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
        '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+
        'xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
        '<ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
            //Create a Product, Pricebook, PricebookEntry
            PricebookEntry pricebookentryRecord = Test_COMM_Factory.createProductAndSetPrice ('Tegra TK1', 'Tegra Embedded', 'Tegra TK1', true, 'Tegra Embedded Opportunity', 1000, 1500);

            //get All Profiles
            list<string> lstProfNames = new list<string>{COMM_Constants.PROF_INT_PARTNER_ADMIN};
            map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);

            //get all Record Types
            list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Opportunity'};
            map<string, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);

            //declare the Account and Contact variable so it is visible down below
            Account partnerAcc;
            Contact partnerContact;

            //Create a Partner Account with Billing Country
            partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NPNAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));

            //create PA with SP and AC (Id accountId, string programName, string programLevel, string competencyName, Date competencySignedDate)
            Partner_Attribute__c pa = Test_COMM_Factory.createPartnerAttribute(partnerAcc.Id, COMM_Constants.PA_PROGRAM_SP, COMM_Constants.PA_LEVEL_ELITE, 'Tegra', Date.Today());

            //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
            partnerAcc.IsPartner = true;
            update partnerAcc;

            //Create a Partner Contact 
            partnerContact = Test_COMM_Factory.createContactWithMailingAddress('LJena1', 'FContact', partnerAcc.Id, 'contactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), 
            COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

            //Set Custom Settings Opportunity Re Engineering Details(ReEngineering Pricebook_Details__c)
            Test_COMM_Factory.set_OpportunityReEngineeringDetailsSettings('Tegra Embedded Opportunity', 'Tegra Embedded Price Book', 'Tegra Embedded',
            'Tegra Products', 'Tegra Product Revenue by Quarter', 'Tegra Product', 
            true, true, true, '', '');
            //set Custom Settings DR_Settings__c
            Test_COMM_Factory.setCSDRSettingsData();

            //Create the Tegra Internal Oppty
            Opportunity tegraInternalOppty = Test_COMM_Factory.createOpportunity('Tegra Internal Opp1', partnerAcc.Id, mapRTNameId.get('Tegra Embedded Opportunity'), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, pricebookentryRecord.PriceBook2Id);

            //Add Opportunity Line Items
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = tegraInternalOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
            insert oli;


            ApexPages.StandardController stdController = new ApexPages.StandardController(tegraInternalOppty);
            clsEditOpportunityRecordType_ExtensionV2 obj = new clsEditOpportunityRecordType_ExtensionV2(stdController);
            obj.redirect();
        Test.stopTest();
    }
    
    /*
     * @Manideep - 1/22/2019 - Rewrote the logic for the above commented methods as part of Opportunity RecordType Cleanup.
    */
    static testMethod void testForOtherOppRecordType() {    

        genericMock fakeResp = new genericMock(200,'Complete',
        '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
        '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
        '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+
        'xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
        '<ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
    
            //Create a Product, Pricebook, PricebookEntry
            PricebookEntry pricebookentryRecord = Test_COMM_Factory.createProductAndSetPrice ('CUDA Support Services', 'GRID SW SUMS', 'CUDA Support Services', true, 'SW & Service Price Book', 1000, 1500);
        
            //get All Profiles
            list<string> lstProfNames = new list<string>{COMM_Constants.PROF_INT_PARTNER_ADMIN};
            map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);

            //get all Record Types
            list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Opportunity'};
            map<string, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);

            //declare the Account and Contact variable so it is visible down below
            Account partnerAcc;
            Contact partnerContact;

            //Create a Partner Account with Billing Country
            partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NPNAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));

            //create PA with SP and AC (Id accountId, string programName, string programLevel, string competencyName, Date competencySignedDate)
            Partner_Attribute__c pa = Test_COMM_Factory.createPartnerAttribute(partnerAcc.Id, COMM_Constants.PA_PROGRAM_SP, COMM_Constants.PA_LEVEL_ELITE, 'SW & Services', Date.Today());

            //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
            partnerAcc.IsPartner = true;
            update partnerAcc;

            //Create a Partner Contact 
            partnerContact = Test_COMM_Factory.createContactWithMailingAddress('LJena1', 'FContact', partnerAcc.Id, 'contactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), 
            COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

            //set Custom Settings DR_Settings__c
            Test_COMM_Factory.setCSDRSettingsData();

            //Create the SW & Services Internal Oppty
            Opportunity SWInternalOppty = Test_COMM_Factory.createOpportunity('Tegra Internal Opp1', partnerAcc.Id, mapRTNameId.get('SW & Service Renewals'), COMM_Constants.OPPTY_STAGE_PROSPECTING, System.Today(), null, pricebookentryRecord.PriceBook2Id);

            //Add Opportunity Line Items
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = SWInternalOppty.Id, PricebookEntryId = pricebookentryRecord.Id, Quantity = 4, UnitPrice = pricebookentryRecord.UnitPrice);
            insert oli;

            ApexPages.StandardController stdController = new ApexPages.StandardController(SWInternalOppty);
            clsEditOpportunityRecordType_ExtensionV2 obj = new clsEditOpportunityRecordType_ExtensionV2(stdController);
            System.currentPageReference().getParameters().put('retURL', 'test.salesforce.com/');
            System.currentPageReference().getParameters().put('cancelURL', 'test.salesforce.com/');
            obj.redirect();
        Test.stopTest();            
    }
   
}