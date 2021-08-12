@isTest
private class NV_Test_ErrorLogHelper {
    
    private static testMethod void ErrorLogSendEmailTest() {
        Community_Settings__c cs = new Community_Settings__c(ERROR_EMAILS__c = 'varunk22@gmail.com');
        insert cs;
        NV_Error_Log__c objNVErrLg = new NV_Error_Log__c();
        objNVErrLg.Error_Description__c = 'test';
        objNVErrLg.Error_Message__c = 'test';
        objNVErrLg.functionality__c = 'test';
        test.startTest();
            insert objNVErrLg;
        test.stopTest();    
    }

}