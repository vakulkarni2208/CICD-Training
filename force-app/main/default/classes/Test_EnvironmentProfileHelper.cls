@isTest(seeAllData=false)
public class Test_EnvironmentProfileHelper{
@isTest(seeAllData=false)
public static void testgetEntitlementList(){
Test.startTest();
Account acc = Test_COMM_Factory.getAccount('test acc');
insert acc;
string strEnvRecordTypeId=Test_COMM_Factory.getRecordTypeId('Environment_Profile__c','DGX');
Environment_Profile__c env= Test_COMM_Factory.getEnvironmentProfile(acc, strEnvRecordTypeId);
insert env;
Entitlement ent = Test_COMM_Factory.getEntitlement('ent1',acc.id);
ent.Environment_Profile__c = env.id;
insert ent;
List<Entitlement> lstEnt=EnvironmentProfileHelper.getEntitlementList(env.id);
EnvironmentProfileHelper.linkEnvironmentProfileToEntitlements(env.id,lstEnt);
Test.stopTest();
}

}