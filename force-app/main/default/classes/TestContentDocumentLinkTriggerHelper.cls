@isTest
public class TestContentDocumentLinkTriggerHelper 
{
    final static String NAME = 'TestContentDocumentLinkTriggerHelper'; 
    
    final static String AGENT_PROFILE_NAME = 'Service Cloud Generic User';
    final static String NV_AGENT_ROLE = 'NV Agent';
    final static String NCR_AGENT_ROLE = 'NCR Agent';
    
    @TestSetup
    static void setup() {
        Profile agentProfile = [select id from profile  where name =: AGENT_PROFILE_NAME];
        UserRole nvAgentRole = [SELECT Id FROM UserRole where Name =: NV_AGENT_ROLE];
        UserRole ncrAgentRole = [SELECT Id FROM UserRole where Name =: NCR_AGENT_ROLE];
        
        List<User> userList = new List<User>();
        User u1 = createUser(agentProfile, NAME+'1');
        User u2 = createUser(agentProfile, NAME+'2');
        User u3 = createUser(agentProfile, NAME+'3', nvAgentRole.Id);
        User u4 = createUser(agentProfile, NAME+'4');
        User u5 = createUser(agentProfile, NAME+'5',ncrAgentRole.Id);
        
        userList.add(u1);
        userList.add(u2);
        userList.add(u3);
        userList.add(u4);
        userList.add(u5);
        
        insert userList;
    }
    
    @isTest
    static void test_bussiness_critical_support() {
        User u4 = [select Id from User where LastName =: NAME+'4'];
        User u5 = [select Id from User where LastName =: NAME+'5'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=: CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        
        Test.startTest();
        Date startDate = Date.today(); //date.newInstance(System.now().year(), System.now().month(), System.now().day());
        
        //Account creation
        Account acc = Test_COMM_Factory.getAccount(NAME);
        insert acc;
        
        Case c      = Test_COMM_Factory.getCase(acc.Id, rt.Id);
        c.Subject   = NAME;
        insert c;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';  
        Blob CVData = Blob.valueOf('Unit Test Attachment Body');         
        cv.VersionData = CVData;          
        insert cv;   

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = c.id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
                
        Test.stopTest();
    }
    
    @isTest
    static void test_qpb_statement() {
        User u4 = [select Id from User where LastName =: NAME+'4'];
        User u5 = [select Id from User where LastName =: NAME+'5'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=: CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        
        Test.startTest();
        Date startDate = Date.today(); //date.newInstance(System.now().year(), System.now().month(), System.now().day());
        
        //Account creation
        Account acc = Test_COMM_Factory.getAccount(NAME);
        insert acc;
        
        QPB_Statement__c qpb = new QPB_Statement__c (
                              Account__c = acc.Id,
                              Fiscal_Year__c = 'FY20',
                              Quarter__c = 'Q3',
                              Type__c = 'Final',
                              Status__c = 'Active'
                              );
        insert qpb;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';  
        Blob CVData = Blob.valueOf('Unit Test Attachment Body');         
        cv.VersionData = CVData;          
        insert cv;   

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = qpb.id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
                
        Test.stopTest();
    }
    
    static User createUser(Profile p, String name){
        return createUser(p, name, null);
    }
    
    static User createUser(Profile p, String name, String roleId){
        User testuser = new User(
                                    Alias           = 'testUser', 
                                    Email           = name+'@test.com',
                                    Emailencodingkey= 'UTF-8', 
                                    Lastname        = name, 
                                    Languagelocalekey= 'en_US',
                                    Localesidkey    = 'en_US',
                                    Profileid       = p.Id, 
                                    Timezonesidkey  = 'America/Los_Angeles', 
                                    Username        = name+'@test.com',
                                    UserRoleId      = roleId,
                                    IsActive        = true
                                );
       return testuser;
    }
}