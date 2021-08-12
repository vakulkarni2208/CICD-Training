/**************************************************************************************************
* Name       : Asset_tgr_cls_test
* Purpose    : Test class for Asset_tgr_cls Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Akhilesh Gupta         | 1.0        | 06/28/2020       | Initial Draft
**************************************************************************************************/
@isTest(SeeAllData=false)
public class Asset_tgr_cls_test {
    final static String NAME = 'Asset_tgr_cls_test';
    
    @testSetup 
    public static void TestUserCreation(){
        //Account creation
        map<string, Id> map_CUSTOMER_ACCOUNT_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER);
        //Account acc = Test_COMM_Factory.getAccount('Test Account');
        Account acc = new Account(name='SAP R3 Customer1', SAP_Customer_Number__c='123', RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER));
        
        //acc.RecordTypeId = map_CUSTOMER_ACCOUNT_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER);
        //acc.EMS_Update_Required__c = false;
        insert acc;
        acc.EMS_Update_Required__c = false;
        acc.SAP_Customer_Number__c = 'SAP123';
        acc.AccountSource = 'Advertising';
        update acc;
        
        //Product creation
        Product2 product = Test_COMM_Factory.getProduct(NAME);
        product.Material_Number__c = '1111';
        insert product;
        
        //Contact creation
        Contact con = Test_COMM_Factory.getContact(acc.Id);
        //con.SAP_Contact_ID__c = '1111';
        insert con;
        
        NV_Component__c cmp = Test_COMM_Factory.getComponent();
        cmp.Asset_Serial_Number__c = '1111';
        insert cmp;
        
        Entitlement ent = Test_COMM_Factory.getEntitlement(NAME, acc.id);
        ent.Hardware_Serial_Number__c = '1111';
        insert ent;
        
        Entitlement ent1 = Test_COMM_Factory.getEntitlement(NAME, acc.id);
        ent.PAK_ID__c = '2222';
        insert ent1;
    }
    
    @isTest
    public static void testAsset(){
        
        Account acc = [SELECT Id FROM Account][0];
        Product2 product = [SELECT Id FROM Product2][0];
        Contact con = [SELECT Id FROM Contact][0];
        
        //Create Asset - 
        Asset ast               =  Test_COMM_Factory.getAsset(NAME, acc.id);
        ast.Serial_Number__c    = '1111';
        ast.SerialNumber        = '1111';
        ast.Material_Number__c  = '1111';
        ast.SAP_PECC_Number__c  = '1111';
        ast.PAKID__c = '1111';
        ast.Link_Entitlements__c = true;
        ast.Product2Id = product.Id;
        ast.Link_Components__c = true;
        insert ast; 
       
        ast.SAP_Account_Number__c   = 'SAP123';
        ast.Sold_To_Partner_SAP_Number__c   = 'SAP123';
        ast.VAR_SAP_Number__c   = 'SAP123';
        ast.SAP_Delivery_Number__c = '1111';
        ast.Link_Entitlements__c = true;
        ast.Link_Components__c = true;
        update ast; 
        
        ast.SerialNumber        = '1234';
        ast.Serial_Number__c    = '1234';
        update ast; 
        
        Asset ast1              =  Test_COMM_Factory.getAsset(NAME, acc.id);
        ast1.SAP_Account_Number__c  = 'SAP123';
        ast1.Sold_To_Partner_SAP_Number__c  = 'SAP123';
        ast1.VAR_SAP_Number__c  = 'SAP123';
        //ast1.Serial_Number__c     = '1234';
        ast1.Material_Number__c     = '1111';
        ast1.SAP_PECC_Number__c     = '1111';
        ast1.PAKID__c = '2222';
        ast1.AccountId = acc.Id;
        ast1.ContactId = con.ID;   
        ast1.Link_Entitlements__c = true;
        insert ast1;
    }
}