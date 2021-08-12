/*
  Methods called by Contact object's trigger named Contact_tgr.

  ChangeList:
  
  2017.07.10: @Manideep - Before Insert/Update: "Country/State picklist Enablement" 
              * Going forward Marketo will sync MKTO_Country/MKTO_State custom fields through the 'Marketo Sync' User and then the logic in the method 'ctryStatePicklistforMKTO()'
                will carry over the appropriate values into Country/State picklist fields.
                MKTO_Country__c --> Country 
                MKTO_State__c   --> State
              * Country/State field values those are changed by non-Marketo users directly are carry over to the MKTO fields by the logic in method 'ctryStateMatchforMKTO()'.
                MailingCountry     -->  MKTO_Country__c
                MailingState       -->  MKTO_State__c 
                MailingCountryCode -->  MKTO_Country__c
                MailingState       -->  MKTO_State__c
                
  2017.11.05 - PJENA - Override updates to Contact's FirstName, LastName, EMAIL by MKTO User
  
  2018.05.27 - PJENA - ESP For NPN Partners
    - Append Permissions & Group Assignments multi-picklist field with the option "Service Cloud Access" if the contact is Partner Contact type and one of the flags "is DGX Contact" or "is GRID Contact" is TRUE
  
  2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
        Removed the setContactRegionSubRegionTerritory method that was using a future call
        Note: No longer setting the Other_Region__c, Other_Sub_Region__c, Other_Territory__c fields as Marketo does not set it too
  
  2018.08.16 - Bug Fix - null check in appendServiceCloudAccessToPSG method
  
  2018.08.21 - Bug Fix - null check defence during Mailing Country update
  
  2019.05.26 - PJENA - ESP for All NPN Partners - Remove the call to appendServiceCloudAccessToPSG method
  (SDS-889 - PUB: Add Service Cloud to NPN Portal using SSO)
  
  2020.02.25 - @Manideep: Excluded the Contacts that have 'Synced_with_Docusign__c = True' from processing through the 'ctryStatePicklistforMKTO()' method 
  (SDS-2053: Platform/Infra: Mailing Country MKTO Country field - Contact trigger enhancement)

  2021-01-02 - SDS-2853 Service: Update Address information on Asset from Entitlement
  2020-01-01   Nilesh Adkar     SDS-2853 Added method setAddressChangeFlag
*/

public class Contact_tgr_cls {
  
    /*
    //Date: 2015.09.02
    //Before Insert, Before Update: 
  Sets Product_Type_2__c based on Product_Type__c field value on Contact object. 
  It appends new options to Product_Type_2__c as and when the value in Product_Type__c changes but never removes any values
  Invoked from Contact Trigger
  */
    public static void setProductType2FromProductType(list<Contact> newContactsInTgr){
      for (Contact con : newContactsInTgr){
          string productType = con.Product_Type__c;
          string productType2 = con.Product_Type_2__c;
          
          //check if the Product_Type__c field is blank, skip setting up the Product_Type_2__c
          if (String.isNotBlank(productType)){
            //if Product_Type_2__c is blank then add Product_Type__c to Product_Type_2__c
            if (String.isBlank(productType2)){
              con.Product_Type_2__c = con.Product_Type__c;
            }else{
              //if Product_Type_2__c does not contain Product_Type__c then append it with a semi-colon
              if (!productType2.containsIgnoreCase(productType)){
                con.Product_Type_2__c = con.Product_Type_2__c + ';' + con.Product_Type__c;
              }
            }
          }
        }
    }
    
