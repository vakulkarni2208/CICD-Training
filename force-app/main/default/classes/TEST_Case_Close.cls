@isTest(seeAllData=false)
class TEST_Case_Close{

@isTest
public static void testCaseClose(){
Test.startTest();

Account acc = new Account();
acc.name = 'test';
acc.Account_Class__c = 'General Account';
acc.website = 'test.com';
acc.industry = 'Automotive';
insert acc;
Id CaseRecTypeId = [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Community_User_Record_Type'].id;
Case c = new case();
c.Submitted_By__c = Userinfo.getUserId();
c.status='New';
c.Type='System Issue';
c.AccountId=acc.id;
c.Origin = 'Email';
c.subject = 'Test';
c.How_would_you_like_to_be_contacted__c = 'Email';
//c.Severity__c = 'S3: Moderate';
c.description = 'test';
c.Product_Category__c = 'DGX';
c.RecordTypeId = CaseRecTypeId ;
insert c;
ApexPages.StandardController controller = new   ApexPages.StandardController(c);
ApexPages.currentPage().getParameters().put('id',c.id);
Case_Close cc = new Case_Close(controller );
Case_Close.closeCase(c.id,false);
Test.stopTest();
}
}