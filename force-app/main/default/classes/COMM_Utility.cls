/*
  Common utility routines used in Community (NV Customer/Partner Portal) related classes
  
  This class is also used in Oppty trigger, Partner Attribute trigger and its classes
  
  1/25/2018 : update code as a part of compentency rename: Line 399 - 405 (SDS-1001)
  
*/
public class COMM_Utility {
  
  /* ******* RAJAT COMMENTED FOR CODE COVERAGE: TO BE UNCOMMENTED AFTERWARDS START ************* 
  //Used for finding the Lead and Account Map - for building EMEAI Leads and its associated Account map - Lead_tgr_cls.autoConvertLead()
  public static list<Account> getAccountsByIds(set<Id> lstAccId){
    list<Account> lstAccounts = [  Select Name, RecordType.Name, RecordTypeId  
                    From Account 
                    Where Id = :lstAccId];
    return lstAccounts;
  }
  ******* RAJAT COMMENTED FOR CODE COVERAGE: TO BE UNCOMMENTED AFTERWARDS FINISH ************ */
  
  //Used for finding the Lead and Account Map - for building NPN Leads and its associated Account map - Lead_tgr_cls.autoConvertLead()
  public static list<Account> getAccsByNameAndRT(set<string> setAccNames, Id strRecTypeId){
    list<Account> lstAccounts = [  Select Name, RecordType.Name, RecordTypeId 
                    From Account
                    Where RecordTypeID = :strRecTypeId
                      And Name =  :setAccNames ];
    return lstAccounts;
  }
  
  //Used for building the map of RT name and its Id - Lead_tgr_cls.autoConvertLead()
  public static map<string, Id> getRTsByName(string sObjectType, string strRTName){
    map<string, Id> allRTsByName = new map<string, Id>();
    list<RecordType> lstRTs;
    if (strRTName == null || strRTName.trim() == ''){
      lstRTs = [Select Name From RecordType Where SobjectType = :sObjectType];
    } else{
      lstRTs = [Select Name From RecordType Where SobjectType = :sObjectType And Name = :strRTName];
    }
    for (RecordType rt : lstRTs){
      allRTsByName.put(rt.Name, rt.Id);
    }
    return allRTsByName;
  }

  //Returns map of Email-AccountId to Contact for a given set of email addresses and Accounts - Lead_tgr_cls.autoConvertLead()
  public static map<string, Contact> getAllContactsByEmailAccId(set<string> setEmails, set<Id> setAccountIds){
    map<string, Contact> mapEmailAccountIdToContact = new map<string, Contact>();
    list<Contact> lstContacts = [  Select Email, AccountId, GPU_Genius_Groups__c, RecordTypeId
                    From Contact
                    Where Email = : setEmails
                      And AccountId = :setAccountIds];
    for (Contact con : lstContacts){
      mapEmailAccountIdToContact.put(con.Email + con.AccountId, con);
    }
    return mapEmailAccountIdToContact;
  }
  
  //Returns all Users by User Names - Lead_tgr_cls.autoConvertLead() - Lead_tgr_cls.autoConvertLead()
  public static map<string, User> getAllUsersByUserNames(list<string> lstUserNames){
    map<string, User> mapUserByUserNames = new map<string, User>();
    list<User> lstUsers = [  Select Name, Username, IsActive, Email 
                From User 
                Where UserName = :lstUserNames];
    for (User usr : lstUsers){
      mapUserByUserNames.put(usr.UserName.toLowerCase(), usr);
    }
    return mapUserByUserNames;
  }
  
  //Returns all Profiles by Name - Lead_tgr_cls.autoConvertLead()
  public static map<string, Id> getProfsByName(string strProfName){
    map<string, Id> allProfsByName = new map<string, Id>();
    list<Profile> lstProfs;
    string strSQL = '';
    if (strProfName == null || strProfName.trim() == ''){
      lstProfs = [Select Name From Profile];
    } else{
      lstProfs = [Select Name From Profile Where Name = :strProfName];
    }
    for (Profile prof : lstProfs){
      allProfsByName.put(prof.Name, prof.Id);
    }
    return allProfsByName;
  }
  
