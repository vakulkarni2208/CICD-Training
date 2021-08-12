@isTest(seeAllData=false)
private class NPN_NFR_SendDocusignCtrl_Test {

  static void makeData(){
    
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
    system.debug('***partnerAcc: ' + partnerAcc);


    //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
    partnerAcc.IsPartner = true;
    update partnerAcc;

    //Create a Partner Contact
    partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com', contactRecTypeId, COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

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

    NFR_Software_Licence__c sobj = new NFR_Software_Licence__c(
      Name = 'NFR_Order Agreement for EULA February 2019',         // DocuSign Template Name
      DocuSIgn_Template_ID__c = '41754ecb-47aa-42dc-9b1d-142925ef2278'         // DocuSIgn Template ID
      );
    insert sobj;

    NPN_NFR_Software_Request__c requestOne = new NPN_NFR_Software_Request__c();
    requestOne.Email__c =   comUser.Email;
    requestOne.Status__c =  'Approved';
    requestOne.Company_Name__c = partnerAcc.Id;
    requestOne.Requested_By__c = comUser.ContactId;
    requestOne.Comments_From_PBM__c = 'Test Comment';
    requestOne.DocuSign_Enevelop_ID__c = '1D40F498-557E-41D8-969F-F091A64F41BD';
    insert requestOne;

    NPN_NFR_Software__c swRequestOne = new NPN_NFR_Software__c();
    swRequestOne.Software__c = 'VDWS';
    swRequestOne.Quantity__c =  2;
    swRequestOne.Comments__c = 'test comment';
    swRequestOne.NPN_NFR_Software_Request__c = requestOne.id;
    insert swRequestOne;

    NPN_NFR_Software__c swRequestTwo = new NPN_NFR_Software__c();
    swRequestTwo.Software__c = 'VPC';
    swRequestTwo.Quantity__c =  5;
    swRequestTwo.Comments__c = 'test comment';
    swRequestTwo.NPN_NFR_Software_Request__c = requestOne.id;
    insert swRequestTwo;

    NPN_NFR_Software__c swRequestThree = new NPN_NFR_Software__c();
    swRequestThree.Software__c = 'VCS';
    swRequestThree.Quantity__c =  5;
    swRequestThree.Comments__c = 'test comment';
    swRequestThree.NPN_NFR_Software_Request__c = requestOne.id;
    insert swRequestThree;
  }

  @isTest static void docuSignTest1(){
      
    genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
    
    

    test.startTest();
    System.Test.setMock(HttpCalloutMock.class, fakeResp);
    
    makeData();
    
    NPN_NFR_Software_Request__c requestOne = [SELECT Id, Name FROM NPN_NFR_Software_Request__c LIMIT 1];
    
    PageReference pageRef = Page.NPN_NFR_SendDocusignPage;
    Test.setCurrentPageReference(pageRef);
    ApexPages.currentPage().getParameters().put('id',requestOne.Id);
    NPN_NFR_SendDocusignCtrl controllerExt = new NPN_NFR_SendDocusignCtrl( new ApexPages.StandardController(requestOne));
    //controllerExt.approveRequest();

    test.stopTest();

  }
}