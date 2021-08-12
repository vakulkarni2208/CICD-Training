/*
  Controller for NV_PartnerCommunityHomePage.page
  
  Change Lists:
  
  2017.05.19 - VKULK- LOG A SUPPORT REQUEST validations & attachments
  2017.05.24 - PJENA- Log A Support Problem, Ask A Question subject changes
*/

global without sharing class NV_CommunityHomePageController {
    
    public string strLstPortalParentWrapper {get;set;}
    public string strNVContacts {get;set;}
    public string currUserLangName {get;set;}
    public Contact contactDetail {get;set;} 
    public boolean isAccountCharts {get;set;} //Done
    public boolean isOwnerCharts {get;set;}   //Done
    public List<NVIDIAContactsWrapper> lstNVIDIAContactsWrapper {get;set;} 
    public list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper {get;set;}
     // Main wrapper class to cosolidate all required object data into single unit. It pass on the VF page.
    public List<PortalParentWrapper> lstPortalParentWrapper {get;set;}
    public class PortalParentWrapper implements comparable{
        public string presentation_Type{get;set;}
        public string presentation_Label{get;set;}
        public decimal srno {get;set;}
        public boolean displayborder {get;set;}
        public string displayboxtitle {get;set;} 
        public boolean displayTitle {get;set;}
        //public string Portal_Home_Page_Box_Name {get;set;}
        public List<PortalChildWrapper> lstPortalChildWrapper {get;set;}
        public PortalParentWrapper(){
            lstPortalChildWrapper = new List<PortalChildWrapper>();
        }
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            PortalParentWrapper compareToPortalParentWrapper = (PortalParentWrapper)compareTo;
            if (srno == compareToPortalParentWrapper.srno) return 0;
            if (srno > compareToPortalParentWrapper.srno) return 1;
            return -1;        
        }
    }   
       
                
    // Wrapper class to consolidate Portal_Home_Page_Box__c data. 
    //public List<PortalChildWrapper> lstPortalChildWrapper {get;set;}
    public class PortalChildWrapper implements comparable{
        public decimal serialNo {get;set;} 
        public string presentation_Name {get;set;}
        public string presentation_Type {get;set;}
        public string presentation_URL{get;set;}
        public string image_URL{get;set;}
        public boolean isLink {get;set;}
        public string imageLocation {get;set;}
        public PortalChildWrapper(){
            serialNo = 0;      
        }
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            PortalChildWrapper compareToPortalChildWrapper = (PortalChildWrapper)compareTo;
            if (serialNo == compareToPortalChildWrapper.serialNo) return 0;
            if (serialNo > compareToPortalChildWrapper.serialNo) return 1;
            return -1;        
        }
    }   
    
    //Variable for report an email thing
    public boolean DisplayPopup_LogASupportRequest {get; set;}
    public boolean DisplayPopup_AskAQuestion {get; set;}
    public blob Attach {get;set;}       
    public string problemType {get;set;}
    public string companyName {get;set;}
    public string phoneNumber {get;set;}
    public string contactMobilePhone{get;set;}
    public string problemDescription {get;set;}
    public string shortDescription {get;set;}       
    public string steptoReproduceProblem {get;set;}    
    public String FileName_Upload {get; set;}    
    public boolean isReportAProblem {get;set;}  
    public string subject {get;set;}
    public string body {get;set;} 
    
    public NV_CommunityHomePageController() {
    
        set<string> setContactUserPortalGroups = new set<string>();   
        lstPortalParentWrapper = new List<PortalParentWrapper>();
        lstNVIDIAContactsWrapper = new List<NVIDIAContactsWrapper>();
        lstNVIDIAContactsProductWiseWrapper = new list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper>();
        currUserLangName = COMM_Utility.getUserLanguage(UserInfo.getLanguage());
        generatePresentationBoxes();
                
        //Get the Contact Details
        //------------------------------------
        getContactDetails(setContactUserPortalGroups);
        
        set<string> chartPermissionSets = new set<string>();
        for(PermissionSetAssignment psa :[Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId = :UserInfo.getUserId() And PermissionSet.Name like '%CHARTS']){
             chartPermissionSets.add(psa.PermissionSet.Name);                                  
        }
        
        if(chartPermissionSets.contains(COMM_Constants.PP_MANAGER_CHARTS)){
            isAccountCharts = true;
            isOwnerCharts = true;
        } else {
            isAccountCharts = false; 
        }
        
        if(chartPermissionSets.contains(COMM_Constants.PP_OWNER_CHARTS)){
            isOwnerCharts = true;
            
        }else{
            isOwnerCharts = false;
        }
                
        //Get all the Partner Portal Box names for the logged on user
        //e.g., Accelerated Computing, Professional Virtualization, Cloud/Virtualization, NVEP, Community
        //------------------------------------------------------
        
        set<string> contentTypes = returnContentTypeSet(setContactUserPortalGroups);
        //-------------------------------------------------------
                       
        //-------------------------------------------------------
        lstNVIDIAContactsProductWiseWrapper = NV_UtilityClass.putAllNVIDIACONTACTDetail(contactDetail, contentTypes);
        system.debug('lstNVIDIAContactsProductWiseWrapper->'+lstNVIDIAContactsProductWiseWrapper);
        //putAllNVIDIACONTACTDetail(contentTypes);
        showContentType();
        
        strLstPortalParentWrapper = String.escapeSingleQuotes(JSON.serialize(lstPortalParentWrapper));
        strNVContacts = String.escapeSingleQuotes(JSON.serialize(lstNVIDIAContactsProductWiseWrapper));
        system.debug(strNVContacts);
    }
    
    public void getContactDetails(set<string> setContactUserPortalGroups ){
        string contactId = [select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
        system.debug('check current user contact id'+contactId);
        if(contactId != null && contactId != ''){
            contactDetail = [   Select FirstName, LastName, Email, Phone, MobilePhone, Portal_User_Content_Type__c, Account.name, Account.Owner.Name, Account.Owner.email,
                                    Account.Owner.Phone,Account.BillingCountry, Account.BillingState, Account.Billing_Region__c, Account.Billing_Sub_Region__c, Portal_Groups__c
                                From Contact 
                                Where Id =:contactId];
            string contactUserPortalGroups = contactDetail.Portal_Groups__c;
            list<string> lstContactUserPortalGroups; 
            if (contactUserPortalGroups != null){
                lstContactUserPortalGroups = contactUserPortalGroups.split(';');
                if (lstContactUserPortalGroups != null) {
                
                    for (string strContactUserPortalGroup : lstContactUserPortalGroups){
                        setContactUserPortalGroups.add(strContactUserPortalGroup.trim());
                    }
                }
            }                   
        }
    }
    //*****************************************************************************
    //  Fetches the permission set names for the current user
    //*****************************************************************************
    public set<String> fetchPermissionSetNameList() {
        set<string> userPSAs = new set<string>();
        for(PermissionSetAssignment psa :[SELECT AssigneeId,Id,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where AssigneeId = :UserInfo.getUserId()]){
            userPSAs.add(psa.PermissionSet.Name);                                    
        }
        return userPSAs;
    }
    
    //*****************************************************************************
    //  Fetches the permission set Ids from the Portal_Permission_Sets__c for the passed permission set names
    //*****************************************************************************
    public set<Id> fetchPortalPermissionSetIdList(set<string> userPSAs) {
        set<Id> portalPermissionId = new set<Id>();
        for(Portal_Permission_Sets__c portalPSet :[Select Id From Portal_Permission_Sets__c  Where Name in :userPSAs]){
            portalPermissionId.add(portalPSet.id);
        }
        return portalPermissionId;
    }
    
    //*****************************************************************************
    //  It builds lstMainWrapper
    //  List of Home Page Boxes and its Home Page Box Contents
    //*****************************************************************************
    public void generatePresentationBoxes(){
        Map<string, Portal_Home_Page_Box__c> mapHomePageBox = new Map<string, Portal_Home_Page_Box__c>(); //Portal Home Page Box
        Map<string, List<Portal_Presentation__c>> mapHomePageBoxContent = new Map<string, List<Portal_Presentation__c>>(); //Portal Home Page Box Content
        //get all Permission Set Assignments for the logged on user
        set<string> userPSAs = fetchPermissionSetNameList();
        //get all the Portal Permission Sets records wrt logged on User's PSAs
        set<Id> portalPermissionId = fetchPortalPermissionSetIdList(userPSAs);

        //Build the mapHomePageBox map and homePageBoxIds
        //--------------------------------------------------------
        set<Id> homePageBoxIds = new set<Id>();
        for(Portal_Home_Page_Box__c PortalHomePageBox : [   Select Id, Name, Display_Border__c, Display_Title__c, Display_Box_Title__c, Presentation_Type__c 
                                                                , Box_Serial_Number__c
                                                            From Portal_Home_Page_Box__c 
                                                            Where Portal_Permission_Set__c in :portalPermissionId
                                                                And (Language__c = :currUserLangName or Language__c = null) ]){
            homePageBoxIds.add(PortalHomePageBox.Id);
            mapHomePageBox.put(PortalHomePageBox.Presentation_Type__c, PortalHomePageBox);
        }
        //--------------------------------------------------------

        //Build mapHomePageBoxContent : Map of home page to list of home page box content
        //Also build a map of Home Page Box to its serial number
        //--------------------------------------------------------
        //Map<string, decimal> mapPresentationTypeAndSerialNumber = new Map<string, decimal>();
        List<Portal_Presentation__c> lstPortal_Presentation = [ Select Id, Name, Image_URL__c, Portal_Profile__c, Presentation_Type__c, Presentation_URL__c,
                                                                    Content_Serial_Number__c, Image_Location__c, Is_Link__c, Permission_Set__c, Permission_Set__r.Name,
                                                                    Portal_Home_Page_Box__c, Portal_Home_Page_Box__r.Name, Portal_Home_Page_Box__r.Box_Serial_Number__c,
                                                                    Portal_Home_Page_Box__r.Display_Box_Title__c , Portal_Home_Page_Box__r.Display_Border__c, 
                                                                    Portal_Home_Page_Box__r.Display_Title__c, Portal_Home_Page_Box__r.Presentation_Type__c
                                                                From Portal_Presentation__c  
                                                                Where Portal_Home_Page_Box__c in :homePageBoxIds];             
        system.debug('lstPortal_Presentation ->'+lstPortal_Presentation );        
        set<string> portal_presentation_Sets = new set<string>();
        for(Portal_Presentation__c objPortalHomePageBoxContent : lstPortal_Presentation){                      
            if(mapHomePageBoxContent.get(objPortalHomePageBoxContent.Portal_Home_Page_Box__r.Presentation_Type__c) == null){
                mapHomePageBoxContent.put(objPortalHomePageBoxContent.Portal_Home_Page_Box__r.Presentation_Type__c, new List<Portal_Presentation__c>());                                            
            }                               
            mapHomePageBoxContent.get(objPortalHomePageBoxContent.Portal_Home_Page_Box__r.Presentation_Type__c).add(objPortalHomePageBoxContent);                           
            portal_presentation_Sets.add(objPortalHomePageBoxContent.Permission_Set__r.Name);
            //mapPresentationTypeAndSerialNumber.put(presentation.Portal_Home_Page_Box__r.Presentation_Type__c, presentation.Portal_Home_Page_Box__r.Box_Serial_Number__c);
        }
        /*Varun comment   */  
        system.debug('****portal_presentation_Sets: ' + portal_presentation_Sets);   
        set<string> portal_presentation_Assigned_To_User_Sets = new set<string>();
               
        for(PermissionSetAssignment psa : [ Select AssigneeId,Id,PermissionSetId,PermissionSet.Name 
                                            From PermissionSetAssignment 
                                            Where AssigneeId=:UserInfo.getUserId() and PermissionSet.Name in :portal_presentation_Sets]){                     
            portal_presentation_Assigned_To_User_Sets.add(psa.PermissionSet.Name);                                  
        }
        
                
        //--------------------------------------------------------
        buildWrappers(mapHomePageBox, mapHomePageBoxContent, userPSAs, portal_presentation_Sets,portal_presentation_Assigned_To_User_Sets );                           
                
    }
    //End of generatePresentationBoxes()
    
    public void buildWrappers(Map<string, Portal_Home_Page_Box__c> mapHomePageBox , Map<string, List<Portal_Presentation__c>> mapHomePageBoxContent, set<string> userPSAs, set<string> portal_presentation_Sets,set<string> portal_presentation_Assigned_To_User_Sets  ) {
        //Build the wrapper objects
        //--------------------------------------------------------              
        for(string presentationType : mapHomePageBoxContent.keyset()){    

            PortalParentWrapper objPortalParentWrapper = new PortalParentWrapper();   //Home Page Box
            objPortalParentWrapper.lstPortalChildWrapper = new List<PortalChildWrapper>();
            objPortalParentWrapper.presentation_Label = mapHomePageBox.get(presentationType).Name;                   
            objPortalParentWrapper.presentation_Type = mapHomePageBox.get(presentationType).Presentation_Type__c;
            objPortalParentWrapper.displayborder  = mapHomePageBox.get(presentationType).Display_Border__c;
            objPortalParentWrapper.displayboxtitle = mapHomePageBox.get(presentationType).Display_Box_Title__c;
            objPortalParentWrapper.displayTitle = mapHomePageBox.get(presentationType).Display_Title__c;
            objPortalParentWrapper.srno = mapHomePageBox.get(presentationType).Box_Serial_Number__c;
            //objPortalParentWrapper.srno = mapHomePageBoxContent.get(presentationType)[0].Portal_Home_Page_Box__r.Box_Serial_Number__c;
            
            for(Portal_Presentation__c objPortalHomePageBoxContent : mapHomePageBoxContent.get(presentationType)){
                if(portal_presentation_Assigned_To_User_Sets.contains(objPortalHomePageBoxContent.Permission_Set__r.Name)){
                    PortalChildWrapper objPortalChildWrapper = new PortalChildWrapper();    //Home Page Box Content
                    objPortalChildWrapper.serialNo = objPortalHomePageBoxContent.Content_Serial_Number__c;                    
                    objPortalChildWrapper.presentation_URL = objPortalHomePageBoxContent.Presentation_URL__c;
                    objPortalChildWrapper.image_URL = objPortalHomePageBoxContent.Image_URL__c;
                    objPortalChildWrapper.presentation_Name = objPortalHomePageBoxContent.Name;
                    objPortalChildWrapper.presentation_Type = objPortalHomePageBoxContent.Presentation_Type__c;
                    objPortalChildWrapper.isLink = objPortalHomePageBoxContent.Is_Link__c;
                    objPortalChildWrapper.ImageLocation = objPortalHomePageBoxContent.Image_Location__c; 
                    objPortalParentWrapper.lstPortalChildWrapper.add(objPortalChildWrapper); 
                }
            }
            objPortalParentWrapper.lstPortalChildWrapper.sort();
            lstPortalParentWrapper.add(objPortalParentWrapper);                                                                                                             
        }

        system.debug('***lstPortalParentWrapper: ' + lstPortalParentWrapper);
        
        //include the NVIDIA Contacts Box
        //Because this Home Page Box does not contain any Home Page Box Contents
        List<Portal_Home_Page_Box__c> lstPortalBoxNVIDIAandGettingStarted = [   Select Name, Presentation_Type__c, Box_Serial_Number__c, Portal_Permission_Set__r.Name 
                                                                                From Portal_Home_Page_Box__c 
                                                                                Where Presentation_Type__c = :COMM_Constants.BOX_PRESENTAIONTYPE_NVIDIA_CONTACTS
                                                                                    And Language__c = :currUserLangName];
        for(Portal_Home_Page_Box__c objnvidiaandgettingstarted  :   lstPortalBoxNVIDIAandGettingStarted){
            if(userPSAs.contains(objnvidiaandgettingstarted.Portal_Permission_Set__r.Name)){    
                PortalParentWrapper objPortalParentWrapper = new PortalParentWrapper();
                objPortalParentWrapper.srno = objnvidiaandgettingstarted.Box_Serial_Number__c;
                objPortalParentWrapper.presentation_Type = objnvidiaandgettingstarted.Presentation_Type__c;
                objPortalParentWrapper.presentation_Label = objnvidiaandgettingstarted.Name;
                lstPortalParentWrapper.add(objPortalParentWrapper);
                break;
            }
        }
        lstPortalParentWrapper.sort();
        system.debug('Check-----lstPortalParentWrapper'+lstPortalParentWrapper);
    }
    
    //**********************************************************************************************************
    //Build lstNVIDIAContactsWrapper object - list of NVIDIAContactsWrapper records with the default Content Type at the top of the list
    // Extracting NV Contacts data based on filtered logic. Preventing to add same content type records into list. If duplicate record exist using third filter with Account Owner.
    //Note: Needs improvement - Left for another revision
    //**********************************************************************************************************
    /*
    public void putAllNVIDIACONTACTDetail(set<string> allContentType){        

        Map<string, integer> mapContentTypeAndUSStates = new Map<string, integer>();
        Map<string, integer> mapContentTypeAndOtherStates = new Map<string, integer>();           
        Map<string, integer> mapContentTypeAndBlankStates = new Map<string, integer>();   
        List<NV_Contacts__c> lstNVContact =   new List<NV_Contacts__c>();
        
        list<NV_Contacts__c> lstNVContacts = [  Select Billing_Country__c, Other_States__c,Account_Owner_Name__c, US_States__c, Marketing_Manager_Contact_Number__c, 
                                        Marketing_Manager_Email__c, Marketing_Manager_Name__c, Product_Line__c, Sales_Manager_Contact_Number__c, Sales_Manager_Email__c, 
                                        Sales_Manager_Name__c, Sales_Manager_Name__r.Name, Support_Manager_Contact_Number__c, Support_Manager_Email__c, Support_Manager_Name__c, 
                                        Sales_Title__c, Marketing_Title__c, Support_Title__c  
                                    From NV_Contacts__c];
                                    
        for( NV_Contacts__c objNV : lstNVContacts ){
            if(objNV.US_States__c != null){              
                if(contactDetail.Account.BillingCountry == objNV.Billing_Country__c && contactDetail.Account.BillingState == objNV.US_States__c && allContentType.contains(objNV.Product_Line__c)){                                                        
                    if(mapContentTypeAndUSStates.get(objNV.Product_Line__c) == null){
                        mapContentTypeAndUSStates.put(objNV.Product_Line__c, 1);
                    }else {
                        mapContentTypeAndUSStates.put(objNV.Product_Line__c, mapContentTypeAndUSStates.get(objNV.Product_Line__c) + 1);                                                    
                    }
                }
            }else if(objNV.Other_States__c != null){
                if(contactDetail.Account.BillingCountry == objNV.Billing_Country__c && contactDetail.Account.BillingState == objNV.Other_States__c && allContentType.contains(objNV.Product_Line__c)){                                                        
                    if(mapContentTypeAndOtherStates.get(objNV.Product_Line__c) == null){
                        mapContentTypeAndOtherStates.put(objNV.Product_Line__c, 1);
                    }else {
                        mapContentTypeAndOtherStates.put(objNV.Product_Line__c, mapContentTypeAndOtherStates.get(objNV.Product_Line__c) + 1);                                                  
                    }
                }   
            }else {
                if(contactDetail.Account.BillingCountry == objNV.Billing_Country__c && allContentType.contains(objNV.Product_Line__c)){                                                        
                    if(mapContentTypeAndBlankStates.get(objNV.Product_Line__c) == null){
                        mapContentTypeAndBlankStates.put(objNV.Product_Line__c,1);
                    }else {
                        mapContentTypeAndBlankStates.put(objNV.Product_Line__c,mapContentTypeAndBlankStates.get(objNV.Product_Line__c)+1);                                                  
                    }
                }
            }
        }
               
        system.debug('mapContentTypeAndUSStates--'+mapContentTypeAndUSStates+'mapContentTypeAndOtherStates--'+mapContentTypeAndOtherStates+'--mapContentTypeAndBlankStates'+mapContentTypeAndBlankStates);
        
        for( NV_Contacts__c objNV : lstNVContacts ){
            if(objNV.US_States__c != null){
                if(mapContentTypeAndUSStates.containskey(objNV.Product_Line__c)){
                    if(mapContentTypeAndUSStates.get(objNV.Product_Line__c) > 1){
                        if(contactDetail.Account.BillingCountry==objNV.Billing_Country__c && contactDetail.Account.BillingState==objNV.US_States__c && allContentType.contains(objNV.Product_Line__c) && contactDetail.Account.OwnerId==objNV.Account_Owner_Name__c){
                            lstNVContact.add(objNV);                            
                        }
                    }else if(contactDetail.Account.BillingCountry==objNV.Billing_Country__c && contactDetail.Account.BillingState==objNV.US_States__c && allContentType.contains(objNV.Product_Line__c)){
                        lstNVContact.add(objNV);     
                    }
                }                       
            }else if(objNV.Other_States__c !=null){
                if(mapContentTypeAndOtherStates.containsKey(objNV.Product_Line__c)){
                    if(mapContentTypeAndOtherStates.get(objNV.Product_Line__c) > 1){
                        if(contactDetail.Account.BillingCountry==objNV.Billing_Country__c && contactDetail.Account.BillingState==objNV.Other_States__c && allContentType.contains(objNV.Product_Line__c) && contactDetail.Account.OwnerId==objNV.Account_Owner_Name__c){
                            lstNVContact.add(objNV);                            
                        }   
                    }else if(contactDetail.Account.BillingCountry==objNV.Billing_Country__c && contactDetail.Account.BillingState==objNV.Other_States__c && allContentType.contains(objNV.Product_Line__c)){
                        lstNVContact.add(objNV); 
                    }
                }
            }else {
                if(mapContentTypeAndBlankStates.containsKey(objNV.Product_Line__c)){
                    if(mapContentTypeAndBlankStates.get(objNV.Product_Line__c) > 1){       
                        if(contactDetail.Account.BillingCountry==objNV.Billing_Country__c && allContentType.contains(objNV.Product_Line__c) && contactDetail.Account.OwnerId==objNV.Account_Owner_Name__c){
                            lstNVContact.add(objNV);                            
                        }
                    }else if(contactDetail.Account.BillingCountry==objNV.Billing_Country__c && allContentType.contains(objNV.Product_Line__c)){
                        lstNVContact.add(objNV);       
                    }
                }
            }
        }
        
        //Build the NV COntacts wrapper object
        for(NV_Contacts__c obj :lstNVContact){
            NVIDIAContactsWrapper objWrapNV = new NVIDIAContactsWrapper();
            objWrapNV.contentType = obj.Product_Line__c;
            
            objWrapNV.Marketing_Manager_Name = obj.Marketing_Manager_Name__c;
            objWrapNV.Marketing_Manager_Email = obj.Marketing_Manager_Email__c;
            objWrapNV.Marketing_Manager_Contact_Number = string.valueOf(obj.Marketing_Manager_Contact_Number__c);
            
            objWrapNV.Sales_Manager_Name = obj.Sales_Manager_Name__r.Name;
            objWrapNV.Sales_Manager_Email = obj.Sales_Manager_Email__c;
            objWrapNV.Sales_Manager_Contact_Number = string.valueOf(obj.Sales_Manager_Contact_Number__c);
            
            objWrapNV.Support_Manager_Name = obj.Support_Manager_Name__c;
            objWrapNV.Support_Manager_Email = obj.Support_Manager_Email__c;
            objWrapNV.Support_Manager_Contact_Number = string.valueOf(obj.Support_Manager_Contact_Number__c);
            
            objWrapNV.SalesManager_Title1 = obj.Sales_Title__c;
            objWrapNV.MarketingManager_Title2 = obj.Marketing_Title__c;
            objWrapNV.SupportManager_Title3 = obj.Support_Title__c;
            lstNVIDIAContactsWrapper.add(objWrapNV);            
        } 
        
        //Bring the record with Default Content Type to the top of the list
        if( lstNVIDIAContactsWrapper.size()>0 ){
            setDefaultContentTypeFirstInList(lstNVIDIAContactsWrapper);
        }
                                   
    }*/
    //end of putAllNVIDIACONTACTDetail()
    //**********************************************************************************************************
    
    //**********************************************************************************************************
    // Wrapper class to hold NV Contacts
    //**********************************************************************************************************    
    public class NVIDIAContactsWrapper{
        public string contentType {get;set;}
        
        public string Marketing_Manager_Name {get;set;}
        public string Marketing_Manager_Email {get;set;}
        public string Marketing_Manager_Contact_Number {get;set;}
        
        public string Sales_Manager_Name {get;set;}
        public string Sales_Manager_Email {get;set;}
        public string Sales_Manager_Contact_Number {get;set;}
        
        public string Support_Manager_Name {get;set;}
        public string Support_Manager_Email {get;set;}
        public string Support_Manager_Contact_Number {get;set;}
        
        public string SalesManager_Title1 {get;set;}
        public string MarketingManager_Title2 {get;set;}
        public string SupportManager_Title3 {get;set;}       
    }   
    //**********************************************************************************************************
    
    //**********************************************************************************************************
    //  Bring the record with Default Content Type to the top of the list
    //**********************************************************************************************************
    /*private void setDefaultContentTypeFirstInList(List<NVIDIAContactsWrapper> lstNVWrapper){
        
        NVIDIAContactsWrapper recWithDefContentType = new NVIDIAContactsWrapper();
        
        //save the records from lstNVIDIAContactsWrapper to a cloned wrapper
        List<NVIDIAContactsWrapper> lstClonedWrapper = lstNVWrapper.clone();        
        
        //remove all records from  lstNVIDIAContactsWrapper
        lstNVIDIAContactsWrapper.clear();
        
        //isolate the record with default content type
        for(NVIDIAContactsWrapper oNVCW : lstClonedWrapper){
            if(oNVCW.contentType  == contactDetail.Portal_User_Content_Type__c){
                recWithDefContentType = oNVCW;
                break;
            }
        }
        
        //Rebuild the lstNVIDIAContactsWrapper list with the first item being the record with Default Content Type
        if(recWithDefContentType.contentType != null && recWithDefContentType.contentType != ''){
            lstNVIDIAContactsWrapper.add(recWithDefContentType);
        }
        for(NVIDIAContactsWrapper oNVCW : lstClonedWrapper){
            if(oNVCW.contentType  != contactDetail.Portal_User_Content_Type__c){
                lstNVIDIAContactsWrapper.add(oNVCW);
            }
        }
        
    }*/
   
   // Creating a select option list on send email popup to add all content type and setting default if size is one else adding None in first record in the list. Same list using for both Email Popup Grid.
   public List<String> lstPortalContentTypes{get;set;}
   public string selectedContentType{get;set;}
   
   //***************************************************************************************
   //Build the Content Type drop down list lstPortalContentTypes
   //***************************************************************************************
   public void showContentType(){
        //initialize the list variable lstPortalContentTypes
        lstPortalContentTypes= new List<String>();
        
        //Get all the Partner Portal Box names for the logged on user
        //e.g., Accelerated Computing, Professional Virtualization, Cloud/Virtualization, NVEP, Community
        //-------------------------------------------------------
        set<string> contentTypes = returnContentTypeSet();
        system.debug('***contentTypes: ' + contentTypes);
        //-------------------------------------------------------
        integer iTotalContentTypes = 0;
        if (contentTypes != null){
            iTotalContentTypes = contentTypes.size();
        }
        
        //build the drop down options
        if(iTotalContentTypes >= 1){
            if (iTotalContentTypes > 1) lstPortalContentTypes.add('--None--'); //if more than one Content Type then show this option
            for (string strContentType : contentTypes){
                lstPortalContentTypes.add(strContentType);
            }
        }
        
        //if the Content Type size = 1, set the only selected option as PRE-SELECTED
        if(iTotalContentTypes == 1){
            selectedContentType = lstPortalContentTypes[0];
        }
        
        //sort the SelectOption list
        lstPortalContentTypes.sort();
        
    }
    
    public  set<string> returnContentTypeSet(set<string> setContactUserPortalGroups){
        set<string> contentTypes = new set<string>();
        system.debug(setContactUserPortalGroups);
        list<NV_Permissions_and_PCL_Mapping__c> lstNV_Permissions_and_PCL_Mapping = NV_Permissions_and_PCL_Mapping__c.getall().values();
        for(NV_Permissions_and_PCL_Mapping__c objNV_Permissions_and_PCL_Mapping : lstNV_Permissions_and_PCL_Mapping) {
          if(setContactUserPortalGroups.contains(objNV_Permissions_and_PCL_Mapping.combination__c)) {
            String subProgram = objNV_Permissions_and_PCL_Mapping.Sub_Program__c==null?'':objNV_Permissions_and_PCL_Mapping.Sub_Program__c ;
            String strProgramNameCompetencyType = objNV_Permissions_and_PCL_Mapping.Program_Name__c + subProgram + objNV_Permissions_and_PCL_Mapping.Competency__c;
            contentTypes.add(strProgramNameCompetencyType);
          }
        }
        system.debug(contentTypes);
        return contentTypes;
    }
    
    public  set<string> returnContentTypeSet(){
        set<string> contentTypes = new set<string>();
        set<string> boxPermissionSets = new set<string>();
        set<Id> customPermissionSets = new Set<Id>();
        for(PermissionSetAssignment psa :[Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId = :UserInfo.getUserId()]){
           //  if(psa.PermissionSet.Name.contains('Box'))
             boxPermissionSets.add(psa.PermissionSet.Name);
        }
           
        for(Portal_Permission_Sets__c pms :[Select Id From Portal_Permission_Sets__c Where Name in :boxPermissionSets]){
                customPermissionSets.add(pms.Id);
        }
        
        for(Partner_Portal_Label__c box : [Select Portal_Content_Type__c From Partner_Portal_Label__c Where Permission_Set__c  In : customPermissionSets]){  
            if(box.Portal_Content_Type__c != null){                                    
                    contentTypes.add(box.Portal_Content_Type__c);                  
            }
        }
        return contentTypes;
    }
    
    public void showPopup_LogASupportRequest() {
        
    }
    
    public void showPopup_AskAQuestion() {
        
    }
    
        //========================================================================================================
    // LOG A SUPPORT REQUEST EMAIL FUNCTIONALITY
    //========================================================================================================   
    @RemoteAction
    global static Boolean sendEmail_LogASupportRequest(String logASupportRequest){   
        boolean flag = false;                
        //system.debug('logASupportRequest'+logASupportRequest);
        Map<String, Object> mapLogASupportRequest = (Map<String, Object>) JSON.deserializeUntyped(logASupportRequest);
        //system.debug('mapLogASupportRequest'+mapLogASupportRequest);
        //Map<String, Object> mapContactData = (Map<String, Object>) JSON.deserializeUntyped((String)mapLogASupportRequest.get('contact'));
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        if(mapLogASupportRequest.get('FileBody') != null && mapLogASupportRequest.get('FileBody') != ''){
            efa.setFileName((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('name'));    
            if(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body')).contains(',')) {        
                efa.setBody(EncodingUtil.base64Decode(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body')).split(',')[1]));
            } else {
                efa.setBody(EncodingUtil.base64Decode(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body'))));
            }
            fileAttachments.add(efa);   
        }
            
        //Build the to addresses
        String[] toAddresses;
        List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
   
        if(lstCSPortalToggles != null && lstCSPortalToggles.size() > 0){
            for(Portal_Toggles__c eachPortalToggle : lstCSPortalToggles){
                if((String)((Map<String, Object>)mapLogASupportRequest.get('selectedContentType')).get('value') == eachPortalToggle.Name){
                    if(eachPortalToggle.Log_A_Support_Request_Email__c != null){
                        toAddresses = new String[] {eachPortalToggle.Log_A_Support_Request_Email__c};
                        break;
                    }
                }
            }
        }
            
        mail.setToAddresses(toAddresses);                
        DateTime d = System.now();
        mail.setSubject(COMM_Constants.LOG_A_SUPPORT_SUBJECT + UserInfo.getFirstName() +' '+ UserInfo.getLastName() + ' on ' + d.month() + '/' + d.day() + '/' + d.year() + '/' + d.time() + ' on ' + mapLogASupportRequest.get('problemType'));
        mail.setBccSender(false); 
        if(fileAttachments.size() > 0){    
            mail.setFileAttachments(fileAttachments);
        }        
            
        //contact phone
        string strContactPhone = '';
        if(((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone') != null && ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone') != ''){
            strContactPhone = (String) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone');
        } else{
            strContactPhone = (String) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Phone');
        }
            
        //build the email body
        string html = '<table width="100%"><tr><td width="30%"><b>Company Name</b></td>';        
        html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('AccountName') + '</td></tr>';        
        html += '<tr><td><b>Contact Name</b></td>';
        html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('FirstName') + '</td></tr>';
        html += '<tr><td><b>Contact Email Address</b></td>';
        html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Email') + '</td></tr>';
        html += '<tr><td><b>Contact Phone Number</b></td>';
        html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Phone') + '</td></tr>';  
        html += '<tr><td><b>Short Description</b></td>';
        html += '<td>' + mapLogASupportRequest.get('problemType') + '</td></tr>';
        html += '<tr><td><b>Problem Description</b></td>';
        html += '<td>' + mapLogASupportRequest.get('problemDescription') + '</td></tr>';
        html += '<tr><td><b>Steps to Reproduce Problem</b></td>';
        html += '<td>' + mapLogASupportRequest.get('stepToReproduce') + '</td></tr></table>';
            
        //set html body
        mail.setHtmlbody(html);      
            
        //send email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        //Capture the details in Salesforce Custom Object
        //----------------------------------------------------------------------------
        Support_Request_And_Question__c supportRec = new Support_Request_And_Question__c();
        supportRec.Account__c = (Id) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('AccountId');
        supportRec.Contact__c = (Id) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Id');
        supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_FULL;
        supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_LOG_A_SUPPORT_REQ;
        supportRec.Competency__c = (String)((Map<String, Object>)mapLogASupportRequest.get('selectedContentType')).get('value');
        supportRec.Contact_Phone_Number__c = (String) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Phone');
        supportRec.Short_Description__c = (String) mapLogASupportRequest.get('problemType');
        supportRec.Problem_Description__c = (String) mapLogASupportRequest.get('problemDescription');
        supportRec.Steps_to_Reproduce_Problem__c = (String) mapLogASupportRequest.get('stepToReproduce');
        supportRec.AAQ_Subject__c = null;
        supportRec.AAQ_Body__c = null;
        insert supportRec;
            
        //insert the attachment if any
        if(fileAttachments.size() > 0){
            Attachment oAttachment = new Attachment();
            /*oAttachment.Body = Blob.valueof((String)mapLogASupportRequest.get('FileBody'));
            oAttachment.Name = 'TestAttach';*/
            oAttachment.name = ((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('name'));    
            if(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body')).contains(',')) {        
                oAttachment.body = EncodingUtil.base64Decode(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body')).split(',')[1]);
            } else {
                oAttachment.body = EncodingUtil.base64Decode(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body')));
            }
            oAttachment.ParentId = supportRec.Id; 
            insert oAttachment;
        }
        //End----------------------------------------------------------------------------
        
        //show succecss message
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Success));
        
        //close pop-up message
        //DisplayPopup_LogASupportRequest = false;
        //closePopup_LogASupportRequest();
          
        return true;
    }
    
    //========================================================================================================
    // ASK A QUESTION EMAIL FUNCTIONALITY
    //========================================================================================================   
    @RemoteAction
    global static Boolean sendEmail_askAQuestion(String askAQuestion){   
        boolean flag = false;                
        system.debug('askAQuestion'+askAQuestion);
        Map<String, Object> mapAskAQuestion = (Map<String, Object>) JSON.deserializeUntyped(askAQuestion);
        system.debug('mapAskAQuestion'+mapAskAQuestion);
            if((String)((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value')=='--None--' || (String)((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value') == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_MSG_Competency_Reqd));
                if(!test.isRunningTest()) return false; 
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
            String[] toAddresses;
            List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
       
            if(lstCSPortalToggles != null && lstCSPortalToggles.size()>0){
                for(Portal_Toggles__c eachPortalToggle: lstCSPortalToggles){
                    if((String)((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value') == eachPortalToggle.Name){
                        if(eachPortalToggle.Ask_A_Question_Email__c != null){
                            toAddresses = new String[] {eachPortalToggle.Ask_A_Question_Email__c};
                            break;
                        }
                    }
                }
            }
        
            mail.setToAddresses(toAddresses);                
            //mail.setSubject('Ask a Question: ' + (String)mapAskAQuestion.get('emailSubject') + ' | Competency = ' + (String)((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value') );
            mail.setSubject(COMM_Constants.ASK_A_QUESTION_SUBJECT + (String)mapAskAQuestion.get('emailSubject') + ' | Competency = ' + (String)((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value') );
            mail.setBccSender(false);       
            mail.setPlainTextBody((String)mapAskAQuestion.get('emailBody'));
            
            //contact phone
            string strContactPhone = '';
            if(((Map<String, Object>)mapAskAQuestion.get('contact')).get('MobilePhone') != null && ((Map<String, Object>)mapAskAQuestion.get('contact')).get('MobilePhone') != ''){
                strContactPhone = (String) ((Map<String, Object>)mapAskAQuestion.get('contact')).get('MobilePhone');
            } else{
                strContactPhone = (String) ((Map<String, Object>)mapAskAQuestion.get('contact')).get('Phone');
            }
            
            //send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            //Capture the details in Salesforce Custom Object
            //----------------------------------------------------------------------------
            Support_Request_And_Question__c supportRec = new Support_Request_And_Question__c();
            supportRec.Account__c = (Id) ((Map<String, Object>)mapAskAQuestion.get('contact')).get('AccountId');
            supportRec.Contact__c = (Id) ((Map<String, Object>)mapAskAQuestion.get('contact')).get('Id');
            supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_FULL;
            supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_ASK_A_QUESTION;
            supportRec.Competency__c = (String) ((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value');
            supportRec.Contact_Phone_Number__c =  (String) ((Map<String, Object>)mapAskAQuestion.get('contact')).get('Phone');
            supportRec.Short_Description__c = null;
            supportRec.Problem_Description__c = null;
            supportRec.Steps_to_Reproduce_Problem__c = null;
            supportRec.AAQ_Subject__c = (String) mapAskAQuestion.get('emailSubject');
            supportRec.AAQ_Body__c = (String) mapAskAQuestion.get('emailBody');
            insert supportRec;
            
            return true;
                 
    }
}