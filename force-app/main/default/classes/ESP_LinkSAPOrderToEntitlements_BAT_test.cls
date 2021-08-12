@isTest
public with sharing class ESP_LinkSAPOrderToEntitlements_BAT_test {
    
    public static final string Name = 'ESP_LinkSAPOrderToEntitlements_BAT_test';
    @testSetup 
    static void setup() {
        //Create product
        Product2 product 		= Test_COMM_Factory.getProduct('Test Product');
        product.Product_Type__c = 'Hardware';
        product.Product_Line__c = 'DGX';
        product.ProductCode 	= 'PRD001';
        product.IsActive 		= true;
        insert product;
        
        //Account creation
        Account acc = Test_COMM_Factory.getAccount(Name);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = :COMM_Constants.SOBJECT_ACCOUNT AND  Name = :COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
        acc.RecordTypeId = rt.Id;
        insert acc;
        
        //Contract creation
        Contract contract = Test_COMM_Factory.getContract(acc.Id);
        insert contract;
        
        //Activate contract
        contract.Status = 'Activated';
        update contract;
        
        //Create SAP Order, with Order Type, Account, Partner, Soldto
        SAP_Order__c ord 	= new SAP_Order__c();
        ord.Order_Type__c 	= 'ZOR';
        ord.Start_Date__c 	= date.today();
        ord.End_Date__c 	= date.today().addYears(3);
        ord.SAP_PAK_ID__c 	= '12345';
        ord.Quantity__c 	= 3;
        ord.Renewed_PAK_ID__c = 'PAK234';
        ord.Sold_To_Partner__c = 'SAPAcc001';
        //ord.Sold_To_Partner_Lookup__c = acc.Id;
        ord.SAP_Sales_Order_Number__c = '111';
        ord.Hardware_Serial_Number__c = 'Serial111';
        SAPOrder_tgr_cls.skipTriggerActions = true;
        //ord.SAP_Account__c	= 'SAPAcc001';
        ord.SFDC_Account__c = acc.Id;
        ord.Product_SKU__c 	= 'PRD001';
        ord.Product__c		= product.Id;
        insert ord;
        
        
        //Subscription creation
        SBQQ__Subscription__c subscription1 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription1.Hardware_Serial_Number__c = 'Serial111';
        subscription1.SAP_Order__c = ord.Id;
        insert subscription1;
        
        //create subscription and entitlement manually
        SBQQ__Subscription__c subscription2 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription2.Hardware_Serial_Number__c = 'Serial111';
        insert subscription2;
        
        
        //Create Entitlement - 
        Entitlement Ent 				= Test_COMM_Factory.getEntitlement('Test Ent', acc.Id);
        Ent.Hardware_Serial_Number__c 	= 'Serial111';
        Ent.PAK_ID__c 					= '12345';
        Ent.Service_product__c 			= product.Id;
        Ent.EndDate 					= Date.today();
        Ent.StartDate 					= Date.today().addDays(-1);
        Ent.Subscription__c				= subscription1.Id;
        
        insert Ent;
        
        Entitlement Ent2 				= Test_COMM_Factory.getEntitlement('Test Ent', acc.Id);
        Ent2.Hardware_Serial_Number__c 	= 'Serial111';
        Ent2.PAK_ID__c 					= '12345';
        Ent2.Service_product__c 		= product.Id;
        Ent2.EndDate 					= Date.today();
        Ent2.StartDate 					= Date.today().addDays(-1);
        Ent2.Subscription__c			= subscription2.Id;
        
        insert Ent2;
        //Create Contact
        //Contact cont = Test_COMM_Factory.getContact(acc.Id);
        //system.assertNotEquals(Null, cont.AccountId);
        //insert cont;
    }
    
    @isTest
    static void testESP_LinkSAPOrderToEntitlements_BAT_sch() { 
        Test.startTest();
            ESP_LinkSAPOrderToEntitlements_BAT_SCH sh = new ESP_LinkSAPOrderToEntitlements_BAT_SCH();
            String sch = '0 0 23 * * ?'; 
            sh.iBatchSize = 2;
            system.schedule('Test Territory Check', sch, sh); 
        Test.stopTest();
    }
    
    @isTest
    static void testESP_LinkSAPOrderToEntitlements_BAT() { 
        Test.startTest();
        DateTime LookBackFromDt = DateTime.Now().addDays(-5);
        DateTime LookBackToDt   = DateTime.Now().addDays(0);
        
        Id batchJobId = Database.executeBatch(new ESP_LinkSAPOrderToEntitlements_BAT(), 2);
        system.debug('batchJobId: '+ batchJobId);
        
        //batchJobId = Database.executeBatch(new ESP_LinkSAPOrderToEntitlements_BAT(LookBackFromDt, LookBackToDt), 1);
        //system.debug('batchJobId: '+ batchJobId);
        
       // batchJobId = Database.executeBatch(new ESP_LinkSAPOrderToEntitlements_BAT('select Id from Account'), 1);
        //system.debug('batchJobId: '+ batchJobId);
        
        //batchJobId = Database.executeBatch(new ESP_LinkSAPOrderToEntitlements_BAT('select Id from Contact'), 1);
        //system.debug('batchJobId: '+ batchJobId);
        
        Test.stopTest();
        
        //System assertion for DGX
        //Account acc1 = [select Product_Lines__c from account where name = 'Test Account'];
        //system.assertequals('DGX',acc1.product_lines__c);
    }
}