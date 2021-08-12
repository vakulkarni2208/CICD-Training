/**
 * Test class for NPN_WidenPageRedirect_Ctrl
 */
@isTest(seeAllData=false)
private class NPN_WidenPageRedirect_Ctrl_Test{

    static User contextUser;

    static void setupData(){

        map<String, Id> mapProfNameId;
        Account partnerAcc;
        Contact partnerContact1;
        User partnerUser1;
        Id accRecTypeId;
        Id contactRecTypeId;
        String userName;

        accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        //get All Profiles (PROF_PP_VGX_GENERIC = NPN Partner Community(LOGIN), PROF_INT_PARTNER_ADMIN = Sales Profile - Partner Admin)
        list<string> lstProfNames = new list<string> {COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN };
        mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);

        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', accRecTypeId);

        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        partnerAcc.EMS_Update_Required__c= false;
        update partnerAcc;

        //Create a Partner Contact
        partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com', contactRecTypeId, COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        NPN_Widen_Role_Mapping__c wrmObj = new NPN_Widen_Role_Mapping__c ( Name ='All Partner Content', Widen_Role__c ='NPN All Partner Content'
        );
        insert wrmObj;

        //Create a Partner User with profile named 'NPN Partner Community(LOGIN)'
        User comUser = new User(
          LastName='one',
          Alias = 'tsale',
          Email = 'nvpartnerone@foo.com',
          Username = 'nvvippartnerone@foo.com.crqext',
          CommunityNickname = 'nvvippartnerone',
          ProfileId = mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC),
          ContactId=partnerContact1.Id,
          TimeZoneSidKey = 'America/Los_Angeles',
          LocaleSidKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US'
          );
        insert comUser;
    }
    
    
    @isTest static void widenOneTest(){
        setupData();
        contextUser = [SELECT Id, Email, ContactId, AccountId FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];
        
        Contact pContact = new Contact( Id = contextUser.ContactId, Portal_Groups__c = 'All Partner Content;');
        update pContact;
        
        system.RunAs(contextUser){
            test.startTest();
            PageReference pageRef = Page.NPN_WidenRedirectPage;
            
            pageRef.getParameters().put('redirect_url', '/search/pf:quadro%20or%20tesla%20or%20vgpu');
            Test.setCurrentPage(pageRef);
                    
            NPN_WidenPageRedirect_Ctrl controllerExt = new NPN_WidenPageRedirect_Ctrl();
            PageReference pageRefRet1 = controllerExt.redirect();
          test.stopTest();
        }
    }
    
    @isTest static void widenTwoTest(){
        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        
        
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        setupData();
        contextUser = [SELECT Id, Email, ContactId, AccountId FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];
        
        Contact pContact = new Contact( Id = contextUser.ContactId, Portal_Groups__c = 'Manage Contacts');
        update pContact;
        
        system.RunAs(contextUser){
            test.startTest();
            PageReference pageRef = Page.NPN_WidenRedirectPage;
            
            pageRef.getParameters().put('redirect_url', '/search/pf:quadro%20or%20tesla%20or%20vgpu');
            Test.setCurrentPage(pageRef);
                    
            NPN_WidenPageRedirect_Ctrl controllerExt = new NPN_WidenPageRedirect_Ctrl();            

            PageReference pageRefRet1 = controllerExt.redirect();
            PageReference pageRefRet2 = controllerExt.closePopup();
          test.stopTest();
        }
    }
}