    /* Date: 2017.07.12
     * @Manideep
     * Before Insert/Update: This is invoked by only 'Marketo Sync' User
     * MailingCountry/State fields picklist enablement
     * 2020.03.03: @Manideep: Excluded the Contacts that have 'Synced_with_Docusign__c = True' from processing through this method.
    */
    public static void ctryStatePicklistforMKTO(List<Contact> contactSrcList) {
       
       list<Contact> contactsFilteredLst = new list<Contact>();
       list<Contact> contactsCtryBlankFilteredLst = new list<Contact>();
       Set<String> strCountrySet = new Set<String>();
       Set<String> strStateSet = new Set<String>();
       
       // Excluding the Contacts those that have the field "Synced_with_Docusign__c = True"
       for(Contact ctc: contactSrcList) {
            if(ctc.Synced_with_Docusign__c != TRUE) {
               if(string.isNotBlank(ctc.MKTO_Country__c)) {
                  contactsFilteredLst.add(ctc);   
                  strCountrySet.add(ctc.MKTO_Country__c);
                  if(string.isNotBlank(ctc.MKTO_State__c)) strStateSet.add(ctc.MKTO_State__c);     
               } else {
                  contactsCtryBlankFilteredLst.add(ctc);
              }
            }         
       }
       
       if(!contactsFilteredLst.isEmpty()) { 
           
           map<String, Country_List__c> countryNameISOCodeMap = new map<String, Country_List__c>();
           if(!strCountrySet.isEmpty()) {
              // query all Counries from CountryList object 
              for(Country_List__c ctry: [Select Id, Name, ISO_Code__c, Region__c, Sub_Region__c, Territory__c, (Select Id, Name, ISO_Code__c from States__r WHERE Name IN:strStateSet or ISO_Code__c IN:strStateSet)
                                         FROM Country_List__c
                                         WHERE Name IN:strCountrySet or ISO_Code__c IN:strCountrySet]) {
                  string strCtryName = string.valueOf(ctry.Name).toUpperCase(); // convert Country name to all CAPS
                  countryNameISOCodeMap.put(strCtryName, ctry);
                  string strCtryISO = string.valueOf(ctry.ISO_Code__c).toUpperCase(); // convert Country ISO Code to all CAPS
                  countryNameISOCodeMap.put(strCtryISO, ctry);
              }
           } 
                        
          // Process the Contacts and populate the values in MailingCountry and MailingState fields           
          for(Contact ctc: contactsFilteredLst) {   
              String strCtryName = string.valueOf(ctc.MKTO_Country__c).toUpperCase(); // convert Country Name to all CAPS
              // check and populate if value in 'MKTO_Country__c' field matches with the CountryName/Country ISO Code   
              if(!countryNameISOCodeMap.isEmpty() && countryNameISOCodeMap.containsKey(strCtryName)) {   
                  ctc.MailingCountry = countryNameISOCodeMap.get(strCtryName).Name;    
                  ctc.MKTO_Country__c = countryNameISOCodeMap.get(strCtryName).Name;
                  //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
                  ctc.Mailing_Region__c = countryNameISOCodeMap.get(strCtryName).Region__c;
                  ctc.Mailing_Sub_Region__c = countryNameISOCodeMap.get(strCtryName).Sub_Region__c;
                  ctc.Mailing_Territory__c = countryNameISOCodeMap.get(strCtryName).Territory__c;
                  if(string.isNotBlank(ctc.MKTO_State__c)) {
                     for(State_List__c stateLst: countryNameISOCodeMap.get(strCtryName).States__r) {
                        if(string.valueOf(ctc.MKTO_State__c).equalsIgnorecase(stateLst.Name) || string.valueOf(ctc.MKTO_State__c).equalsIgnoreCase(stateLst.ISO_Code__c)) {
                            ctc.MailingState = stateLst.Name;
                            ctc.MKTO_State__c = stateLst.Name;
                            break;
                        }    
                     }
                  } else {
                     ctc.MailingState = '';
                  }  
              }          
          }  
       
       }
       
       // Contacts with blank MailingCountry 
       if(!contactsCtryBlankFilteredLst.isEmpty()) {
            for(Contact ctc: contactsCtryBlankFilteredLst) {
                   ctc.MailingCountry = '';
                   ctc.MailingState = '';
                   ctc.MKTO_State__c = '';
        //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
        ctc.Mailing_Region__c = '';
        ctc.Mailing_Sub_Region__c = ''; 
        ctc.Mailing_Territory__c = '';
            }
       }  
           
    }  //end of 'ctryStatePicklistforMKTO()'
    
