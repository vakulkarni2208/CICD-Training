@isTest(seeAllData=false)
public class NPN_Test_SubmitPosReminder_Batch {

@TestSetup
static void makeData(){
    Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
    Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

    Profile sysAdmin = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    Profile partnerProf = [SELECT Id, Name FROM Profile WHERE Name = :COMM_Constants.PROF_PP_TPP_GENERIC LIMIT 1];
    
    List<Account> listAccounts = new List<Account>();
    List<Contact> listContacts = new List<Contact>();
    List<User> listUsers = new List<User>();

    for(Integer i=0; i<=2; i++) {
        listAccounts.add(
            new Account(
                Name                        = 'TestAcct'+i,
                RecordTypeId                = accRecTypeId,
                NPN_Program_Signed_Date__c  = Date.valueOf(System.today().addMonths(-3)),
                POS_Reporter_ID__c          = 'ABCD'+i
                )
            );
    }
    insert listAccounts;

    list<Partner_Attribute__c> partnerAttrbList = new List<Partner_Attribute__c>();


    if(!listAccounts.isEmpty()) {
        for(Integer i=0; i<=2; i++) {
            Contact cont = new Contact();
            cont.FirstName      =   'Jake';
            cont.LastName       =   'Paul'+i;
            cont.Email          =   'jake.paul_'+listAccounts[i].Name+'@abc.com';
            cont.Phone          =   '789-978-5529';
            cont.AccountId      =   listAccounts[i].Id;
            cont.Role__c        =   'POS;Partner Primary Contact';
            cont.RecordTypeId   =   contactRecTypeId;

            Contact cont2 = new Contact();
            cont2.FirstName      =   'Jake';
            cont2.LastName       =   'Paul2'+i;
            cont2.Email          =   'jake.paul2_'+listAccounts[i].Name+'@abc.com';
            cont2.Phone          =   '789-978-5523';
            cont2.AccountId      =   listAccounts[i].Id;
            cont2.Role__c        =   'POS';
            cont2.RecordTypeId   =   contactRecTypeId;

            listContacts.add(cont);
            listContacts.add(cont2);

            Partner_Attribute__c pAttrb = new Partner_Attribute__c(
                Account_Name__c  =  listAccounts[i].Id,
                Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
                Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
                Partner_Sub_Program__c ='',
                Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
                ATP_Partner__c = true,
                ATP_Partner_Termination_Date__c = null,
                Date_Competency_Terminated__c = null,
                Exempted_from_POS_Submission__c = false,
                ATP_Partner_Start_Date__c = Date.valueOf(system.today())
                );
            partnerAttrbList.add(pAttrb);

            Partner_Attribute__c pAttrb2 = new Partner_Attribute__c(
                Account_Name__c  =  listAccounts[i].Id,
                Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_PV,
                Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
                Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
                ATP_Partner_Termination_Date__c = null,
                Date_Competency_Terminated__c = null,
                Exempted_from_POS_Submission__c = false,
                ATP_Partner_Start_Date__c = Date.valueOf(system.today())
                );
            partnerAttrbList.add(pAttrb2);
        }
    }

    if(!partnerAttrbList.isEmpty()) {
        insert partnerAttrbList;
    }

    if(!listContacts.isEmpty()) {
        Database.SaveResult[] srList = database.insert(listContacts, false);
        System.debug('--> listContacts '+ listContacts);
        System.debug('--> srList '+ srList);

        for(Contact contVar : listContacts) {
            User comUser = new User(
                LastName        =       contVar.LastName,
                Alias   = contVar.LastName,
                Email = contVar.Email,
                Username = contVar.Email+'.crqext',
                CommunityNickname = contVar.LastName+'nvvippartnerone',
                ProfileId = partnerProf.Id,
                ContactId=contVar.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                IsActive = true
                );
            listUsers.add(comUser);
        }
    }

    if(!listUsers.isEmpty()) {
        Database.SaveResult[] srList = database.insert(listUsers, false);
        System.debug('--> listUsers '+ listUsers);
        System.debug('--> srList '+ srList);

        List<Contact> updateContacts = new List<Contact>();

        for(User comUsr :listUsers) {
            Contact cont1 = new Contact();
            cont1.Id = comUsr.ContactId;
            cont1.Community_User__c = comUsr.Id;
            updateContacts.add(cont1);
        }

        if(!updateContacts.isEmpty()) {
            Database.SaveResult[] srUpdateList = database.update(updateContacts, false);
            System.debug('--> updateContacts '+ updateContacts);
            System.debug('--> srUpdateList '+ srUpdateList);
        }
    }
}

@isTest
static void batchTestMethod() {

    Id ptnrContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

    List<Contact> contactList = [SELECT Id, Email, Name, Account.name, Role__c, Community_User__c, Community_User_Active__c FROM Contact /*WHERE RecordTypeId = : ptnrContRecTypeId AND Community_User_Active__c = true AND Role__c INCLUDES ('POS ','Partner Primary Contact ')*/];

    System.debug('--> ** contactList '+contactList);

    Map<String, String> posNotifyDataMap = new Map<String, String>();
    for(NPN_POS_Notify_Data__mdt pndObj : [SELECT Id, DeveloperName, Value__c FROM NPN_POS_Notify_Data__mdt]) {
        posNotifyDataMap.put(pndObj.DeveloperName, pndObj.Value__c);
    }

    Integer batchSize = Integer.ValueOf(posNotifyDataMap.get('Batch_Size') != null ? Integer.ValueOf(posNotifyDataMap.get('Batch_Size')) : 50);
    String jobId = '';

    Test.StartTest();

    NPN_SubmitPosReminder_Batch batchName = new NPN_SubmitPosReminder_Batch();
    jobId = Database.executeBatch(batchName,batchSize);

    Test.StopTest();

    System.assertNotEquals(null, jobId,'Did not get the same Cron Expression back');
    System.debug('--> jobId '+jobId);
}

@isTest
static void batchTestMethodTwo() {

    Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();

    List<POS_Notification_History__c> posNHObjList = new List<POS_Notification_History__c>();

    for(Account act : [SELECT Id, Name FROM Account WHERE RecordTypeId = : accRecTypeId AND NPN_Program_Termination_Date__c = NULL AND Inactive__c = FALSE AND POS_Portal_Submission__c = true]) {
        POS_Notification_History__c pObj = new POS_Notification_History__c();
        pObj.Account__c = act.Id;
        posNHObjList.add(pObj);
    }

    insert posNHObjList;

    Map<String, String> posNotifyDataMap = new Map<String, String>();
    for(NPN_POS_Notify_Data__mdt pndObj : [SELECT Id, DeveloperName, Value__c FROM NPN_POS_Notify_Data__mdt]) {
        posNotifyDataMap.put(pndObj.DeveloperName, pndObj.Value__c);
    }

    Integer batchSize = Integer.ValueOf(posNotifyDataMap.get('Batch_Size') != null ? Integer.ValueOf(posNotifyDataMap.get('Batch_Size')) : 50);
    String jobId = '';

    Test.StartTest();

    NPN_SubmitPosReminder_Batch batchName = new NPN_SubmitPosReminder_Batch();
    jobId = Database.executeBatch(batchName,batchSize);

    Test.StopTest();

    System.assertNotEquals(null, jobId,'Did not get the same Cron Expression back');
    System.debug('--> jobId '+jobId);
}

@isTest
static void scheduleTestMethod(){

    Map<String, String> posNotifyDataMap = new Map<String, String>();
    for(NPN_POS_Notify_Data__mdt pndObj : [SELECT Id, DeveloperName, Value__c FROM NPN_POS_Notify_Data__mdt]) {
        posNotifyDataMap.put(pndObj.DeveloperName, pndObj.Value__c);
    }

    String cronexp = String.isNotBlank(posNotifyDataMap.get('Cron_Expression')) ? posNotifyDataMap.get('Cron_Expression') : '0 0 0 11,21 * ? *';

    Test.StartTest();

    NPN_SubmitPosReminder_Batch sch = new NPN_SubmitPosReminder_Batch();
    String jobId = System.schedule('NPN_SubmitPosReminder_Batch',cronexp,sch);

    CronTrigger ct = [SELECT CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = : jobId];

    Test.StopTest();

    System.assertEquals(posNotifyDataMap.get('Cron_Expression'), ct.CronExpression,'Did not get the same Cron Expression back');
    System.assertEquals(0, ct.TimesTriggered,'The job has been run and should not have');
}
}