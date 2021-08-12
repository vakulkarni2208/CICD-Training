/*
* Akhilesh Gupta    | 1.0        | 11/18/2019       | Created test class for RenewEntitlementHelper
*/
@isTest
public class RenewEntitlementHelper_test {
    final static String NAME = 'TestRenewEntitlementHelper_test';
    
    @testsetup
    public static void setup(){}
    
    @isTest
    public static void TestRenewEntitlement(){
        
        Test.startTest();
            //Account creation
            Account acc = Test_COMM_Factory.getAccount(NAME);
            insert acc;            
            //Entitlement creation
            Entitlement ent  = Test_COMM_Factory.getEntitlement(NAME,acc.id);
            insert ent;
            
            Entitlement__c custEnt = [SELECT Id, Entitlement__c FROM Entitlement__c WHERE Entitlement__c =:ent.id];
            system.assertNotEquals(Null, custEnt.id);
        
            RenewEntitlementHelper.RenewEntitlement(custEnt.id);
            Entitlement ent1 = [select Id, Renew_Entitlement__c from Entitlement where id =: ent.Id];
            system.assertEquals(False, ent1.Renew_Entitlement__c);
        Test.stopTest();
    }
}