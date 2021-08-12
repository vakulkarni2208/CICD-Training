/*
  Controller for vfCustomerPortalHomeLite.page
  
  Change Lists:
  2015.09.10 - add MDFV2 of MDFV3 flags.
    If the user's PS is having "MKTG : MDF Portal : READ : CHANNEL" then isMDFV2User
    If the user's PS is having "MKTG : MDFV3 : VIEWER"  then isMDFV3User
  
  2015.09.23 - Ask A Question section
     - Change Ask a Question to Getting Started/Need Help
    - Change it to drop down
    - Add How to Navigate the portal, MDF Training and Ask a Question options in the dropdown
  
  2016.04.01 - Inception Partners related changes
  
  2016.10.03 - Services Subcontractors related changes
  
*/
public class clsCustomerPortalHomeLite {
 public clsCustomerPortalHomeLite(){
 }
    //Whole Class commented out - Varun 8/16/2019
    /*public string strGGGroups{get;set;}
    public string ContactName {get;set;}  
    public Contact contactDetail {get;set;}
    public string emeai_training_username_extn {get; private set;}
    public string brainshark_url {get; set;}
    public string strTabName{get;set;}
    public string strImageiframeName{get;set;}
    public string currUserLangName{get;set;}
    
    // Declaring varibale for each text box on visualforce page.
    public string email {get;set;}
    public string emailReportAProblem {get;set;} 
    public string subject {get;set;}
    public string body {get;set;} 
    public string contactfirstlastname{get;set;}
    public string contactEmail{get;set;}
    public string contactMobilePhone{get;set;}
    public string contactPhone{get;set;}

    //Variable for report an email thing
    public boolean DisplayPopup_LogASupportRequest {get; set;}
    public boolean DisplayPopup_AskAQuestion {get; set;}
    public blob Attach {get;set;}       
    public string problemType {get;set;}
    public string companyName {get;set;}
    public string phoneNumber {get;set;}    
    public string problemDescription {get;set;}
    public string shortDescription {get;set;}       
    public string steptoReproduceProblem {get;set;}    
    public String FileName_Upload {get; set;}    
    public boolean isReportAProblem {get;set;}
    
  //Main wrapper class to cosolidate all required object data into single unit. It pass on the VF page.
  public List<wrapperMain> lstMainWrapper {get;set;}
  public class wrapperMain{
    public string presentation_Label{get;set;}
    public string presentation_Type{get;set;}
    public decimal srno {get;set;}
        public boolean displayborder {get;set;}
        public string displayboxtitle {get;set;} 
        public boolean displayTitle {get;set;}
        public List<wrapper> lstW {get;set;}
        public wrapperMain(){
          lstW = new List<wrapper>();
    }
  }   

  // Wrapper class to consolidate Portal_Home_Page_Box__c data. 
    public List<wrapper> lstWrapper {get;set;}
    public class wrapper{
      public decimal serialNo {get;set;} 
        public string presentation_Name {get;set;}
        public string presentation_text {get;set;}
        public string presentation_URL{get;set;}
        public string image_URL{get;set;}
        public boolean isLink {get;set;}
        public string imageLocation {get;set;}
        public wrapper(){
          serialNo = 0;      
    }
  }   
    
    public List<COMM_NVContact_Utility.NVIDIAContactsWrapper> lstNVIDIAContactsWrapper {get;set;} 
    public list<COMM_NVContact_Utility.NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper {get;set;}
    public boolean isNVEPUser{get;set;}
    public boolean isNPNCommunityUser{get;set;}
    public boolean isPortalLiteUser{get;set;}
    public boolean isInceptionPartnerUser{get;set;}
    public boolean isServicesSubcontractors{get;set;}
    
    public List<SelectOption> lstLPCompetencies{get;set;}
     public string selectedLPCompetency{get;set;}
     
     //Wrapper class to hold Lite_Portal_Competencies__c custom settings records
     public class LitePortalCompetenciesWrapper{
       public string competencyName{get;set;}
       public string askAQuestionRecipients{get;set;}
       public string logASupportRequestRecipients{get;set;}
       public LitePortalCompetenciesWrapper(string competencyName, string askAQuestionRecipients, string logASupportRequestRecipients){
         this.competencyName = competencyName;
         this.askAQuestionRecipients = askAQuestionRecipients;
         this.logASupportRequestRecipients = logASupportRequestRecipients;
       }
     }
     public map<string, LitePortalCompetenciesWrapper> mapLitePortalCompetenciesWrapper {get; set;}
     
     //2015.09.10 - add MDFV2 of MDFV3 flags.
     public boolean isMDFV2User{get;set;}
     public boolean isMDFV3User{get;set;}
     //End: 2015.09.10 - add MDFV2 of MDFV3 flags.

  //Constructor
    public clsCustomerPortalHomeLite(){
        try{
            set<string> setContactUserPortalGroups = new set<string>();     
          //if showLASR param = 1, show the Log A Support Request form
          string logASupportLinkClicked = ApexPages.currentPage().getParameters().get('showLASR');
          if (logASupportLinkClicked != null && logASupportLinkClicked == '1'){
            showPopup_LogASupportRequest();
          }
          
          //if showAAQ param = 1, show the Ask A Question Request form
          string askAQuestionLinkClicked = ApexPages.currentPage().getParameters().get('showAAQ');
          if (askAQuestionLinkClicked != null && askAQuestionLinkClicked == '1'){
            showPopup_AskAQuestion();
          }
          
            emeai_training_username_extn = COMM_Constants.USRNAME_EXTN_EMEAI_TRAIN;
            //set the user type based on the user name extension, this will not be required later when all old contacts will have the Permissions & Group Assignments field set their respective values
            if (UserInfo.getUserName().toLowerCase().contains(COMM_Constants.USRNAME_EXTN_EMEAI_TRAIN.toLowerCase())){
              isNVEPUser = true;
            }
            
            if (UserInfo.getUserName().toLowerCase().contains(COMM_Constants.USRNAME_EXTN_NPN_COMM.toLowerCase())){
              isNPNCommunityUser = true;
            }
            //End: set th user type
            
            brainshark_url = Community_Settings__c.getOrgDefaults().BRAINSHARK_URL__c;
            lstMainWrapper = new List<wrapperMain>();
            lstWrapper = new List<Wrapper>();
            lstNVIDIAContactsWrapper = new List<COMM_NVContact_Utility.NVIDIAContactsWrapper>();
            lstNVIDIAContactsProductWiseWrapper = new list<COMM_NVContact_Utility.NVIDIAContactsProductWiseWrapper>();
            
            //Logic: If the user records langauge is found in the Community_User_Local_Settings__c then user the use the matching record otherwise default it to English
            currUserLangName = COMM_Utility.getUserLanguage(UserInfo.getLanguage());
            
        //set lstMainWrapper and lstWrapper
        generatePresentationBoxes();
      
      //set lstLPCompetencies, selectedLPCompetency, mapLitePortalCompetenciesWrapper 
      buildCompetencyTypes();
      
      //2015.09.10 - add MDFV2 of MDFV3 flags - Set the isMDFV2User and isMDFV3User based on the Permission Set
      //get user's Permission Sets from PermissionSetAssignments object 
      //--------------------------------------------------------------------------
      set<string> userPermisionSets = new set<string>();
      list<PermissionSetAssignment> lstUserPSs = [Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId=:UserInfo.getUserId()];
          if (!lstUserPSs.isEmpty()){
            for(PermissionSetAssignment psa : lstUserPSs){
                userPermisionSets.add(psa.PermissionSet.Name);                                    
        }
          }
          if (userPermisionSets.contains(COMM_Constants.PS_MKTG_MDF_PORTAL_READ_CHANNEL)){
            isMDFV2User = true;
          }
          if (userPermisionSets.contains(COMM_Constants.PS_MKTG_MDFV3_VIEWER)){
            isMDFV3User = true;
          }
      //--------------------------------------------------------------------------
      
      //set contactDetail object
            string contactId = [select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
      if(contactId != null && contactId != ''){
        contactDetail = [  Select FirstName, LastName, Email, Portal_User_Content_Type__c, Portal_Groups__c, MobilePhone, Phone, 
                    AccountId, Account.Name, Account.Owner.Name, Account.Owner.email, Account.Owner.Phone, Account.BillingCountry, Account.Region__c, Account.Sub_Region__c,
                                        Account.BillingState, Account.Marketing_Manager_Name__c, Account.Marketing_Manager_Contact_Number__c, Account.Marketing_Manager_Email__c,
                                        Account.Support_Manager_Name__c, Account.Support_Manager_Contact_Number__c, Account.Support_Manager_Email__c, GPU_Genius_Groups__c 
                  From Contact 
                  Where Id =:contactId];
        contactfirstlastname =  contactDetail.firstname + ' ' +  contactDetail.lastname;
        contactEmail = contactDetail.Email;
        contactMobilePhone = contactDetail.MobilePhone;
        contactPhone = contactDetail.Phone;
        string contactUserPortalGroups = contactDetail.Portal_Groups__c;
        list<string> lstContactUserPortalGroups; 
        
        if (contactUserPortalGroups != null){
          lstContactUserPortalGroups = contactUserPortalGroups.split(';');
          if (lstContactUserPortalGroups != null) {
            
            for (string strContactUserPortalGroup : lstContactUserPortalGroups){
              setContactUserPortalGroups.add(strContactUserPortalGroup.trim());
            }
            if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_PORTAL_LITE)){ //'Portal Lite'
              isPortalLiteUser = true;
            }
            if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_NVEP)){ //'NVEP'
              isNVEPUser = true;
            }
            if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_COMMUNITY)){ //'Community'
              isNPNCommunityUser = true;
            }

            if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_INCEPTION_PARTNERS)){ //'Inception Partners'
                isInceptionPartnerUser = true;
            }
            
            //2016.10.03 - Services Subcontractors related changes
            if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_SERVICESSUBCONTRACTORS)){ //Services Subcontractors
                isServicesSubcontractors = true;
            }
            
          }
        }
        
      }
            
            //set strGGGroups. These will be passed a query string parameters to the Learning Locker iFrame
            //-----------------------------------------------
            if (contactDetail.GPU_Genius_Groups__c != null) {
                List<string> lstGGGroups = contactDetail.GPU_Genius_Groups__c.split(';'); 
                for (string s : lstGGGroups) {
                    List<string> ss = s.split(':');
                    if (strGGGroups == null) {
                        strGGGroups = ss[1];
                    }
                    else {
                        strGGGroups = strGGGroups + ',' + ss[1];
                    }
                }                  
            }
            //-----------------------------------------------
            
           set<string> contentTypes = returnContentTypeSet(setContactUserPortalGroups);
      //set lstNVIDIAContactsWrapper list of objects
            lstNVIDIAContactsProductWiseWrapper = COMM_NVContact_Utility.putAllNVIDIACONTACTDetail(contactDetail ,contentTypes);
            
            
    }Catch(Exception ee){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ee.getMessage() + '-' + ee.getLineNumber());
                ApexPages.addMessage(myMsg);
    }
    }
    
    
  //--------------------------------------------------------------------------------------------------------
  
  //--------------------------------------------------------------------------------------------------------
  //Build the wrapper objects lstMainWrapper, lstWrapper
  //--------------------------------------------------------------------------------------------------------
  public void generatePresentationBoxes(){
    //Portal_Home_Page_Box__c = Portal Home Page Box
    //Portal_Presentation__c = Portal Home Page Box Content
    Map<string, Portal_Home_Page_Box__c> mapHPBoxNameAndHPBoxDetail = new Map<string,Portal_Home_Page_Box__c>();
      Map<string, List<Portal_Presentation__c>> mapHPBoxNameAndListOfHPBoxContents = new Map<string,List<Portal_Presentation__c>>();

    //get user's Permission Sets from PermissionSetAssignments object
    set<string> userPermisionSets = new set<string>();
    list<PermissionSetAssignment> lstUserPSs = [Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId=:UserInfo.getUserId()];
        if (!lstUserPSs.isEmpty()){
          for(PermissionSetAssignment psa : lstUserPSs){
              userPermisionSets.add(psa.PermissionSet.Name);                                    
      }
        }

    set<Id> portalPermissionSets = new set<Id>();
        for(Portal_Permission_Sets__c portalPSet :[Select Name From Portal_Permission_Sets__c  Where Name in :userPermisionSets]){
          portalPermissionSets.add(portalPSet.id);
    }
    
    //Fill mapHPBoxNameAndHPBoxDetail
    //---------------------------------------------------------------------------------------------------
    //get the country filter of the logged on user,
    
    //string currUserLocaleLangKey = UserInfo.getLanguage();
    //string currUserLangName = COMM_Utility.getUserLanguage(currUserLocaleLangKey);
    
    //get the Content Language filter
    string strUserContentLanguageSearchFilter = COMM_Utility.getUserContentLanguageSearchFilter(UserInfo.getLanguage());
    system.debug('***strUserContentLanguageSearchFilter: ' + strUserContentLanguageSearchFilter);
    
    set<Id> portalHomeBoxId = new set<Id>();
        for(Portal_Home_Page_Box__c PortalHomePageBox : [  Select Name, Display_Border__c, Display_Title__c, Display_Box_Title__c, Presentation_Type__c
                                  From Portal_Home_Page_Box__c 
                                  Where Portal_Permission_Set__c in :portalPermissionSets 
                                    And Language__c = :currUserLangName]){
          portalHomeBoxId.add(PortalHomePageBox.Id);
            mapHPBoxNameAndHPBoxDetail.put(PortalHomePageBox.Presentation_Type__c, PortalHomePageBox);
    }

        List<Portal_Presentation__c> lstPortal_Presentation = [Select Id,Name,Image_URL__c,Portal_Profile__c,Presentation_Type__c,Presentation_URL__c,
                                  Content_Serial_Number__c,Image_Location__c,Is_Link__c,Permission_Set__c,Permission_Set__r.Name,
                                  Portal_Home_Page_Box__c,Portal_Home_Page_Box__r.Name,Portal_Home_Page_Box__r.Box_Serial_Number__c,
                                  Portal_Home_Page_Box__r.Display_Box_Title__c , Portal_Home_Page_Box__r.Display_Border__c, Portal_Home_Page_Box__r.Display_Title__c,
                                  Portal_Home_Page_Box__r.Presentation_Type__c, Presentation_Text__c
                                From Portal_Presentation__c
                                Where Portal_Home_Page_Box__c in :portalHomeBoxId];
        //---------------------------------------------------------------------------------------------------
        
        //Fill mapHPBoxNameAndListOfHPBoxContents
        set<string> portal_presentation_Sets = new set<string>();
    Map<string, decimal> mapPresentationTypeAndSerialNumber = new Map<string, decimal>();
        for(Portal_Presentation__c presentation : lstPortal_Presentation){
      if(mapHPBoxNameAndListOfHPBoxContents.get(presentation.Portal_Home_Page_Box__r.Presentation_Type__c) == null){
              mapHPBoxNameAndListOfHPBoxContents.put(presentation.Portal_Home_Page_Box__r.Presentation_Type__c, new List<Portal_Presentation__c>());                                            
      }                               
      mapHPBoxNameAndListOfHPBoxContents.get(presentation.Portal_Home_Page_Box__r.Presentation_Type__c).add(presentation);                           
      portal_presentation_Sets.add(presentation.Permission_Set__r.Name);
      mapPresentationTypeAndSerialNumber.put(presentation.Portal_Home_Page_Box__r.Presentation_Type__c, presentation.Portal_Home_Page_Box__r.Box_Serial_Number__c);

    }

    set<string> portal_presentation_Assigned_To_User_Sets = new set<string>();
        for(PermissionSetAssignment psa : [  Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId=:UserInfo.getUserId() and PermissionSet.Name in :portal_presentation_Sets]){                     
          portal_presentation_Assigned_To_User_Sets.add(psa.PermissionSet.Name);                                  
    }
                        
    List<wrapperMain> lstMailWrapTosort = new List<wrapperMain>();                
    
    for(string presentationType : mapHPBoxNameAndListOfHPBoxContents.keyset()){    
      List<wrapper> lstwrapperToSort = new List<wrapper>();                                                
      wrapperMain w = new wrapperMain();
      w.presentation_Label = mapHPBoxNameAndHPBoxDetail.get(presentationType).Name; 
      w.presentation_Type = mapHPBoxNameAndHPBoxDetail.get(presentationType).Presentation_Type__c;
      //w.presentation_Type = presentationType;
      system.debug('***w.presentation_Type = ' + w.presentation_Type);
      w.displayborder  = mapHPBoxNameAndHPBoxDetail.get(presentationType).Display_Border__c;
      w.displayboxtitle = mapHPBoxNameAndHPBoxDetail.get(presentationType).Display_Box_Title__c;
      w.displayTitle = mapHPBoxNameAndHPBoxDetail.get(presentationType).Display_Title__c;
      w.srno = mapPresentationTypeAndSerialNumber.get(presentationType);
      
      for(Portal_Presentation__c presentation : mapHPBoxNameAndListOfHPBoxContents.get(presentationType)){
        if(portal_presentation_Assigned_To_User_Sets.contains(presentation.Permission_Set__r.Name)){
          wrapper ww = new wrapper();
          ww.serialNo = presentation.Content_Serial_Number__c; 
          //ww.presentation_URL = presentation.Presentation_URL__c;
          //if the presentation URL is Salesforce Content, then pass the user local language filter
          //--------------------------------------------------------------------------------------
          string strPresentationURL = presentation.Presentation_URL__c;
          String strSFCSearchURLToken =  COMM_Constants.CONTENT_SEARCH_URLTOKEN; //'sfc/#search'
          if (strPresentationURL != null && strPresentationURL.toLowerCase().endsWith(strSFCSearchURLToken.toLowerCase()) && strUserContentLanguageSearchFilter.length() > 0 ){
            strPresentationURL = strPresentationURL + '?' + COMM_Constants.CONTENT_SEARCH_FILTER_PARAMETER_KEY + '=' + strUserContentLanguageSearchFilter;
          }
          ww.presentation_URL = strPresentationURL;
          //--------------------------------------------------------------------------------------
          ww.image_URL = presentation.Image_URL__c;
          ww.presentation_Name = presentation.Name;
          ww.presentation_Text = StripBGColor(presentation.Presentation_Text__c); //change the bgcolor to none
          ww.isLink = presentation.Is_Link__c;
          ww.ImageLocation = presentation.Image_Location__c; 
          lstwrapperToSort.add(ww);
        }
      }
      w.lstW = sorting(lstwrapperToSort);
      lstMailWrapTosort.add(w);                                                                                                             
    }
    
    //Add the NVIDIA CONTACTS Box
    //---------------------------------------------------------------------------------------------------
    List<Portal_Home_Page_Box__c> lstPHBoxNVIDIAContacts = [  Select Name, Presentation_Type__c, Box_Serial_Number__c, Portal_Permission_Set__r.Name 
                                  From Portal_Home_Page_Box__c 
                                  Where Presentation_Type__c = :COMM_Constants.BOX_PRESENTAIONTYPE_NVIDIA_CONTACTS
                                    And Language__c = :currUserLangName]; 
    for(Portal_Home_Page_Box__c PHBoxNVIDIAContact : lstPHBoxNVIDIAContacts){
      if(userPermisionSets.contains(PHBoxNVIDIAContact.Portal_Permission_Set__r.Name)){    
        wrapperMain w1 = new wrapperMain();
        w1.srno = PHBoxNVIDIAContact.Box_Serial_Number__c;
        w1.presentation_Type = PHBoxNVIDIAContact.Presentation_Type__c;
        w1.presentation_Label = PHBoxNVIDIAContact.Name;
        lstMailWrapTosort.add(w1);
        break;
      }
    }
    //---------------------------------------------------------------------------------------------------
    
    //sort the list of MainWrapper
    lstMainWrapper = sorting(lstMailWrapTosort);
    //system.debug('***lstMainWrapper: ' + lstMainWrapper);
  }
  //--------------------------------------------------------------------------------------------------------
  
  //--------------------------------------------------------------------------------------------------------
  //Sorting of list of Wrapper objects
  //--------------------------------------------------------------------------------------------------------   
  public list<Wrapper> sorting(list<Wrapper> currlist){
    integer j = 0;          
    Wrapper tmp = new Wrapper();  
    if(currlist.size() > 1){              
      for(integer i = 0; i < currlist.size(); i++){
        j = i;
        for(integer k = i; k < currlist.size(); k++){               
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
    //--------------------------------------------------------------------------------------------------------
    
    //--------------------------------------------------------------------------------------------------------
    // Sorting of list of WrapperMain objects  
    //--------------------------------------------------------------------------------------------------------  
     public list<WrapperMain> sorting(list<WrapperMain> currlist){
    integer j = 0;          
    WrapperMain tmp = new WrapperMain();  
    if(currlist.size() > 1){
      for(integer i=0; i < currlist.size(); i++){
        j = i;
        for(integer k = i; k < currlist.size(); k++){
          if(currlist[j].srno > currlist[k].srno){
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
  //--------------------------------------------------------------------------------------------------------
  
  //--------------------------------------------------------------------------------------------------------
  //Replaces bg color that comes from SFDC Rich Text Box
  //--------------------------------------------------------------------------------------------------------
  private string StripBGColor(string strInput){
    if (strInput != null){
      strInput = strInput.replace('background-color: rgb(255, 255, 255);', '');
    }
    return strInput;
  }
  //--------------------------------------------------------------------------------------------------------
  
  //========================================================================================================
  // LOG A SUPPORT REQUEST EMAIL FUNCTIONALITY
  //========================================================================================================   
    public void sendEmail_LogASupportRequest(){
        boolean flag = false;                
        try{
          if(selectedLPCompetency == '--None--' || selectedLPCompetency == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Competency_Reqd));
                return ; 
            }
            if (contactMobilePhone == null){
              if(phoneNumber == ''){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Phone_Reqd));
                  return;
              }     
              if(phoneNumber.length() != 10){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Phone_10_Digits));
                  return ;
              }
            }      
            
            if(problemType == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Short_Desc_Reqd));
                return ;   
            }
            
            if(problemDescription == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Problem_Desc_Reqd));
                return ;  
            }
            if(steptoReproduceProblem == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Steps_to_Reproduce_Reqd));
                return ;
            }
            
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
           
            if(Attach != null && FileName_Upload != null){
              efa.setFileName(FileName_Upload);
                efa.setBody(Attach);
                fileAttachments.add(efa);   
            }               
           
            
            //Build the to addresses from Lite_Portal_Competencies__c custom settings based on the selected Competency
            string[] toAddresses;
            string strLogASupportRequestRecipients;
            LitePortalCompetenciesWrapper lpcWrapper = mapLitePortalCompetenciesWrapper.get(selectedLPCompetency);
            if (lpcWrapper != null){
              strLogASupportRequestRecipients = lpcWrapper.logASupportRequestRecipients;
              if (strLogASupportRequestRecipients != null && strLogASupportRequestRecipients != ''){
                toAddresses = strLogASupportRequestRecipients.split(',');
                for (integer i=0; i < toAddresses.size(); i++){
                  toAddresses[i] = toAddresses[i].trim();
                }
              }
            }
      
      system.debug('***toAddresses: ' + toAddresses);
      
            mail.setToAddresses(toAddresses);                
            DateTime d = System.now();
            mail.setSubject('Problem Submitted by '+ UserInfo.getFirstName() +' '+ UserInfo.getLastName() + ' on ' + d.month() + '/' + d.day() + '/' + d.year() + '/' + d.time() + ' on ' + problemType);
            mail.setBccSender(false); 
            if(fileAttachments.size() > 0){
                mail.setFileAttachments(fileAttachments);
            }        
            
            //contact phone
            string strContactPhone = '';
            if(contactMobilePhone != null && contactMobilePhone != ''){
              strContactPhone = contactMobilePhone;
            } else{
              strContactPhone = phoneNumber;
            }
            
            //build the email body
            string html = '<table width="100%">';
            html += '<tr><td width="30%"><b>Competency</b></td>';        
            html += '<td>' + selectedLPCompetency + '</td></tr>'; 
            html += '<tr><td width="30%"><b>Company Name</b></td>';        
            html += '<td>' + contactDetail.Account.Name + '</td></tr>';        
            html += '<tr><td><b>Contact Name</b></td>';
            html += '<td>' + contactfirstlastname + '</td></tr>';
            html += '<tr><td><b>Contact Email Address</b></td>';
            html += '<td>' + contactEmail + '</td></tr>';
            html += '<tr><td><b>Contact Phone Number</b></td>';
            html += '<td>' + strContactPhone + '</td></tr>';  
            html += '<tr><td><b>Short Description</b></td>';
            html += '<td>' + problemType + '</td></tr>';
            html += '<tr><td><b>Problem Description</b></td>';
            html += '<td>' + problemDescription + '</td></tr>';
            html += '<tr><td><b>Steps to Reproduce Problem</b></td>';
            html += '<td>' + steptoReproduceProblem + '</td></tr></table>';      
            
            //set html body
            mail.setHtmlbody(html);      
             
             //send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            
            //Capture the details in Salesforce Custom Object
            //----------------------------------------------------------------------------
            Support_Request_And_Question__c supportRec = new Support_Request_And_Question__c();
            supportRec.Account__c = contactDetail.AccountId;
            supportRec.Contact__c = contactDetail.Id;
            supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_LITE;
            supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_LOG_A_SUPPORT_REQ;
            supportRec.Competency__c = selectedLPCompetency;
            supportRec.Contact_Phone_Number__c = strContactPhone;
            supportRec.Short_Description__c = problemType;
            supportRec.Problem_Description__c = problemDescription;
            supportRec.Steps_to_Reproduce_Problem__c = steptoReproduceProblem;
            supportRec.AAQ_Subject__c = null;
            supportRec.AAQ_Body__c = null;
            insert supportRec;
            
            //insert the attachment if any
        if(fileAttachments.size() > 0){
          Attachment oAttachment = new Attachment();
          oAttachment.Body = Attach;
          oAttachment.Name = FileName_Upload;
          oAttachment.ParentId = supportRec.Id; 
          insert oAttachment;
        }
            //End----------------------------------------------------------------------------
      
      
            //show succecss message
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Success));
            
            //close pop-up message
            //DisplayPopup_LogASupportRequest = false;
            closePopup_LogASupportRequest();
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Failure ));
            system.debug('***Error: ' + ex.getStackTraceString());
        }      
    }
    
    public void closePopup_LogASupportRequest() {
        DisplayPopup_LogASupportRequest = false;
        selectedLPCompetency = '';
        email = '';
        contactName = '';
        phoneNumber = '';   
        problemType = '';
        problemDescription = '';
        companyName = ''; 
        emailReportAProblem='';
        steptoReproduceProblem ='';
        Attach = null;
        FileName_Upload = null;
    }
     
    public void showPopup_LogASupportRequest() {
        DisplayPopup_LogASupportRequest = true;
        selectedLPCompetency = '';
        email = '';
        contactName = '';
        phoneNumber = '';   
        problemType = '';
        problemDescription = '';
        companyName = ''; 
        emailReportAProblem='';
        steptoReproduceProblem ='';
        Attach = null;
        FileName_Upload = null;
    }
  //END: LOG A SUPPORT REQUEST EMAIL FUNCTIONALITY
  //========================================================================================================   
  
  
  //========================================================================================================
  // ASK A QUESTION EMAIL FUNCTIONALITY
  //========================================================================================================   
    public void sendEmail_AskAQuestion(){
        boolean flag = false; 
        try{
          if(selectedLPCompetency == '--None--' || selectedLPCompetency == ''){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_MSG_Competency_Reqd));
              if(!test.isRunningTest()) return ; 
            }
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
          string[] toAddresses;
            string strAskAQuestionRecipients;
            LitePortalCompetenciesWrapper lpcWrapper = mapLitePortalCompetenciesWrapper.get(selectedLPCompetency);
            if (lpcWrapper != null){
              strAskAQuestionRecipients = lpcWrapper.askAQuestionRecipients;
              if (strAskAQuestionRecipients != null && strAskAQuestionRecipients != ''){
                toAddresses = strAskAQuestionRecipients.split(',');
                for (integer i=0; i < toAddresses.size(); i++){
                  toAddresses[i] = toAddresses[i].trim();
                }
              }
            }
          system.debug('***toAddresses: ' + toAddresses);
          
          mail.setToAddresses(toAddresses);                
          mail.setSubject('Ask a Question: ' + subject + ' | Competency = ' + selectedLPCompetency);
          mail.setBccSender(false);       
          mail.setPlainTextBody(body);
      
      //contact phone
            string strContactPhone = '';
            if(contactMobilePhone != null && contactMobilePhone != ''){
              strContactPhone = contactMobilePhone;
            } else{
              strContactPhone = contactPhone;
            }
            
      //send email
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          
          //Capture the details in Salesforce Custom Object
            //----------------------------------------------------------------------------
            Support_Request_And_Question__c supportRec = new Support_Request_And_Question__c();
            supportRec.Account__c = contactDetail.AccountId;
            supportRec.Contact__c = contactDetail.Id;
            supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_LITE;
            supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_ASK_A_QUESTION;
            supportRec.Competency__c = selectedLPCompetency;
            supportRec.Contact_Phone_Number__c = strContactPhone;
            supportRec.Short_Description__c = null;
            supportRec.Problem_Description__c = null;
            supportRec.Steps_to_Reproduce_Problem__c = null;
            supportRec.AAQ_Subject__c = subject;
            supportRec.AAQ_Body__c = body;
            insert supportRec;
            //End----------------------------------------------------------------------------
          
          //show succecss message
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Success));
          
          //close pop-up message
          DisplayPopup_AskAQuestion = false;
          
    }Catch(Exception ee){
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Failure)); 
            system.debug('***Error: ' + ee.getStackTraceString());
        }
                 
  }
    
    public void closePopup_AskAQuestion() {
        DisplayPopup_AskAQuestion = false; 
    }
    
    public void showPopup_AskAQuestion() {
        DisplayPopup_AskAQuestion = true;
        subject = '';
        body = '';   
    }
    //End: ASK A QUESTION EMAIL FUNCTIONALITY
    
    private void buildCompetencyTypes(){
    set<string> setLPComptencyTypes = new set<string>();
    //initialize the mapLitePortalCompetenciesWrapper and lstLPCompetencies
    mapLitePortalCompetenciesWrapper = new map<string, LitePortalCompetenciesWrapper>();
    lstLPCompetencies = new List<selectoption>();
    
    //query all data from Lite_Portal_Competency__c
        list<Lite_Portal_Competency__c> lstCSLitePortalCompetency = Lite_Portal_Competency__c.getAll().values();
       
    if( lstCSLitePortalCompetency != null && !lstCSLitePortalCompetency.isEmpty() ){
      for(Lite_Portal_Competency__c competency : lstCSLitePortalCompetency){
        if (mapLitePortalCompetenciesWrapper.get(competency.name) == null){
          mapLitePortalCompetenciesWrapper.put(competency.name, new LitePortalCompetenciesWrapper(competency.name, competency.Ask_A_Question_Recipients__c, competency.Log_A_Support_Request_Recipients__c));
        }
          }  
    }
        
        setLPComptencyTypes = mapLitePortalCompetenciesWrapper.keySet();
        list<string> lstLPComptencyTypes = new list<string>(setLPComptencyTypes);
        //sort the competency types
        lstLPComptencyTypes.sort();
        
        //add a blank option
    lstLPCompetencies.add(new selectOption('--None--', '--None--'));
        for (string strCompetencyType : lstLPComptencyTypes){
             lstLPCompetencies.add(new SelectOption(strCompetencyType, strCompetencyType));
        }  
    }
    
    public  set<string> returnContentTypeSet(set<string> setContactUserPortalGroups){
        set<string> contentTypes = new set<string>();
        list<NV_Permissions_and_PCL_Mapping__c> lstNV_Permissions_and_PCL_Mapping = NV_Permissions_and_PCL_Mapping__c.getall().values();
        for(NV_Permissions_and_PCL_Mapping__c objNV_Permissions_and_PCL_Mapping : lstNV_Permissions_and_PCL_Mapping) {
            if(setContactUserPortalGroups.contains(objNV_Permissions_and_PCL_Mapping.combination__c)) {
                String strProgramNameCompetencyType = objNV_Permissions_and_PCL_Mapping.Program_Name__c + objNV_Permissions_and_PCL_Mapping.Competency__c;
                contentTypes.add(strProgramNameCompetencyType);
            }
        }
        return contentTypes;
    }
    */
}