  //returns all Public Groups by Name - Lead_tgr_cls.autoConvertLead()
  public static map<string, Id> getPGsByName(list<string> lstPGName){
    map<string, Id> allPGssByName = new map<string, Id>();
    
    list<Group> lstPGs = new list<Group>();
    
    if (lstPGName == null || lstPGName.isEmpty()){
      lstPGs = [Select Name From Group];
    } else{
      lstPGs = [Select Name From Group Where Name = :lstPGName];
    }
    
    for (Group grp : lstPGs){
      allPGssByName.put(grp.Name, grp.Id);
    }
    return allPGssByName;
  }
  
  //returns all Permission Sets by Name
  public static map<string, Id> getPSsByName(list<string> lstPSName){
    map<string, Id> allPSsByName = new map<string, Id>();
    
    list<PermissionSet> lstPS = new list<PermissionSet>();
    
    if (lstPSName == null || lstPSName.isEmpty()){
      lstPS = [Select Name From PermissionSet];
    } else{
      lstPS = [Select Name From PermissionSet Where Name = :lstPSName];
    }
    
    for (PermissionSet ps : lstPS){
      allPSsByName.put(ps.Name, ps.Id);
    }
    return allPSsByName;
  }
  
  //Return map of ContactId and Users associated with it (in case of Partner or Customer user) - Lead_tgr_cls.autoConvertLead()
  public static map<Contact, User> getPortalUsers(list<Id> lstContactIds){
    map<Contact, User> mapContactIdToUser = new map<Contact, User>();
    list<User> lstPortalUser = [Select Username, Email, ContactId, AccountId, isActive, Contact.AccountId, Contact.Email, Contact.GPU_Genius_Groups__c 
                  From User 
                  Where ContactId = :lstContactIds];
    for (User oUser : lstPortalUser){
      mapContactIdToUser.put(oUser.Contact, oUser);
    }
    return mapContactIdToUser;
  }
  
  //Checks if the email address is well formed - Lead_tgr_cls.autoConvertLead()
  public static boolean validateEmail(string email) {
    boolean res = false;
    String emailRegex = '^[a-zA-Z0-9._|%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,50}$'; 
    Pattern oPattern = Pattern.compile(emailRegex);
    Matcher oMatcher = oPattern.matcher(email);

    if (oMatcher.matches()){
      res = true;
    }
    return res;  
  }
  
  //Wrapper class for Portal User Local Language details
  public class Community_User_Local_Settings_Wrapper{
    public string USER_COUNTRY {get;set;}
    public string USER_ALIAS {get;set;}
    public string USER_EMAILENCODEKEY {get;set;}
    public string USER_LANGLOCALEKEY {get;set;}
    public string USER_LANGUAGE {get;set;}
    public string USER_LOCALESIDKEY {get;set;}
    public string USER_TZSIDKEY {get;set;}
    public string CONTACT_GPUGENIUS_GROUP {get;set;}
    public boolean LOCALIZED_PORTAL {get;set;}
    
    public Community_User_Local_Settings_Wrapper(string USER_COUNTRY, string USER_ALIAS, string USER_EMAILENCODEKEY, string USER_LANGLOCALEKEY, string USER_LANGUAGE, string USER_LOCALESIDKEY, string USER_TZSIDKEY, string CONTACT_GPUGENIUS_GROUP, boolean LOCALIZED_PORTAL){
      this.USER_COUNTRY = USER_COUNTRY;
      this.USER_ALIAS = USER_ALIAS;
      this.USER_EMAILENCODEKEY = USER_EMAILENCODEKEY;
      this.USER_LANGLOCALEKEY = USER_LANGLOCALEKEY;
      this.USER_LANGUAGE = USER_LANGUAGE;
      this.USER_LOCALESIDKEY = USER_LOCALESIDKEY;
      this.USER_TZSIDKEY = USER_TZSIDKEY;
      this.CONTACT_GPUGENIUS_GROUP = CONTACT_GPUGENIUS_GROUP;
      this.LOCALIZED_PORTAL = LOCALIZED_PORTAL;
    }
    
