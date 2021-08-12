@isTest(seeAllData=false)
private class NV_Test_LtngCommunityHomePageController {

@TestSetup
static void makeData(){

    Id accRT= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
    Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

    Account accSobj = new Account(
        Name = 'AddOnTesting',
        Phone = '922497367',
        NPN_Program_Signed_Date__c = Date.valueOf(system.today()),
        Inactive__c = false,
        Approved__c = false,
        //Account_Email__c = 'pardeshiakash143@gmail.com.invalid',
        MDF_Program_Active__c = false,
        RecordTypeId = accRT
        );
    insert accSobj;

    Contact contact1 = new Contact();
    contact1.FirstName      =   'partner';
    contact1.LastName       =   'one';
    contact1.Email          =   'nvpartnerone@foo.com';
    contact1.Phone          =   '789-978-5529';
    contact1.AccountId      =   accSobj.Id;
    contact1.Role__c        =   'Partner Primary Contact';
    contact1.Portal_User_Content_Type__c = '';
    contact1.portal_groups__c = 'SP Tesla Preferred';
    contact1.RecordTypeId   =   contactRecTypeId;
    insert contact1;

    List<Profile> comntyProfileList = [SELECT Id FROM Profile WHERE Name = 'NPN Partner Community(LOGIN)'];
    User comUser = new User(
        LastName='one',
        Alias = 'tsale',
        Email = 'nvpartnerone@foo.com',
        Username = 'nvvippartnerone@foo.com.crqext',
        CommunityNickname = 'nvvippartnerone',
        ProfileId = comntyProfileList[0].Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        IsActive = true,
        ContactId = contact1.Id
        );
    insert comUser;

    Competency_Data__c compObj = new Competency_Data__c(
        Name = 'HEALTHCARE', // Competency Data Name
        Partner_Home_Page_Image__c = '\n', // Partner Home Page Image
        Static_Resource_Image_Path__c = 'DL', // Static Resource Image Path
        Vertical_Competency__c = true // Vertical Competency
        );
    insert compObj;

    Competency_Data__c compObj1 = new Competency_Data__c(
        Name = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,         // Competency Data Name
        Partner_Home_Page_Image__c = '\n',         // Partner Home Page Image
        Static_Resource_Image_Path__c = 'DL',         // Static Resource Image Path
        Vertical_Competency__c = true         // Vertical Competency
        );
    insert compObj1;

    Partner_Attribute__c paObj = new Partner_Attribute__c(
        Account_Name__c= accSobj.Id,
        Partner_Competency__c = 'HEALTHCARE',
        Partner_Program_Name__c = 'Solution Provider', // Partner Program Name
        Program_Level__c = 'Elite', // Program Level
        Date_Competency_Signed__c = Date.valueOf(system.today()), // Date Competency Signed
        Exempted_from_POS_Submission__c = false
        );
    insert paObj;

    Partner_Attribute__c paObj1 = new Partner_Attribute__c(
        Account_Name__c= accSobj.Id,
        Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
        Partner_Program_Name__c = 'Solution Provider',         // Partner Program Name
        Program_Level__c = 'Elite',         // Program Level
        Date_Competency_Signed__c = Date.valueOf(system.today()),         // Date Competency Signed
        Exempted_from_POS_Submission__c = false
        );
    insert paObj1;

    List<NPN_Community_Home_Page_Link__c> homePageList = new List<NPN_Community_Home_Page_Link__c>();
    NPN_Community_Home_Page_Link__c chplObj1 = new NPN_Community_Home_Page_Link__c();
    chplObj1.Link_Label__c = 'Ops Reg';
    chplObj1.Link_Type__c='Dashboard';
    chplObj1.Link_URL__c ='/NV_DR_Pipeline_PendingApproval ? sfdc.tabName=01r1W000000AGSC';
    chplObj1.Button_Label__c = 'REGISTER A DEAL';
    chplObj1.Button_Link__c='/apex/DR_CreateDR';
    chplObj1.Has_Button__c=true;
    chplObj1.order__c=4;
    chplObj1.CustomPermissionName__c='DealRegForCommunityHomePage';

    homePageList.add(chplObj1);

    NPN_Community_Home_Page_Link__c chplObj2 = new NPN_Community_Home_Page_Link__c(
        Link_Type__c = 'Header', // Link Type
        Link_Label__c = 'SALES TOOLS', // Link Label
        Link_URL__c = '/apex/NV_PartnerCommunityTabs?tab=Sales', // Link URL
        Order__c = 4,      // Order
        Has_Button__c = false, // Has Button
        Open_For_All__c = true, // Open For All
        CustomPermissionName__c = 'SalesTabForCommunityHomePage' // CustomPermissionName
        );
    homePageList.add(chplObj2);

    NPN_Community_Home_Page_Link__c chplObj3 = new NPN_Community_Home_Page_Link__c(
        Link_Type__c = 'Header', // Link Type
        Link_Label__c = 'SUPPORT', // Link Label
        Link_URL__c = '/apex/NV_PartnerCommunityTabs?tab=Support', // Link URL
        Order__c = 1,        // Order
        Has_Button__c = false, // Has Button
        Open_For_All__c = true, // Open For All
        CustomPermissionName__c = 'SupportTabForCommunityHomePage' // CustomPermissionName
        );
    homePageList.add(chplObj3);

    NPN_Community_Home_Page_Link__c chplObj4 = new NPN_Community_Home_Page_Link__c(
        Link_Type__c = 'Dashboard', // Link Type
        Link_Label__c = 'GPU Genius Training', // Link Label
        Link_URL__c = '/apex/NV_PartnerCommunityTabs?tab=Training', // Link URL
        Order__c = 1,        // Order
        Has_Button__c = false, // Has Button
        Open_For_All__c = false, // Open For All
        CustomPermissionName__c = 'TrainingForCommunityHomePage' // CustomPermissionName
        );
    homePageList.add(chplObj4);

    NPN_Community_Home_Page_Link__c chplObj5 = new NPN_Community_Home_Page_Link__c(
        Link_Type__c = 'Header', // Link Type
        Link_Label__c = 'GPU GENIUS TRAINING', // Link Label
        Link_URL__c = '/apex/NV_PartnerCommunityTabs?tab=Training', // Link URL
        Order__c = 2,        // Order
        Has_Button__c = false, // Has Button
        Open_For_All__c = true, // Open For All
        CustomPermissionName__c = 'GPUTabForCommunityHomePage' // CustomPermissionName
        );
    homePageList.add(chplObj5);

    NPN_Community_Home_Page_Link__c chplObj6 = new NPN_Community_Home_Page_Link__c(
        Link_Type__c = 'Dashboard', // Link Type
        Link_Label__c = 'Leads', // Link Label
        Link_URL__c = '/00Q/o', // Link URL
        Order__c = 2,   // Order
        Has_Button__c = false, // Has Button
        Open_For_All__c = false, // Open For All
        CustomPermissionName__c = 'LeadsForCommunityHomePage' // CustomPermissionName
        );
    homePageList.add(chplObj6);

    insert homePageList;

    List<NPN_Community_Home_Page_Message__c> listPortalMsg = new List<NPN_Community_Home_Page_Message__c>();
    for(Integer i=0; i<6; i++) {
        NPN_Community_Home_Page_Message__c mgsobj = new NPN_Community_Home_Page_Message__c(
            Portal_Message__c = 'Submit your POS using the POS Submission link in the my dashboard section !', portal_groups__c = 'SP Virtualization Preferred'
            );
        listPortalMsg.add(mgsobj);
    }

    insert listPortalMsg;
}

@isTest
static void homePageTestOne(){
    NV_LightningCommunityHomePageController lchpObj = new NV_LightningCommunityHomePageController();
    NV_LightningCommunityHomePageController.InitializationData hpiObj = new NV_LightningCommunityHomePageController.InitializationData();

    List<NV_LightningCommunityHomePageController.HomePageLinks> linkList = new List<NV_LightningCommunityHomePageController.HomePageLinks>();

    User u = [SELECT Id, Name FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
    Test.StartTest();
    System.runAs(u){
        linkList = NV_LightningCommunityHomePageController.getHomePageLinks(u);
    }
    Test.StopTest();
}

@isTest
static void homePageTestTwo(){

    User u = [SELECT Id, Name FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
    Test.StartTest();
    System.runAs(u){

        User u1 = NV_LightningCommunityHomePageController.getUserInfo();
        String baseUrl = NV_LightningCommunityHomePageController.getBaseUrl();
        List<NV_LightningCommunityHomePageController.HomePageMessage> homepageMsgList= NV_LightningCommunityHomePageController.getHomePageMessages(u1);
        //List<Competency_Data__c> comptencyDataList = NV_LightningCommunityHomePageController.getCompetencyData();
        List<Competency_Data__c> comptencyDataList = NV_LightningCommunityHomePageController.getCompetencyData(u1);

        boolean boo = NV_LightningCommunityHomePageController.hasIndustryCompetency(comptencyDataList,u1);
    }
    Test.stopTest();
}

@isTest
static void homePageTestThree(){

    User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
    Test.StartTest();
    System.runAs(u){

        User u1 = NV_LightningCommunityHomePageController.getUserInfo();
        String baseUrl = NV_LightningCommunityHomePageController.getBaseUrl();
        List<NV_LightningCommunityHomePageController.HomePageMessage> homepageMsgList= NV_LightningCommunityHomePageController.getHomePageMessages(u1);
        //List<Competency_Data__c> comptencyDataList = NV_LightningCommunityHomePageController.getCompetencyData();
        List<Competency_Data__c> comptencyDataList = NV_LightningCommunityHomePageController.getCompetencyData(u1);

        NV_LightningCommunityHomePageController.InitializationData initObj = new NV_LightningCommunityHomePageController.InitializationData();
        initObj = NV_LightningCommunityHomePageController.getInitializationData();

        NV_LightningCommunityHomePageController.PartnerPerformanceScorecard ppObj = new NV_LightningCommunityHomePageController.PartnerPerformanceScorecard();
        ppObj = NV_LightningCommunityHomePageController.PartnerPerformanceScorecard.loadPartnerScorecard(u);
    }
    Test.stopTest();
}
}