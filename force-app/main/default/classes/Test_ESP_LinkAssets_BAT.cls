@isTest
public with sharing class Test_ESP_LinkAssets_BAT {
    @isTest
    public static void testAsset(){
        //Account creation
        Account acc = Test_COMM_Factory.getAccount('Test Account');
        insert acc;
        
        //Asset ast = Test_COMM_Factory.getAsset(NAME, acc.Id);
        //insert ast;
        
        Asset ast 							=  new Asset();
        ast.Name 							= 'astName';
        ast.SAP_Account_Number__c 			= 'SAP123';
        ast.Sold_To_Partner_SAP_Number__c 	= 'SAP123';
        ast.VAR_SAP_Number__c 				= 'SAP123';
        ast.Serial_Number__c 				= 'BAT11111';
        ast.Material_Number__c 				= '11111';
        ast.SAP_PECC_Number__c 				= '11111';  
        ast.AccountId 						= acc.Id;
        insert ast;
        
        Entitlement Ent 				= Test_COMM_Factory.getEntitlement('NAME', acc.Id);
        Ent.Hardware_Serial_Number__c 	= 'BAT11111';
        Ent.PAK_ID__c 					= '12345';
        //Ent.Service_product__c 			= product.Id;
        //Ent.EndDate 					= Date.today();
        //Ent.StartDate 				= Date.today().addDays(-1);
        insert Ent;
    }
    
    @isTest
    static void testESP_RollupProductLinesOnAccount_BAT() { 
        Id batchJobId = Database.executeBatch(new ESP_LinkAssets_BAT());
        System.assert(batchJobId != null);
        DateTime LookBackFromDt = DateTime.now();
        DateTime LookBackToDt = DateTime.now();
        ESP_LinkAssets_BAT batchObj = new ESP_LinkAssets_BAT(LookBackFromDt, LookBackToDt);
        String query = 'select Id, SerialNumber, PAKID__c, Link_Entitlements__c, Link_Components__c '
            + ' from Asset where (Link_Entitlements__c = true OR Link_Components__c = true)'
            + ' AND (lastmodifieddate >= ' +LookBackFromDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T') 
            + ' AND lastmodifieddate <= '+LookBackToDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T')
            + ')';
        Id batchJobId2 = Database.executeBatch(new ESP_LinkAssets_BAT(query));
    }
    
    @isTest
    static void testESP_LinkAssets_BAT_SCH() { 
        Test.startTest();
            ESP_LinkAssets_BAT_SCH sh = new ESP_LinkAssets_BAT_SCH();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test ESP_LinkAssets_BAT_SCH', sch, sh); 
        Test.stopTest();
    }
}