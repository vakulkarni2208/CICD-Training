/*
 *  This is a batch job that attempts to deactivate (and sync) the IDM DGX/GRID Users via an external callout
 *  Following User records are eligible for sync
 *  - User record is inactive (i.e. isActive = false)
 *  - must be a DGX Contact (i.e. Contact.is_DGX_Contact__c = true) or GRID Contact (i.e. Contact.is_GRID_Contact__c = true)
 *  - deactivate sync is yet to take place i.e. Deactivation_Sync_IDM_DGX__c = false or Deactivation_Sync_IDM_GRID__c = false
 *  This batch job may be instantiated in a couple of ways
 *  - a single argument constuctor with a specific User record identifier that needs to be de-activated & synced in IDM
 *  - a no argument constructor where all inactive DGX/GRID user contacts that have not been synced yet will be processed
 */ 
global class IDM_User_Deactivation_Sync implements Database.Batchable<sObject>, Database.AllowsCallouts {
  String query;
  List<Contact> contactList = new List<Contact>();
  public string MESSAGE_TEXT {get;set;}
  public string MESSAGE_TYPE {get;set;}
  // This is just used for troubleshooting by passing a single record.
  global IDM_User_Deactivation_Sync(String usrId){
    query = PRFT_DomainLayer.buildQueryFields('User',' Where Id = \''+usrId+'\'','Select ');
        System.debug('Checking query constructor--'+query);
  }
  // Retrieve all the Inactive Grid/DGX contact for which is sync_IDM checkbox  isfalse. Is created is only set when a success response is received from webservice.
    global IDM_User_Deactivation_Sync() {
        //query = PRFT_DomainLayer.buildQueryFields('User',' Where (Contact.is_DGX_Contact__c = true or Contact.is_GRID_Contact__c = true) and (Deactivation_Sync_IDM_DGX__c = false or Deactivation_Sync_IDM_GRID__c = false) and IsActive = false','Select Contact.is_DGX_Contact__c,Contact.is_GRID_Contact__c ,');
        query = PRFT_DomainLayer.buildQueryFields('User',' Where Deactivation_Sync_IDM_DGX__c = false and IsActive = false and (Profile.name =\'ESP Community User\' or Profile.name =\'NVES Community User Non-Admin\')  and (Not Email LIKE \'%invalid%\')','Select ');
        System.debug('Checking query--'+query);
    }
  // Query the Contacts
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('checking query11---'+query);
        return Database.getQueryLocator(query);
    }
  // Execute the batch apex to resync them due to batch limits it is ideal to set the batch size as 10.
    global void execute(Database.BatchableContext BC, List<User> scope) {
        System.debug('checking execuet 11---'+scope);
        Map<String,List<RMA__c>> caseVsRMA = new Map<String,List<RMA__c>> ();
        List<User> usrList = new List<User>();
        Map<Id,user> userMap = new Map<Id,User>();
        integer i =0;
        RMA_IDM_Callouts callout = new RMA_IDM_Callouts();
        for(User usr : scope){
              if(i>=10)
              break; 
          //if(usr.Contact.is_DGX_Contact__c == true || usr.Contact.is_GRID_Contact__c == true ){
           //if(usr.Contact.is_DGX_Contact__c == true && usr.Deactivation_Sync_IDM_DGX__c == false){
                   // String response = callout.invokeIDMDGXUserDeactivationCallout(usr.ContactId,usr.LanguageLocaleKey,usr.Id);
                   String response = callout.invokeIDMCommunityUserDeactivationCallout(usr.email);
                   if(!response.contains('Callout Exception') && usr.Community_ContactId__c  != null){
                        if(!userMap.containsKey(usr.Id)){
                            userMap.put(usr.Id,usr);
                        }
                        User u1 = userMap.get(usr.Id);
                        u1.Deactivation_Sync_IDM_DGX__c = true;
                        u1.IDM_DGX_Deactivation_Callout_Message__c = response;
                        userMap.put(usr.Id,u1);
                      
                    } else if(usr.Community_ContactId__c  != null){
                        if(!userMap.containsKey(usr.Id)){
                            userMap.put(usr.Id,usr);
                        }
                        User u1 = userMap.get(usr.Id);
                        u1.IDM_DGX_Deactivation_Callout_Message__c = response;
                        userMap.put(usr.Id,u1);
                    }
                    i++;
                //}
                /*if(usr.Contact.is_GRID_Contact__c == true && usr.Deactivation_Sync_IDM_GRID__c == false ){
                        System.debug('with in grid Deactivation---'+usr.Id);
                   String response = callout.invokeIDMGridUserDeactivationCallout(usr.ContactId,usr.LanguageLocaleKey,usr.Id);
                   if(!response.contains('Callout Exception') && usr.ContactId != null){
                        if(!userMap.containsKey(usr.Id)){
                            userMap.put(usr.Id,usr);
                        }
                        User u1 = userMap.get(usr.Id);
                        u1.Deactivation_Sync_IDM_GRID__c = true;
                        u1.IDM_GRID_Deactivation_Callout_Message__c = response;
                        userMap.put(usr.Id,u1);
                    } else if(usr.Contact != null){
                        if(!userMap.containsKey(usr.Id)){
                            userMap.put(usr.Id,usr);
                        }
                        User u1 = userMap.get(usr.Id);
                        u1.IDM_GRID_Deactivation_Callout_Message__c = response;
                       userMap.put(usr.Id,u1);
                    }

                    i++;
                }*/
            //}
         }// end for
         if(!userMap.isEmpty()){
                Database.update(userMap.values(),false);
          }
        
    }
    
    // Final Method checks if all the records have been executed or not.
    global void finish(Database.BatchableContext BC) {
        // calling final
        System.debug('With in final.');
        if(System.label.ExecuteIDMDeactivation == 'true'){
            query = PRFT_DomainLayer.buildQueryFields('User',' Where Deactivation_Sync_IDM_DGX__c = false and IsActive = false and (Profile.name =\'ESP Community User\' or Profile.name =\'NVES Community User Non-Admin\') and (Not Email LIKE \'%invalid%\')','Select ');
            List<User> userList = Database.query(query);
            if(userList != null && !userList.isEmpty()){
                IDM_User_Deactivation_Sync dgx = new IDM_User_Deactivation_Sync();
                if(!Test.isRunningTest()){
                    Id batchJobId = Database.executebatch(dgx,10);
                }    
            } 
        }
    } 

  
}