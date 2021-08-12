public with sharing class ESP_SyncSAPOrderToEntitlement_BAT implements Database.Batchable<sObject>, Database.RaisesPlatformEvents, Database.Stateful{
    
    //Pending Action Items:
    /// Add Logic for Synced Checkbox : Done
    // - Update Trigger and check if update is from the batch job or other place...
    /// Recurring batch job: Done
    /// Log error on SAP Order: Done
    /// Different logic for Insert vs Update: Done
    /// Custom metadata for recurrance setting similar to ESP_CreateEntFromSubscr_Settings__c....
    
    ///private DateTime LookBackFromDt;
    ///private DateTime LookBackToDt;
    private Integer iRecurTime = 1;
    private String query;
    public DateTime LookBackFromDt;
    
    /*
    public ESP_SyncSAPOrderToEntitlement_BAT() {
    	system.debug('20191213 1.1');
        LookBackFromDt = DateTime.Now().addDays(-1); 
        LookBackToDt   = DateTime.Now();
    }
    public ESP_SyncSAPOrderToEntitlement_BAT(String strQuery) {
    	system.debug('20191213 1.2');
        query = strQuery;
    }
    public ESP_SyncSAPOrderToEntitlement_BAT(DateTime sDate, DateTime eDate) {
    	system.debug('20191213 1.3');
        LookBackToDt   = (eDate != null) ? eDate : DateTime.Now();
        LookBackFromDt = (sDate != null) ? sDate : LookBackToDt.addDays(-1);
    } */
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	system.debug('20191213 2');
        if(query == null || query == '') {
        	System.debug('20191213 2.1');
        	query = 'SELECT Synced_with_Entitlement__c, Product_SKU__c, SAP_Account__c, Name,SFDC_Account__c, Start_Date__c,End_Date__c'
        			+ ',Entitlement_Processing_Status__c, Product__r.Description,Quantity__c,Hardware_Serial_Number__c'
        			+ ',SAP_PAK_ID__c,Product__c,Renewed_PAK_ID__c,SAP_Sales_Order_Number__c,ID, Sold_To_Partner_Lookup__c'
        			+ ',Order_Type__c, Reseller_Account__c, Product_End_Customer_Contact__c, Sold_To_Partner__c, (Select Id From Entitlements__r)'
        			+ ' FROM SAP_Order__c'
        			+ ' where Order_Type__c in (\'ZOR\', \'ZSO\', \'ZDO\', \'ZMRS\', \'ZKB\' )'
        			;
        	
        	query 	+=' AND Entitlement_Type__c != \'PL\'';
			/*if (LookBackFromDt != null && LookBackToDt != null) { 
	        	query 	+=' AND (lastmodifieddate >= ' +LookBackFromDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T') 
	        			+ ' AND lastmodifieddate <= '+LookBackToDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T')+')';
	        } else{*/
	        	query 	+=' AND Synced_with_Entitlement__c ='+ false;
	        ///}
	        //DateTime LookBackFromDt = DateTime.newInstance(2019, 12, 25, 0, 0, 0);
	        if(LookBackFromDt != null)
            	query   +=' AND lastmodifieddate > '+ LookBackFromDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T');
            	
            system.debug('LookBackFromDt: '+ LookBackFromDt);
        }
        
        /* Set Lookback date for next job */
        ///LookBackFromDt = (LookBackToDt != null && DateTime.now() > LookBackToDt) ? LookBackToDt: DateTime.now();
        ///system.debug('new LookBackFromDt: '+ LookBackFromDt + ' DateTime.now(): '+ DateTime.now() + ' LookBackToDt: '+ LookBackToDt);
        
        System.debug('Query: ' + query);
		return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> Scope ){
        system.debug('20191213 3');
        List<SAP_Order__C> lstSAPOrder = Scope;
        
        System.debug('Query Result==' + lstSAPOrder);
        processSAPOrders(lstSAPOrder);
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('20191213 5');
        
        NV_Batch_Job_Setting__mdt batchJobSetting = NV_Utility.getbatchJobSetting('ESP_SyncSAPOrderToEntitlement_BAT');
        
        Decimal dRecurTime  	= batchJobSetting.Frequency__c ; //in minutes
		Decimal dBatchSize 		= batchJobSetting.Batch_Size__c;
		Boolean isJobEnabled 	= batchJobSetting.Disable_Job__c;
        
        if(!isJobEnabled) {
	        iRecurTime 		= (dRecurTime != null) ? integer.valueOf(dRecurTime) : iRecurTime;
	        DateTime nextScheduleDateTime = system.now().addMinutes(iRecurTime);
	      	string minute 	= string.valueof(nextScheduleDateTime.minute());
	      	string second 	= string.valueof(nextScheduleDateTime.second ());
	      	string jobName 	= 'Sync_SAPOrder_to_Entitlement - ' + nextScheduleDateTime.format('hh:mm');
	 		string cronValue= second + ' ' + minute + ' * * * ?' ;
	 		
	    	///ESP_SyncSAPOrderToEntitlement_BAT_SCH sch = new ESP_SyncSAPOrderToEntitlement_BAT_SCH(LookBackFromDt, NULL);
	    	///system.debug('20191213 5: Next Batch Scheduled to process records from '+ LookBackFromDt);
	    	ESP_SyncSAPOrderToEntitlement_BAT_SCH sch = new ESP_SyncSAPOrderToEntitlement_BAT_SCH();
	    	sch.LookBackFromDt = LookBackFromDt;
	    	sch.BATCH_SIZE = (dBatchSize != null) ? integer.valueOf(dBatchSize) : 200;
	    	system.schedule(jobName, cronValue , sch);
        }
    }
    
    public static map<String,String> productMap = new map<String,String>();
    public static map<String,String> accountMap = new map<String,String>();
    
    public void processSAPOrders(List<SAP_Order__C> lstSAPOrder){
    	system.debug('20191213 4');
    	list<Entitlement> lstEntToInsertUpdate  = new list<Entitlement>();
    	list<SAP_Order__c> sapOrdersToUpdate 	= new list<SAP_Order__c>();
    	
        if (lstSAPOrder != null && !lstSAPOrder.isEmpty()) {
        	set<String> sapAccountIds = new set<String>();
    		set<String> sapProductCodes = new set<String>();
        	for(SAP_Order__C sapOrder : lstSAPOrder) {
        		system.debug('20200902 Order Type: '+ sapOrder.Order_Type__c);
        		if(sapOrder.Order_Type__c == 'ZMRS' || sapOrder.Order_Type__c == 'ZKB') {
        			if(sapOrder.SAP_Account__c != null && sapOrder.SAP_Account__c != '' )
        				sapAccountIds.add(sapOrder.SAP_Account__c);
    				if(sapOrder.Sold_To_Partner__c != null && sapOrder.Sold_To_Partner__c != '' )
        				sapAccountIds.add(sapOrder.Sold_To_Partner__c);
    				if(sapOrder.Product_SKU__c != null && sapOrder.Product_SKU__c != '' )
        				sapProductCodes.add(sapOrder.Product_SKU__c);
        		}
        	}
        	
        	system.debug('20200902 sapAccountIds: '+ sapAccountIds);
        	system.debug('20200902 sapProductCodes: '+ sapProductCodes);
        	if(sapProductCodes != null && !sapProductCodes.isEmpty()) {
        		system.debug('20201002 sapProductCodes: '+ sapProductCodes);
	        	for(Product2 prod:[Select id, ProductCode from Product2 where ProductCode in: sapProductCodes]){
		            productMap.put(prod.ProductCode, prod.id);
		        }
    		}
    		
    		if(sapAccountIds != null && !sapAccountIds.isEmpty()) {
    			system.debug('20201002 sapAccountIds: '+ sapAccountIds);
        	
    			list<Account> accounts = [Select id, SAP_Customer_Number__c from Account where SAP_Customer_Number__c in: sapAccountIds];
		        for(Account acc: accounts) {
		            accountMap.put(acc.SAP_Customer_Number__c, acc.id);
		        }
	        }
	        
        	//try {
				for (SAP_Order__C sapOrder : lstSAPOrder) {
					system.debug('20191213 4.1');
					Boolean bError = false;
					
					if(sapOrder.Order_Type__c == 'ZMRS' || sapOrder.Order_Type__c == 'ZKB') {
						system.debug('20200902 accountMap: '+ accountMap);
						system.debug('20200902 productMap: '+ productMap);
						if(sapOrder.SFDC_Account__c == NULL && accountMap != NULL)
							sapOrder.SFDC_Account__c = accountMap.get(sapOrder.SAP_Account__c);
						if(sapOrder.Product__c == NULL && productMap != NULL)
							sapOrder.Product__c = productMap.get(sapOrder.Product_SKU__c); 
						if(sapOrder.Sold_To_Partner_Lookup__c == NULL && accountMap != NULL)
							sapOrder.Sold_To_Partner_Lookup__c = accountMap.get(sapOrder.Sold_To_Partner__c);
					}
					
					sapOrder.Entitlement_Processing_Status__c = '';
					if(sapOrder.SFDC_Account__c == null || sapOrder.Product__c == null) {
						//if(sapOrder.Order_Type__c != 'ZMRS'  || sapOrder.Order_Type__c == 'ZKB') 
							bError = true;
						if(sapOrder.SFDC_Account__c == null)
							sapOrder.Entitlement_Processing_Status__c  = 'ERROR: Account missing is SFDC;';// for SAP Account number '+ ((sapOrder.SAP_Account__c == null) ? '': sapOrder.SAP_Account__c) + ';';
						if(sapOrder.Product__c == null)
							sapOrder.Entitlement_Processing_Status__c += 'ERROR: Product missing in SFDC;';// for SAP Product SKU '  + ((sapOrder.Product_SKU__c == null) ? '': sapOrder.Product_SKU__c) + ';';
					}
					
					list<Entitlement> lstEnt = sapOrder.Entitlements__r;
                    if (lstEnt.isEmpty()){
						Entitlement ent 	= getEntitlementFromSAPOrder(sapOrder, new Entitlement());
						if(!bError) {
							lstEntToInsertUpdate.add(ent);
						}
					} else {
						for (Entitlement existingEnt : lstEnt){
							existingEnt = getEntitlementFromSAPOrder(sapOrder, existingEnt);
							if(!bError) {
								lstEntToInsertUpdate.add(existingEnt);
							}
						}
					}
					
					if(!bError) {
						sapOrder.Entitlement_Processing_Status__c = 'Entitlement is created in Service Cloud for '+ sapOrder.Name;
					}
					sapOrder.Synced_with_Entitlement__c = true;
					sapOrdersToUpdate.add(sapOrder);
				}
			
				system.debug('***lstEntToInsertUpdate: ' + lstEntToInsertUpdate.size());
			
				if (!lstEntToInsertUpdate.isEmpty()){
					upsert lstEntToInsertUpdate;
					
					/*Database.UpsertResult[] lstSR = database.upsert(lstEntToInsertUpdate, false);
					
					list<Service_Cloud_Error_Log__c> lstEntCRUDStatus = new list<Service_Cloud_Error_Log__c>();
					for (integer i = 0; i < lstSR.size(); i++){
						Database.UpsertResult sr = lstSR[i];
						Service_Cloud_Error_Log__c entCRUDError = new Service_Cloud_Error_Log__c();
						entCRUDError.Functionality_Name__c 		= 'ESP_CreateEntFromSubscr_Sch';
						if (!sr.isSuccess()){
							// Operation failed, so get all errors 
							system.debug('The following error has occurred.');
							entCRUDError.Error_Type__c 			= 'EntitlementSync Failure';	
							string errorDetails 				= 'Id erred = ' + lstEntToInsertUpdate[i].Id +  ' |err.StatusCode = ' + sr.getErrors()[0].getStatusCode() + ' |err.getFields() =' + sr.getErrors()[0].getFields() + ' | err.getStatusCode() = ' + sr.getErrors()[0].getStatusCode() + ' | err.getMessage() = ' +sr.getErrors()[0].getMessage();
							entCRUDError.Error_Description__c 	= errorDetails;
							system.debug('***errorDetails: ' + errorDetails);
						}else{
							// Operation was successful, so get the ID of the record that was processed
							system.debug('Successfully Created/Edited Entitlement.Id: ' + sr.getId());
							entCRUDError.Error_Type__c 			= 'EntitlementSync Success';
							entCRUDError.Error_Description__c 	= 'Successfully Created/Edited Entitlement.Id: ' + sr.getId();
						}
						lstEntCRUDStatus.add(entCRUDError);
					}
					
					//insert the stauts to Service_Cloud_Error_Log__c object
					if (!lstEntCRUDStatus.isEmpty()){
						Database.insert(lstEntCRUDStatus, false);
					}*/
				}
				
				if(!sapOrdersToUpdate.isEmpty()) {
					SAPOrder_tgr_cls.skipTriggerActions = true;
					update sapOrdersToUpdate;
					SAPOrder_tgr_cls.skipTriggerActions = false;
				}
        	//}  catch(Exception ex){}
        }
        system.debug('---------Exiting processSubscriptions() method-------------------');
    }
    
    public static Entitlement getEntitlementFromSAPOrder(SAP_Order__C sapOrder, Entitlement ent) {
    	String entName = string.IsBlank(sapOrder.Hardware_Serial_Number__c) 
    						? sapOrder.SAP_PAK_ID__c  + '-' + sapOrder.Product__r.Description 
    						: sapOrder.Hardware_Serial_Number__c + '-' + sapOrder.Product__r.Description;
		
		/*if(sapOrder.Order_Type__c == 'ZMRS' || sapOrder.Order_Type__c == 'ZKB') {
			system.debug('20200902 accountMap: '+ accountMap);
			system.debug('20200902 productMap: '+ productMap);
			ent.AccountId 			= accountMap.get(sapOrder.SAP_Account__c);
			ent.Service_Product__c 	= productMap.get(sapOrder.Product_SKU__c);
		}
		else {*/
    		ent.AccountId 			= sapOrder.SFDC_Account__c;
    		ent.Service_Product__c 	= sapOrder.Product__c;
    		//ent.Product__c 		= sapOrder.Product__c;
    		ent.Partner__c 			= sapOrder.Sold_To_Partner_Lookup__c;
		//}
		ent.Name 					= entName.left(80);
		ent.StartDate 				= sapOrder.Start_Date__c;
		ent.EndDate 				= sapOrder.End_Date__c;
		ent.PAK_ID__c 				= sapOrder.SAP_PAK_ID__c;
		ent.Renewed_PAK_ID__c 		= sapOrder.Renewed_PAK_ID__c;
		ent.Renewal_Quantity__c		= sapOrder.Quantity__c;
		ent.NVIDIA_Sales_Order__c	= sapOrder.SAP_Sales_Order_Number__c;
		ent.SAP_Order__c 			= sapOrder.Id;
		ent.Order_Type__c 			= sapOrder.Order_Type__c;
        ent.VAR__c 					= sapOrder.Reseller_Account__c;
        ent.Customer_Contact__c     = sapOrder.Product_End_Customer_Contact__c;
		if(ent.Id == null) { //On Insert
			ent.Hardware_Serial_Number__c = sapOrder.Hardware_Serial_Number__c;
		}
		//ent.Regular_Price__c		= sapOrder.SBQQ__RegularPrice__c;
		//ent.Renewal_Price__c		= sapOrder.SBQQ__RenewalPrice__c;
		//ent.Renewed_Date__c 		= sapOrder.SBQQ__RenewedDate__c;
		//ent.Entitlement_ID_SAP__c	= sapOrder.Entitlement_ID__c;
		//ent.Renewed_Entitlement_ID__c = sapOrder.Renewed_Entitlement_ID__c;
    	return ent;
    }
}