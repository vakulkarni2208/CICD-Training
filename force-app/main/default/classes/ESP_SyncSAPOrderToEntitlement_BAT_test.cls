@isTest(SeeAllData=false)
public class ESP_SyncSAPOrderToEntitlement_BAT_test {
    
    public static final string accName = 'AccountName';
    
    @testsetup
    public static void setup(){
        
        //Create Account with SAPID
        Account acc = Test_COMM_Factory.getAccount(accName);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = :COMM_Constants.SOBJECT_ACCOUNT AND Name = :COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER];
        acc.SAP_Customer_Number__c = 'SAPAcc001';
        //acc.EMS_Update_Required__c 	= False;
        acc.RecordTypeId = rt.Id;
        insert acc;
        
        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>Customer</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
             
        //Contract creation
        //Contract contract = Test_COMM_Factory.getContract(acc.Id);
        //insert contract;
        
        //Activate contract
        //contract.Status = 'Activated';
        //update contract;
        
        //Create product with Product Code
        Product2 product 		= Test_COMM_Factory.getProduct('Test Product');
        product.Product_Type__c = 'Hardware';
        product.Product_Line__c = 'DGX';
        product.ProductCode 	= 'PRD001';
        product.IsActive 		= true;
        insert product;
        
        //Subscription creation
        /*SBQQ__Subscription__c subscription1 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription1.Hardware_Serial_Number__c = 'Serial111';
        insert subscription1;
        
        //create subscription and entitlement manually
        SBQQ__Subscription__c subscription2 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription2.Hardware_Serial_Number__c = 'Serial111';
        insert subscription2;
        */
        
        //QuoteGeneratorHelperTest.CreateTestOrders();
        
        //list<Entitlement> lstEnt2 = [Select Id From Entitlement where Subscription__c = :subscription2.Id];
        //if (lstEnt2 == null || lstEnt2.isEmpty()){
        //    Entitlement ent2 = new Entitlement(name='TestEnt', AccountId = acc.Id, Subscription__c =  subscription2.Id, Hardware_Serial_Number__c = '1234Test' );
        //    insert ent2;
        //}
        
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
        ord.Hardware_Serial_Number__c = '123456';
        SAPOrder_tgr_cls.skipTriggerActions = true;
        insert ord;
        
        ord.Order_Type__c 	= 'ZMRS';
        ord.SAP_Account__c	= 'SAPAcc001';
        //ord.SFDC_Account__c = acc.Id;
        ord.Product_SKU__c 	= 'PRD001';
        //ord.Product__c		= product.Id;
        update ord;
    }
    
    static testMethod void createEntitlement() {
        Test.startTest();
        	ESP_SyncSAPOrderToEntitlement_BAT bat = new ESP_SyncSAPOrderToEntitlement_BAT();
			bat.LookBackFromDt = DateTime.now().addDays(-1);
			Id batchJobId = Database.executeBatch(bat,1);
        	
        	/*SAP_Order__c ord 	= [select id from SAP_Order__c limit 1];
	        ord.Order_Type__c 	= 'ZMRS';
	        ord.SAP_Account__c	= 'SAPAcc001';
	        //ord.SFDC_Account__c = acc.Id;
	        ord.Product_SKU__c 	= 'PRD001';
	        //ord.Product__c		= product.Id;
	        update ord;
        	
        	ESP_SyncSAPOrderToEntitlement_BAT bat1 = new ESP_SyncSAPOrderToEntitlement_BAT();
			bat1.LookBackFromDt = DateTime.now().addDays(-1);
			Id batchJobId1 = Database.executeBatch(bat1,1);
        	*/
            /*string CRON_EXP = '0 1 * ? * *';
                
             // Schedule the test job
            String jobId = System.schedule('ESP_SyncSAPOrderToEntitlement_BAT_test',  CRON_EXP,  new ESP_SyncSAPOrderToEntitlement_BAT_SCH());
    
             // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    
            // Verify the expressions are the same
            System.assertEquals(CRON_EXP, ct.CronExpression);
    
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);*/
        Test.stopTest();
    }
   
}