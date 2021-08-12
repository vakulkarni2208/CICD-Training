/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-30-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-30-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest(seeAllData=false)
class Test_NVBugOperations{

@testsetup
public static void CreateSetupData(){
    
    Account acc= Test_COMM_Factory.getAccount('testAcc');
    insert acc;
    Id RecTypeId = Test_COMM_Factory.getRecordTypeId('Case', 'Community_User_Record_Type');
    List<Environment_Profile__c > lstEnv = new List<Environment_Profile__c >();
    Environment_Profile__c env = Test_COMM_Factory.getEnvironmentProfile(acc.id);
    env.RecordTypeId= Test_COMM_Factory.getRecordTypeId('Environment_Profile__c', 'DGX');    
    lstEnv.add(env);
    env = Test_COMM_Factory.getEnvironmentProfile(acc.id);
    env.RecordTypeId= Test_COMM_Factory.getRecordTypeId('Environment_Profile__c', 'vGPU');
    lstEnv.add(env);
    env = Test_COMM_Factory.getEnvironmentProfile(acc.id);
    env.RecordTypeId= Test_COMM_Factory.getRecordTypeId('Environment_Profile__c', 'DRIVE_Constellation');
    lstEnv.add(env);    
    insert lstEnv ;
    List<Case> lstCases = new List<Case>();
    Case cse = Test_COMM_Factory.getCase(acc.id, RecTypeId );
    cse.Environment_Profile__c = lstEnv.get(0).id;
    cse.Product_Category__C='GRID';
    lstCases.add(cse );
    cse = Test_COMM_Factory.getCase(acc.id, RecTypeId );
    cse.Product_Category__C='DGX';
    cse.Environment_Profile__c = lstEnv.get(1).id;
    lstCases.add(cse );
    cse = Test_COMM_Factory.getCase(acc.id, RecTypeId );
    cse.Product_Category__C='DRIVE Constellation';
    cse.Environment_Profile__c = lstEnv.get(2).id;
    lstCases.add(cse );
    insert lstCases;
    RMA__C rma = new RMA__c(Case__c = lstCases.get(0).id,NVIDIA_Part_Description__c='part1',Crm_Complaint_Number__c='0657839');
    insert rma;
    NVBug__c nvbug = NVBugOperations.getPrepopulatedNVBug(lstCases.get(0).id);
    nvbug.NVBug_Description__c = nvbug.NVBug_Description__c + '<img src="/servlet/rtaImage?eid=a577i0000006tkI&amp;feoid=00N1W000003O1kv&amp;refid=0EM7i000000Al7I" <br><br><br/><br/><p><p></p></p>';
    nvbug.RMA__c=rma.id;
    nvbug = NVBugOperations.saveNewNVBug(nvbug);//Test_COMM_Factory.getNVBug(cse1.id);    
    nvbug = NVBugOperations.getPrepopulatedNVBug(lstCases.get(1).id);
    nvbug = NVBugOperations.getPrepopulatedNVBug(lstCases.get(2).id);

}

@isTest
public static void testSaveBugCallout(){
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Mock());
    NVbug__C nvbug = [select Requestor__c,Is_Send_Notification__c,RMA__c,Severity__c,Priority__c,NVBug_Description__c,Synopsis__c,name,Versions__c,NVBug_Template__c from NVbug__C limit 1];
    string str = NVBugOperations.saveBug(nvbug);
    NVbug__C nvbug1= nvbug.clone();
    nvbug1.RMA__c=null;
    NVBugOperations.saveNewNVBug(nvbug1);
    str = NVBugOperations.saveBug(nvbug1);

    Id RecTypeId = Test_COMM_Factory.getRecordTypeId('NV_Ticket__c', 'NVBug');
    List<Case> lstCases = [select id from Case];
    NV_Ticket__c nvt1 = Test_COMM_Factory.getNV_Ticket(lstCases.get(0).id,'NVBug',RecTypeId );
    nvt1.NVbug__C =nvbug.id;
    insert nvt1;
    
    NV_Ticket__c nvt2 = Test_COMM_Factory.getNV_Ticket(lstCases.get(1).id,'NVBug',RecTypeId );
    nvt2.Bug_no_in_NVBug_Not_in_SFDC__c= '1001';
    nvt2.nvbug__C=null;
    insert nvt2;
     
    NV_Ticket__c nvt3 = Test_COMM_Factory.getNV_Ticket(lstCases.get(2).id,'NVBug',RecTypeId );
    nvt3.Bug_no_in_NVBug_Not_in_SFDC__c= '1000';
    nvt3.nvbug__C=null;
    insert nvt3;    
    Test.stopTest();
}
@isTest
public static void testFileUploads(){
    Test.startTest();
    List<NVbug__C > lstnvbug = [select Case__c,Is_Send_Notification__c,RMA__c,Severity__c,Priority__c,NVBug_Description__c,Synopsis__c,name,Versions__c,NVBug_Template__c from NVbug__C limit 1];
    List<ContentVersion > lstcv = new List<ContentVersion >();
    ContentVersion cv=new ContentVersion();
    cv.Title = 'test.csv';
    cv.PathOnClient = 'test.csv' ;
    cv.VersionData = EncodingUtil.base64Decode('qwertyvfvfv');
    cv.IsMajorVersion = true;
    cv.FirstPublishLocationId  = lstnvbug.get(0).Case__c;
    lstcv.add(cv);
    insert lstcv;
    NVBugOperations.updateFileNewName(lstCv);
    lstcv= NVBugOperations.getFilesOnCases(lstnvbug.get(0).Case__c);
    Test.setMock(HttpCalloutMock.class, new Mock());
    NVBugOperations.linkCaseFilesToNVbug(lstcv,lstnvbug ); 
    NVBugOperations.getNVBugs(lstnvbug.get(0).Case__c);   
    Test.stopTest();

}