    /*  Date: 2017.07.12 - @Manideep
     *  Before Insert/Update: This is invoked by non - 'Marketo Sync' User.
     *  Country/State fields picklist Enablement 
    */    
    public static void ctryStateMatchforMKTO(List<Contact> contactSrcList, map<Id, Contact> newContactsMap, map<Id, Contact> oldContactsMap) {
            
       List<Contact> contactsFiltered = new List<Contact>();
       set<String> mktoCtrySet = new set<string>();
       map<String, Country_List__c> ctryCodeListMap = new map<String, Country_List__c>();
       set<String> mktoStateSet = new set<String>();
       map<String, State_List__c> stateCodeListMap = new map<String, State_List__c>();
                                       
     // for Contact 'Update'
       if(newContactsMap != null && oldContactsMap != null) {  
         for(Contact ctc: newContactsMap.values()) {           
              // when 'MailingCountryCode' field value is Changed
              if(string.isNotBlank(string.valueOf(ctc.MailingCountryCode)) && ((ctc.MailingCountryCode != oldContactsMap.get(ctc.Id).MailingCountryCode))) {
                   mktoCtrySet.add(ctc.MailingCountryCode);
                   contactsFiltered.add(ctc);   
              } else if(string.isBlank(string.valueOf(ctc.MailingCountryCode)) && ((ctc.MailingCountryCode != oldContactsMap.get(ctc.Id).MailingCountryCode))) {
                   contactsFiltered.add(ctc); 
              }
              
              // when 'MailingStateCode' field value is Changed  
             if(string.isNotBlank(string.valueOf(ctc.MailingStateCode)) && ((ctc.MailingStateCode != oldContactsMap.get(ctc.Id).MailingStateCode) || !mktoCtrySet.isEmpty())) {
                  mktoStateSet.add(ctc.MailingStateCode); 
                  if(mktoCtrySet.isEmpty()) mktoCtrySet.add(ctc.MailingCountryCode);
                  contactsFiltered.add(ctc); 
             } else if(string.isBlank(string.valueOf(ctc.MailingStateCode)) && (ctc.MailingStateCode != oldContactsMap.get(ctc.Id).MailingStateCode)) {
                   contactsFiltered.add(ctc);  
              }   
              
              // when 'MailingCountry'/'MailingState' field values are Changed
              if((ctc.MailingCountry != oldContactsMap.get(ctc.Id).MailingCountry) || (ctc.MailingState != oldContactsMap.get(ctc.Id).MailingState)) {
          if(ctc.MailingCountry != ctc.MKTO_Country__c) {
            ctc.MKTO_Country__c = ctc.MailingCountry;
            //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
            mktoCtrySet.add(ctc.MailingCountry);
                    }
                    if(ctc.MailingState != ctc.MKTO_State__c){
            ctc.MKTO_State__c = ctc.MailingState;
                    }
             }   
         }
         } else if(!contactSrcList.isEmpty()) {  // for Contact 'Insert'
              for(Contact ctc: contactSrcList) {
                if(string.isNotBlank(string.valueOf(ctc.MailingCountryCode))) {
                  mktoCtrySet.add(ctc.MailingCountryCode);
                  contactsFiltered.add(ctc); 
                    if(string.isNotBlank(string.valueOf(ctc.MailingStateCode))) {
                       mktoStateSet.add(ctc.MailingStateCode); 
                       contactsFiltered.add(ctc);
          } 
        } else if(string.isNotBlank(string.valueOf(ctc.MailingCountry))) {
          ctc.MKTO_Country__c = ctc.MailingCountry;
                    //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
          mktoCtrySet.add(ctc.MailingCountry);
          ctc.MKTO_State__c = ctc.MailingState;
              }
             }     
         }
       
       if(!mktoCtrySet.isEmpty()) {
      //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
           for(Country_List__c ctryLst: [Select Id, Name, ISO_Code__c, Region__c, Sub_Region__c, Territory__c, (Select Id, Name, ISO_Code__c from States__r WHERE ISO_Code__c IN:mktoStateSet) From Country_List__c WHERE ISO_Code__c IN :mktoCtrySet Or Name IN :mktoCtrySet]) {
                 ctryCodeListMap.put(ctryLst.ISO_Code__c, ctryLst);
                 for(State_List__c stateLst: ctryCodeListMap.get(ctryLst.ISO_Code__c).States__r) {
                    stateCodeListMap.put(stateLst.ISO_Code__c, stateLst);
                }
            }      
         }
              
    for(Contact ctc: contactsFiltered) {
             // MailingCountry  
      if(string.isNotBlank(string.valueOf(ctc.MailingCountryCode)) && !ctryCodeListMap.isEmpty() && ctryCodeListMap.containsKey(ctc.MailingCountryCode)){
                  ctc.MKTO_Country__c = ctryCodeListMap.get(ctc.MailingCountryCode).Name;
                  //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
                  ctc.Mailing_Region__c = ctryCodeListMap.get(ctc.MailingCountryCode).Region__c;
        ctc.Mailing_Sub_Region__c = ctryCodeListMap.get(ctc.MailingCountryCode).Sub_Region__c;
        ctc.Mailing_Territory__c = ctryCodeListMap.get(ctc.MailingCountryCode).Territory__c;
      } else if(string.isBlank(string.valueOf(ctc.MailingCountryCode)) && string.isNotBlank(string.valueOf(ctc.MKTO_Country__c))){
        ctc.MKTO_Country__c = '';
        //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
                  ctc.Mailing_Region__c = '';
        ctc.Mailing_Sub_Region__c = '';
        ctc.Mailing_Territory__c = '';
      }
      
            // MailingState      
            if(string.isNotBlank(string.valueOf(ctc.MailingStateCode)) && !stateCodeListMap.isEmpty() && stateCodeListMap.containsKey(ctc.MailingStateCode))   
                ctc.MKTO_State__c = stateCodeListMap.get(ctc.MailingStateCode).Name; 
            else if(string.isBlank(string.valueOf(ctc.MailingStateCode)) && string.isNotBlank(string.valueOf(ctc.MKTO_State__c)))
                ctc.MKTO_State__c = ''; 
                
            
      //2018.08.07 - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
      //for update cases
      //2018.08.21 - Bug Fix - null check defence during Mailing Country update
      if(trigger.IsUpdate && string.isNotBlank(ctc.MailingCountry) && ctc.MailingCountry != oldContactsMap.get(ctc.Id).MailingCountry && ctryCodeListMap.containsKey(ctc.MailingCountry) ){
        ctc.Mailing_Region__c = ctryCodeListMap.get(ctc.MailingCountry).Region__c;
        ctc.Mailing_Sub_Region__c = ctryCodeListMap.get(ctc.MailingCountry).Sub_Region__c;
        ctc.Mailing_Territory__c = ctryCodeListMap.get(ctc.MailingCountry).Territory__c;
      } else if (trigger.IsUpdate && string.isBlank(ctc.MailingCountry) && string.isBlank(ctc.MailingCountryCode) ){
        ctc.Mailing_Region__c = '';
        ctc.Mailing_Sub_Region__c = '';
        ctc.Mailing_Territory__c = '';
      }
       }
            
    } // end of 'ctryStateMatchforMKTO()'
    
    
    //2017.11.05 - PJENA - Override updates to Contact's FirstName, LastName, EMAIL by MKTO User
    public static void overrideUpdatesByMKTOUser(list<Contact> lstContactNewVal, map<Id, Contact> oldMapContactVal){
      system.debug('***Enters: overrideUpdatesByMKTOUser()');
    string sfdcUserIdsFromConfig = MKTO_ContactUpdateOverride_Settings__c.getOrgDefaults().SDFCUserIds__c;
    
    if (sfdcUserIdsFromConfig != null){
          list<string> lstUserIds = sfdcUserIdsFromConfig.split(';');
          set<string> setValidUserIds = new set<string>();
           for (string userId : lstUserIds){
             setValidUserIds.add(userId.trim().left(15));
           }
           system.debug('***setValidUserIds: ' + setValidUserIds);
           system.debug('***userinfo.getUserId(): ' + userinfo.getUserId().left(15));
           
           if (setValidUserIds.contains(userinfo.getUserId().left(15))){
             system.debug('***update gets overridden');
             for (Contact con : lstContactNewVal){
               con.email = oldMapContactVal.get(con.Id).email;
               con.firstName = oldMapContactVal.get(con.Id).firstName;
               con.lastName = oldMapContactVal.get(con.Id).lastName;
             }
           }
           
    }
    system.debug('***Exits: overrideUpdatesByMKTOUser()');
    }


// SDS-2853 Added method   

