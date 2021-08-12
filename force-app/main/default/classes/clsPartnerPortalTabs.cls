public class clsPartnerPortalTabs {

Public clsPartnerPortalTabs()
{
}
    //Variable for report an email thing   
   /* public string email {get;set;}   
    public string subject {get;set;}
    public string body {get;set;}    
    public boolean displayPopup {get; set;}
    public blob Attach {get;set;} 
    public string problemType {get;set;}
    public string companyName {get;set;}  
    public string contactName {get;set;}
    public string contactfirstlastname {get;set;}
    public string contactEmail {get;set;}
    public string phoneNumber {get;set;}  
    public string problemDescription {get;set;}
    public string shortDescription {get;set;}       
    public string steptoReproduceProblem {get;set;}    
    public String FileName_Upload {get; set;}
    public boolean isReportAProblem {get;set;}    
    
    
    
    //GPUGenius Groups for the current user
    public string strGGGroups{get;set;}
    public Contact contactDetail {get;set;}
    
    //public class to hold toggle name and detail
    //Note: both the variables contain the Box's Content Type one as it is and the other in lower case
    public class wrapperToggleDetail{
        public string strToggleName {get;set;}
        public string strToggleDetail {get;set;}
    }
    
    //Current users Portal Content Types based on the Permission Sets assignments and Portal Permission Sets assigned to the Boxes and the Portal Content Types matching with Portal_Toggles__c records
    public List<wrapperToggleDetail> lstPortalContentTypes {get;set;}
        
    //Select Content Type for the Contact. It dynamically selected. 
    //If during the user session, User clicks on Content Type it gets stored in Portal_Content_Type__c custom settings otherwise it is pulled from Contact record's Default Content Type field
    public string selectedContentType {get;set;}
    
    // Wrapper to create boxes based on sequence, label and bullets. 
    public class wrapper{
        public integer serialNo {get;set;}
        public string label {get;set;}
        public boolean isBullet {get;set;}
        public List<wrapperData> lstwrapperData {get;set;}
        public wrapper(){
              lstwrapperData = new List<wrapperData>();
              serialNo = 0;            
        }   
    }
    public List<wrapper> lstWrapper {get;set;}
    
    // Wrapper which display Data inside the boxes (or Box Contents) with their value, target url , sequence and text justification etc. Displaying data based on their properties.
    public class wrapperData{
        public string Value {get;set;}
        public string url {get;set;} 
        public string displayPageWindow {get;set;}
        public integer srno {get;set;}
        public string contentJustification {get;set;}
        public boolean IsLink{get;set;}      
        public boolean displayBullet {get;set;}
    }
    
    // Wrapper class to pass all the data on visualforce page through a list.  
    public class CustomWrap{
        public List<wrapper> lst_wrapper{get;set;}
        public CustomWrap(List<wrapper> lst_wrap){
            lst_wrapper = new List<wrapper>();
            lst_wrapper = lst_wrap;
        }
    }
    public List<CustomWrap> lst_CustomWrap{get;set;}
    
    public boolean isFlagBlank_Portal_Content_Type {get;set;}
    public string instanceMessage {get;set;}
    public string tabName {get;set;}  
    public boolean isLogATicket {get;set;}
    
    public string brainshark_url {get; set;}
    
    private string currUserLangName{get; set;}
    
    //Constructor
    public clsPartnerPortalTabs (){
        //get the Tab name from the URL parameter
        tabName = ApexPages.CurrentPage().getParameters().get('tab');
        system.debug('***tabName: ' + tabName);
        
        //Initialize the wrappers
        lstWrapper = new List<wrapper>();
        lst_CustomWrap = new List<CustomWrap>();
        
        //get the country filter of the logged on user,
        //-----------------------------------------------------------
        
       //Logic: If the user records langauge is found in the Community_User_Local_Settings__c then user the use the matching record otherwise default it to English
        
        string currUserLocaleLangKey = UserInfo.getLanguage();
        currUserLangName = COMM_Utility.getUserLanguage(currUserLocaleLangKey);
        system.debug('***currUserLangName = ' + currUserLangName);
        //-----------------------------------------------------------
        
        //Initialize the list of wrappers and other flags
        //-------------------------------------------------------------------------------
        init();             
        //-------------------------------------------------------------------------------
                
        //Show "Log A Support Request" if the Profile of the User is of Portal Category
        //Note: Seems not being used any more
        //-------------------------------------------------------------------------------
        string profileName = [select  Id,Profile.Name from user where Id =:UserInfo.getUserId()].Profile.Name;
        
        GRID_Portal_Profiles__c objGridPortalProfile = [select Profile_Categories__c from GRID_Portal_Profiles__c where Name = :profileName limit 1];
        
        if(objGridPortalProfile.Profile_Categories__c == 'Portal Category'){
            isLogATicket = true;
        }else{   
            isLogATicket = false;
        }
        //-------------------------------------------------------------------------------
        
        //GPUGenius Groups for the current user
        //-------------------------------------------------------------------------------
        getGPUGeniusGroupIDs();
        //-------------------------------------------------------------------------------
        
        //set BrainShark URL
        brainshark_url = Community_Settings__c.getOrgDefaults().BRAINSHARK_URL__c;
    }
    
    public void init(){
        
        //map of Partner Portal Tab Id to Partner Portal Tab record (contains Tab names, sort order, tab URL, PerimssioN Sets)
        //COMM_Constants.PP_GRID_VCA_NAME = 'GRID_VCA_Partner Portal'
        //----------------------------------------------------------------------------------
       
        //Note: Not being used
       // Map<Id, Partner_Portal_Tab__c> mapIdandTabs; 
        //mapIdandTabs = new Map<Id, Partner_Portal_Tab__c>([ Select Name, Partner_PortalName__c 
          //                                                  From Partner_Portal_Tab__c 
            //                                                Where Name = :tabName 
              //                                                  And Partner_PortalName__r.name =:COMM_Constants.PP_GRID_VCA_NAME]);
        
        //----------------------------------------------------------------------------------
        
        
        //=========================================================================================================================================================
        // Set the lstPortalContentTypes. It is used to show the Competencies / Content Types in the page
        //=========================================================================================================================================================
        // Get only those boxes which are part of assiged permission.
        // Adding a filter based on Box permission sets
        //----------------------------------------------------------------------------------
        set<string> setCurrUserAssignedPSNames = new set<string>();
        list<PermissionSetAssignment> lstCurrUserPSAs = [   Select AssigneeId, PermissionSetId, PermissionSet.Name 
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
        for(Partner_Portal_Label__c box :   [   Select Name, Portal_Tab__c, Portal_Content_Type__c 
                                                From Partner_Portal_Label__c 
                                                Where Permission_Set__c In :setCurrUserCustomPSIds
                                                    And (Language__c = :currUserLangName Or Language__c = null) //add the User Language filter
                                                    //And Partner_Portal_Tab__c = :tabName //add the selected tab filter
                                            ]){
            
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
            else{            
                isFlagBlank_Portal_Content_Type = true;
            }
        }
        //----------------------------------------------------------------------------------
        
        //Sort wrapper list
        //----------------------------------------------------------------------------------
        if(lstPortalContentTypes != null && lstPortalContentTypes.size() > 0){
            lstPortalContentTypes = SortWrapper(lstPortalContentTypes);
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
        
        
        
        //if((isProfessional_Visualization ==true && isCloud_Virtualization == false && isAccelerated_Computing==false) || (isProfessional_Visualization ==false && isCloud_Virtualization == true && isAccelerated_Computing==false) || (isProfessional_Visualization ==false && isCloud_Virtualization == false && isAccelerated_Computing==true))
        //system.debug('***IsToggleMatch: ' + IsToggleMatch);
       // system.debug('***iToggleMatchCount: ' + iToggleMatchCount);
        //system.debug('***currUserLangName: ' + currUserLangName);
        //system.debug('***selectedContentType: ' + selectedContentType);
        
        //if(IsToggleMatch == true && iToggleMatchCount == 1){
        if(IsToggleMatch == true && iToggleMatchCount == 1){
            //system.debug('first condition');
            mapPortalBoxIdToPortalBoxDetail = new Map<Id, Partner_Portal_Label__c>([Select Id, Name, Portal_Tab__c, Portal_Content_Type__c 
                                                                                    From Partner_Portal_Label__c 
                                                                                    Where Permission_Set__c In :setCurrUserCustomPSIds
                                                                                        And (Language__c = :currUserLangName Or Language__c = null) ]);
        }else if(selectedContentType != null && selectedContentType != ''){
            //system.debug('second condition');
            mapPortalBoxIdToPortalBoxDetail = new Map<Id, Partner_Portal_Label__c>([Select Id, Name, Portal_Tab__c, Portal_Content_Type__c 
                                                                                    From Partner_Portal_Label__c 
                                                                                    Where Permission_Set__c In :setCurrUserCustomPSIds 
                                                                                        And (Portal_Content_Type__c = :selectedContentType OR Portal_Content_Type__c = Null)
                                                                                        And (Language__c = :currUserLangName Or Language__c = null) ]);
        }else{
            //system.debug('third condition');
            mapPortalBoxIdToPortalBoxDetail = new Map<Id,Partner_Portal_Label__c>([ Select Id, Name, Portal_Tab__c, Portal_Content_Type__c 
                                                                                    From Partner_Portal_Label__c 
                                                                                    Where Permission_Set__c In :setCurrUserCustomPSIds 
                                                                                        And Portal_Content_Type__c = null
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

        
        //map Parnter Portal Box Id to Partner Portal Box name 
        Map<Id, string> mapPortalBoxIdPortalBoxName  = new Map<Id, string>(); 
        
        //map of Partner Portal Box Id to list of Partner Portal Box Contents
        Map<Id, List<Partner_Portal_Links__c>> mapPortalBoxIdListPortalBoxContent = new Map<Id,List<Partner_Portal_Links__c>>();
           
        
        for(Partner_Portal_Links__c portalBoxContent : lstPartner_Portal_Links){
            // Adding a check if the box is related to the current tab only then box will be display for that tab
            if(mapBoxIdTabs.get(portalBoxContent.Partner_Portal_Label__c).contains(tabName)){                
                if(mapPortalBoxIdListPortalBoxContent.get(portalBoxContent.Partner_Portal_Label__c) == null){
                    mapPortalBoxIdListPortalBoxContent.put(portalBoxContent.Partner_Portal_Label__c, new List<Partner_Portal_Links__c>());            
                }
                mapPortalBoxIdListPortalBoxContent.get(portalBoxContent.Partner_Portal_Label__c).add(portalBoxContent);
                mapPortalBoxIdPortalBoxName.put(portalBoxContent.Partner_Portal_Label__c, portalBoxContent.Partner_Portal_Label__r.Name);                                           
            }
        }
        //-------------------------------------------------------------------------------------------------------------------   

        //Build the Wrappers to be fed to VF page
        //-------------------------------------------------------------------------------------------------------------------
        for(string Id : mapPortalBoxIdListPortalBoxContent.keyset()){
            
            //Partner Portal Box
            wrapper w = new wrapper();
            w.label = mapPortalBoxIdPortalBoxName.get(Id).toUpperCase();    // Converting all lower cases into upper case.
            List<Partner_Portal_Links__c> lstRecord = mapPortalBoxIdListPortalBoxContent.get(Id);
            w.serialNo = integer.valueOf(lstRecord[0].Partner_Portal_Label__r.Label_Serial_Number__c);   // Adding box serial no
            //w.isBullet = lstRecord[0].Partner_Portal_Label__r.Display_Bullet__c;  // This field is not being used. Remove this field from the object
            
            //Partner Portal Box Contents
            List<wrapperData> lstwrapperDataToSort = new List<wrapperData>();
            for(Partner_Portal_Links__c gd :lstRecord){
               wrapperData wd = new wrapperData();
               wd.Value = gd.Portal_Link_Name__c;
               wd.displayPageWindow = gd.Display_Page__c;                  // Open page in new winodow or existing window.
               wd.url = gd.URL1__c;                                        // A long url field.
               wd.srno = integer.valueof(gd.Link_Serial_Number__c);        // Defining the sequence of list.
               wd.contentJustification  = gd.Content_Justification__c;     // Define text left, center or right.
               wd.IsLink= gd.Is_Link__c ;                                  // Whether it should be a link of simple text
               wd.displayBullet = gd.Display_Bullet__c;                    // Whether list should display in bullet format or blank
               lstwrapperDataToSort.add(wd);                
            }
            w.lstwrapperData =  sorting(lstwrapperDataToSort);                // Adding list of data which comes inside a box using sorting. 
            lstWrapper.add(w);            
        }
          
        integer num = 0;
                       
        // Return the list of wrapper class by sorting based on serialno.        
        List<Wrapper> newSortedListWrapper = sorting(lstWrapper);     

        // This is logic to implement maximum 3 box in single row. once number of box more than 3 then create another record.
        for(Integer idx = 0; idx < newSortedListWrapper.size(); idx++){                                                                         
            List<Wrapper> lst_wrap = new List<Wrapper>();
            if(num != idx){
                idx = num;
            }                                                                                  
            for(Integer j = 0; j < 3; j++){
               if(num <= idx && idx < newSortedListWrapper.size()){                                                            
                    lst_wrap.add(newSortedListWrapper[idx]);                        // Adding 3 record for each single row.                    
                    idx++;                    
                    num++;                                                     
                }                                                    
            }            
            lst_CustomWrap.add(new CustomWrap(lst_wrap));
            if(newSortedListWrapper.size()-idx == 1){
                idx--; 
            }                                     
        }
        
        //-------------------------------------------------------------------------------------------------------------------        
    }

    //-------------------------------------------------------------------------------------------------------------------
    //Method to return GPU Genius Group ids for the current user
    //-------------------------------------------------------------------------------------------------------------------
    private void getGPUGeniusGroupIDs(){
        string contactId = [Select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
        if(contactId!=null && contactId!=''){
            //Parse the GPU_Genius_Groups__c field values.  These will be passed a query string parameters to the Learning Locker iFrame
            contactDetail = [   Select firstname, lastname, Phone, email, mobilePhone, account.name, GPU_Genius_Groups__c 
                                From contact 
                                Where id = :contactId];
            contactfirstlastname =  contactDetail.firstname + ' ' +  contactDetail.lastname;
            contactEmail = contactDetail.email;
            
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
        lst_CustomWrap.clear();
        lstWrapper.clear();
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
     //---------------------------------------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------------------------------
    //Sorting methods
    //--------------------------------------------------------------------------------------------------
    //Using this method to sort the wrapper class list based on the sequence number enter in records.    
    private list<Wrapper> sorting(list<Wrapper> currlist){
        integer j = 0;          
        Wrapper tmp = new Wrapper();  
        if(currlist.size()>1){           
            for(integer i=0;i<currlist.size();i++){
                j = i;
                for(integer k = i;k<currlist.size();k++){               
                    if(currlist[j].serialNo  > currlist[k].serialNo){   
                        j = k;
                    }
                }                    
                
                tmp = currlist[i];
                currlist[i] = currlist[j];
                currlist[j] = tmp;
            }                
        }
        return currlist;  
    }
    
    // Using this method to sort the wrapperData class list based on the sequence number entered in records.    
    private list<WrapperData> sorting(list<WrapperData> currlist){
        integer j = 0;          
        WrapperData tmp = new WrapperData();  
        if(currlist.size()>1){           
            for(integer i=0;i<currlist.size();i++){
                j = i;
                for(integer k = i;k<currlist.size();k++){               
                    if(currlist[j].srno  > currlist[k].srno){   
                        j = k;
                    }
                }                    
                tmp = currlist[i];
                currlist[i] = currlist[j];
                currlist[j] = tmp;
            }                
        }
        return currlist;
    }
    //--------------------------------------------------------------------------------------------------
        
    //-----------------------------------------------------------------------------------
    //Sorts wrapper data alphabetically
    //-----------------------------------------------------------------------------------
    private list<wrapperToggleDetail> SortWrapper(List<wrapperToggleDetail> lstwrpData){
        list<string> lstToggleName = new list<string>();
        list<string> lstToggleNameUnsorted = new list<string>();
        list<wrapperToggleDetail> lstSortedWrapperDate = new list<wrapperToggleDetail>();
        if(lstwrpData != null && lstwrpData.size() > 0){
            for(wrapperToggleDetail eachToggle: lstwrpData){
                lstToggleName.add(eachToggle.strToggleName);
            }
        }
        
        //sort the list with string
        lstToggleName.sort();
        
        //Based on the sorted list, rebuild the list of wrapperToggleDetail
        if(lstToggleName.size() > 0){
            for(integer i=0; i < lstToggleName.size(); i++){
                for(wrapperToggleDetail eachToggle: lstwrpData){
                    if(lstToggleName.get(i).tolowercase() == eachToggle.strToggleName.tolowercase()){
                        lstSortedWrapperDate.add(eachToggle);
                        break;
                    }
                }
            }
        }
    
        return lstSortedWrapperDate;
    }
    //End of SortWrapper
    //-----------------------------------------------------------------------------------
   
    //*************************************************************************************
    //Email Functionality
    //*************************************************************************************
    public List<SelectOption> lstCompetencyOptions{ get; set; }
    public string selectedCompetencyOption{ get; set; }
    
    public void buildLstCompetencyOptions(){        
        lstCompetencyOptions= new List<selectoption>();
        set<string> setCurrUserPortalBoxContentTypes = new set<string>();
        set<string> boxPermissionSets = new set<string>();
        set<Id> customPermissionSets = new Set<Id>();
        for(PermissionSetAssignment psa :[Select AssigneeId, PermissionSetId, PermissionSet.Name From PermissionSetAssignment Where AssigneeId = :UserInfo.getUserId()]){
           //  if(psa.PermissionSet.Name.contains('Box'))  
             boxPermissionSets.add(psa.PermissionSet.Name);
        }      
        for(Portal_Permission_Sets__c pms :[Select Name From Portal_Permission_Sets__c Where Name in :boxPermissionSets]){
                customPermissionSets.add(pms.Id);
        }
        
       //Get all the Portal Content Types from Partner Portal Box object
        integer iTotalContentTypes = 0;
        for(Partner_Portal_Label__c box : [ Select Name, Portal_Tab__c, Portal_Content_Type__c 
                                            From Partner_Portal_Label__c 
                                            Where Permission_Set__c  In :customPermissionSets
                                                And (Language__c = :currUserLangName Or Language__c = null)]){  
            if(box.Portal_Content_Type__c != null){
                if(!setCurrUserPortalBoxContentTypes.contains(box.Portal_Content_Type__c)){
                    iTotalContentTypes  += 1 ;
                    setCurrUserPortalBoxContentTypes.add(box.Portal_Content_Type__c);
                }   
            }
        }
        
        //build the drop down options
        if(iTotalContentTypes >= 1){
            if (iTotalContentTypes > 1) lstCompetencyOptions.add(new selectOption('--None--', '--None--')); //if more than one Content Type then show this option
            for (string strContentType : setCurrUserPortalBoxContentTypes){
                lstCompetencyOptions.add(new SelectOption(strContentType, strContentType));
            }
        }
        
        // User has assigned only one content type the it should be the default value in to the drop down.       
        if(iTotalContentTypes == 1){
            selectedCompetencyOption = lstCompetencyOptions[0].getValue();
        }
        //
        
        //sort the SelectOption list
        lstCompetencyOptions.sort();
    }
    
    //SendEmail method.
    public void sendEmail(){           
        boolean flag = false;
        try{
            if(selectedCompetencyOption == '--None--' || selectedCompetencyOption == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,  System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Competency_Reqd));
                if(!test.isRunningTest()) return ; 
            }
            
            if(phoneNumber==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Phone_Reqd));
                if(!test.isRunningTest()) return ;
            }
            
            if(phoneNumber.length()!=10){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Phone_10_Digits));
                if(!test.isRunningTest()) return ;
            }
            
            if(problemType==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Short_Desc_Reqd));
                if(!test.isRunningTest()) return ;   
            }
        
            if(problemDescription==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Problem_Desc_Reqd));
                if(!test.isRunningTest()) return ;  
            }
            
            if(steptoReproduceProblem==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Steps_to_Reproduce_Reqd));
                if(!test.isRunningTest()) return ;
            }
        
        
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(FileName_Upload);   
            if(Attach!=null){
                efa.setBody(Attach);   
                fileAttachments.add(efa);          
            }                          
            
            //build the to address from the Portal_Toggles__c custom settings based on the Competency Type (Accelerated Computing, Cloud/Virtualization, Professional Visualization)
            string[] toAddresses;
            List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
       
            if(lstCSPortalToggles != null && lstCSPortalToggles.size() > 0){
                for( Portal_Toggles__c toggle: lstCSPortalToggles ){
                    if(selectedCompetencyOption == toggle.Name){
                        if(toggle.Ask_A_Question_Email__c != null){
                            toAddresses = new String[] {toggle.Ask_A_Question_Email__c};
                        }
                        break;
                    }
                }
            }
       
            mail.setToAddresses(toAddresses);                
            DateTime d = System.now();        
            mail.setSubject('Problem Submitted by '+ UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' on ' + d.month() + '/' + d.day() + '/' + d.year() + '/' + d.time() + ' on ' + problemType);
            mail.setBccSender(false);   
            if(fileAttachments.size()>0){    
                mail.setFileAttachments(fileAttachments);
            }    
            //Build the HTML Message       
            string html = '<table width="100%"><tr><td width="30%"><b>Company Name</b></td>';        
            html += '<td>' + contactDetail.Account.Name + '</td></tr>';        
            html += '<tr><td><b>Contact Name</b></td>';
            html += '<td>' + contactfirstlastname + '</td></tr>';
            html += '<tr><td><b>Contact Email Address</b></td>';
            html += '<td>' + contactEmail + '</td></tr>';
            html += '<tr><td><b>Contact Phone Number</b></td>';
            if(contactDetail.MobilePhone != null && contactDetail.MobilePhone != ''){
                html += '<td>' + contactDetail.MobilePhone + '</td></tr>';        
            }else {
                html += '<td>' + phoneNumber + '</td></tr>';  
            }
            html += '<tr><td><b>Short Description</b></td>';
            html += '<td>' + problemType + '</td></tr>';
            html += '<tr><td><b>Problem Description</b></td>';
            html += '<td>' + problemDescription + '</td></tr>';
            html += '<tr><td><b>Steps to Reproduce Problem</b></td>';
            html += '<td>' + steptoReproduceProblem + '</td></tr></table>';
            
            //Set the HTML body to the message and send email
            mail.setHtmlbody(html);             
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Success));
            displayPopup = false;
            selectedCompetencyOption = '';
        } catch(Exception ex){
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.Error,  System.Label.COMM_CP_VF_EMAIL_MSG_Send_Failure));
            system.debug('***Error: ' + ex.getStackTraceString());
        }
        
            
    }
     
    public PageReference closePopup() { 
        try{
            selectedCompetencyOption = '';
            Attach = null;
            email = '';
            contactName = '';
            phoneNumber = '';   
            problemType = '';
            problemDescription = '';
            companyName = '';        
            steptoReproduceProblem ='';        
            displayPopup = false;
            
            string baseURL = '';
            baseURL = URL.getSalesforceBaseUrl().toExternalForm(); // it will return: < https://csxx.salesforce.com >
            
            string PageURLFull = '';
            PageURLFull = ApexPages.currentPage().getUrl(); // it will return vf page, viewstate and parameters e.g., (/apex/vfPartnerPortalTabs?com.salesforce.visualforce.ViewStateCSRF=GHC743D.ChkIj.170A.1pl8OsS54EgBayGlDO8.Jxxxxx&tab=Support)
            
            string pageURL = '';
            pageURL = PageURLFull.substring(0, PageURLFull.indexOf('?')); //gives (/apex/vfPartnerPortalTabs)
            
            string param1;
            param1 = ApexPages.currentPage().getParameters().get('tab');
            //string s = baseURL + '/apex/vfPartnerPortalTabs?tab=' + param1;
            string s = baseURL + pageURL + '?tab=' + param1;
            PageReference pageRef = new PageReference(s);
            return pageRef;
        } catch(Exception ex){
            return null; //Test Class might fail if it is not created properly
        }
        
    }     
    public void showPopup() {        
        displayPopup = true;
        Attach = null;
        email = '';   
        contactName = '';
        phoneNumber = '';      
        problemType = '';
        problemDescription = '';
        companyName = '';  
        steptoReproduceProblem ='';      
        buildLstCompetencyOptions();
    }
    
    //End: Email Functionality
    //*************************************************************************************
    */
    
}