/*
 * Author: Manideep
 * Created Date: 2/12/2020
 * JIRA # SDS-1493
 * Description: This Test Class covers the code coverage of the classes below
                - CRM_Tegra_Embd_Reg_Expirations_BAT_SCH.cls
                - CRM_Tegra_Embd_Reg_Exp_BAT_Helper.cls
 */

@isTest
public class CRM_Tegra_Embd_Reg_Expry_BAT_SCH_Test {

    /*
     * Create Custom Setting/Custom object and its values/records needed for this test Class.
     */
    @testSetup static void dataSetup() {

        //Create Partner Users
        Id Pid = [Select Id from Profile where Name = 'Sales Profile - Tegra Embedded'].Id;
        Id RoleId = [Select Id From UserRole where Name = 'Sales Europe Manager - Tegra Auto/Emb'].Id;

        List<User> Users = new List<User>();
        User u;

        u = new User(FirstName = 'test', LastName = 'user 1', email = 'tusr1@example.com', Username = 'tusr1@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 2', email = 'tusr2@example.com', Username = 'tusr2@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 3', email = 'tusr3@example.com', Username = 'tusr3@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 4', email = 'tusr4@example.com', Username = 'tusr4@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 5', email = 'tusr5@example.com', Username = 'tusr5@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 6', email = 'tusr6@example.com', Username = 'tusr6@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 7', email = 'tusr7@example.com', Username = 'tusr7@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 8', email = 'tusr8@example.com', Username = 'tusr8@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 9', email = 'tusr9@example.com', Username = 'tusr9@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 10', email = 'tusr10@example.com', Username = 'tusr10@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 11', email = 'tusr11@example.com', Username = 'tusr11@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                     EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);
        Users.add(u);
        u = new User(FirstName = 'test', LastName = 'user 12', email = 'tusr12@example.com', Username = 'tusr12@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
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

        // Create records for ChannelAdmin Approval Routing and pass the Channel Admins by each Region
        List<ChannelAdmin_Approval_Routing__c> chAdminAprRtngList = new List<ChannelAdmin_Approval_Routing__c>();

        chAdminAprRtngList.add( new ChannelAdmin_Approval_Routing__c ( Name = 'JP', Jetson_Approver__c = UserList[4].Id));
        chAdminAprRtngList.add( new ChannelAdmin_Approval_Routing__c ( Name = 'KR', Jetson_Approver__c = UserList[5].Id));
        chAdminAprRtngList.add( new ChannelAdmin_Approval_Routing__c ( Name = 'US', Jetson_Approver__c = UserList[1].Id));
        chAdminAprRtngList.add( new ChannelAdmin_Approval_Routing__c ( Name = 'CN', Jetson_Approver__c = UserList[3].Id));
        chAdminAprRtngList.add( new ChannelAdmin_Approval_Routing__c ( Name = 'RU', Jetson_Approver__c = UserList[7].Id));
        chAdminAprRtngList.add( new ChannelAdmin_Approval_Routing__c ( Name = 'FR', Jetson_Approver__c = UserList[10].Id));


        insert chAdminAprRtngList;
    }


    /*
     * This method covers code coverage for "TegraEmb_Regstr_Expirations_Batch"
       and for its helper class "TegraEmb_Regstr_Expirations_Batch_Helper".
     */
    private static testMethod void insertAndUpdateTegraOpportunitywithDatesForBatch() {

        list<Opportunity> tEmdOpplst = new list<Opportunity>(); // list for Opportunities
        User usr = [Select Id from User where Id = :UserInfo.getUserId()];

        // Fetch the Opportunity Record Type 'Tegra Embedded Partner Opportunity' by Name
        map<string, Id> map_tEmbd_Opportunity_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_OPPORTUNITY, COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);

        /*
           // Create Accounts
           for(integer i=1; i<10; i++) {
            Account acc = new Account();
            acc.Name = 'TegraEmb_Regstr_Expirations_Batch_Test_' + 'Acc' + i;
            acc.RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA);
            accList.add(acc);
           }
           insert accList;
           list<Account> accList2 = [SELECT Id, Name from Account WHERE Name LIKE '%TegraEmb_Regstr_Expirations_Batch_Test_Acc%' ORDER BY Name ASC];
         */

        /*
           list<Account> accList3 = [SELECT Id, Name from Account WHERE RecordType.Name = :COMM_Constants.ACCOUNT_RT_NV_PPA
                                  AND Name LIKE '%TegraEmb_Regstr_Expirations_Batch_Test_Acc%'
                                  ORDER BY Name ASC];
           system.debug('accList3------>'+accList3);
         */

        // Create Partner Account, Contact and User
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);

        
        // Create Partner Account (string Name, string RecordTypeId, Boolean isPartner, Boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('TegraEmb_Regstr_Expirations_Batch_Test_Acc_1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);

        //Create a Partner Contact
        Contact partnerContact = Test_COMM_Factory.createContact('TegraEmb_Regstr_Expirations_Batch_Test_PC_1', 'TestPC1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);

        //Create a Partner User
        User partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
        list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id =:partnerUser.Id AND IsPortalEnabled = TRUE];

        // Create records for the Custom object 'Tegra Embedded Regstr Expiration by Partner'
        list<Tegra_Embd_Regstr_Expiration_by_Partners__c> tembRegExpbyPartnerList = new list<Tegra_Embd_Regstr_Expiration_by_Partners__c>();

        Account pacct = [Select Id, Name, RecordTypeId, RecordType.Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where Id =:partnerAccount.Id];
        pacct.BillingStreet = '1234 Test Street';
        pacct.BillingCity = 'Santa Clara';
        pacct.BillingState = 'California';
        pacct.BillingCountry = 'United States';
        pacct.BillingPostalCode = '12345';
        update pacct;
        system.debug('pacct------->'+pacct);

        //for(integer i=1; i<10; i++) {
        Tegra_Embd_Regstr_Expiration_by_Partners__c terExpPartner = new Tegra_Embd_Regstr_Expiration_by_Partners__c();
        //terExpPartner.Partner_Sales_Rep_Company__c = accList2[i-1].Id;
        terExpPartner.Partner_Sales_Rep_Company__c = pacct.Id;
        terExpPartner.Default_Threshold_Limit_for_Partner__c = 60;
        terExpPartner.Expire_Registration__c = True;
        tembRegExpbyPartnerList.add(terExpPartner);
        //}
        system.debug('tembRegExpbyPartnerList before insert----->'+tembRegExpbyPartnerList);
        insert tembRegExpbyPartnerList; // Create records into Custom Object 'Tegra Embd Regstr Expiration by Partners'

        list<Account> partAccList = [SELECT Id, Name from Account WHERE RecordType.Name =:COMM_Constants.ACCOUNT_RT_NV_PPA
                                                                                          AND Name LIKE '%TegraEmb_Regstr_Expirations_Batch_Test_Acc%'
                                                                                          ORDER BY Name
                                                                                          ASC];
        system.debug('partAccList------>'+partAccList);

        // login as Partner User
        system.runAs(partnerUser) {

            // Create Opportunities for 1st Email Notification
            for(integer i=1; i<4; i++) {
                Opportunity opp = new Opportunity();
                opp.Name = 'TegraEmb_Regstr_Expirations_Batch_Test_' + 'opp' + i;
                opp.ownerId = usr.id;
                //opp.AccountId = accList2[i-1].Id;
                opp.AccountId = partnerAccount.Id;
                opp.StageName = 'Prospect';
                opp.RecordTypeId = map_tEmbd_Opportunity_RT.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
                //opp.DR_Partner_Sales_Rep_Company__c = accList3[i-1].Id;
                opp.DR_Partner_Sales_Rep_Company__c = partAccList[0].Id;
                opp.DR_SalesOps_Approver__c = partnerUser.Id;
                opp.Opportunity_Expired__c = false;
                opp.LastModifiedDate_by_Partner__c = (system.today() - 46);
                opp.CloseDate = system.today() + 10;
                opp.Region__c = 'EMEA';
                tEmdOpplst.add(opp);
            }

            // Create Opportunities for 2nd Email Notification
            for(integer i=4; i<7; i++) {
                Opportunity opp = new Opportunity();
                opp.Name = 'TegraEmb_Regstr_Expirations_Batch_Test_' + 'opp' + i;
                opp.ownerId = usr.id;
                //opp.AccountId = accList2[i-1].Id;
                opp.AccountId = partnerAccount.Id;
                opp.StageName = 'Prospect';
                opp.RecordTypeId = map_tEmbd_Opportunity_RT.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
                //opp.DR_Partner_Sales_Rep_Company__c = accList3[i-1].Id;
                opp.DR_Partner_Sales_Rep_Company__c = partAccList[0].Id;
                opp.DR_SalesOps_Approver__c = partnerUser.Id;
                opp.Opportunity_Expired__c = false;
                opp.LastModifiedDate_by_Partner__c = (system.today() - 55);
                opp.CloseDate = system.today() + 10;
                opp.Region__c = 'NALA';
                tEmdOpplst.add(opp);
            }

            // Create Opportunities for 3rd Email Notification
            for(integer i=7; i<10; i++) {
                Opportunity opp = new Opportunity();
                opp.Name = 'TegraEmb_Regstr_Expirations_Batch_Test_' + 'opp' + i;
                opp.ownerId = usr.id;
                //opp.AccountId = accList2[i-1].Id;
                opp.AccountId = partnerAccount.Id;
                opp.StageName = 'Prospect';
                opp.RecordTypeId = map_tEmbd_Opportunity_RT.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
                //opp.DR_Partner_Sales_Rep_Company__c = accList3[i-1].Id;
                opp.DR_Partner_Sales_Rep_Company__c = partAccList[0].Id;
                opp.DR_SalesOps_Approver__c = partnerUser.Id;
                opp.Opportunity_Expired__c = false;
                opp.LastModifiedDate_by_Partner__c = (system.today() - 60);
                opp.CloseDate = system.today() + 10;
                opp.Region__c = 'EMEA';
                tEmdOpplst.add(opp);
            }

            insert tEmdOpplst;

        } // end of login As Partner User

        list<Opportunity> tegraPartnerOppList = [SELECT Id, Name, RecordType.Name, DR_Partner_Sales_Rep_Company__c, DR_SalesOps_Approver__c, LastModifiedDate_by_Partner__c
                                                 FROM Opportunity
                                                 WHERE RecordType.Name = :COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY
                                                                         AND Name LIKE '%TegraEmb_Regstr_Expirations_Batch_Test_opp%'
                                                                         AND CreatedDate = Today
                                                                                           ORDER BY Name
                                                                                           ASC];
        system.debug('tegraPartnerOppList------>'+tegraPartnerOppList);

        // Manually populate the 'LastModifiedDate_by_Partner__c' field again as the logic in Opportunity trigger will overwrite the above inserted dates because earlier logged in as Partner User for inserting Opportunities.
        integer counter = 0;
        for(Opportunity tegOpp: tegraPartnerOppList) {
            counter = counter + 1;
            if(counter>0 && counter<4) tegOpp.LastModifiedDate_by_Partner__c = (system.today() - 46);
            if(counter>3 && counter<7) tegOpp.LastModifiedDate_by_Partner__c = (system.today() - 55);
            if(counter>6 && counter<10) tegOpp.LastModifiedDate_by_Partner__c = (system.today() - 60);
        }
        system.debug('tegraPartnerOppList------>'+tegraPartnerOppList);
        update tegraPartnerOppList;

        // invoke the batch class
        Test.StartTest();
        CRM_Tegra_Embd_Reg_Expry_BAT_SCH schBatch = new CRM_Tegra_Embd_Reg_Expry_BAT_SCH();
        String schTime = '0 0 23 * * ?';
        system.schedule('Test check', schTime, schBatch);
        Test.stopTest();

        /*
           // Validate if the Email Notifications are created successfully in the custom object 'Tegra Embd Regstr Expiry Notifications'
           list<Tegra_Embd_Regstr_Expiry_Notifications__c> tegRegExpNotificationList = [SELECT Id, Opportunity__c, First_Notification_Sent__c, Second_Notification_Sent__c, Third_Notification_Sent__c
                                                                                     FROM Tegra_Embd_Regstr_Expiry_Notifications__c
                                                                                     WHERE Name LIKE '%TegraEmb_Regstr_Expirations_Batch_Test_opp%'
                                                                                     AND CreatedDate = Today
                                                                                     ORDER BY Name
                                                                                     ASC];
           system.assertEquals(tegRegExpNotificationList.size(), 9);  // Total no. of notifications sent

           system.assertEquals(tegRegExpNotificationList[0].Opportunity__c, tegraPartnerOppList[0].Id);
           system.assertEquals(tegRegExpNotificationList[0].First_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[1].Opportunity__c, tegraPartnerOppList[1].Id);
           system.assertEquals(tegRegExpNotificationList[1].First_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[2].Opportunity__c, tegraPartnerOppList[2].Id);
           system.assertEquals(tegRegExpNotificationList[2].First_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[3].Opportunity__c, tegraPartnerOppList[3].Id);
           system.assertEquals(tegRegExpNotificationList[3].Second_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[4].Opportunity__c, tegraPartnerOppList[4].Id);
           system.assertEquals(tegRegExpNotificationList[4].Second_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[5].Opportunity__c, tegraPartnerOppList[5].Id);
           system.assertEquals(tegRegExpNotificationList[5].Second_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[6].Opportunity__c, tegraPartnerOppList[6].Id);
           system.assertEquals(tegRegExpNotificationList[6].Third_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[7].Opportunity__c, tegraPartnerOppList[7].Id);
           system.assertEquals(tegRegExpNotificationList[7].Third_Notification_Sent__c, True);

           system.assertEquals(tegRegExpNotificationList[8].Opportunity__c, tegraPartnerOppList[8].Id);
           system.assertEquals(tegRegExpNotificationList[8].Third_Notification_Sent__c, True);
         */

    } // end of insertAndUpdateTegraOpportunitywithDatesForBatch()

}