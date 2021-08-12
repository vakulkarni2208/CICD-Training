@isTest(seeAllData=false)
public class NPN_Tableau_UserMgmt_Bat_sch_Test {

    static String sessionBody;
    static void makeData(){
        
        list<Community_Settings__c> listCommunity_Settings= new list<Community_Settings__c> ();

        Community_Settings__c Co1= new Community_Settings__c ();
        Co1.name= 'Test';
        Co1.setupownerid= UserInfo.getOrganizationId();
        Co1.acc_computing_tesla__c= 'Tesla';
        Co1.brainshark_url__c= 'https://staging.brainshark.com/portal/psapis/api/psSession.aspx';
        Co1.cloud_virtualization_vgx__c= 'Virutalization';
        Co1.prof_visualization_vca__c= 'Visualization';
        Co1.ps_pg_assign_lkbk_time__c= 8;
        Co1.ps_pg_assign_recur__c= 5;
        Co1.ps_pg_enable_schduled_job__c= false;
        //Co1.contentversion_language_region_metaid__c= '00N40000002WvBR';
        //Co1.contentversion_competency_metaid__c= '00N40000002zGdx';
        Co1.error_emails__c= 'apardeshi@nvidia.com.invalid;vakulkarni@nvidia.com.invalid';
        Co1.username_extension__c= 'npnbu';
        Co1.batchjob_ps_pg_assign_lkbk_time__c= 8;
        Co1.batchjob_ps_pg_assign_recur__c= 5;
        Co1.batchjob_ps_pg_batch_size__c= 25;
        Co1.batchjob_ps_pg_enable_schduled_job__c= true;
        Co1.batchjob_ps_pg_escape_user_settings_prof__c= 'Marketing Customer Community';
        Co1.batchjob_u2csync_batch_size__c= 100;
        Co1.batchjob_u2csync_enable_schduled_job__c= true;
        Co1.batchjob_u2csync_lkbk_time__c= 20;
        Co1.batchjob_u2csync_recur__c= 10;

        listCommunity_Settings.add(Co1);


        insert listCommunity_Settings;

        list<NPN_Tableau_UserMgmt__c> listNPN_Tableau_UserMgmt= new list<NPN_Tableau_UserMgmt__c> ();

        NPN_Tableau_UserMgmt__c NP1= new NPN_Tableau_UserMgmt__c ();
        NP1.setupownerid= UserInfo.getOrganizationId();
        NP1.siterole__c= 'Viewer';
        NP1.userlicense__c= 'Partner Community Login';
        NP1.contact_permission__c= 'NPN Compliance Tab';

        listNPN_Tableau_UserMgmt.add(NP1);


        insert listNPN_Tableau_UserMgmt;

        map<String, Id> mapProfNameId;
        Account partnerAcc;
        Contact partnerContact1,partnerContact2;
        User partnerUser1;
        String userName;

        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        //get All Profiles (PROF_PP_VGX_GENERIC = NPN Partner Community(LOGIN), PROF_INT_PARTNER_ADMIN = Sales Profile - Partner Admin)
        list<string> lstProfNames = new list<string> {COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN };
        mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);


        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){

            //Account partnerAcc = [SELECT Id, Name FROM Account WHERE Id = '0012200000MBJcb' LIMIT 1];

            //Create a NPN Account with Billing Country, Region
            partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', accRecTypeId);


            //Create a Partner Contact
            //partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com.invalid', contactRecTypeId, COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

            partnerContact1 = new Contact(
                LastName='LNameTest',
                FirstName='FContact11',
                AccountId=partnerAcc.Id,
                Email='drcontact@nv.com.invalid',
                RecordTypeId=contactRecTypeId,
                MailingStreet='The NVIDIA Way64731572844891211',
                MailingCity='Santa Clara',
                MailingState='California',
                MailingCountry='United States',
                MailingPostalCode='95050',
                Portal_Groups__c = 'NPN Compliance Tab;Submit POS;'
                );

            insert partnerContact1;

            partnerContact2 = new Contact(
                LastName='LNameTest',
                FirstName='FContact11',
                AccountId=partnerAcc.Id,
                Email='drcontactTwo@nv.com.invalid',
                RecordTypeId=contactRecTypeId,
                MailingStreet='The NVIDIA Way64731572844891211',
                MailingCity='Santa Clara',
                MailingState='California',
                MailingCountry='United States',
                MailingPostalCode='95050',
                Portal_Groups__c = 'Submit POS;'
                );

            insert partnerContact2;


            //Create a Partner User with profile named 'NPN Partner Community(LOGIN)'
            User comUser = new User(
                LastName='one',
                Alias = 'tsale',
                Email = 'nvpartnerone@foo.com.invalid',
                Username = 'nvvippartnerone@foo.com.crqext',
                CommunityNickname = 'nvvippartnerone',
                ProfileId = mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC),
                ContactId=partnerContact1.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Tableau_IsUserCreated__c = false,
                Tableau_Do_Not_Sync__c = false
                );
            insert comUser;

            User comUser2 = new User(
                LastName='one',
                Alias = 'tsale',
                Email = 'nvpartnerTwo@foo.com.invalid',
                Username = 'nvpartnerTwo@foo.com.crqext',
                CommunityNickname = 'nvpartnerTwo',
                ProfileId = mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC),
                ContactId=partnerContact2.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Tableau_IsUserCreated__c = false,
                Tableau_Do_Not_Sync__c = false
                );
            insert comUser2;

        }
    }

    
    
    @isTest
    static void testBatchClassSchedule(){

        Test.startTest();
        NPN_Tableau_UserMgmt_Bat_sch sch = new NPN_Tableau_UserMgmt_Bat_sch();
        string cronexp='0 0 * ? * * *';
        Id jobId = System.schedule('TableauUserCreationFromTEST',cronexp,sch);

        System.abortJob(jobId);
        Test.stopTest();

    }

    @isTest
    static void testBatchClassExecuteUserActive(){

        Test.setMock(HttpCalloutMock.class, new Mock());
        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' AND (Contact.Portal_Groups__c != null OR Contact.Portal_Groups__c != '') ];

        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        
        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
                             'xmlns="urn:partner.soap.sforce.com"' +
                             'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                             '<soapenv:Body>' +
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/Soap/u/10.0</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '<userInfo>' +
                             '<!-- ... -->' +
                             '</userInfo>' +
                             '</result>' +
                             '</loginResponse>' +
                             '</soapenv:Body>' +
                             '</soapenv:Envelope>';
        
        User admin = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(admin){
            Test.startTest();
            NPN_Tableau_UserMgmt_Bat_sch oNPNTableauUserMgtBAtchSch = new NPN_Tableau_UserMgmt_Bat_sch();


            oNPNTableauUserMgtBAtchSch.token  ='1pd0jXlNKOSU';
            oNPNTableauUserMgtBAtchSch.siteRole = 'Viewer';
            oNPNTableauUserMgtBAtchSch.siteId = 'testSiteId';

            oNPNTableauUserMgtBAtchSch.mapIDMResponseElements.put('iserror','false');
            system.debug('*** Active '+commUser);

            NPN_Tableau_UserMgmt__c objNPNTableauUser = NPN_Tableau_UserMgmt__c.getInstance();

            oNPNTableauUserMgtBAtchSch.portalPermissions = objNPNTableauUser.contact_permission__c;


            oNPNTableauUserMgtBAtchSch.execute(null, commUser);

            Test.stopTest();
        }
    }

    @isTest
    static void testBatchClassExecuteUserInactive(){
        Test.setMock(HttpCalloutMock.class, new Mock());        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvpartnerTwo@foo.com.crqext'
                                                                                                                                                          AND (Contact.Portal_Groups__c != null OR Contact.Portal_Groups__c != '')];

        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
                             'xmlns="urn:partner.soap.sforce.com"' +
                             'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                             '<soapenv:Body>' +
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/Soap/u/10.0</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '<userInfo>' +
                             '<!-- ... -->' +
                             '</userInfo>' +
                             '</result>' +
                             '</loginResponse>' +
                             '</soapenv:Body>' +
                             '</soapenv:Envelope>';
        User admin = [SELECT Id FROM User WHERE Profile.Name ='System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(admin){
            Test.startTest();
            NPN_Tableau_UserMgmt_Bat_sch oNPNTableauUserMgtBAtchSch = new NPN_Tableau_UserMgmt_Bat_sch();

            oNPNTableauUserMgtBAtchSch.token  ='1pd0jXlNKOSU';
            oNPNTableauUserMgtBAtchSch.siteRole = 'Viewer';
            oNPNTableauUserMgtBAtchSch.siteId = 'testSiteId';

            oNPNTableauUserMgtBAtchSch.mapIDMResponseElements.put('iserror','false');

            NPN_Tableau_UserMgmt__c objNPNTableauUser = NPN_Tableau_UserMgmt__c.getInstance();

            oNPNTableauUserMgtBAtchSch.portalPermissions = objNPNTableauUser.contact_permission__c;

            system.debug('*** Inactive '+commUser);
            oNPNTableauUserMgtBAtchSch.execute(null, commUser);

            Test.stopTest();
        }
    }


    @isTest
    static void testBatchClassFinish(){

        Test.setMock(HttpCalloutMock.class, new Mock());
        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];

        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
                             'xmlns="urn:partner.soap.sforce.com"' +
                             'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                             '<soapenv:Body>' +
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/Soap/u/10.0</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '<userInfo>' +
                             '<!-- ... -->' +
                             '</userInfo>' +
                             '</result>' +
                             '</loginResponse>' +
                             '</soapenv:Body>' +
                             '</soapenv:Envelope>';

        Test.startTest();        

        NPN_Tableau_UserMgmt_Bat_sch oNPNTableauUserMgtBAtchSch = new NPN_Tableau_UserMgmt_Bat_sch();

        oNPNTableauUserMgtBAtchSch.token  ='1pd0jXlNKOSU';
        oNPNTableauUserMgtBAtchSch.siteRole = 'Viewer';
        oNPNTableauUserMgtBAtchSch.siteId = 'testSiteId';

        oNPNTableauUserMgtBAtchSch.mapIDMResponseElements.put('iserror','false');


        oNPNTableauUserMgtBAtchSch.lstFailureUsers = new List<NPN_Tableau_UserMgmt_Bat_sch.UserFailure>();
        oNPNTableauUserMgtBAtchSch.lstFailureUsers.add(new NPN_Tableau_UserMgmt_Bat_sch.UserFailure(commUser[0],'test Error' ));

        oNPNTableauUserMgtBAtchSch.finish(null);

        Test.stopTest();
    }

    @isTest
    static void testBtachClassStart(){

        Test.setMock(HttpCalloutMock.class, new Mock());
        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];

        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
                             'xmlns="urn:partner.soap.sforce.com"' +
                             'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                             '<soapenv:Body>' +
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/Soap/u/10.0</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '<userInfo>' +
                             '<!-- ... -->' +
                             '</userInfo>' +
                             '</result>' +
                             '</loginResponse>' +
                             '</soapenv:Body>' +
                             '</soapenv:Envelope>';
        Test.startTest();
       
        NPN_Tableau_UserMgmt_Bat_sch oNPNTableauUserMgtBAtchSch = new NPN_Tableau_UserMgmt_Bat_sch();

        Database.QueryLocator qlObj = oNPNTableauUserMgtBAtchSch.start(null);

        Test.stopTest();
    }


    @isTest
    static void syncWithTableauTest(){

        Test.setMock(HttpCalloutMock.class, new Mock());
        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];
        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<root>' +
                             '<element>' +
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '<userInfo>' +
                             '<!-- ... -->' +
                             '</userInfo>' +
                             '</result>' +
                             '</loginResponse>' +
                             '</element>' +
                             '</root>';

        String newUser = 'testUser';
        String siteRole = 'Viewer';
        String token  ='dptjyeVTXpcJH8B6A6EJtNf0';
        String siteId = 'dptjyeVTXpcJH8B6A6EJtNf0';

        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> newResponseMap = new Map<String, String>();

        Test.startTest();

        /*NPN_Tableau_UserMgmt_Bat_sch.token  ='dptjyeVTXpcJH8B6A6EJtNf0';
           NPN_Tableau_UserMgmt_Bat_sch.siteRole = 'Viewer';
           NPN_Tableau_UserMgmt_Bat_sch.siteId = 'testSiteId';*/

        //NPN_Tableau_Wrapper.syncWithTableau('testUser', 'Viewer');
        newResponseMap = NPN_Tableau_Wrapper.createTableauUser(newUser, siteRole, siteId, responseMap, token );

        Test.stopTest();
    }

    @isTest
    static void createTableauUserTest(){

        Test.setMock(HttpCalloutMock.class, new Mock());
        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];
        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<root>'+
                             '<element>'+
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '</result>'+
                             '</loginResponse>' +
                             '</element>' +
                             '<element>'+
                             '<tsRequest>'+
                             '<user name="testUser" siteRole="Viewer" authSetting="SAML"/>'+
                             '</tsRequest>'+
                             '</element>' +
                             '</root>';
      
        String newUser = 'testUser';
        String siteRole = 'Viewer';
        String token  ='dptjyeVTXpcJH8B6A6EJtNf0';
        String siteId = 'dptjyeVTXpcJH8B6A6EJtNf0';

        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> newResponseMap = new Map<String, String>();
        
        Test.startTest();

        newResponseMap = NPN_Tableau_Wrapper.createTableauUser(newUser, siteRole, siteId, responseMap, token );

        Test.stopTest();
    }


    @isTest
    static void getTableauUserIdrTest(){

        Test.setMock(HttpCalloutMock.class, new Mock());    
        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];
        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<root>'+
                             '<element>'+
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '</result>'+
                             '</loginResponse>' +
                             '</element>' +
                             '<element>'+
                             '<tsRequest>'+
                             '<user name="testUser" siteRole="Viewer" authSetting="SAML"/>'+
                             '</tsRequest>'+
                             '</element>' +
                             '</root>';
        
        String newUser = 'testUser';
        String siteRole = 'Viewer';
        String token  ='dptjyeVTXpcJH8B6A6EJtNf0';
        String siteId = 'dptjyeVTXpcJH8B6A6EJtNf0';

        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> newResponseMap = new Map<String, String>();


        responseMap.put('paginationtotalAvailable', '1');

        Test.startTest();

        newResponseMap = NPN_Tableau_Wrapper.getTableauUserId(newUser, siteId, responseMap, token );

        Test.stopTest();
    }



    @isTest
    static void removeTableauUserTest(){

        Test.setMock(HttpCalloutMock.class, new Mock());
        
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];
        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<root>'+
                             '<element>'+
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '</result>'+
                             '</loginResponse>' +
                             '</element>' +
                             '<element>'+
                             '<tsRequest>'+
                             '<user name="testUser" siteRole="Viewer" authSetting="SAML"/>'+
                             '</tsRequest>'+
                             '</element>' +
                             '</root>';
                             
       
        String newUser = 'testUser';
        String siteRole = 'Viewer';
        String token  ='dptjyeVTXpcJH8B6A6EJtNf0';
        String siteId = 'dptjyeVTXpcJH8B6A6EJtNf0';

        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> newResponseMap = new Map<String, String>();


        responseMap.put('paginationtotalAvailable', '1');

        Test.startTest();
      
        newResponseMap = NPN_Tableau_Wrapper.removeTableauUser(newUser, siteId, responseMap, token );
        Test.stopTest();

    }

    @isTest
    static void signInTest(){
        
        Test.setMock(HttpCalloutMock.class, new Mock());
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];
        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<root>'+
                             '<element>'+
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '</result>'+
                             '</loginResponse>' +
                             '</element>' +
                             '<element>'+
                             '<tsRequest>'+
                             '<user name="testUser" siteRole="Viewer" authSetting="SAML"/>'+
                             '</tsRequest>'+
                             '</element>' +
                             '</root>';
                             
        String newUser = 'testUser';
        String siteRole = 'Viewer';
        String token  ='dptjyeVTXpcJH8B6A6EJtNf0';
        String siteId = 'dptjyeVTXpcJH8B6A6EJtNf0';

        Map<String, String> responseMap = new Map<String, String>();
        Map<String, String> newResponseMap = new Map<String, String>();


        responseMap.put('paginationtotalAvailable', '1');

        Test.startTest();
        newResponseMap = NPN_Tableau_Wrapper.signIn( responseMap );
        Test.stopTest();
    }

    @isTest
    static void signoutTest(){

        Test.setMock(HttpCalloutMock.class, new Mock());
        makeData();

        List<User> commUser = [SELECT Id,Name, email, username, IsActive, Contact.Portal_Groups__c, ContactId, Tableau_IsUserCreated__c, Tableau_IsUserDeleted__c,
                               Tableau_UserCreationDateTime__c, Tableau_UserCreationLastAPICallResponse__c, Tableau_UserDeletionDateTime__c, Tableau_UserDeletionLastAPICallResponse__c,
                               Tableau_UserId__c, Tableau_Username__c, Tableau_Do_Not_Sync__c, Tableau_API_Response_Failure__c FROM USER WHERE UserName = 'nvvippartnerone@foo.com.crqext' ];
        Map<String,String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'text/xml; charset=utf-8');

        sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
                             '<root>'+
                             '<element>'+
                             '<loginResponse>' +
                             '<result>' +
                             '<passwordExpired>false</passwordExpired>' +
                             '<serverUrl>https://na1.salesforce.com/services/</serverUrl>' +
                             '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
                             '<userId>'+commUser[0].Id+'</userId>' +
                             '</result>'+
                             '</loginResponse>' +
                             '</element>' +
                             '<element>'+
                             '<tsRequest>'+
                             '<user name="testUser" siteRole="Viewer" authSetting="SAML"/>'+
                             '</tsRequest>'+
                             '</element>' +
                             '</root>';
               
        String token  ='dptjyeVTXpcJH8B6A6EJtNf0';      
        
        Test.startTest();
        NPN_Tableau_Wrapper.signout(token );
        Test.stopTest();

    }
    
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('https://nvidiacorporation')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('<?xml version="1.0" encoding="UTF-8"?>'+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
           '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
           '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage>'+
           '</ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
           '<ax21:syncType>PartnerUser</ax21:syncType></ns:return>'+
           '</ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>');
                res.setStatusCode(200);
                
                return res;
            } else {
                HTTPResponse res = new HTTPResponse();
                res.setBody(NPN_Tableau_UserMgmt_Bat_sch_Test.sessionBody);
                res.setHeader('Content-Type', 'text/xml; charset=utf-8');
                res.setStatusCode(200);
                return res;
                
            }
        }
    }
}