    public Community_User_Local_Settings_Wrapper(string USER_COUNTRY, string USER_ALIAS, string USER_EMAILENCODEKEY, string USER_LANGLOCALEKEY, string USER_LANGUAGE, string USER_LOCALESIDKEY, string USER_TZSIDKEY, string CONTACT_GPUGENIUS_GROUP){
      this.USER_COUNTRY = USER_COUNTRY;
      this.USER_ALIAS = USER_ALIAS;
      this.USER_EMAILENCODEKEY = USER_EMAILENCODEKEY;
      this.USER_LANGLOCALEKEY = USER_LANGLOCALEKEY;
      this.USER_LANGUAGE = USER_LANGUAGE;
      this.USER_LOCALESIDKEY = USER_LOCALESIDKEY;
      this.USER_TZSIDKEY = USER_TZSIDKEY;
      this.CONTACT_GPUGENIUS_GROUP = CONTACT_GPUGENIUS_GROUP;
    }
  }
  
  
  //Returns Map of Country Name and Locale details from custom settings named Community_User_Local_Settings__c
  //Used in Lead_tgr_cls.cls to set GPU Genius and User attributes (alias, emailencodingkey, languagelocalekey, localesidkey, timezonesidkey)
  public static Map<string, COMM_Utility.Community_User_Local_Settings_Wrapper> getCommUserLocalSettings(){
    //Map of country name and Locale Settings Wrapper
    Map<string, COMM_Utility.Community_User_Local_Settings_Wrapper>  mapCountryNameLocaleWrapper = new Map<string, COMM_Utility.Community_User_Local_Settings_Wrapper>();
    
    Map<String, Community_User_Local_Settings__c> allCommUserLocalSettings = Community_User_Local_Settings__c.getAll();
    
    for (Community_User_Local_Settings__c cs : allCommUserLocalSettings.Values() ){
      
      string strCountryList = cs.COUNTRY_LIST__c;
    
      if (strCountryList != null){
        list<string> lstCountry = strCountryList.split(',');
        for (string strCountry : lstCountry){
          string strCountrySpaceTrimmed = strCountry.trim();
          if (strCountrySpaceTrimmed != '' && mapCountryNameLocaleWrapper.get(strCountrySpaceTrimmed) == null){
            //create the wrapper object and add it to the map
            COMM_Utility.Community_User_Local_Settings_Wrapper oLocaleWrapper = new COMM_Utility.Community_User_Local_Settings_Wrapper(strCountrySpaceTrimmed, cs.USER_ALIAS__c, cs.USER_EMAILENCODEKEY__c, cs.USER_LANGLOCALEKEY__c, cs.USER_LANGUAGE__c, cs.USER_LOCALESIDKEY__c, cs.USER_TZSIDKEY__c, cs.CONTACT_GPUGENIUS_GROUP__c, cs.LOCALIZED_PORTAL__c);
            mapCountryNameLocaleWrapper.put(strCountrySpaceTrimmed, oLocaleWrapper);
          }
        }
      }
    
    }
    return mapCountryNameLocaleWrapper;
  }
  
  //returns map of LangLocalKey to Language Name (ex. tr=>Turkish, de=>German, es=>Spanish, en_GB => English) from custom settings Community_User_Local_Settings__c
  public static map<string, string> getCommUserLocalSettingsLangKeyLanguageName(){
    //Map of country name and Locale Settings Wrapper
    map<string, string>  mapLangKeyLanguageName = new map<string, string>();
    
    Map<String, Community_User_Local_Settings__c> allCommUserLocalSettings = Community_User_Local_Settings__c.getAll();
    
    for (Community_User_Local_Settings__c cs : allCommUserLocalSettings.Values() ){
      mapLangKeyLanguageName.put(cs.USER_LANGLOCALEKEY__c, cs.USER_LANGUAGE__c);
    }
    return mapLangKeyLanguageName;
  }
  
