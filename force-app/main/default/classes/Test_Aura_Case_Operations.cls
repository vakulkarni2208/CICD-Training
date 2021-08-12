@isTest(seeAllData=false)
class Test_Aura_Case_Operations{


public testmethod static void  testAddCommunityCaseTeamMember() {
        Test.startTest();
        Account acc = Test_COMM_Factory.getAccount('NA TEST');
        insert acc;
        Contact con1 = Test_COMM_Factory.getContact(acc.id);
        insert con1;
        Contact con2 = Test_COMM_Factory.getContact(acc.id);
        insert con2;
        string recordTypeId = Test_COMM_Factory.getRecordTypeId('Case', 'Community_User_Record_Type');
        Case cse = Test_COMM_Factory.getCase(acc.id, recordTypeId);
        insert cse;
        AccountTeamMember accMember = Test_COMM_Factory.getAccountTeamMember(acc.id, UserInfo.getUserId(),'Support Team Member');
        insert accMember;
        CaseTeamRole caseRole = Test_COMM_Factory.getCaseTeamRole('Support Team Member');
        CaseTeamMember caseTeam=  Test_COMM_Factory.getCaseTeamMember(UserInfo.getUserId(), caseRole.id, cse.id);
        insert caseTeam;
        caseRole = Test_COMM_Factory.getCaseTeamRole('Customer');
        caseTeam=  Test_COMM_Factory.getCaseTeamMember(con1.id, caseRole.id, cse.id);
        insert caseTeam;
        Aura_Case_Operations.getContactLookup();
        Aura_Case_Operations.getCaseTeamMembers(cse.id);
        Aura_Case_Operations.addCommunityCaseTeamMember(cse.id, con2.id);
        Aura_Case_Operations.addCommunityCaseTeamMember(cse.id, con2.id);
        Aura_Case_Operations.removeCaseTeamMember(con1.id,cse.id);
        Test.stopTest();
        
    }
}