@isTest
public class createServiceCloudUserByUserDetailsTest {
    public static String sfdcOrgURL = URL.getSalesforceBaseUrl().toExternalForm() + '/'; 
    
    /**************************************************************************************************
* Input Parameters: No input parameters 
* Author : Venkat G
* Purpose: Test method for ServiceCloudApi's class positive scenario
***************************************************************************************************/ 
    
    @isTest
    static void getAccountByEmailPositiveTest(){
        
        Account accountObj= new Account();
        accountObj.Name ='Test';
        insert accountObj;
        
        Contact contactObj = new Contact();
        contactObj.lastname = 'testcontact';
        contactObj.Email = 'test123@gmail.com';
        contactObj.AccountId = accountObj.Id;
        insert contactObj;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        RestRequest requestObj = new RestRequest();
        requestObj.requestUri = sfdcOrgURL+'services/apexrest/NVService/getAccountByEmail/test123@gmail.com';
        requestObj.httpMethod = 'GET';
        RestContext.request = requestObj;
        genericMock fakeResp = new genericMock(200,  'Complete', '{"StatusCode": "200","Status": "Success","Message": "Success : Found Records","Data": {"Type": "NPN Account Registry","Name": "Solution Advisor J1","Id": "001n000000Sozo4AAB"}}',null);
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        getAccountsByEmailAPI.getAccountByEmail();
        Test.stopTest();
        
    }
    
    
    /**************************************************************************************************
* Input Parameters: No input parameters 
* Author : Venkat G
* Purpose: Test method for testing createServiceCloudUserByUserDetailsPost
***************************************************************************************************/    
    static testMethod  void testcreateServiceCloudUserByUserDetailsPost() {
        // prepare test-data
        
        Account accountObj= new Account();
        accountObj.Name ='Test';
        insert accountObj;
        
        Contact contactObj = new Contact();
        contactObj.lastname = 'testcontact';
        contactObj.Email = 'test423@gmail.com';
        contactObj.AccountId = accountObj.Id;
        insert contactObj;
        //As Per Best Practice it is important to instantiate the Rest Context
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = sfdcOrgURL+'/services/apexrest/NVService/createServiceCloudUserByUserDetails';
        req.httpMethod = 'POST';
        
        
        //String Jsonmsg = '{ "contactId": "003g000001rUSgz", "Email": "muthu9701+1@gmail.com", "Username": "muthu9701+1@gmail.com.v1" }'; = '{ "contactId": "003g000001rUSgz", "Email": "muthu9701+1@gmail.com", "Username": "muthu9701+1@gmail.com.v1" }';
        req.requestBody = Blob.valueof('{ "contactId": "003g000001rUSgz", "Email": "muthu9701+1@gmail.com", "Username": "muthu9701+1@gmail.com.v1" }');
        RestContext.request = req;
        RestContext.response= res;
        // System.Test.setMock(HttpCalloutMock.class, req);
       createServiceCloudUserByUserDetails.createServiceCloudUser();
       createServiceCloudUserByUserDetails.ServiceCloudUserInfo scui = new createServiceCloudUserByUserDetails.ServiceCloudUserInfo();
        string conid = String.ValueOf(contactObj.id);
       createServiceCloudUserByUserDetails.createUser(conid);
        Test.stopTest();
        
        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }
}