  //returns current user's Language based on the user's language key e.g., de => German
  public static string getUserLanguage(string currUserLocaleLangKey){
    string currUserLangName = COMM_Constants.USER_LANG_DEFAULT_ENGLISH; //'ENGLISH' - Default language of all users
    
    //Check if the user's LangLocalKey has any matching Language Name in the custom settings, if found set it to currUserLanguageName
    map<string, string> mapCSCommUserSettings_LangKeyToLangName = COMM_Utility.getCommUserLocalSettingsLangKeyLanguageName();
    if (mapCSCommUserSettings_LangKeyToLangName != null && !mapCSCommUserSettings_LangKeyToLangName.isEmpty()){
      if ( mapCSCommUserSettings_LangKeyToLangName.keyset().contains(currUserLocaleLangKey) ){
        currUserLangName = mapCSCommUserSettings_LangKeyToLangName.get(currUserLocaleLangKey);
      }
    }
    return currUserLangName;
  }
    /* ******* RAJAT COMMENTED FOR CODE COVERAGE: TO BE UNCOMMENTED AFTERWARDS START ************* 
    public static set<String> getAllLocalesForEMEA() {
        list<Community_User_Local_Settings__c> lstCommunityUesrLocaleSettings = Community_User_Local_Settings__c.getAll().values();
        set<String> setUserLocaleSidKeyEMEA = new Set<String>();
        for(Community_User_Local_Settings__c objCommunityUesrLocaleSettings : lstCommunityUesrLocaleSettings) {
            if(objCommunityUesrLocaleSettings.REGION__c == COMM_Constants.ADDRESS_REGION_EMEA) {
                setUserLocaleSidKeyEMEA.add(objCommunityUesrLocaleSettings.USER_LANGLOCALEKEY__c.toUpperCase());    
            }           
        }  
        return setUserLocaleSidKeyEMEA;
    }
    
    public static string getCurrentUserRegion() {
        list<User> lstUser = [select id, contactID from User where id = :Userinfo.getUserId()];
        list<Contact> lstContact;
        list<String> lstCompetency = new list<String>();
        if(lstUser.size() > 0) {
             lstContact = [select Account.Billing_Region__c from Contact where id = :lstUser[0].contactId];
        }       
        if(lstContact.size() > 0) {
            return lstContact[0].Account.Billing_Region__c;
        }
        return '';
    }
    ******* RAJAT COMMENTED FOR CODE COVERAGE: TO BE UNCOMMENTED AFTERWARDS FINISH ************ */
  
