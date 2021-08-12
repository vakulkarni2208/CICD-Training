/*
 *  This is a batch job that attempts to sync the IDM GRID User via an external callout
 *  Following Contact records are eligible for sync
 *  - must be a GRID Contact i.e. is_GRID_Contact__c = true
 *  - sync is yet to take place i.e. Synced_IDM_GRID__c  = false
 *  This batch job may be instantiated in a couple of ways
 *  - a single argument constuctor with a specific contact identifier that needs to be synced in IDM
 *  - a no argument constructor where all contacts that have not been synced yet will be processed
 */ 
global class IDM_Grid_Retry implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    String query;
  List<Contact> contactList = new List<Contact>();
  public string MESSAGE_TEXT {get;set;}
  public string MESSAGE_TYPE {get;set;}
  global IDM_Grid_Retry(String contactId){
    query = PRFT_DomainLayer.buildQueryFields('Contact',' Where Id = \''+contactId+'\'','Select ');
        System.debug('Checking query constructor--'+query);
  }
  // Retrieve all the DGX contact for which is created isfalse. Is created is only set when a success response is received from webservice.
    global IDM_Grid_Retry() {
        query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_GRID_Contact__c = true and Synced_IDM_GRID__c  = false','Select ');
        System.debug('Checking query--'+query);
    }
    
  // Query the Contacts
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('checking query---'+query);
        return Database.getQueryLocator(query);
    }
  // Execute the batch apex to resync them due to batch limits it is ideal to set the batch size as 10.
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        Map<String,List<RMA__c>> caseVsRMA = new Map<String,List<RMA__c>> ();
        RMA_IDM_Callouts calloutCls = new RMA_IDM_Callouts();
        integer i =0;
        Map<Id,Contact> conMap = new Map<Id,Contact> (scope);
        Map<String,String> conVsUser = new Map<String,String>();
        Map<String,User> conVsUserMap = new Map<String,User>();
        List<User> userUpdates = new List<User>();
        if(!conMap.isEmpty()){
            List<User> usrList = [Select Id, ContactId,isActive,FederationIdentifier,Email From User Where ContactId in :conMap.keySet() and isActive = true];
            if(!usrList.isEmpty()){
                for(User usr :usrList){
                    conVsUser.put(usr.ContactId,usr.email);
                    conVsUserMap.put(usr.ContactId,usr);
                }
            }
        }
       if(!conVsUser.isEmpty())
       for(String str : conMap.keySet()){
            if(i >= 10)
            break;
           Contact con = conMap.get(str);
           if(conVsUser.containsKey(str)){
            String usrId = conVsUser.get(str); // setting email 
            User usrFed = conVsUserMap.get(str);
            String response = calloutCls.invokeIDMGRIDUserCreationCallout(str,'en',usrId); 
            // Update the flag on contact to indicate callout was successful.
            if(!response.contains('Callout Exception') && con != null){
                con.Synced_IDM_GRID__c = true;
                con.IDM_GRID_Callout_Message__c = response;
                if(String.isBlank(usrFed.FederationIdentifier)){
                    usrFed.FederationIdentifier = usrFed.Email;
                    userUpdates.add(usrFed);
                }
                contactList.add(con);
            } else if(con != null){
                con.IDM_GRID_Callout_Message__c = response;
                contactList.add(con);
            } 
            
            
         i++;
        }
    }
     if(!contactList.isEmpty()){
          Database.update(contactList,false);
       }
       if(!userUpdates.isEmpty()){
          Database.update(userUpdates,false);
       }

    }
    
  // Final Method checks if all the dgx records have been processed or not.
    global void finish(Database.BatchableContext BC) {
        if(System.label.ExecuteIDMSyncJobs == 'true'){
            String query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_DGX_Contact__c = true and Synced_IDM_DGX__c  = false','Select ');
             List<Contact> userList = Database.query(query);
             if(userList != null && !userList.isEmpty()){
            IDM_DGX_RETRY dgx = new IDM_DGX_RETRY();
            if(!Test.isRunningTest())
                Id batchJobId = Database.executebatch(dgx,10);
            }
        }
    } 

  
}