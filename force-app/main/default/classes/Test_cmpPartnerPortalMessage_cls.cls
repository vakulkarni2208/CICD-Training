/*
    Test class for Custom Component Controller: cmpPartnerPortalMessage_cls
    Assumption: 
        Profile names are changing frequently. So creating parnter users automatically may break the test methods
        1. SeeAllData = true
        2. Existing Test User configured in the label named Label.PortalUserName
    Note: These methods should be self sufficient with creation of test user and data itself. Revisit the code whenever possible (Time, Resource)
    2021.04.15  Test class optimization
 */
@isTest(seeAllData=false)
private class Test_cmpPartnerPortalMessage_cls {

    @isTest static void testWithPSGAndCountry() {   
    
        list<GRID_VCA_Instant_Message__c> lstAllUnExpiredMessagesOUT = [   Select URL__c, Country__c, Permission_Set_Groups__c, Message__c 
                From GRID_VCA_Instant_Message__c 
                Where Expiration_Date__c > today
                Order By Expiration_Date__c ASC ];

            system.debug('>>> FROM @testWithPSGAndCountry WITHOUT RUN AS lstAllUnExpiredMessagesOUT.size() = '+ lstAllUnExpiredMessagesOUT.size());
            system.debug('>>> FROM @testWithPSGAndCountry WITHOUT RUN AS lstAllUnExpiredMessagesOUT = '+ lstAllUnExpiredMessagesOUT);
                
    
    
        User testPartnerUser = [SELECT Id, ContactId, Profile.Name FROM User WHERE IsActive = true AND Email ='test1@nv.com' LIMIT 1];
        
        system.debug('>>> testPartnerUser = '+ testPartnerUser);
        
        //Clean up Partner Contact's Mailing City and Permissions & Group Assignments
        Contact testPartnerContact = getCleanedUpContact(testPartnerUser.ContactId);        
       
        //Update the Partner Contact's Mailing City and Permissions & Group Assignments
        testPartnerContact.MailingCountry = COMM_Constants.PIM_COUNTRY_US;
        testPartnerContact.Portal_Groups__c = 'SP Virtualization Preferred;'; //COMM_Constants.PIM_PSG_SPCVP;
        update testPartnerContact;
        
        test.startTest();
            system.runAs(testPartnerUser){
                
                
            list<GRID_VCA_Instant_Message__c> lstAllUnExpiredMessages = [   Select URL__c, Country__c, Permission_Set_Groups__c, Message__c 
                From GRID_VCA_Instant_Message__c 
                Where Expiration_Date__c > today
                Order By Expiration_Date__c ASC ];

            system.debug('>>> FROM @testWithPSGAndCountry lstAllUnExpiredMessages.size() = '+ lstAllUnExpiredMessages.size());
            system.debug('>>> FROM @testWithPSGAndCountry lstAllUnExpiredMessages = '+ lstAllUnExpiredMessages);
                
                
                cmpPartnerPortalMessage_cls oCMPPartnerPortalMessage_cls = new cmpPartnerPortalMessage_cls();               
                
                List<GRID_VCA_Instant_Message__c> listTst = [SELECT Id FROM GRID_VCA_Instant_Message__c];
                System.debug('>>>>>>>>>> listTst Size(): '+listTst.size()+' <<<<<<<<<<<<<<<');
                system.debug('>>>>>>> size:' + oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() +' <<<<<<<<<<<');
                
                //Both the message with matcing Country and matching PSG, matching Country, matching PSG, NO Country and NO PSG gets considered     
                system.assert(oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() == 4);
            }
        test.stopTest();
    }
    
    
    @isTest static void testWithNoPSGNoCountry() {
        
        User testPartnerUser = [SELECT Id, ContactId FROM User WHERE IsActive = true AND Email ='test1@nv.com' LIMIT 1]; 
        
        //Clean up Partner Contact's Mailing City and Permissions & Group Assignments
        Contact testPartnerContact = getCleanedUpContact(testPartnerUser.ContactId);
        
        test.startTest();
             system.runAs(testPartnerUser){
                 
                 
                list<GRID_VCA_Instant_Message__c> lstAllUnExpiredMessages = [   Select URL__c, Country__c, Permission_Set_Groups__c, Message__c 
                From GRID_VCA_Instant_Message__c 
                Where Expiration_Date__c > today
                Order By Expiration_Date__c ASC ];

            system.debug('>>> FROM @testWithNoPSGNoCountry lstAllUnExpiredMessages.size() = '+ lstAllUnExpiredMessages.size());
            system.debug('>>> FROM @testWithNoPSGNoCountry lstAllUnExpiredMessages = '+ lstAllUnExpiredMessages);
            
            
                cmpPartnerPortalMessage_cls oCMPPartnerPortalMessage_cls = new cmpPartnerPortalMessage_cls();
                //Only records with NO Country and NO PSG gets considered
                system.debug('>>>>>>> size:' + oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() +' <<<<<<<<<<<');
                system.assert(oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() == 1);
                
             }
        test.stopTest();      
    }
    
    
    @isTest static void testWithNoCountry() {
        
        User testPartnerUser = [SELECT Id, ContactId FROM User WHERE IsActive = true AND Email ='test1@nv.com' LIMIT 1];
        
        //Clean up Partner Contact's Mailing City and Permissions & Group Assignments
        Contact testPartnerContact = getCleanedUpContact(testPartnerUser.ContactId);        

        //Update the Partner Contact's Mailing City and Permissions & Group Assignments
        testPartnerContact.Portal_Groups__c = 'SP Virtualization Preferred;'; //COMM_Constants.PIM_PSG_SPCVP;
        update testPartnerContact;
        
        test.startTest();
            system.runAs(testPartnerUser){
                
                
                list<GRID_VCA_Instant_Message__c> lstAllUnExpiredMessages = [   Select URL__c, Country__c, Permission_Set_Groups__c, Message__c 
                From GRID_VCA_Instant_Message__c 
                Where Expiration_Date__c > today
                Order By Expiration_Date__c ASC ];

            system.debug('>>> FROM @testWithNoCountry lstAllUnExpiredMessages.size() = '+ lstAllUnExpiredMessages.size());
            system.debug('>>> FROM @testWithNoCountry lstAllUnExpiredMessages = '+ lstAllUnExpiredMessages);
                
                cmpPartnerPortalMessage_cls oCMPPartnerPortalMessage_cls = new cmpPartnerPortalMessage_cls();
                //Both the message with matching PSG, NO Country and NO PSG gets considered
                system.debug('>>>>>>> size:' + oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() +' <<<<<<<<<<<');
                system.assert(oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() == 2);
            }
        test.stopTest();
       
    }
    
