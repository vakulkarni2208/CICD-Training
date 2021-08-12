/*
 * Author: @Manideep
 * Date: 8/6/2018
 * Description:
    * This test class covers code coverage for 'briefingSourceService' class.
    * This class invokes an other test class 'BriefingSourceServiceTestMockCallout' for mocking the callout.
*/
@isTest(seeAllData=False)
public class BriefingSourceServiceTest {
  
 static bsource__BS_Deal_Support_Request__c createBriefing() {   
   bsource__BS_Deal_Support_Request__c bs = new bsource__BS_Deal_Support_Request__c();
   bs.Name = 'Test Briefing';
   bs.bsource__BriefingID__c = '234';
   insert bs;
   return bs;
 }
 
 static testMethod void testGETServiceUpsertBriefing() {
       
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    createBriefing();    
    list<bsource__BS_Deal_Support_Request__c> testBriefingList = [Select id, Name from bsource__BS_Deal_Support_Request__c WHERE bsource__BriefingID__c = '234'];
    
    req.requestURI = '/services/apexrest/invokeServiceBriefingSourcetoSFDC';  
    req.addParameter('briefingId', '234');
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new BriefingSourceServiceTestMockCallout());
    briefingSourceService.getBriefingintoSF();
    Test.stopTest();
    
    //String testBlob = res.responseBody.toString(); 
    //System.assert(testBlob.contains(testBriefing.Name)); 
    
 }  
    
}