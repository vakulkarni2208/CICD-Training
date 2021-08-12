/*
 *  This is a batch job that attempts to sync the IDM DGX User via an external callout
 *  Following Contact records are eligible for sync
 *  - must be a DGX Contact i.e. is_DGX_Contact__c = true
 *  - sync is yet to take place i.e. Synced_IDM_DGX__c  = false
 *  This batch job may be instantiated in a couple of ways
 *  - a single argument constuctor with a specific contact identifier that needs to be synced in IDM
 *  - a no argument constructor where all contacts that have not been synced yet will be processed
 */ 
global class IDM_DGX_RETRY implements Database.Batchable<sObject>, Database.AllowsCallouts {
  String query;
  List<Contact> contactList = new List<Contact>();
  public string MESSAGE_TEXT {get;set;}
  public string MESSAGE_TYPE {get;set;}
  global IDM_DGX_RETRY(String contactId){
    query = PRFT_DomainLayer.buildQueryFields('Contact',' Where Id = \''+contactId+'\'','Select ');
        System.debug('Checking query constructor--'+query);
  }
  // Retrieve all the DGX contact for which is created isfalse. Is created is only set when a success response is received from webservice.
    global IDM_DGX_RETRY() {
        query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_DGX_Contact__c = true and Synced_IDM_DGX__c  = false','Select ');
        System.debug('Checking query--'+query);
    }
    
  // Query the Contacts
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('checking query11---'+query);
        return Database.getQueryLocator(query);
    }
  // Execute the batch apex to resync them due to batch limits it is ideal to set the batch size as 10.
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        System.debug('checking execuet 11---'+scope);
        Map<String,List<RMA__c>> caseVsRMA = new Map<String,List<RMA__c>> ();
        RMA_IDM_Callouts calloutCls = new RMA_IDM_Callouts();
        integer i =0;
        Map<Id,Contact> conMap = new Map<Id,Contact> (scope);
        Map<String,String> conVsUser = new Map<String,String>();
        Map<String,User> conVsUserMap = new Map<String,User>();
        List<User> userUpdates = new List<User>();
        System.debug('checking mapdd--'+conMap);
        if(!conMap.isEmpty()){
            List<User> usrList = [Select Id, ContactId,isActive,FederationIdentifier,Email From User Where ContactId in :conMap.keySet() and isActive = true];
            if(!usrList.isEmpty()){
                for(User usr :usrList){
                    conVsUser.put(usr.ContactId,usr.email);
                    conVsUserMap.put(usr.ContactId,usr);
                    
                }
            }
        }

        System.debug('checking map--'+conVsUser);
       if(!conVsUser.isEmpty())
       for(String str : conMap.keySet()){
            if(i >= 10)
            break;
           Contact con = conMap.get(str);
           if(conVsUser.containsKey(str)){
            String usrId = conVsUser.get(str);// setting email
            User usrFed = conVsUserMap.get(str);
            String response = calloutCls.invokeIDMDGXUserCreationCallout(str,'en',usrId);
            // Update the flag on contact to indicate callout was successful.
            if(!response.contains('Callout Exception') && con != null){
                con.Synced_IDM_DGX__c = true;
                con.IDM_DGX_Callout_Message__c = response;
                if(String.isBlank(usrFed.FederationIdentifier)){
                    usrFed.FederationIdentifier = usrFed.Email;
                    userUpdates.add(usrFed);
                }
                contactList.add(con);
            } else if(con != null){
                con.IDM_DGX_Callout_Message__c = response;
                contactList.add(con);
            }
            
         i++;
        }
    }
    List<Database.SaveResult> lstUpdate = new List<Database.SaveResult>();
     if(!contactList.isEmpty()){
          Database.update(contactList,false);
       }
       if(!userUpdates.isEmpty()){
          lstUpdate = Database.update(userUpdates,false);
       }
       list<Service_Cloud_Error_Log__c> lstIDMIntegrationErrors = new  list<Service_Cloud_Error_Log__c>();
       if (!lstUpdate.isEmpty()){
          for (integer j = 0; j < lstUpdate.size(); j++){
                    Database.SaveResult sr = lstUpdate[j];
                    if (!sr.isSuccess()){
                        // Operation failed, so get all errors 
                        system.debug('The following error has occurred.');
                        string errorDetails = 'User Id erred = ' + lstUpdate[j].Id + ' |err.getFields() =' + sr.getErrors()[0].getFields() + ' | err.getStatusCode() = ' + sr.getErrors()[0].getStatusCode() + ' | err.getMessage() = ' +sr.getErrors()[0].getMessage();
                        system.debug('***errorDetails: ' + errorDetails);
                        Database.DMLOptions dml = new Database.DMLOptions();
                        dml.allowFieldTruncation = true;
                        String recordUrl=   System.Url.getSalesforceBaseURL().toExternalForm() +'/'+ lstUpdate[j].Id;
                        Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(  Functionality_Name__c = 'IDM DGX Batch Update', 
                                              Error_Code__c = errorDetails,  Record_URL__c = recordURL,Error_Type__c = 'SALESFORCE BATCH');
                        errorLog.setOptions(dml);
                        lstIDMIntegrationErrors.add(errorLog);
                    }else{
                        // Operation was successful, so get the ID of the record that was processed
                        system.debug('Successfully Updated User with User.Id: ' + sr.getId());
                    }
                }
                                        
                if (!lstIDMIntegrationErrors.isEmpty()){
                    database.insert(lstIDMIntegrationErrors, false);
                }
            }

    }
    
  // Final Method checks if all the records have been executed or not.
    global void finish(Database.BatchableContext BC) {
        // calling Grid as dgx is processed
        //if(System.label.ExecuteIDMSyncJobs == 'true'){
             String query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_GRID_Contact__c = true and Synced_IDM_GRID__c  = false','Select ');
             List<Contact> userList = Database.query(query);
             if(!userList.isEmpty()){
            IDM_Grid_Retry dgx = new IDM_Grid_Retry();
            if(!Test.isRunningTest())
                Id batchJobId = Database.executebatch(dgx,10);
            }
        //}
         
    } 

  
}