    @isTest static void testWithNoPSG() {
        
        User testPartnerUser = [SELECT Id, ContactId FROM User WHERE IsActive = true AND Email ='test1@nv.com' LIMIT 1]; 
        
        //Clean up Partner Contact's Mailing City and Permissions & Group Assignments
        Contact testPartnerContact = getCleanedUpContact(testPartnerUser.ContactId);
        
        //Update the Partner Contact's Mailing City and Permissions & Group Assignments
        testPartnerContact.MailingCountry = COMM_Constants.PIM_COUNTRY_US;
        update testPartnerContact;
        
        test.startTest();
             system.runAs(testPartnerUser){
                 
                 
                list<GRID_VCA_Instant_Message__c> lstAllUnExpiredMessages = [   Select URL__c, Country__c, Permission_Set_Groups__c, Message__c 
                From GRID_VCA_Instant_Message__c 
                Where Expiration_Date__c > today
                Order By Expiration_Date__c ASC ];

                system.debug('>>> FROM @testWithNoPSG lstAllUnExpiredMessages.size() = '+ lstAllUnExpiredMessages.size());
                system.debug('>>> FROM @testWithNoPSG lstAllUnExpiredMessages = '+ lstAllUnExpiredMessages);

                cmpPartnerPortalMessage_cls oCMPPartnerPortalMessage_cls = new cmpPartnerPortalMessage_cls();
                //Both the message with matching Country, NO Country and NO PSG gets considered
                system.debug('>>>>>>> size:' + oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() +' <<<<<<<<<<<');
                system.assert(oCMPPartnerPortalMessage_cls.lstWrappedInstanceMessages.size() == 2);
             }
        test.stopTest();
       
    }
    
    /*static User createTestPartnerUser(){
        //User testPartnerUser = [select ContactId from User where isActive=true and userName = :Label.PortalUserName  limit 1]; //npnportaluser@nvidia.com     
        
        User testPartnerUser;
        User usr = [SELECT Id,Profile.Name,Profile.Id FROM User WHERE isActive=true and Profile.Name = 'System Administrator' LIMIT 1];

        //create Partner Portal Account
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC);

        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);

        //Check if the Account is a partner account
        //system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------

        //Create a partner contact
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test1', 'test1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);        

        //Create a Partner User
      
        System.runAs(usr) {
            testPartnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_CP_QPP_GENERIC));
            testPartnerUser.IsActive = true;
            update testPartnerUser;
        }
        return testPartnerUser;
    }*/
    
    static Contact getCleanedUpContact(string contactId){
        Contact testPartnerContact = [Select Portal_Groups__c, MailingCountry From Contact Where Id = :contactId];
        testPartnerContact.Portal_Groups__c = null;
        testPartnerContact.MailingCountry = null;
        update testPartnerContact;
        return testPartnerContact;
    }
    
