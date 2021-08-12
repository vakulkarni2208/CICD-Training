@isTest(SeeAllData=false)
private class NV_Test_CommunityLoginController{
    
    @testSetup
    static void makeData(){
        NV_NPN_TestDataFactory.setupCustomSettings(); 
        
        User usr, usr1;
        Id accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PartnerAccount').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Profile communityProfile = [SELECT Id,Name,UserLicense.Name FROM Profile WHERE UserLicense.Name = 'Overage Customer Portal Manager Custom' AND Name ='Community Lite Profile' LIMIT 1];

        Account acc = new Account();
        acc.name = 'abcd1234';
        acc.RecordTypeId = accRecTypeId;        
        insert acc;
           
        Contact con = new Contact();
        con.firstName = 'mike';
        con.lastName = 'Ross';
        con.email = 'mike.ross@asdf.com';
        con.accountId = acc.id;
        con.RecordTypeId = contactRecTypeId;
        insert con;
        
        
        usr = new User();
        usr.LastName = 'Ross';
        usr.FirstName='mike';
        usr.Alias = 'mross';
        usr.Email = 'mike.ross@asdf.com';
        usr.Username = 'mike.ross1@asdf.com';
        usr.ProfileId = communityProfile.Id;
        usr.TimeZoneSidKey = 'GMT';
        usr.LanguageLocaleKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LocaleSidKey = 'en_US';
        usr.ContactId = con.id;
        insert usr;        
        System.setPassword(usr.id, 'abcdef@123');
    }
    
    
    static testmethod void testSiteSuccessfulLoginController (){
        
        Id accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PartnerAccount').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Profile communityProfile = [SELECT Id,Name,UserLicense.Name FROM Profile WHERE UserLicense.Name = 'Overage Customer Portal Manager Custom' AND Name ='Community Lite Profile' LIMIT 1];

        Account acc = new Account();
        acc.name = 'efgh1234';
        acc.RecordTypeId = accRecTypeId;        
        insert acc;
        
        Contact con1 = new Contact();
        con1.firstName = 'Harvey';
        con1.lastName = 'Specter';
        con1.email = 'harvey.specter@asdf.com';
        con1.accountId = acc.id;
        con1.RecordTypeId = contactRecTypeId;
        insert con1;
        
        User usr1 = new User();
        usr1.LastName = 'Harvey';
        usr1.FirstName='Specter';
        usr1.Alias = 'hspec';
        usr1.Email = 'mike.ross@asdf.com';
        usr1.Username = 'harvey.specter1@asdf.com';
        usr1.ProfileId = communityProfile.Id;
        usr1.TimeZoneSidKey = 'GMT';
        usr1.LanguageLocaleKey = 'en_US';
        usr1.EmailEncodingKey = 'UTF-8';
        usr1.LocaleSidKey = 'en_US';
        usr1.ContactId = con1.id;
        insert usr1;
        
        System.setPassword(usr1.id, 'abcdef@123');

        // Instantiate a new controller with all parameters in the page        
        NV_CommunityLoginController controller = new NV_CommunityLoginController();                
        NV_CommunityLoginController.login(usr1.Email,'abcdef@123','','');                           
    }
    
    static testmethod void testSiteLoginController (){
        // Instantiate a new controller with all parameters in the page
        NV_CommunityLoginController controller = new NV_CommunityLoginController();                
        NV_CommunityLoginController.login('mike.ross1@asdf.com','abcdef@123','','');                           
    }
    
    static testmethod void testSiteIncorrectLoginController (){
        // Instantiate a new controller with all parameters in the page
        NV_CommunityLoginController controller = new NV_CommunityLoginController();                
        NV_CommunityLoginController.login(Label.PortalUserName,'123456','','');                           
    }
    
    static testmethod void testIsNotAnUser (){
        // Instantiate a new controller with all parameters in the page
        NV_CommunityLoginController controller = new NV_CommunityLoginController();                
        NV_CommunityLoginController.login('vakulkarni@nvidia.com','123456','','');                           
    }
}