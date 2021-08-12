/**
* Akhilesh:        : 11/18/2019 : Created A test class for AddUserHelper
*/
@isTest
public with sharing class AddUserHelper_test {
    final static String ESP_Community_User  = 'ESP Community User';
    final static String Name                = 'AddUserHelper_test';
    
    @testsetup
    public static void setup(){
        //Create product
        Product2 product = Test_COMM_Factory.getProduct(Name);
        product.Product_Type__c = 'Hardware';
        product.Product_Line__c = 'DGX';
        product.IsActive        = true;
        insert product;
        
        //Create Account -
        Account acc = Test_COMM_Factory.getAccount(Name);
        insert acc;
        
        //Create Entitlement - 
        Entitlement ent  = Test_COMM_Factory.getEntitlement(NAME,acc.id);
        insert ent;
        
        //Create Contact
        Contact cont = Test_COMM_Factory.getContact(acc.Id);
        system.assertNotEquals(Null, cont.AccountId);
        insert cont;
        
        //Create Community User
        Profile espProfile  = [select id from profile  where name =: ESP_Community_User];
        User usr            = Test_COMM_Factory.createUser(cont.Id, espProfile.Id);
        system.assertNotEquals(Null, usr.Email);  
        system.assertNotEquals(Null, usr.username);
    }
    
    @istest
    static void TestsendRegistrationEMail(){
        Test.startTest();
        User usr = [Select Id, Email from User where Account.Name =: Name][0];
        
        //Run as (Community User Id) 
        system.runAs(usr) {
            String Email = usr.email;
            String hostName = 'www';
            String prodFamilySelected = 'DGX';
            
            AddUserHelper.UserType();
            AddUserHelper.sendRegistrationMail(Email, hostName, prodFamilySelected);
            //AddUserHelper.sendonBoardingMail(null, null, null, null, null);
            //System.assert();
        }
        Test.stopTest();
    }
}