    public static void setAddressChangeFlag(List<Contact> lstOldContact, List<Contact> lstNewContact){
      List<Contact> lstTimezoneChangedContacts = new List<Contact>();
      Schema.DescribeFieldResult F = Contact.TimeZone__c.getDescribe();
      List<Schema.PicklistEntry> lstPickList = F.getPicklistValues();
      
      if(Trigger.isInsert){
        lstTimezoneChangedContacts.addAll(lstNewContact);
      }
      else if(Trigger.isUpdate && lstOldContact!=null && !lstOldContact.isEmpty() && lstNewContact!=null && !lstNewContact.isEmpty()){
          for(integer i=0;i<lstNewContact.size();i++){
              if(lstOldContact.get(i).MailingCity !=lstNewContact.get(i).MailingCity
               || lstOldContact.get(i).MailingCountry !=lstNewContact.get(i).MailingCountry
               || lstOldContact.get(i).MailingPostalCode !=lstNewContact.get(i).MailingPostalCode
               || lstOldContact.get(i).MailingState !=lstNewContact.get(i).MailingState
               || lstOldContact.get(i).MailingStreet !=lstNewContact.get(i).MailingStreet
               ){
                  lstTimezoneChangedContacts.add(lstNewContact.get(i));
               }
               else if(lstOldContact.get(i).TimeZone__c !=lstNewContact.get(i).TimeZone__c ){
                   
                    for(Schema.PicklistEntry tmp : lstPickList){
                        if(lstNewContact.get(0).TimeZone__c == tmp.getvalue()){
                            lstNewContact.get(0).Time_Zone_Text__c = tmp.getlabel();
                        }    
                    }
               }
          }
      }
      for(Contact tmpContact : lstTimezoneChangedContacts){
        tmpContact.Is_Mailing_Address_Changed__c=true;
      }
    }

 
     public static void processSelfRegister(list<Contact> lstContact) {
        /*list<Contact> contactsToBeProcessed = new list<Contact>();
        list<ID> contactIdsToBeProcessed = new list<Id>();
        for(Contact objContact : lstContact){
            if(objContact.SelfRegistration__c == true) {
                contactIdsToBeProcessed.add(objContact.Id);
            }
        }
        if(!contactIdsToBeProcessed.isEmpty()) {
            contactsToBeProcessed = [select id, name, portal_groups__c, Create_Full_Portal_User__c, accountId, role__c, GPU_Genius_Groups__c,Portal_User_Content_Type__c  from contact where id in :contactIdsToBeProcessed];
            contactsToBeProcessed = NPN_TempContactHelper.getPermissionGeniusValuesForContacts(contactsToBeProcessed, null);
            for(Contact objContact : contactsToBeProcessed){
                objContact.Create_Full_Portal_User__c = true;
            }
            if(!contactsToBeProcessed.isEmpty()) {
                Database.SaveResult[] srList = Database.Update(contactsToBeProcessed, false);
            }
        }*/
    } 
}