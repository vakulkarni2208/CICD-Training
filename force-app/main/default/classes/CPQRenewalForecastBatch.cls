global class CPQRenewalForecastBatch implements Database.Batchable<sObject> , Database.Stateful {
    
    String query;
    global List<Contract> contracts{get;set;}

    global CPQRenewalForecastBatch() {
        //contracts=mycontracts;
    }
    
    

    global Integer recordsProcessed = 0;
    global Map<String,String> errorOrders=new Map<String, String>();
    global List<String> successOrders=new List<String>();
    global List<String> conList=new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT CreatedDate, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND EndDate >=:system.today()]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contract> scope){

        //Update Renewal Forecast to True and Add to Cons to Update List so it can be processed by the Database Save Result and no an update
        List<Contract> constoUpdate=new List<Contract>();

        for(Contract contract:scope){
            
            DateTime x24hrDate=contract.CreatedDate.addHours(24);
            if(x24hrDate <= system.now() || test.isRunningTest()){
                constoUpdate.add(contract);

                contract.SBQQ__RenewalForecast__c = TRUE;
                recordsProcessed = recordsProcessed + 1;
                conlist.add(contract.id);
            }

        }


    

        //Save the Contract, if error messages appear, grab the ID that caused the error
        Database.SaveResult[] srList=Database.update(constoUpdate, false);

        for(Database.SaveResult sr:srList){
            if(sr.isSuccess()){
                system.debug('Success');
                conlist.add(constoUpdate.get(0).id);
                successOrders.add(constoUpdate.get(0).id);
            }else{
                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    errorOrders.put(constoUpdate.get(0).id,err.getMessage());
                    System.debug('SAP Order fields that affected this error: ' + err.getFields());
                }
            }
        }


    }
    global void finish(Database.BatchableContext bc){
       // Get the ID of the AsyncApexJob representing this batch job
       // from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
       String errorDetails='';
       String successDetails='';
       system.debug(errorOrders);

       if(!errorOrders.isEmpty()){
            errorDetails='<p>Following Errors Occured: </p>';
            for(String s:errorOrders.keySet()){
                errorDetails = errorDetails + '<p>Failed ID: ' + s + ' Reason: ' + errorOrders.get(s) + '<br/></p>';
           }
       }

       if(!successOrders.isEmpty()){
            successDetails='<p>Following Contracts Renewed Successfully: </p>';
            for(String s:successOrders){
                successDetails = successDetails + '<p>Passed ID: ' + s + '<br/></p>';
           }
       }
       
       if(!errorOrders.isEmpty() || !successOrders.isEmpty()){
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
              TotalJobItems, CreatedBy.Email
              FROM AsyncApexJob WHERE Id =
              :BC.getJobId()];
           //Send an email to the Apex job's submitter notifying of job completion.
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] {a.CreatedBy.Email};
           //String[] ccAddresses = new String[] {'messayas@nvidia.com','tchestnut@salesforce.com'};
           //String[] ccAddresses = new String[] {'tchestnut@salesforce.com'};
           
           mail.setToAddresses(toAddresses);
           //mail.setCcAddresses(ccAddresses);
           mail.setSubject('CPQ Contract Renewal Batch Job' + a.Status);
           mail.setHTMLBody('<p>' + successDetails + '</p>' + '<p>' + errorDetails + '</p>');
           
           if(!test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
           
           system.debug(conlist);
       }

       //List<String> quoteIds=new List<String>();
       //List<String> oppIds=new List<String>();

       //if(!conList.isEmpty()){
       //       for(Opportunity o:[Select id, SBQQ__PrimaryQuote__c from Opportunity where SBQQ__RenewedContract__c IN: conList]){
       //           oppIds.add(o.id);
       //       }

       //       for(SBQQ__Quote__c quote: [Select id from SBQQ__Quote__c where SBQQ__Opportunity2__c IN: oppIds]){
       //           quoteIds.add(quote.id);
       //       }

   
       //}
       
    }
    
}