    @testSetup static void setupData(){
        
        User testPartnerUser;
        User usr = [SELECT Id,Profile.Name,Profile.Id FROM User WHERE isActive=true and Profile.Name = 'System Administrator' LIMIT 1];
        
        System.runAs(usr) {

            //create Partner Portal Account
            map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
            map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
            map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName('Community Lite Profile');
            
            //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
            Account partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);

            //Create a partner contact
            Contact partnerContact = Test_COMM_Factory.createContact('Test1', 'test1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);        

            //Create a Partner User       
            testPartnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get('Community Lite Profile'));
            testPartnerUser.IsActive = true;
            update testPartnerUser;
            
            list<GRID_VCA_Instant_Message__c> lstInstantMsgs = new list<GRID_VCA_Instant_Message__c>();
            
            //PSG and Country = US
            GRID_VCA_Instant_Message__c objGridVCAMsg1 = new GRID_VCA_Instant_Message__c();
            objGridVCAMsg1.Start_Date__c = System.today();  
            objGridVCAMsg1.Expiration_Date__c = System.today().addDays(30);
            objGridVCAMsg1.Message__c = 'You are what you want to be, never loose guard'; 
            objGridVCAMsg1.URL__c = 'https://info.nvidia.com/'; 
            objGridVCAMsg1.Country__c = COMM_Constants.PIM_COUNTRY_US;
            objGridVCAMsg1.Permission_Set_Groups__c =   'SP Virtualization Preferred;'; //COMM_Constants.PIM_PSG_SPCVP;                   
            lstInstantMsgs.add(objGridVCAMsg1);
            
            //PSG and Country = INVALID
            GRID_VCA_Instant_Message__c objGridVCAMsg2 = new GRID_VCA_Instant_Message__c();
            objGridVCAMsg2.Start_Date__c = System.today();  
            objGridVCAMsg2.Expiration_Date__c = System.today().addDays(30);
            objGridVCAMsg2.Message__c = 'If you loose ground, you are just flowing with the wind!';
            objGridVCAMsg2.URL__c = 'https://info.nvidia.com/';         
            objGridVCAMsg2.Country__c = COMM_Constants.PIM_COUNTRY_INVALID;
            objGridVCAMsg2.Permission_Set_Groups__c =   'SP Virtualization Preferred;';//COMM_Constants.PIM_PSG_SPCVP;                   
            lstInstantMsgs.add(objGridVCAMsg2);
            
            //No PSG and No Country
            GRID_VCA_Instant_Message__c objNoPSGNoCountry = new GRID_VCA_Instant_Message__c();
            objNoPSGNoCountry.Start_Date__c = System.today();  
            objNoPSGNoCountry.Expiration_Date__c = System.today().addDays(30);
            objNoPSGNoCountry.Message__c = 'You can mingle with everybody';
            objNoPSGNoCountry.URL__c = 'https://info.nvidia.com/';          
            lstInstantMsgs.add(objNoPSGNoCountry);
            
            //No PSG and Country = US
            GRID_VCA_Instant_Message__c objWithPSGOnly = new GRID_VCA_Instant_Message__c();
            objWithPSGOnly.Start_Date__c = System.today();  
            objWithPSGOnly.Expiration_Date__c = System.today().addDays(30);
            objWithPSGOnly.Country__c = COMM_Constants.PIM_COUNTRY_US;
            objWithPSGOnly.Message__c = 'You can mingle with everybody having matching PSG';
            objWithPSGOnly.URL__c = 'https://info.nvidia.com/';
            
            lstInstantMsgs.add(objWithPSGOnly);
            
             //PSG and NO Country
            GRID_VCA_Instant_Message__c objWithCountryOnly = new GRID_VCA_Instant_Message__c();
            objWithCountryOnly.Start_Date__c = System.today();  
            objWithCountryOnly.Expiration_Date__c = System.today().addDays(30);
            objWithCountryOnly.Permission_Set_Groups__c =   'SP Virtualization Preferred;'; //COMM_Constants.PIM_PSG_SPCVP;
            objWithCountryOnly.Message__c = 'You can mingle with everybody having matching PSG';                
            objWithCountryOnly.URL__c = 'https://info.nvidia.com/';
            lstInstantMsgs.add(objWithCountryOnly);
            
            //Expired 
            GRID_VCA_Instant_Message__c objGridVCAMsg_expired1 = new GRID_VCA_Instant_Message__c();
            objGridVCAMsg_expired1.Start_Date__c = System.today();  
            objGridVCAMsg_expired1.Expiration_Date__c = System.today().addDays(-3);
            objGridVCAMsg_expired1.Message__c = 'As you do not have control, you are considered expired!'; 
            objGridVCAMsg_expired1.Country__c = COMM_Constants.PIM_COUNTRY_INVALID;
            objGridVCAMsg_expired1.Permission_Set_Groups__c =   'SP Virtualization Preferred;';//COMM_Constants.PIM_PSG_SPCVP;                   
            objGridVCAMsg_expired1.URL__c = 'https://info.nvidia.com/';
            lstInstantMsgs.add(objGridVCAMsg_expired1);
            
            insert lstInstantMsgs;
                    
            list<GRID_VCA_Instant_Message__c> lstAllUnExpiredMessages = [Select URL__c, Country__c, Permission_Set_Groups__c, Message__c 
                                                                        From GRID_VCA_Instant_Message__c 
                                                                        Where Expiration_Date__c > today
                                                                        Order By Expiration_Date__c ASC ];
        
            system.debug('>>> FROM @testSetup lstAllUnExpiredMessages.size() = '+ lstAllUnExpiredMessages.size());
            system.debug('>>> FROM @testSetup lstAllUnExpiredMessages = '+ lstAllUnExpiredMessages);
        }
    }
}