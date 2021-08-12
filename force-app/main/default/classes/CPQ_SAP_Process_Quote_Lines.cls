/*
Date:  8/16/2018
Developer:  Tayo Chestnut
Details:  Process Quote Lines coming from SAP Orders that have been processed in Batches to avoid record locking issues
Schedule to run every 20 minutes
*/


global class CPQ_SAP_Process_Quote_Lines implements Database.Batchable<sObject> {
    
    String query;
    
    global CPQ_SAP_Process_Quote_Lines() {

        //List<SAP_Order__c> orders=new List<SAP_Order__c>([Select id, Status__c,Error_Log__c, Subscription_Term__c, Entitlement_ID__c,SAP_PAK_ID__c,SFDC_Quote_Line__c from SAP_Order__c]);
        //system.debug(orders);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Gather processed lines
        return Database.getQueryLocator([Select id, Status__c,Error_Log__c, Subscription_Term__c, Entitlement_ID__c,SAP_PAK_ID__c,SFDC_Quote_Line__c from SAP_Order__c where Status__c='Processed']);
    }

    global void execute(Database.BatchableContext BC, List<SAP_Order__c> scope) {
        
        Map<String, SAP_Order__c> sapMap=new Map<String, SAP_Order__c>();
        Map<String,String> errorOrders=new Map<String, String>();

        //Retrieve all of the Quote Line Ids from the SAP Processed Orders
        for(SAP_Order__c order: scope){
            sapMap.put(order.SFDC_Quote_Line__c,order);
        }

        //Create List of Quote Lines to Edit
        List<SBQQ__QuoteLine__c> qls=new List<SBQQ__QuoteLine__c>([Select id,SAP_Order__c,SBQQ__RenewedSubscription__c,NumberOfMonthsContract__c,Entitlement_ID__c,PAK_ID__c,SBQQ__SubscriptionTerm__c from SBQQ__QuoteLine__c where id IN: sapMap.keySet()]);

        //Updated Quote lines with Pak Ids and Entitled Ids
        for(SBQQ__QuoteLine__c ql: qls){
            SAP_Order__c order=sapMap.get(ql.id);
            ql.Entitlement_ID__c=order.Entitlement_ID__c;
            ql.PAK_ID__c=order.SAP_PAK_ID__c;
            
        }

        //Save the Quote Lines, if error messages appear, grab the ID that caused the error
        Database.SaveResult[] srList=Database.update(qls, false);

        for(Database.SaveResult sr:srList){
            if(sr.isSuccess()){
                system.debug('Success');
            }else{
                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    errorOrders.put(sr.getId(),err.getMessage());
                    System.debug('SAP Order fields that affected this error: ' + err.getFields());
                }
            }
        }

        system.debug('Checking Orders');
        //Update SAP Order Records as Synced or Error
        for(SAP_Order__c order:scope){
            if(errorOrders.containsKey(order.SFDC_Quote_Line__c)){
                    system.debug('Error Occured');
                    order.Status__c='Error';
                    order.Error_Log__c=errorOrders.get(order.SFDC_Quote_Line__c);
                }else{
                    system.debug('Success');
                    order.Status__c='Synced';
                }
        }

        update scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}