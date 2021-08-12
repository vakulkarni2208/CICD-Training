@isTest(seeAllData=false)
private class SuRF_DGX_HOT_CPL_tgr_cls_Test{


    @TestSetup
    static void makeData(){  
        
        
        Account partnerAcc;
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();

        
        genericMock fakeResp = new genericMock(200,'Complete',
        '<?xml version="1.0" encoding="UTF-8"?>'+
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
        '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
        '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage>'+
        '</ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
        '<ax21:syncType>PartnerUser</ax21:syncType></ns:return>'+
        '</ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);

        System.Test.setMock(HttpCalloutMock.class, fakeResp);  


        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', accRecTypeId);
        system.debug('***partnerAcc: ' + partnerAcc);


        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;

        Partner_Attribute__c pAttrb2 = new Partner_Attribute__c(
            Account_Name__c  =  partnerAcc.Id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            Exempted_from_POS_Submission__c = false,
            ATP_Partner_Start_Date__c = Date.valueOf(system.today()));
        insert pAttrb2;
    }

    @isTest static void testOne(){   

        Account partnerAcc = [SELECT Id,
                                    Name 
                                    FROM Account 
                                    WHERE Name ='DRNPNAccountRegistry1' LIMIT 1];

        SuRF_DGX_HOT_Compliance__c dObj = new SuRF_DGX_HOT_Compliance__c (
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
            Category__c = 'Training Compliance',
            Account_Id__c = partnerAcc.Id,
            Account_Name__c = partnerAcc.Name,
            Partner_Sub_Program__c ='',
            Flag__c =1,
            Billing_Sub_Region__c ='NA',
            BillingCountry__c = 'United States',
            Order__c = 1
        );
        insert dObj;
    }

    @isTest static void testTwo(){   

        Account partnerAcc = [SELECT Id,
                                    Name 
                                    FROM Account 
                                    WHERE Name ='DRNPNAccountRegistry1' LIMIT 1];

        SuRF_DGX_HOT_Compliance__c dObj = new SuRF_DGX_HOT_Compliance__c (
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
            Category__c = 'Training Compliance',
            Account_Id__c = partnerAcc.Id,
            Account_Name__c = partnerAcc.Name,
            Partner_Sub_Program__c ='',
            Flag__c = -1,
            Billing_Sub_Region__c ='NA',
            BillingCountry__c = 'United States',
            Order__c = 1
        );
        insert dObj;
    }
}