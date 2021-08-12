global class CPQ_SAP_Legacy_Renewal_Quoted_Batch implements Database.Batchable<sObject> , Database.Stateful {
    
    String query;
    
    global CPQ_SAP_Legacy_Renewal_Quoted_Batch() {
        
    }
    
    global Integer recordsProcessed = 0;
    global Map<String,String> errorOrders=new Map<String, String>();
    global List<String> successOrders=new List<String>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
            if(test.isRunningTest()){
                return Database.getQueryLocator([Select SBQQ__RenewalQuoted__c, LegacyRenewalQuotedDate__c from Contract where SBQQ__RenewalQuoted__c=false]);
            }else{
                return Database.getQueryLocator([Select SBQQ__RenewalQuoted__c, LegacyRenewalQuotedDate__c from Contract where SBQQ__RenewalQuoted__c=false and LegacyRenewalQuotedDate__c<=:system.today() and EndDate >=:system.today()]);
            }
        
    }

    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        List<Contract> constoUpdate=new List<Contract>();
        for(Contract con:scope){
            con.SBQQ__RenewalQuoted__c=true;
            constoUpdate.add(con);
        }

        //Save the Contract, if error messages appear, grab the ID that caused the error
        Database.SaveResult[] srList=Database.update(constoUpdate, false);

        for(Database.SaveResult sr:srList){
            if(sr.isSuccess()){
                system.debug('Success');
                
                successOrders.add(constoUpdate.get(0).id);
            }else{
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    errorOrders.put(constoUpdate.get(0).id,err.getMessage());
                    System.debug('Contract fields that generated this error: ' + err.getFields());
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
            successDetails='<p>Following Contracts Renewed/Quoted Successfully: </p>';
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

           
           mail.setToAddresses(toAddresses);
           //mail.setCcAddresses(ccAddresses);
           mail.setSubject('CPQ Legacy Renewal Quoted Batch Job' + a.Status);
           mail.setHTMLBody('<p>' + successDetails + '</p>' + '<p>' + errorDetails + '</p>');
           
           if(!test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           }
           
       }
       
    }
    
}