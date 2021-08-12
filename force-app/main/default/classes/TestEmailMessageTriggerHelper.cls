@isTest
public class TestEmailMessageTriggerHelper 
{
    final static String NAME 				= 'TestEmailMessageTriggerHelper';
    final static String AGENT_PROFILE_NAME  = 'Service Cloud Generic User';
    final static String NV_AGENT_ROLE 		= 'NV Agent';
    final static String NCR_AGENT_ROLE 		= 'NCR Agent';
    
    @TestSetup
    static void setup() {
        Profile agentProfile  = [select id from profile  where name =: AGENT_PROFILE_NAME];
        UserRole nvAgentRole  = [SELECT Id FROM UserRole where Name =: NV_AGENT_ROLE];
        UserRole ncrAgentRole = [SELECT Id FROM UserRole where Name =: NCR_AGENT_ROLE];
        
        List<User> userList = new List<User>();
        User u1 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'1', null);
        User u2 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'2', null);
        User u3 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'3', nvAgentRole.Id);
        User u4 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'4', null);
        User u5 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'5', ncrAgentRole.Id);
        
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
        
        Case c 		= Test_COMM_Factory.getCase(acc.Id, rt.Id);
        c.Subject	= NAME;
        insert c;
        
        EmailMessage em = Test_COMM_Factory.getEmailMessage(c.Id, 'test@nvidia.com', 'test2@nvidia.com');
        insert em;
        update em;
        delete em;
        
        Test.stopTest();
    }
    
    /*
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
    }*/
}