private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            string strResponse;
            system.debug('**req.getEndpoint()**'+ req.getEndpoint() + '**' +req.getEndpoint().contains('SF_NVBugAttachment_Metadata_Out'));
            if (req.getEndpoint().contains('getbug')) {
                strResponse = '{"TotalCount": 1,"StartIndex": 0,"EndIndex": 0,"IsSuccess": true,"ErrorMessage": "","ReturnValue": {"ClonedSourceBugID": null,"DaysOpen": 0,"CustomerAdditionalIDList": "","IsSubmitted": null,"ArchitectureExtendedProperty": null,"GeographicOrigin": "India, Pune","Origin": "Customer","Application": "","ProjectedFixDate": "","ClosedDate": "3/30/2020 6:11:38 AM","FixedDate": "3/30/2020 6:11:38 AM","DescriptionPlainTextReadOnly": "Case Number : 00055337Serial Number :Agent Description :Case Description : cpu0-alert","CustomerName": "","CustomerAdditionalList": "","IsSendNotification": false,"Version": "BTY 1, BTY 3, test 5 (Branch 5), test 6 (Branch 5)","VersionFixedAfter": "","DirectXVersion": "","QAVersion": "","FixForReleaseVersion": "","VersionBranchType": 0,"CustomKeywords": "3DBD, 3DTV_Cert","PersonDaysSaved": null,"BangBuckFinalRatio": 0,"Categories": "Bugs Test TWO, Wistron - VoW001","BusinessUnits": "PS3, IT","ARBFullName": null,"BugActions": null,"EngineerFullName": null,"BugPriority": null,"RequesterFullName": null,"BugSeverity": null,"DevTechFullName": null,"Dispositions": null,"ModuleName": null,"QAEngineerFullName": null,"BugApplicationIntegration": [],"BugId": 1786994,"Synopsis": "null | Saturn V | cpu0-alert","Description": "cpu0-alert","Requester": {"Key": 46187,"Value": "Nilesh Adkar"},"Engineer": {"Key": 11179,"Value": "Jonathan Piersa"},"QAEngineer": {"Key": 19332,"Value": "Deepak Bora"},"DevTech": null,"Module": null,"ModuleInfo": {"Key": 303,"Value": "Bugs Test"},"ARB": [],"ARBNTAccount": [],"CCUsers": [{"Key": 31255,"Value": "Akash Pardeshi"},{"Key": 46187,"Value": "Nilesh Adkar"},{"Key": 31103,"Value": "Varun Kulkarni"},{"Key": 31103,"Value": "Varun Kulkarni"}],"CCGroups": [{"Key": 14550,"Value": "*nvbugs developers"}],"BugAction": {"Key": 39,"Value": "QA - Closed - Verified"},"Disposition": {"Key": 47,"Value": "Bug - Fixed"},"ApplicationDivisionID": 1,"BugTypeID": 6,"BugType": "Software","Priority": {"Key": 340,"Value": "Unprioritized"},"Severity": {"Key": 30,"Value": "3-Functionality"}}}';
            } else if (req.getEndpoint().contains('SaveBug')) {
                strResponse = '{"Version":"BTY 1, BTY 3","DescriptionMarkup":"/servlet/rtaImage?","Synopsis":"[GRID ] [Saturn V]  [cpu0-alert]","Severity":{"Value":null,"Key":null},"QAEngineer":{"Value":"Scott Fields","Key":11790},"Priority":{"Value":"Unprioritized","Key":null},"Origin":"Customer","OperatingSystems":"","ModuleInfo":{"Value":"Silicon - GV100 MPC","Key":16346},"IsSendNotification":true,"GeographicOrigin":"US, NC, Durham","Engineer":{"Value":"Milton Lei","Key":5453},"Disposition":{"Value":"Duplicate","Key":101},"Description":"<p>Customer Provided Case Description : cpu0-alert</p><p><br></p>","CustomKeywords":"","CCUsers":[{"Value":"Stuart Oberman","Key":6516},{"Value":"Summers Brennan","Key":23639}],"CCGroups":[{"Value":"*volta-mpc-asic","Key":41329}],"Categories":"","BusinessUnits":"","BugType":"Hardware","BugId":0,"BugApplicationIntegration":[{"LinkSummary":"cpu0-alert","ApplicationURL":"https://nvcrm--sfdcstage1.my.salesforce.com/5000t000007TF2rAAG","ApplicationName":"Salesforce","ApplicationID":"00055337"}],"BugAction":{"Value":"HW - Closed","Key":115},"ARB":[],"ApplicationDivisionID":2}';
            } else if (req.getEndpoint().contains('NVBug_Middleware_Endpoint')) {
                strResponse = '<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Header/><SOAP:Body/></SOAP:Envelope>';
                system.debug('**req.getEndpoint()**'+ req.getEndpoint().contains('SF_NVBugAttachment_Metadata_Out'));
            }else if(req.getEndpoint().contains('AddBugToApplication')){
                strResponse = '{"TotalCount":1,"StartIndex":0,"EndIndex":0,"IsSuccess":true,"ErrorMessage":"","ReturnValue":null}';
            }             
            else if(req.getEndpoint().contains('sobjects/NVBug__c')){
                strResponse = '<img src="/servlet/rtaImage?eid=a577i0000006tkI&amp;feoid=00N1W000003O1kv&amp;refid=0EM7i000000Al7I"';
            }             
            else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
            res.setBody(strResponse);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}