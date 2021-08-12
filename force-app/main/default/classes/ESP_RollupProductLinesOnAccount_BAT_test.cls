@isTest
public class ESP_RollupProductLinesOnAccount_BAT_test {
	  
    @testSetup 
    static void setup() {
        //Create product
        Product2 product 		= Test_COMM_Factory.getProduct('Test Product');
        product.Product_Type__c = 'Hardware';
        product.Product_Line__c = 'DGX';
        product.IsActive 		= true;
        insert product;
        
        //Create Account -
        Account acc = Test_COMM_Factory.getAccount('Test Account');
        insert acc;
        
        //Create Entitlement - 
        Entitlement Ent 				= Test_COMM_Factory.getEntitlement('Test Ent', acc.Id);
        Ent.Hardware_Serial_Number__c 	= '123';
        Ent.PAK_ID__c 					= '12345';
        Ent.Service_product__c 			= product.Id;
        Ent.EndDate 					= Date.today();
        Ent.StartDate 					= Date.today().addDays(-1);
        insert Ent;
        
        //Create Contact
        Contact cont = Test_COMM_Factory.getContact(acc.Id);
        system.assertNotEquals(Null, cont.AccountId);
        insert cont;
    }
    
    @isTest
    static void testESP_RollupProductLinesOnAccount_BAT_sch() { 
        Test.startTest();
            ESP_RollupProductLinesOnAccount_BAT_SCH sh = new ESP_RollupProductLinesOnAccount_BAT_SCH();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Territory Check', sch, sh); 
        Test.stopTest();
    }
    
    @isTest
    static void testESP_RollupProductLinesOnAccount_BAT() { 
        Test.startTest();
        DateTime LookBackFromDt = DateTime.Now().addDays(-5);
        DateTime LookBackToDt   = DateTime.Now().addDays(0);
        
        Id batchJobId = Database.executeBatch(new ESP_RollupProductLinesOnAccount_BAT(), 1);
        system.debug('batchJobId: '+ batchJobId);
        
        batchJobId = Database.executeBatch(new ESP_RollupProductLinesOnAccount_BAT(LookBackFromDt, LookBackToDt), 1);
        system.debug('batchJobId: '+ batchJobId);
        
        batchJobId = Database.executeBatch(new ESP_RollupProductLinesOnAccount_BAT('select Id from Account'), 1);
        system.debug('batchJobId: '+ batchJobId);
        
        batchJobId = Database.executeBatch(new ESP_RollupProductLinesOnAccount_BAT('select Id from Contact'), 1);
        system.debug('batchJobId: '+ batchJobId);
        
        Test.stopTest();
        
        //System assertion for DGX
        Account acc1 = [select Product_Lines__c from account where name = 'Test Account'];
        system.assertequals('DGX',acc1.product_lines__c);
    }
}