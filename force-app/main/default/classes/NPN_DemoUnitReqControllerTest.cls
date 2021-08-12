/*
 * @name       NPN_DemoUnitReqControllerTest
 * @description   Test class for NPN_DemoUnitReqController
 * @author       Rajat Kamble
 */
@isTest(seeAllData=false)
private class NPN_DemoUnitReqControllerTest {


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

		NPN_NFR_Software_Request__c requestOne = new NPN_NFR_Software_Request__c();
		requestOne.Email__c =   comUser.Email;
		requestOne.Status__c =  'Pending';
		requestOne.Company_Name__c = partnerAcc.Id;
		requestOne.Requested_By__c = comUser.ContactId;
		requestOne.Comments_From_PBM__c = 'Test Comment';
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
	}

	@isTest static void testOne(){

		genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);


		System.Test.setMock(HttpCalloutMock.class, fakeResp);

		makeData();
		User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];
		test.startTest();
		system.RunAs(contextUser){
			PageReference pageRef = Page.NPN_DemoUnitRequest;
			Test.setCurrentPageReference(pageRef);
			NPN_DemoUnitReqController ctrllr = new NPN_DemoUnitReqController();
			List<NPN_DemoUnitReqController.SwReqWrapper> wrapList = new List<NPN_DemoUnitReqController.SwReqWrapper>();
			wrapList = ctrllr.getswRequests();
			system.assert (true, !wrapList.isEmpty());
		}
		test.stopTest();
	}
	@isTest static void  createRequest(){

		genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
		System.Test.setMock(HttpCalloutMock.class, fakeResp);

		makeData();
		Map<String, String> metaRecordsMap = new Map<String,String>();
		List<String> licenseNameList = new List<String>();
		for(NPN_NFR_Request_Data__mdt mdRec : [SELECT Id, DeveloperName, MasterLabel, Value__c FROM NPN_NFR_Request_Data__mdt]) {
			metaRecordsMap.put(mdRec.DeveloperName, mdRec.Value__c);
		}

		if(!metaRecordsMap.isEmpty()) {
			licenseNameList = metaRecordsMap.get('Softwares').split(';');
		}
		User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

		test.startTest();
		system.RunAs(contextUser){
			PageReference pageRef = Page.NPN_DemoUnitRequest;
			Test.setCurrentPageReference(pageRef);
			NPN_DemoUnitReqController ctrllr = new NPN_DemoUnitReqController();

			List<NPN_DemoUnitReqController.SwReqWrapper> softwareList = new List<NPN_DemoUnitReqController.SwReqWrapper>();

			for(String swVar : licenseNameList) {
				NPN_DemoUnitReqController.SwReqWrapper swWrpObj = new NPN_DemoUnitReqController.SwReqWrapper ();
				swWrpObj.swComment = 'test comment';
				swWrpObj.swName = swVar;
				swWrpObj.swQuantity = Integer.valueOf(3);
				softwareList.add(swWrpObj);
			}
			/*
			   NPN_DemoUnitReqController.SwReqWrapper swWrpObj1 = new NPN_DemoUnitReqController.SwReqWrapper ();
			   swWrpObj1.swComment = 'test comment';
			   swWrpObj1.swName = 'vPC';
			   swWrpObj1.swQuantity = Integer.valueOf(3);
			   NPN_DemoUnitReqController.SwReqWrapper swWrpObj2 = new NPN_DemoUnitReqController.SwReqWrapper ();
			   swWrpObj2.swComment = 'test comment';
			   swWrpObj2.swName = 'vWS';
			   swWrpObj2.swQuantity = Integer.valueOf(3);*/
			ctrllr.saveRequest();
		}
		test.stopTest();
	}

	@isTest static void  sendEmailTest(){

		genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
		System.Test.setMock(HttpCalloutMock.class, fakeResp);

		makeData();

		User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

		test.startTest();
		system.RunAs(contextUser){
			PageReference pageRef = Page.NPN_DemoUnitRequest;
			Test.setCurrentPageReference(pageRef);
			NPN_DemoUnitReqController ctrllr = new NPN_DemoUnitReqController();
			NPN_NFR_Software_Request__c requestOne = new NPN_NFR_Software_Request__c();
			requestOne.Status__c =  'Pending';
			requestOne.Comments_From_PBM__c = 'Test Comment';
			insert requestOne;
			ctrllr.sendApprovalMail(requestOne.Id);
		}
		test.stopTest();
	}
}