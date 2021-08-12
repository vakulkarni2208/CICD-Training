/*
  Controller for NV_PartnerCommunityTabs.page
  
  Change Lists:
  
  2017.05.19 - VKULK- LOG A SUPPORT REQUEST validations & attachments
  2017.05.24 - PJENA- Log A Support Problem, Ask A Question subject changes
*/
global without sharing class NV_PartnerCommunityTabs {

    //Variable for report an email thing     
    public string problemType {get;set;}
    public string problemDescription {get;set;}       
    public string steptoReproduceProblem {get;set;}
    public boolean isReportAProblem {get;set;}    
    public Boolean bUnRestricted {get;set;}
    
    //GPUGenius Groups for the current user
    public string strGGGroups{get;set;}
    public Contact contactDetail {get;set;}
    
    //public class to hold toggle name and detail
    //Note: both the variables contain the Box's Content Type one as it is and the other in lower case
    public class wrapperToggleDetail implements comparable{
        public string strToggleName {get;set;}
        public string strToggleDetail {get;set;}
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            wrapperToggleDetail compareTowrapperToggleDetail = (wrapperToggleDetail)compareTo;
            if (strToggleName == compareTowrapperToggleDetail.strToggleName) return 0;
            if (strToggleName > compareTowrapperToggleDetail.strToggleName) return 1;
            return -1;        
        }
    }
    
    //Current users Portal Content Types based on the Permission Sets assignments and Portal Permission Sets assigned to the Boxes and the Portal Content Types matching with Portal_Toggles__c records
    public List<wrapperToggleDetail> lstPortalContentTypes {get;set;}
    public String strLstPortalContentTypes {get;set;}
        
    //Select Content Type for the Contact. It dynamically selected. 
    //If during the user session, User clicks on Content Type it gets stored in Portal_Content_Type__c custom settings otherwise it is pulled from Contact record's Default Content Type field
    public string selectedContentType {get;set;}
    
    // Wrapper to create boxes based on sequence, label and bullets. 
    public class Box implements comparable{
        public integer serialNo {get;set;}
        public string competency {get;set;}
        public string label {get;set;}
        public boolean isBullet {get;set;}
        public List<BoxContent> lstBoxContent {get;set;}
        public Box(){
              lstBoxContent = new List<BoxContent>();
              serialNo = 0;            
        }   
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            Box compareToBox = (Box)compareTo;
            if (serialNo == compareToBox.serialNo) return 0;
            if (serialNo > compareToBox.serialNo) return 1;
            return -1;        
        }
    }
    public List<Box> lstBox {get;set;}
    
    // Wrapper which display Data inside the boxes (or Box Contents) with their value, target url , sequence and text justification etc. Displaying data based on their properties.
    public class BoxContent implements comparable{
        public string value {get;set;}
        public string url {get;set;} 
        public string displayPageWindow {get;set;}
        public integer srno {get;set;}
        public string contentJustification {get;set;}
        public boolean IsLink{get;set;}      
        public boolean displayBullet {get;set;}
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            BoxContent compareToBoxContent = (BoxContent)compareTo;
            if (srno == compareToBoxContent.srno) return 0;
            if (srno > compareToBoxContent.srno) return 1;
            return -1;        
        }
    }
    
    // Wrapper class to pass all the data on visualforce page through a list.  
    public class BoxList {
        public List<Box> lstBox{get;set;}
        public BoxList(List<Box> lstBox){
            system.debug(lstBox);
            this.lstBox = lstBox;
        }
    }
    public List<BoxList> lstBoxList{get;set;}
    public String strLstBoxList{get;set;}
    
    public string instanceMessage {get;set;}
    public string tabName {get;set;}
    
    public string brainshark_url {get; set;}
    
    private string currUserLangName{get; set;}
    
    //Constructor
    public NV_PartnerCommunityTabs(){
        //get the Tab name from the URL parameter
        tabName = ApexPages.CurrentPage().getParameters().get('tab');
        system.debug('***tabName: ' + tabName);
        
        //Initialize the wrappers
        lstBox = new List<Box>();
        lstBoxList = new List<BoxList>();
        
        //get the country filter of the logged on user,
        //-----------------------------------------------------------
        /*
        Logic: If the user records langauge is found in the Community_User_Local_Settings__c then user the use the matching record otherwise default it to English
        */
        string currUserLocaleLangKey = UserInfo.getLanguage();
        currUserLangName = COMM_Utility.getUserLanguage(currUserLocaleLangKey);
        system.debug('***currUserLangName = ' + currUserLangName);
        //-----------------------------------------------------------
        
        //Initialize the list of wrappers and other flags
        //-------------------------------------------------------------------------------
        init();             
        //-------------------------------------------------------------------------------

        //GPUGenius Groups for the current user
        //-------------------------------------------------------------------------------
        getGPUGeniusGroupIDs();
        //-------------------------------------------------------------------------------
        
        //set BrainShark URL
        brainshark_url = Community_Settings__c.getOrgDefaults().BRAINSHARK_URL__c;
    }
    
    public void init(){

        //=========================================================================================================================================================
        // Set the lstPortalContentTypes. It is used to show the Competencies / Content Types in the page
        //=========================================================================================================================================================
        // Get only those boxes which are part of assiged permission.
        // Adding a filter based on Box permission sets
        //----------------------------------------------------------------------------------
        string contactId = [select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
        Contact contactDetail = [Select id, account.EAR_Restricted__c from Contact where id = :contactId];
        if(contactDetail.account.EAR_Restricted__c) {
             bUnRestricted = false;
         } else {
             bUnRestricted = true;
         }
        set<string> setCurrUserAssignedPSNames = new set<string>();
        list<PermissionSetAssignment> lstCurrUserPSAs = [   Select AssigneeId, PermissionSetId, PermissionSet.Name, Assignee.Account.EAR_Restricted__c
                                                            From PermissionSetAssignment 
                                                            Where AssigneeId = :UserInfo.getUserId() ];
        for(PermissionSetAssignment psa :lstCurrUserPSAs){
           // if(psa.PermissionSet.Name.contains('Box'))  
             setCurrUserAssignedPSNames.add(psa.PermissionSet.Name);                   
        }
        //----------------------------------------------------------------------------------
        
        
        //Check if REPORT A PROBLEM BUTTON needs to be shown in Support tab
        //--------------------------------------------------------------------
        //COMM_Constants.BOX_REPORTAPROBLEM = 'REPORT A PROBLEM BUTTON'
        Portal_Home_Page_Box__c oPHPB_ReportAProblemBTN = [Select Name, Portal_Permission_Set__r.Name From Portal_Home_Page_Box__c Where Name = :COMM_Constants.BOX_REPORTAPROBLEMBTN limit 1];                
        List<PermissionSetAssignment> lstPSAForReportAProblemBTN = [Select AssigneeId, PermissionSetId, PermissionSet.Name 
                                                                    From PermissionSetAssignment
                                                                    Where AssigneeId = :UserInfo.getUserId() 
                                                                        And PermissionSet.Name = :oPHPB_ReportAProblemBTN.Portal_Permission_Set__r.Name];
        
        if(lstPSAForReportAProblemBTN.size() > 0 && tabName == COMM_Constants.TAB_SUPPORT){
            isReportAProblem = true;
        }else{
            isReportAProblem = false; 
        }
        //--------------------------------------------------------------------    
         
       //get all the Custom Portal Permission Set record Ids the current user is assigned to
       //-------------------------------------------------------------------- 
        set<Id> setCurrUserCustomPSIds = new set<Id>(); 
        
        for(Portal_Permission_Sets__c pms : [Select Id From Portal_Permission_Sets__c Where Name in :setCurrUserAssignedPSNames]){
            setCurrUserCustomPSIds.add(pms.Id);               
        }                        
        //-------------------------------------------------------------------- 
        
        //get all the Toggle names from Custom Settings
        //---------------------------------------------------------------------------------
        List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
        map<string,string> mapCSPortalToggles = new map<string,string>(); 
        if(lstCSPortalToggles != null && lstCSPortalToggles.size() > 0){
            for(Portal_Toggles__c cspToggle: lstCSPortalToggles){
                mapCSPortalToggles.put(cspToggle.Name.toLowerCase(), cspToggle.Toggle_Description__c);
            }
        }
        //----------------------------------------------------------------------------------
        
        
                                  
        //Find all the Portal Content Types for the User
        //Current users Portal Content Types based on the Permission Sets assignments and Portal Permission Sets assigned to the Boxes and the Portal Content Types matching with Portal_Toggles__c records
        //----------------------------------------------------------------------------------
        lstPortalContentTypes = new List<wrapperToggleDetail>();
        
        set<string> setCurrUserBoxContentTypes = new set<string>();
        boolean IsToggleMatch = false;
        integer iToggleMatchCount = 0;
        //if the Box Portal Content Type matches with Toggle Competency, increment iToggleMatchCount count
        //build lstPortalContentTypes from Box's Portal Content Types
        system.debug('***currUserLangName: ' + currUserLangName);
        system.debug('***setCurrUserCustomPSIds: ' + setCurrUserCustomPSIds);

        list<Partner_Portal_Label__c> lstPPBox = new list<Partner_Portal_Label__c>();
        if(bUnRestricted == false) {
            lstPPBox = [Select Name, Portal_Tab__c, Portal_Content_Type__c 
                            From Partner_Portal_Label__c 
                            Where Permission_Set__c In :setCurrUserCustomPSIds
                                And (Language__c = :currUserLangName Or Language__c = null) //add the User Language filter
                                And Not_for_Restricted_Accounts__c = false
                                And Portal_Tab__c includes (:tabName)
                                //And Partner_Portal_Tab__c = :tabName //add the selected tab filter
                        ];
        } else {
            lstPPBox = [Select Name, Portal_Tab__c, Portal_Content_Type__c 
                            From Partner_Portal_Label__c 
                            Where Permission_Set__c In :setCurrUserCustomPSIds
                                And (Language__c = :currUserLangName Or Language__c = null) //add the User Language filter
                                And Portal_Tab__c includes (:tabName)
                                //And Partner_Portal_Tab__c = :tabName //add the selected tab filter
                        ];
        }
        for(Partner_Portal_Label__c box : lstPPBox){
            
            if(box.Portal_Content_Type__c != null){
                //if the Box Portal Content Type matches with Toggle Competency, increment iToggleMatchCount count
                if(lstCSPortalToggles != null && lstCSPortalToggles.size() > 0){
                    for(Portal_Toggles__c oToggleCompetency: lstCSPortalToggles){
                        if(box.Portal_Content_Type__c.tolowercase() == string.valueof(oToggleCompetency.Name.toLowerCase()) ){
                            IsToggleMatch = true;
                            iToggleMatchCount = iToggleMatchCount  + 1; //do not know why
                        }
                    }
                }
                
                //Build the list of wrapper object containing Box's Portal Content Type and Portal Content Type in lowercase
                if(!setCurrUserBoxContentTypes.contains(box.Portal_Content_Type__c)){
                    setCurrUserBoxContentTypes.add(box.Portal_Content_Type__c);
                    if(mapCSPortalToggles != null && mapCSPortalToggles.get(box.Portal_Content_Type__c.toLowerCase()) != null){
                        wrapperToggleDetail objwrpTD = new wrapperToggleDetail();
                        objwrpTD.strToggleName = box.Portal_Content_Type__c;
                        objwrpTD.strToggleDetail = mapCSPortalToggles.get(box.Portal_Content_Type__c.toLowerCase());
                        lstPortalContentTypes.add(objwrpTD);
                    }                   
                }
                
            }
        }
        system.debug(lstPortalContentTypes);
        //----------------------------------------------------------------------------------
        
        //Sort wrapper list
        //----------------------------------------------------------------------------------
        if(lstPortalContentTypes != null && lstPortalContentTypes.size() > 0){
            lstPortalContentTypes.sort();
        }
        //----------------------------------------------------------------------------------
        
        //End: setting lstPortalContentTypes
        //=========================================================================================================================================================
        
        //Based on the selected Content Type and Permission Set Assignment, get a map of Portal Boxe Id and its detail
        //-------------------------------------------------------------------------------------------------------------------
        //map of Portal Box Id to the Portal Box Details matching with Current User's Permission Sets
        map<Id, Partner_Portal_Label__c> mapPortalBoxIdToPortalBoxDetail = new map<Id, Partner_Portal_Label__c>();
        
                
        //Check content type for the login user
        //For the first login, the selected content type would be taken from the Contact record afterwards as and when the user selects the Content Type it gets stored in custom settings named Portal_Content_Type__c
        selectedContentType = returnSelectedContentTypeFromCustomSetting();
        
        
        
        /*if((isProfessional_Visualization ==true && isCloud_Virtualization == false && isAccelerated_Computing==false) || (isProfessional_Visualization ==false && isCloud_Virtualization == true && isAccelerated_Computing==false) || (isProfessional_Visualization ==false && isCloud_Virtualization == false && isAccelerated_Computing==true))*/
        system.debug('***IsToggleMatch: ' + IsToggleMatch);
        system.debug('***iToggleMatchCount: ' + iToggleMatchCount);
        system.debug('***currUserLangName: ' + currUserLangName);
        system.debug('***selectedContentType: ' + selectedContentType);
        
        if(IsToggleMatch == true && iToggleMatchCount == 1){
           if(bUnRestricted == false) {
               mapPortalBoxIdToPortalBoxDetail = new Map<Id, Partner_Portal_Label__c>([Select Id, Name, Portal_Tab__c, Portal_Content_Type__c 
                                                                                    From Partner_Portal_Label__c 
                                                                                    Where Permission_Set__c In :setCurrUserCustomPSIds
                                                                                        And Not_for_Restricted_Accounts__c = false
                                                                                        And (Language__c = :currUserLangName Or Language__c = null) ]);
           } else {
               mapPortalBoxIdToPortalBoxDetail = new Map<Id, Partner_Portal_Label__c>([Select Id, Name, Portal_Tab__c, Portal_Content_Type__c 
                                                                                    From Partner_Portal_Label__c 
                                                                                    Where Permission_Set__c In :setCurrUserCustomPSIds
                                                                                        And (Language__c = :currUserLangName Or Language__c = null) ]);
           }
        } else if(bUnRestricted == false) {
                mapPortalBoxIdToPortalBoxDetail = new Map<Id,Partner_Portal_Label__c>([ Select Id, Name, Portal_Tab__c, Portal_Content_Type__c 
                                                                                    From Partner_Portal_Label__c 
                                                                                    Where Permission_Set__c In :setCurrUserCustomPSIds 
                                                                                        And Not_for_Restricted_Accounts__c = false
                                                                                        And (Portal_Content_Type__c IN :setCurrUserBoxContentTypes OR Portal_Content_Type__c = Null)
                                                                                        And (Language__c = :currUserLangName Or Language__c = null) ]);
        } else {
            mapPortalBoxIdToPortalBoxDetail = new Map<Id,Partner_Portal_Label__c>([ Select Id, Name, Portal_Tab__c, Portal_Content_Type__c 
                                                                                    From Partner_Portal_Label__c 
                                                                                    Where Permission_Set__c In :setCurrUserCustomPSIds 
                                                                                        And (Portal_Content_Type__c IN :setCurrUserBoxContentTypes OR Portal_Content_Type__c = Null)
                                                                                        And (Language__c = :currUserLangName Or Language__c = null) ]);
        }
        //-------------------------------------------------------------------------------------------------------------------
        
        //Find all Box Ids and its corresponding Tabs it should be shown under
        //-------------------------------------------------------------------------------------------------------------------
        //Map of Box Ids to its Sets of Tabs
        Map<Id, set<string>> mapBoxIdTabs = new Map<Id, set<string>>();
        for(Partner_Portal_Label__c box :mapPortalBoxIdToPortalBoxDetail.values()){
            if(box.Portal_Tab__c != null){
                set<string> tabs = new set<string>();
                for(string val : box.Portal_Tab__c.split(';')){
                   tabs.add(val); 
                }   
                mapBoxIdTabs.put(box.Id, tabs); 
            }                        
        }
        system.debug('***mapBoxIdTabs: ' + mapBoxIdTabs);
        //-------------------------------------------------------------------------------------------------------------------
        
        //Build Map of Box Id to Box Name and Map of Box Id to list of Box Contents for the selected Tab
        //-------------------------------------------------------------------------------------------------------------------
        //Get all the Partner Portal Box Contents belonging to the Partner Portal Boxes
        List<Partner_Portal_Links__c> lstPartner_Portal_Links = [Select Name, Content_Justification__c, Display_Bullet__c, Is_Link__c, Portal_Link_Name__c, Display_Page__c, 
                                                                    Link_Serial_Number__c, Partner_Portal_Label__c, URL__c, URL1__c, Partner_Portal_Label__r.Name, 
                                                                    Partner_Portal_Label__r.Display_Bullet__c, Partner_Portal_Label__r.Portal_Content_Type__c, 
                                                                    Partner_Portal_Label__r.Label_Serial_Number__c 
                                                                From Partner_Portal_Links__c
                                                                Where Partner_Portal_Label__c In :mapPortalBoxIdToPortalBoxDetail.keySet() 
                                                                    And Partner_Portal_Label__c In :mapBoxIdTabs.keyset()];        
        
        //map of Partner Portal Box Id to list of Partner Portal Box Contents
        Map<Id, List<Partner_Portal_Links__c>> mapPortalBoxIdListPortalBoxContent = new Map<Id,List<Partner_Portal_Links__c>>();
           
        
        for(Partner_Portal_Links__c portalBoxContent : lstPartner_Portal_Links){
            // Adding a check if the box is related to the current tab only then box will be display for that tab
            if(mapBoxIdTabs.get(portalBoxContent.Partner_Portal_Label__c).contains(tabName)){                
                if(!mapPortalBoxIdListPortalBoxContent.containsKey(portalBoxContent.Partner_Portal_Label__c)){
                    mapPortalBoxIdListPortalBoxContent.put(portalBoxContent.Partner_Portal_Label__c, new List<Partner_Portal_Links__c>{portalBoxContent});            
                } else {
                    mapPortalBoxIdListPortalBoxContent.get(portalBoxContent.Partner_Portal_Label__c).add(portalBoxContent);
                }                                       
            }
        }
        //-------------------------------------------------------------------------------------------------------------------   

        //Build the Wrappers to be fed to VF page
        //-------------------------------------------------------------------------------------------------------------------
        for(string Id : mapPortalBoxIdListPortalBoxContent.keyset()){
            
            //Partner Portal Box
            Box objBox = new Box();
            objBox.label = mapPortalBoxIdListPortalBoxContent.get(Id)[0].Partner_Portal_Label__r.Name.toUpperCase();    // Converting all lower cases into upper case.
            objBox.competency = mapPortalBoxIdListPortalBoxContent.get(Id)[0].Partner_Portal_Label__r.Portal_Content_Type__c;
            List<Partner_Portal_Links__c> lstRecord = mapPortalBoxIdListPortalBoxContent.get(Id);
            objBox.serialNo = integer.valueOf(lstRecord[0].Partner_Portal_Label__r.Label_Serial_Number__c);   // Adding box serial no
            //w.isBullet = lstRecord[0].Partner_Portal_Label__r.Display_Bullet__c;  // This field is not being used. Remove this field from the object
            
            //Partner Portal Box Contents
            List<BoxContent> lstBoxContent = new List<BoxContent>();
            for(Partner_Portal_Links__c gd :lstRecord){
               BoxContent objBoxContent = new BoxContent();
               objBoxContent.value = gd.Portal_Link_Name__c;
               objBoxContent.displayPageWindow = gd.Display_Page__c;                  // Open page in new winodow or existing window.
               objBoxContent.url = gd.URL1__c;                                        // A long url field.
               objBoxContent.srno = integer.valueof(gd.Link_Serial_Number__c);        // Defining the sequence of list.
               objBoxContent.contentJustification  = gd.Content_Justification__c;     // Define text left, center or right.
               objBoxContent.IsLink= gd.Is_Link__c ;                                  // Whether it should be a link of simple text
               objBoxContent.displayBullet = gd.Display_Bullet__c;                    // Whether list should display in bullet format or blank
               lstBoxContent.add(objBoxContent);                
            }
            lstBoxContent.sort();                // Adding list of data which comes inside a box using sorting.
            objBox.lstBoxContent = lstBoxContent; 
            lstBox.add(objBox);            
        }
        // Return the list of wrapper class by sorting based on serialno.        
        lstBox.sort();     
        
        system.debug(lstBox);
        lstBoxList.add(new BoxList(lstBox));
        strLstBoxList = String.escapeSingleQuotes(JSON.serialize(lstBoxList));
        strLstPortalContentTypes = String.escapeSingleQuotes(JSON.serialize(lstPortalContentTypes));
        system.debug(lstBoxList);
        //-------------------------------------------------------------------------------------------------------------------        
    }

    //-------------------------------------------------------------------------------------------------------------------
    //Method to return GPU Genius Group ids for the current user
    //-------------------------------------------------------------------------------------------------------------------
    private void getGPUGeniusGroupIDs(){
        string contactId = [Select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
        if(contactId!=null && contactId!=''){
            //Parse the GPU_Genius_Groups__c field values.  These will be passed a query string parameters to the Learning Locker iFrame
            contactDetail = [   Select Id, firstname, lastname, Phone, email, mobilePhone, accountId, account.name, GPU_Genius_Groups__c 
                                From contact 
                                Where id = :contactId];
            
            if(contactDetail.GPU_Genius_Groups__c != null){
                List<String> lstGGGroups = contactDetail.GPU_Genius_Groups__c.split(';');   
                for (String s : lstGGGroups) {
                    List<String> ss = s.split(':');
                    if (strGGGroups == null) {
                        strGGGroups = ss[1];
                    }
                    else {
                        strGGGroups = strGGGroups + ',' + ss[1];
                    }
                }
            }
        }
    }
    //End: getGPUGeniusGroupIDs
    //-------------------------------------------------------------------------------------------------------------------
    
    

    
 
    //-------------------------------------------------------------------------------------
    // Method to return detfault content type of the user.
    //-------------------------------------------------------------------------------------     
    private string userDefaultcontentType(){
        //get the contact id of the logged on user
        string strDefaultContctType = '';
        string conId = [select contactId from User where Id = :UserInfo.getUserId()].ContactId;
        list<Contact> lstContact = [Select Portal_User_Content_Type__c From Contact Where Id = :conId ];
        if (!lstContact.isEmpty()){
            strDefaultContctType =  lstContact[0].Portal_User_Content_Type__c;
        }
        return strDefaultContctType;
    }     
    //-------------------------------------------------------------------------------------
    
       
    
    
    //-------------------------------------------------------------------------------------
    //It will invoke everytime and update existing custom setting ( Portal_Content_Type__c) with recently clicked Content Type for the user.
    //Called from the VF page when user clicks on a Content Type
    //-------------------------------------------------------------------------------------
    public void selectContentType(){
        lstBoxList.clear();
        lstBox.clear();
        Portal_Content_Type__c objPortal_Content_Type = Portal_Content_Type__c.getValues(UserInfo.getUserId());
        objPortal_Content_Type.Content_Type__c = selectedContentType;
        update objPortal_Content_Type;
        init();        
    }
    //-------------------------------------------------------------------------------------
    
    //Get the Content type for the current user's session (implemented/stored in custom settings: Portal_Content_Type__c)
    //If not found then return the Default Content Type from the Contact record
    //---------------------------------------------------------------------------------------------------------
    private string returnSelectedContentTypeFromCustomSetting(){
        string strUserContentType = '';
        //get it from Portal_Content_Type__c custom settings else from Contact record
        Portal_Content_Type__c objPortal_Content_Type = Portal_Content_Type__c.getValues(UserInfo.getUserId());
        
        if(objPortal_Content_Type != null){
            if(objPortal_Content_Type.Content_Type__c != null){          
                strUserContentType = objPortal_Content_Type.Content_Type__c;
            }else{
                return userDefaultcontentType();
            }
        }else {
            strUserContentType = userDefaultcontentType();
        }
        
        return strUserContentType;
    }
    //---------------------------------------------------------------------------------------------------------
    
    //---------------------------------------------------------------------------------------------------------
    //Inserting custom settings so that portal tab index can be fliped.
    //This function is called from VF page's action method to insert logged user's default content type to the Custom Settings Portal_Content_Type__c
    //---------------------------------------------------------------------------------------------------------
    public void insertCustomSettings(){
        Portal_Content_Type__c objPortal_Content_Type = Portal_Content_Type__c.getValues(UserInfo.getUserId());
        if(objPortal_Content_Type == null){
            Portal_Content_Type__c objPortal_Content_Type_Insert = new Portal_Content_Type__c();
            objPortal_Content_Type_Insert.Name = UserInfo.getUserName();
            objPortal_Content_Type_Insert.SetupOwnerId = UserInfo.getUserId();
            insert objPortal_Content_Type_Insert;           
        }
    }

    //SendEmail method.
    @RemoteAction
    global static boolean sendEmail(String logASupportRequest){           
        boolean flag = false;
        Map<String, Object> mapLogASupportRequest = (Map<String, Object>) JSON.deserializeUntyped(logASupportRequest);
        system.debug(mapLogASupportRequest);
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
        
        //build the to address from the Portal_Toggles__c custom settings based on the Competency Type (Accelerated Computing, Cloud/Virtualization, Professional Visualization)
        string[] toAddresses;
        List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
   
        if(lstCSPortalToggles != null && lstCSPortalToggles.size() > 0){
            for( Portal_Toggles__c toggle: lstCSPortalToggles ){
                if((String)((Map<String, Object>)mapLogASupportRequest.get('selectedContentType')).get('value') == toggle.Name){
                    if(toggle.Log_a_Support_Request_Email__c != null){
                        toAddresses = new String[] {toggle.Log_a_Support_Request_Email__c};
                    }
                    break;
                }
            }
        }
   
        mail.setToAddresses(toAddresses);                
        DateTime d = System.now();        
        mail.setSubject(COMM_Constants.LOG_A_SUPPORT_SUBJECT + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' on ' + d.month() + '/' + d.day() + '/' + d.year() + '/' + d.time() + ' on ' + mapLogASupportRequest.get('problemType'));
        mail.setBccSender(false);   
        if(fileAttachments.size()>0){    
            mail.setFileAttachments(fileAttachments);
        }    
        //Build the HTML Message       
        string html = '<table width="100%"><tr><td width="30%"><b>Company Name</b></td>';        
        html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('AccountName') + '</td></tr>';        
        html += '<tr><td><b>Contact Name</b></td>';
        html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('FirstName') + '</td></tr>';
        html += '<tr><td><b>Contact Email Address</b></td>';
        html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Email') + '</td></tr>';
        html += '<tr><td><b>Contact Phone Number</b></td>';
        if(((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone') != null && ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone') != ''){
            html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone') + '</td></tr>';        
        }else {
            html += '<td>' + ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Phone') + '</td></tr>';  
        }
        html += '<tr><td><b>Short Description</b></td>';
        html += '<td>' + mapLogASupportRequest.get('problemType') + '</td></tr>';
        html += '<tr><td><b>Problem Description</b></td>';
        html += '<td>' + mapLogASupportRequest.get('problemDescription') + '</td></tr>';
        html += '<tr><td><b>Steps to Reproduce Problem</b></td>';
        html += '<td>' + mapLogASupportRequest.get('stepToReproduce') + '</td></tr></table>';
        
        //Set the HTML body to the message and send email
        mail.setHtmlbody(html);             
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Success));
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
    //End: Email Functionality
    //*************************************************************************************
    
    
}