  //returns current user's Content Language Filter based on the user's language key. The result sent is URLEncoded
  //e.g., de => {"00N40000002WvBR":["5"]} where 00N40000002WvBR is the id of the Customer field ContentVersion.Language_Region__c and 5 is the index of the pick list option German (DE) of that field
  //Used in Lite Portal Home page controllers
  public static string getUserContentLanguageSearchFilter(string currUserLocaleLangKey){
   //START : Commented by Varun 11/15/2019 - Code not in use
   /* string strSearchFilter = '';
    String strCompetencyPicklistIndexes = '';
    String strLangPicklistIndexes = '';
    String strRegionPicklistIndex = '';
    string currUserLangName = currUserLocaleLangKey.toUpperCase();
    set<String> setUserLocaleSidKeyEMEA = new Set<String>();
    setUserLocaleSidKeyEMEA = getAllLocalesForEMEA();
    list<String> lstCompetency = getCurrentUserCompetency();
    String strRegion = getCurrentUserRegion();
    list<Integer> lstCompetencyPicklistIndexes = new list<Integer>();
    list<Integer> lstLangPicklistIndexes = new list<Integer>();
    list<Integer> lstRegionPicklistIndexes = new list<Integer>();
    //get the Field Metadata Id
    //-----------------------------------------------------------
    //SOBJECT_CONTENTVERSION = 'CONTETVERSION';   CONTENTVERSION_LANGUAGE_FIELD_NAME = 'Language_Region'
    string strFieldMetaDataId = getFieldMetaDataId(COMM_Constants.SOBJECT_CONTENTVERSION, COMM_Constants.CONTENTVERSION_LANGUAGE_FIELD_NAME);
    string strCompetencyFieldMetaDataId = Community_Settings__c.getOrgDefaults().CONTENTVERSION_COMPETENCY_METAID__c;
    //string strRegionFieldMetaDataId = Community_Settings__c.getOrgDefaults().CONTENTVERSION_REGION_METAID__c;
    
    //trim the Id to 15 digit to be used in the browser
    if (strFieldMetaDataId.length() >= 15){
      strFieldMetaDataId = strFieldMetaDataId.substring(0,15);
    }
    system.debug('***strFieldMetaDataId: ' + strFieldMetaDataId);
    //-----------------------------------------------------------
    
    //get the Language picklist indexes
    //-----------------------------------------------------------
    integer intLangPickListIndex = 0;
    integer intRegionPickListIndex = 0;
    integer intCompetencyPickListIndex = 0;
    map<string, integer> mapAllContentVersionLanguageISOCodeAndPickListIndex = getContentVersionLanguageISOCodeAndPickListIndex();
    map<string, integer> mapAllContentVersionCompetencyAndPickListIndex = getContentVersionLanguageISOCodeAndPickListIndex(ContentVersion.Competency__c.getDescribe());
    //map<string, integer> mapAllContentVersionRegionAndPickListIndex = getContentVersionLanguageISOCodeAndPickListIndex(ContentVersion.Region__c.getDescribe());
    system.debug('***mapAllContentVersionLanguageISOCodeAndPickListIndex: ' + mapAllContentVersionLanguageISOCodeAndPickListIndex);
    system.debug('***currUserLangName: ' + currUserLangName);
    system.debug('***strRegion: ' + strRegion);
    system.debug((setUserLocaleSidKeyEMEA.contains(currUserLangName) || strRegion == COMM_Constants.ADDRESS_REGION_EMEA ));
    system.debug(mapAllContentVersionLanguageISOCodeAndPickListIndex.get('EN_GB')!=null);
    if (mapAllContentVersionLanguageISOCodeAndPickListIndex.get(currUserLangName) != null){
        lstLangPicklistIndexes.add(integer.valueOf(mapAllContentVersionLanguageISOCodeAndPickListIndex.get(currUserLangName)));
        if(!currUserLangName.contains('EN')){
            if((setUserLocaleSidKeyEMEA.contains(currUserLangName) || strRegion == COMM_Constants.ADDRESS_REGION_EMEA) && mapAllContentVersionLanguageISOCodeAndPickListIndex.get('EN_GB')!=null){
                lstLangPicklistIndexes.add(integer.valueOf(mapAllContentVersionLanguageISOCodeAndPickListIndex.get('EN_GB')));
            } else if(mapAllContentVersionLanguageISOCodeAndPickListIndex.get('EN_US') != null) {
                lstLangPicklistIndexes.add(integer.valueOf(mapAllContentVersionLanguageISOCodeAndPickListIndex.get('EN_US')));
            }
        }
    } else if (strRegion == COMM_Constants.ADDRESS_REGION_EMEA && mapAllContentVersionLanguageISOCodeAndPickListIndex.get('EN_GB')!=null) {
        lstLangPicklistIndexes.add(integer.valueOf(mapAllContentVersionLanguageISOCodeAndPickListIndex.get('EN_GB')));
    }
    system.debug('***mapAllContentVersionCompetencyAndPickListIndex: ' + mapAllContentVersionCompetencyAndPickListIndex);
    if(lstCompetency != null && lstCompetency.size() > 0) {
        for(String competency : lstCompetency) {
            if(mapAllContentVersionCompetencyAndPickListIndex.containsKey(competency)) {
                lstCompetencyPicklistIndexes.add(integer.valueOf(mapAllContentVersionCompetencyAndPickListIndex.get(competency)));
            }
        }       
    }
    
    //if(mapAllContentVersionRegionAndPickListIndex.containsKey(strRegion)) {
    //    strRegionPicklistIndex = String.valueOf(mapAllContentVersionRegionAndPickListIndex.get(strRegion));
    //}
    strCompetencyPicklistIndexes = String.join(lstCompetencyPicklistIndexes, '\",\"');
    strLangPicklistIndexes = String.join(lstLangPicklistIndexes, '\",\"');
    system.debug('***lstLangPicklistIndexes: ' + lstLangPicklistIndexes);
    system.debug('***lstCompetency: ' + lstCompetency + '***lstCompetencyPicklistIndexes' + lstCompetencyPicklistIndexes);
    //-----------------------------------------------------------
    
    if(strFieldMetaDataId.length() > 0 && strLangPicklistIndexes != '' && strCompetencyFieldMetaDataId.length() > 0 && strCompetencyPicklistIndexes != ''){     
      strSearchFilter = '{\"' + strFieldMetaDataId + '\":[\"' +  strLangPicklistIndexes + '\"],\"' + strCompetencyFieldMetaDataId + '\":[\"' +  strCompetencyPicklistIndexes + '\"]}';  
    } else if(strCompetencyFieldMetaDataId.length() > 0 && strCompetencyPicklistIndexes != '') {
        strSearchFilter = '{\"' + strCompetencyFieldMetaDataId + '\":[\"' +  strCompetencyPicklistIndexes + '\"]}';
    } else if(strFieldMetaDataId.length() > 0 && strLangPicklistIndexes != '') {
        strSearchFilter = '{\"' + strFieldMetaDataId + '\":[\"' +  strLangPicklistIndexes + '\"]}';
    }
    //endcode the filter
    strSearchFilter =  EncodingUtil.urlEncode(strSearchFilter, 'UTF-8');    
    
    system.debug('***strSearchFilter: ' + strSearchFilter);
    return strSearchFilter;
    */     
    //END : Commented by Varun 11/15/2019 - Code not in use
    
    /*if(strCompetencyFieldMetaDataId.length() > 0 && strCompetencyPicklistIndexes != '') {
        strSearchFilter = '{\"' + strCompetencyFieldMetaDataId + '\":[\"' +  strCompetencyPicklistIndexes + '\"]';
    } if(strFieldMetaDataId.length() > 0 && strLangPicklistIndexes != '') {
        if(strSearchFilter != null && strSearchFilter != '')
            strSearchFilter += ',\"' + strFieldMetaDataId + '\":[\"' +  strLangPicklistIndexes + '\"]';
        else    
            strSearchFilter = '{\"' + strFieldMetaDataId + '\":[\"' +  strLangPicklistIndexes + '\"]';
    } if(strRegionFieldMetaDataId.length() > 0 && strRegionPicklistIndex != '') {
        if(strSearchFilter != null && strSearchFilter != '')
            strSearchFilter += ',\"' + strRegionFieldMetaDataId + '\":[\"' +  strRegionPicklistIndex + '\"]';
        else    
            strSearchFilter = '{\"' + strRegionFieldMetaDataId + '\":[\"' +  strRegionPicklistIndex + '\"]';
    }
    if(strSearchFilter != '') {
        strSearchFilter += '}';
    }*/
    return null;
  }
  /* ******* RAJAT COMMENTED FOR CODE COVERAGE: TO BE UNCOMMENTED AFTERWARDS START ************* 
  
  //Returns all Content Version.Language (Region) piklist options with index
  public static map<string, integer> getContentVersionLanguageISOCodeAndPickListIndex(){
       return getContentVersionLanguageISOCodeAndPickListIndex(ContentVersion.Language_Region__c.getDescribe());
  }
  
  //Returns all Content Version.Language (Region) piklist options with index
  public static map<string, integer> getContentVersionLanguageISOCodeAndPickListIndex(Schema.DescribeFieldResult dfr){
     
    List<Schema.PicklistEntry> lstPLEntry = dfr.getPicklistValues();
    map<string, integer> mapLangISOCodeIndex = new map<string, integer>();
    system.debug('***lstPLEntry: ' + lstPLEntry);
    for (integer i = 0; i < lstPLEntry.size(); i++){
      string lang = string.valueOf(lstPLEntry[i].getLabel());
      integer sIndex = lang.indexOf('(');
      integer eIndex = lang.indexOf(')');
      
      integer currIndex = i;
      if (sIndex >= 0 && eIndex >=0){
        mapLangISOCodeIndex.put(lang.substring(sIndex+1, eIndex).toUpperCase(),  currIndex+1); //the position starts with 1
      } else {
        mapLangISOCodeIndex.put(lang,  currIndex+1);
      }
    }
    system.debug('***mapLangISOCodeIndex: ' + mapLangISOCodeIndex);
    return mapLangISOCodeIndex;
  }
  
  
  
  public static list<String> getCurrentUserCompetency() {
      list<User> lstUser = [select id, contactID from User where id = :Userinfo.getUserId()];
      list<Contact> lstContact;
      list<String> lstCompetency = new list<String>();
      if(lstUser.size() > 0) {
           lstContact = [select Portal_Groups__c from Contact where id = :lstUser[0].contactId];
      }       
      if(lstContact.size() > 0) {
          if(lstContact[0].Portal_Groups__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_AC))
              lstCompetency.add(COMM_Constants.TEST_PORTAL_COMPETENCY_AC);
          if(lstContact[0].Portal_Groups__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_GV))
              lstCompetency.add(COMM_Constants.TEST_PORTAL_COMPETENCY_CV);
          if(lstContact[0].Portal_Groups__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_PV))
              lstCompetency.add(COMM_Constants.TEST_PORTAL_COMPETENCY_PV);
          if(lstContact[0].Portal_Groups__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_DL))
              lstCompetency.add(COMM_Constants.TEST_PORTAL_COMPETENCY_DL);
              if(lstContact[0].Portal_Groups__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_Jetson))
              lstCompetency.add(COMM_Constants.TEST_PORTAL_COMPETENCY_Jetson);
      }
      return lstCompetency;
  }
  ******* RAJAT COMMENTED FOR CODE COVERAGE: TO BE UNCOMMENTED AFTERWARDS FINISH *************  */
  
