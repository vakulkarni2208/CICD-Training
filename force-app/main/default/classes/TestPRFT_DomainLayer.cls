/**************************************************************************************************
* Name       : TestPRFT_DomainLayer
* Purpose    : Test class for PRFT_DomainLayer
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/16/2017       | Initial Draft
*Perficient         | 1.0        | 1/17/2018        | Final Draft
**************************************************************************************************/
@isTest
public class TestPRFT_DomainLayer {
    final static String NAME = 'TestPRFT_DomainLayer'; 
    static Case createCase(Id acctId){
        String rtName = CaseTriggerHelper.COMM_CASE_RT_DEV_NAME;
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:rtName];
        Case c = new Case();
        c.RecordTypeId = rt.Id;
        c.AccountId = acctId;
        c.Severity__c = 'S2:_Severe';
        c.Status = 'New';
        c.Origin = 'Email';
        return c;
    }
    static Account createAccount(String name){
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        Account acct = new Account();
        acct.Name = name;
        acct.BillingState ='California';
        acct.BillingCountry ='United States';
        acct.BillingStreet = 'Test';
        acct.BillingCity ='Test';
        acct.BillingPostalCode ='123213';
        acct.Billing_Region__c = 'NALA';
        acct.RecordTypeId = rt.Id;
        return acct;
    }
    @isTest
    public static void testDomainLayer(){
    
        PRFT_DomainLayer domLayer = new PRFT_DomainLayer();
        Account acct=createAccount(NAME);
        insert acct;
        Case c = createCase(acct.Id);
        insert c;
        Test.startTest();
        List<Case> casList = (List<Case>) PRFT_DomainLayer.queryObj('Case','WHERE Id ='+'\''+c.id+'\'', 'Select Case.Account.Name,');
        
        PRFT_DomainLayer.buildQueryFields('Case','WHERE Id ='+'\''+C.id+'\'','Select Case.Account.Name,');
        PRFT_DomainLayer.getPicklistValues(new Case(),'Status');
        PRFT_DomainLayer.getFieldMap('product2');
        PRFT_DomainLayer.readFieldSet('RMA_FieldSetsLeft','RMA__c');
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock(''));
        //Not needed as calls from other test classes cover this class
        Test.stopTest();
    }

    @isTest
    static void test_getPicklistValues(){
        Test.startTest();
        List<SelectOption> optionList = PRFT_DomainLayer.getPicklistValues(new Case(),'Status');
        System.assertNotEquals(0,optionList.size());
        Test.stopTest();
    }

    @isTest
    static void test_PRFT_Error(){
        Test.startTest();
        PRFT_DomainLayer.PRFT_Error err = new PRFT_DomainLayer.PRFT_Error('endpointURL','request','errorMessage','response','WebService Callout');
        List<Service_Cloud_Error_Log__c> logList = [SELECT ID FROM Service_Cloud_Error_Log__c];
        System.assertEquals(1,logList.size());
        PRFT_DomainLayer.PRFT_Error err2 = new PRFT_DomainLayer.PRFT_Error('endpointURL','request','errorMessage','response','Salesforce');
        logList = [SELECT ID FROM Service_Cloud_Error_Log__c];
        System.assertEquals(2,logList.size());
        PRFT_DomainLayer.PRFT_Error err3 = new PRFT_DomainLayer.PRFT_Error('functionalityName','description','errorMessage','recURL',true);
        logList = [SELECT ID FROM Service_Cloud_Error_Log__c];
        System.assertEquals(3,logList.size());
        Test.stopTest();
    }

    @isTest
    static void test_crmcomplaintproxyresponse(){
        crmcomplaintproxyresponse res = new crmcomplaintproxyresponse();
        crmcomplaintproxyresponse.CrmComplaintProxyResponse_element resEle = new crmcomplaintproxyresponse.CrmComplaintProxyResponse_element();
        crmcomplaintproxyresponse.RMA_element rmaEle = new crmcomplaintproxyresponse.RMA_element();

        nvidiaServicecloud nvd = new nvidiaServicecloud();
        nvidiaServicecloud.HTTPS_Port hp = new nvidiaServicecloud.HTTPS_Port();
        Map<String,String> iheader = hp.inputHttpHeaders_x;
        Map<String,String> oheader = hp.outputHttpHeaders_x;
        String ccn = hp.clientCertName_x;
        String ccx = hp.clientCert_x;
        String pwd = hp.clientCertPasswd_x;
        Integer tox = hp.timeout_x;
        /*hp.ServiceCloud_Complaint('EXTERNAL_REFERENCE_NUMBER',
                                                      'SFDC_CASE_INCIDENT_NUMBER',
                                                      'SPECIAL_SHIPPING_INSTRUCTIONS',
                                                      new crmcomplaintproxy.SoldToAddress_element(),
                                                      new crmcomplaintproxy.ShipToAddress_element(),
                                                      new String[]{},
                                                      new crmcomplaintproxy.OnSiteContact_element[]{},
                                                      new crmcomplaintproxy.RmaItemInformation_element[]{});
        
    */}
}