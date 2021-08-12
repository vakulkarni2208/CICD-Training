global class ContactToUserCreationBatch implements Database.Batchable<sObject>, Database.Stateful{

   global final String Query;
   global list<Id> lstContactId;
   global list<ErrorInsert> lstErrorInsert;
   //global map<String, list<String>> mapPortalGroupListPermissionSet = new map<String, list<String>>();
   //global map<String, String> mapPermissionSetNameID = new map<String, String>();

   global ContactToUserCreationBatch(String q){
      Query=q;
      //this.mapPortalGroupListPermissionSet = mapPortalGroupListPermissionSet;
      //this.mapPermissionSetNameID = mapPermissionSetNameID;
      lstContactId = new list<Id>();
      lstErrorInsert = new list<ErrorInsert>();
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       map<Id,Contact> mapIdContact = new map<Id,Contact>();
       Community_settings__c cs = Community_Settings__c.getInstance();
       map<string, Id> mapProfQPPCPGeneric = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC);
       map<string, Id> mapProfPPGeneric = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
       List<User> lstNewUsersToBeCreated = new list<User>();
       Database.DMLOptions dmo = new Database.DMLOptions();
       dmo.EmailHeader.triggerUserEmail = true;
       Map<string, COMM_Utility.Community_User_Local_Settings_Wrapper> mapCountryNameLocaleWrapper = COMM_Utility.getCommUserLocalSettings();
       for(sobject s : scope){
           mapIdContact.put(s.id,(Contact)s);                    
       }
       list<User> lstUsers = [select id,contactId from User where contactId in :mapIdContact.keySet()];
       list<Id> lstContactIdExistingUsers = new list<Id>();
       if(lstUsers.size() > 0) {
           for(User objUsr : lstUsers) {
               lstContactIdExistingUsers.add(objUsr.contactId);
               //System.ResetPasswordResult rpr = system.resetPassword(objUsr.Id, true);
           }          
       }
       mapIdContact.keyset().removeAll(lstContactIdExistingUsers);
       for(Id ContactId : mapIdContact.keyset()) {
           User newUser = new User();
           newUser.email = mapIdContact.get(ContactId).Email;
           newUser.firstName = mapIdContact.get(ContactId).FirstName;
           newUser.lastname = mapIdContact.get(ContactId).LastName;
           newUser.title = mapIdContact.get(ContactId).title;
           newUser.companyName = mapIdContact.get(ContactId).account.name;
           if(mapIdContact.get(ContactId).create_full_portal_user__c) {
               newUser.profileid = mapProfPPGeneric.get(COMM_Constants.PROF_PP_TPP_GENERIC);
           } else if(mapIdContact.get(ContactId).create_user__c) {
               newUser.profileid = mapProfQPPCPGeneric.get(COMM_Constants.PROF_CP_QPP_GENERIC);
           }
           newUser.contactId = contactId;
           string strCountry = mapIdContact.get(contactId).MailingCountry;
           if (strCountry != null && mapCountryNameLocaleWrapper.get(strCountry.toUpperCase()) != null){
               newUser.alias = mapCountryNameLocaleWrapper.get(strCountry.toUpperCase()).USER_ALIAS;
               newUser.emailencodingkey = mapCountryNameLocaleWrapper.get(strCountry.toUpperCase()).USER_EMAILENCODEKEY;
               if(mapCountryNameLocaleWrapper.get(strCountry.toUpperCase()).LOCALIZED_PORTAL)
                   newUser.languagelocalekey = mapCountryNameLocaleWrapper.get(strCountry.toUpperCase()).USER_LANGLOCALEKEY;
               else 
                   newUser.languagelocalekey = COMM_Constants.USER_LANGLOCALEKEY;        
               newUser.localesidkey = mapCountryNameLocaleWrapper.get(strCountry.toUpperCase()).USER_LOCALESIDKEY;
               newUser.timezonesidkey = mapCountryNameLocaleWrapper.get(strCountry.toUpperCase()).USER_TZSIDKEY;
           }else {
               newUser.alias = COMM_Constants.USER_ALIAS;
               newUser.emailencodingkey = COMM_Constants.USER_EMAILENCODEKEY;
               newUser.languagelocalekey = COMM_Constants.USER_LANGLOCALEKEY;
               newUser.localesidkey = COMM_Constants.USER_LOCALESIDKEY;
               newUser.timezonesidkey = COMM_Constants.USER_TZSIDKEY;
           }
              
           //if lead origin is EMEAI, then add different extn
           /*if (mapLeadsInTgrNew.get(leadId).lead_orgin__c == COMM_Constants.LEAD_ORIGIN_EMEAI_TRAINING_WEB_FORM){
               newUser.username = mapLeadsInTgrNew.get(leadId).Email + COMM_Constants.USRNAME_EXTN_EMEAI_TRAIN;
           } else{*/
           newUser.username = mapIdContact.get(contactId).Email + '.'+ cs.USERNAME_EXTENSION__c;
           //}
           newUser.setOptions(dmo); //send email notification when new user created
           lstNewUsersToBeCreated.add(newUser);
       }
       Database.SaveResult[] srList = Database.insert(lstNewUsersToBeCreated, false);
       integer count = 0;
       for(Database.SaveResult objSR : srList) {
           if(objSR.isSuccess()) {
               lstContactId.add(lstNewUsersToBeCreated[count].contactid);
           } else {
               lstErrorInsert.add(new ErrorInsert(lstNewUsersToBeCreated[count].contactid, objSR.getErrors()[0].getMessage()));
           }
           count++;
       }
       /*list<PermissionSetAssignment> lstPermissionSetAssignment = new list<PermissionSetAssignment>();
       for(User objUser : lstNewUsersToBeCreated) {
           set<Id> setUserSpecificPermissionSet = new set<Id>();
           if(mapIdContact.containsKey(objUser.contactId) && mapIdContact.get(objUser.contactId) != null && mapIdContact.get(objUser.contactId).portal_groups__c != null) {
               for(String strPortalGroup : mapIdContact.get(objUser.contactId).portal_groups__c.split(';')) {
                   if(mapPortalGroupListPermissionSet.containsKey(strPortalGroup)) {
                       for(String strPermissionSetName : mapPortalGroupListPermissionSet.get(strPortalGroup)) {                           
                           if(mapPermissionSetNameID.containsKey(strPermissionSetName)) {
                               if(!setUserSpecificPermissionSet.contains(mapPermissionSetNameID.get(strPermissionSetName))) {
                                   PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment();
                                   objPermissionSetAssignment.assigneeId = objUser.id;
                                   objPermissionSetAssignment.PermissionSetId = mapPermissionSetNameID.get(strPermissionSetName);
                                   setUserSpecificPermissionSet.add(mapPermissionSetNameID.get(strPermissionSetName));
                                   lstPermissionSetAssignment.add(objPermissionSetAssignment);
                               }
                           }
                       }
                   }
               }
           }
       }
       Database.SaveResult[] lstPSAinsert = Database.insert(lstPermissionSetAssignment, false);*/
       //update scope;
   }

   global void finish(Database.BatchableContext BC){
       
       ContactToUserCreationUpdateBatch objCUCB = new ContactToUserCreationUpdateBatch(lstContactId,lstErrorInsert);
       Database.executeBatch(objCUCB,200);       
   }
   
   global class ErrorInsert {
       public Id contactId;
       public String strErrorMessage;
       public ErrorInsert(Id contactId, String strErrorMessage) {
           this.contactId = contactId;
           this.strErrorMessage = strErrorMessage;
       }
   }
}