  //returns field's metadata Id e.g,  metadata Id = 00N40000002WvBR for Field Name=Language_Region, Data Type=Picklist, API Name=Language_Region__c
  //('ContentVersion', 'Language_Region') ;
  public static string getFieldMetaDataId(string objectName, string fieldName){
    string fieldMetaDataId = '';
    
    //NOTE: Tooling API erring out for Partner Users
    /*
    list<map<string, object>> results =  getFieldMetaDataFromToolingAPI(objectName, fieldName);

    if ( results.size() > 0){
      map<string, object> mapFieldDetails = results[0];
      if (mapFieldDetails.get('Id') != null){
        fieldMetaDataId = string.valueOf(mapFieldDetails.get('Id'));
      }
    }
    */
    //get thhe CONTENTVERSION_LANGUAGE_REGION Field Id
    fieldMetaDataId = Community_Settings__c.getOrgDefaults().CONTENTVERSION_LANGUAGE_REGION_METAID__c;
    
    return fieldMetaDataId;
  }
  
  /*
  //Tooling API to get the Custom Field's Metadata Id which is not exposed thru Describe Field Result yet
  public static list<map<string,object>> getFieldMetaDataFromToolingAPI(string objectName, string fieldName) {
        
        list<map<string, object>> results = new list<map<string, object>>();
        
        fieldName = fieldName.replace('__c','');
        //string objectName = 'ContentVersion';
        string instanceURL = System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        
        String toolingendpoint = 'https://'+instanceURL+'/services/data/v31.0/tooling/';
        //String toolingendpoint = 'https://cs16.salesforce.com/services/data/v31.0/tooling/';
        
        //query for custom fields
        //toolingendpoint += 'query/?q=Select+id,DeveloperName,FullName+from+CustomField+where+DeveloperName+=+\''+fieldName+'\'';
        toolingendpoint += 'query/?q=Select+id,DeveloperName,FullName+from+CustomField+where+DeveloperName+=+\''+fieldName+'\''+'and+TableEnumOrId+=+\''+objectName+'\'';
        system.debug('***toolingendpoint: ' + toolingendpoint);
        req.setEndpoint(toolingendpoint);
        req.setMethod('GET');
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        //convert the original data structure into a map of objects. The data we want is in the records property of this object
        map<string,object> reqData = (map<string,object>) json.deserializeUntyped(res.getBody());
        
        //now create a list of objects from the records property. This serialize/deserialize trick is the only way I know to convert a generic object
        //into something else when the source data is 'salesforce Map encoded' (no quotes around field names or values, parenthesis to denote open and close, etc)
        list<object> fieldData = (list<object>) JSON.deserializeUntyped(JSON.serialize(reqData.get('records')));    
        
        //iterate over each object in the list and create a map of string to object out of it and add it to the list
        for(object thisObj : fieldData)
        {
            map<string, object> thisFieldData =  (map<string, object>) json.deserializeUntyped(JSON.serialize(thisObj));
            results.add(thisFieldData);
        }
       system.debug('***results: ' + results);
        return results;    
    }
    */
    
}