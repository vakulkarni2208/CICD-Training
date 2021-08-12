// This controller is using in two VF pages VFCustomerPortalHomeLite & vfPartnerPortalHome page for NV CONTACT details. So remember when ever required NV Contact detail differently in both VF pages. For now Same NV Contact detail require on both VF pages.
public class clsPartnerPortalHome {    
public clsPartnerPortalHome(){
}        
    //Whole Class commented out - Varun 8/16/2019
    /*
    public string instanceMessage {get;set;}
            
    
    // Declaring varibale for each text box on visualforce page.
    public string email {get;set;}
    public string emailReportAProblem {get;set;} 
    public string subject {get;set;}
    public string body {get;set;} 
    public string contactfirstlastname{get;set;}
    public string contactEmail{get;set;}
    public string contactPhone{get;set;}
      
    public string ContactName {get;set;}  
    public Contact contactDetail {get;set;}       

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
    
    
    

    // Main wrapper class to cosolidate all required object data into single unit. It pass on the VF page.
    public List<wrapperMain> lstMainWrapper {get;set;}
    public class wrapperMain{
        public string presentation_Type{get;set;}
        public string presentation_Label{get;set;}
        public decimal srno {get;set;}
        public boolean displayborder {get;set;}
        public string displayboxtitle {get;set;} 
        public boolean displayTitle {get;set;}
        //public string Portal_Home_Page_Box_Name {get;set;}
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
        public string presentation_Type {get;set;}
        public string presentation_URL{get;set;}
        public string image_URL{get;set;}
        public boolean isLink {get;set;}
        public string imageLocation {get;set;}
        public wrapper(){
            serialNo = 0;      
        }
    }   
       
    
    public boolean isGettingStarted {get;set;} //Done
    public boolean isNvidiaContacts {get;set;} //Done
    public boolean isAccountCharts {get;set;} //Done
    public boolean isOwnerCharts {get;set;}   //Done
    public boolean isNewTechnicalPresentations {get;set;}  //Done
    public boolean isNewPresentations {get;set;} //Done
    public boolean isNewCustomerPresentations {get;set;}
    public boolean isNewTrainingPresentations {get;set;}   
    public boolean isNewMarketingPresentations {get;set;}
    public boolean isLogATicketImage {get;set;} 
    public boolean isNewTechnicalTraining {get;set;}
    
    public List<COMM_NVContact_Utility.NVIDIAContactsWrapper> lstNVIDIAContactsWrapper {get;set;} 
    public list<COMM_NVContact_Utility.NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper {get;set;}
    
    public string currUserLangName {get;set;}

    //**********************************************************************************************************
    //Constructor that sets wrappers and flags to be used in the VF
    //**********************************************************************************************************
    public clsPartnerPortalHome(){
        try{
            set<string> setContactUserPortalGroups = new set<string>();     
            lstMainWrapper = new List<wrapperMain>();
            lstWrapper = new List<Wrapper>();
            lstNVIDIAContactsWrapper = new List<COMM_NVContact_Utility.NVIDIAContactsWrapper>(); 
            lstNVIDIAContactsProductWiseWrapper = new list<COMM_NVContact_Utility.NVIDIAContactsProductWiseWrapper>();
            
            email = COMM_Constants.EMAILID_GRID_VCA_PARTNER_NV; //'GRID_VCA_partner@nvidia.com'; Note: Do not know the usage of this varaible
            //email = 'rgade@nvidia.com';
            
            //Logic: If the user records langauge is found in the Community_User_Local_Settings__c then user the use the matching record otherwise default it to English
            currUserLangName = COMM_Utility.getUserLanguage(UserInfo.getLanguage());
            
            //Build up the list of wrapper objects which has Home Page Boxes and its list of Home Page Box Content based on the Permission Set assigned with the logged on user
            //----------------------------------
            generatePresentationBoxes();
            //----------------------------------
            
            //Get the Contact Details
            //------------------------------------
            string contactId = [select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
            system.debug('check current user contact id'+contactId);
            //if(!test.isRunningTest()){
                if(contactId != null && contactId != ''){
                    contactDetail = [   Select FirstName, LastName, Email, Phone, MobilePhone, Portal_User_Content_Type__c, Portal_Groups__c, Account.name, Account.Owner.Name, Account.Owner.email,
                                            Account.Owner.Phone,Account.BillingCountry, Account.BillingState, Account.Marketing_Manager_Name__c, Account.Marketing_Manager_Contact_Number__c,
                                            Account.Marketing_Manager_Email__c, Account.Support_Manager_Name__c, Account.Support_Manager_Contact_Number__c, Account.Support_Manager_Email__c,
                                            Account.Region__c, Account.Sub_Region__c
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
                          }
                     }
                }
            //}
            //------------------------------------
            
            //If Profile Category belongs to Sales, Marketing, or Manager, show Getting Started
            //-------------------------------------------------------
            string profileName = [select  Id,Profile.Name from user where Id =:UserInfo.getUserId()].Profile.Name;  
            GRID_Portal_Profiles__c objGridPortalProfile = [select Profile_Categories__c from GRID_Portal_Profiles__c where Name=:profileName limit 1];
            
            if(objGridPortalProfile.Profile_Categories__c == COMM_Constants.PROFILE_CATEGORY_SALES || objGridPortalProfile.Profile_Categories__c == COMM_Constants.PROFILE_CATEGORY_MARKETING || objGridPortalProfile.Profile_Categories__c == COMM_Constants.PROFILE_MANAGER){
                isGettingStarted = true;
            }else{
                isGettingStarted = false;
            }
            //-------------------------------------------------------
                    
            //set values true false based on assigned permission set for Account chart and Owner chart.
            //-------------------------------------------------------
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
            //-------------------------------------------------------
            
            //Get all the Partner Portal Box names for the logged on user
            //e.g., Accelerated Computing, Professional Virtualization, Cloud/Virtualization, NVEP, Community
            //-------------------------------------------------------
            set<string> contentTypes = returnContentTypeSet(setContactUserPortalGroups);
            //-------------------------------------------------------
                           
            //-------------------------------------------------------
            lstNVIDIAContactsProductWiseWrapper = COMM_NVContact_Utility.putAllNVIDIACONTACTDetail(contactDetail, contentTypes);
            //-------------------------------------------------------
        }Catch(Exception ex){
            system.debug('***Exception: ' + ex);
        }
    }
    //End of Constructor clsPartnerPortalHome()
    //**********************************************************************************************************
    
    //*****************************************************************************
    //  It builds lstMainWrapper
    //  List of Home Page Boxes and its Home Page Box Contents
    //*****************************************************************************
    public void generatePresentationBoxes(){
        Map<string, Portal_Home_Page_Box__c> mapHomePageBox = new Map<string, Portal_Home_Page_Box__c>(); //Portal Home Page Box
        Map<string, List<Portal_Presentation__c>> mapHomePageBoxContent = new Map<string, List<Portal_Presentation__c>>(); //Portal Home Page Box Content
        //get all Permission Set Assignments for the logged on user
        set<string> userPSAs = new set<string>();
        for(PermissionSetAssignment psa :[SELECT AssigneeId,Id,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where AssigneeId = :UserInfo.getUserId()]){
            //if(psa.PermissionSet.Name.contains('HOME_BOX') || psa.PermissionSet.Name.contains('NV_CONTACTS') || psa.PermissionSet.Name.contains('GET_START') || psa.PermissionSet.Name.contains('REPORT_A_PROBLEM')) 
            userPSAs.add(psa.PermissionSet.Name);                                    
        }

        //get all the Portal Permission Sets records wrt logged on User's PSAs
        set<Id> portalPermissionId = new set<Id>();
        for(Portal_Permission_Sets__c portalPSet :[Select Id From Portal_Permission_Sets__c  Where Name in :userPSAs]){
            portalPermissionId.add(portalPSet.id);
        }
        
        //get the country filter of the logged on user,
        //-----------------------------------------------------------
       
        //string currUserLocaleLangKey = UserInfo.getLanguage();
        //string currUserLangName = COMM_Utility.getUserLanguage(currUserLocaleLangKey);
        //-----------------------------------------------------------
        
        
        //Build the mapHomePageBox map and homePageBoxIds
        //--------------------------------------------------------
        set<Id> homePageBoxIds = new set<Id>();
        for(Portal_Home_Page_Box__c PortalHomePageBox : [   Select Id, Name, Display_Border__c, Display_Title__c, Display_Box_Title__c, Presentation_Type__c 
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
        Map<string, decimal> mapPresentationTypeAndSerialNumber = new Map<string, decimal>();
        List<Portal_Presentation__c> lstPortal_Presentation = [ Select Id, Name, Image_URL__c, Portal_Profile__c, Presentation_Type__c, Presentation_URL__c,
                                                                    Content_Serial_Number__c, Image_Location__c, Is_Link__c, Permission_Set__c, Permission_Set__r.Name,
                                                                    Portal_Home_Page_Box__c, Portal_Home_Page_Box__r.Name, Portal_Home_Page_Box__r.Box_Serial_Number__c,
                                                                    Portal_Home_Page_Box__r.Display_Box_Title__c , Portal_Home_Page_Box__r.Display_Border__c, 
                                                                    Portal_Home_Page_Box__r.Display_Title__c, Portal_Home_Page_Box__r.Presentation_Type__c
                                                                From Portal_Presentation__c  
                                                                Where Portal_Home_Page_Box__c in :homePageBoxIds];             
                
        set<string> portal_presentation_Sets = new set<string>();
        for(Portal_Presentation__c presentation : lstPortal_Presentation){             
            //if(presentation.Portal_Home_Page_Box__r.Name!='Report_A_Problem_Button'){         
            if(mapHomePageBoxContent.get(presentation.Portal_Home_Page_Box__r.Presentation_Type__c) == null){
                mapHomePageBoxContent.put(presentation.Portal_Home_Page_Box__r.Presentation_Type__c, new List<Portal_Presentation__c>());                                            
            }                               
            mapHomePageBoxContent.get(presentation.Portal_Home_Page_Box__r.Presentation_Type__c).add(presentation);                           
            portal_presentation_Sets.add(presentation.Permission_Set__r.Name);
            mapPresentationTypeAndSerialNumber.put(presentation.Portal_Home_Page_Box__r.Presentation_Type__c, presentation.Portal_Home_Page_Box__r.Box_Serial_Number__c);
            //}
        }
                
        set<string> portal_presentation_Assigned_To_User_Sets = new set<string>();
        for(PermissionSetAssignment psa : [ Select AssigneeId,Id,PermissionSetId,PermissionSet.Name 
                                            From PermissionSetAssignment 
                                            Where AssigneeId=:UserInfo.getUserId() and PermissionSet.Name in :portal_presentation_Sets]){                     
            portal_presentation_Assigned_To_User_Sets.add(psa.PermissionSet.Name);                                  
        }
                
        //--------------------------------------------------------
                
        //Build the wrapper objects
        //--------------------------------------------------------
        List<wrapperMain> lstMainWrapTosort = new List<wrapperMain>();                
        for(string presentationType : mapHomePageBoxContent.keyset()){    
            List<wrapper> lstwrapperToSort = new List<wrapper>();                                                
            
            wrapperMain w = new wrapperMain();   //Home Page Box
            w.presentation_Label = mapHomePageBox.get(presentationType).Name;                   
            w.presentation_Type = mapHomePageBox.get(presentationType).Presentation_Type__c;
            w.displayborder  = mapHomePageBox.get(presentationType).Display_Border__c;
            w.displayboxtitle = mapHomePageBox.get(presentationType).Display_Box_Title__c;
            w.displayTitle = mapHomePageBox.get(presentationType).Display_Title__c;
            w.srno = mapPresentationTypeAndSerialNumber.get(presentationType);
            
            for(Portal_Presentation__c presentation : mapHomePageBoxContent.get(presentationType)){
                if(portal_presentation_Assigned_To_User_Sets.contains(presentation.Permission_Set__r.Name)){
                    wrapper ww = new wrapper(); //Home Page Box Content
                    ww.serialNo = presentation.Content_Serial_Number__c;                    
                    ww.presentation_URL = presentation.Presentation_URL__c;
                    ww.image_URL = presentation.Image_URL__c;
                    ww.presentation_Name = presentation.Name;
                    ww.presentation_Type = presentation.Presentation_Type__c;
                    ww.isLink = presentation.Is_Link__c;
                    ww.ImageLocation = presentation.Image_Location__c; 
                    lstwrapperToSort.add(ww); 
                }
            }
            w.lstW = sorting(lstwrapperToSort);
            lstMainWrapTosort.add(w);                                                                                                             
        }

        system.debug('***lstMainWrapTosort: ' + lstMainWrapTosort);
        
        //include the NVIDIA Contacts Box
        //Because this Home Page Box does not contain any Home Page Box Contents
        List<Portal_Home_Page_Box__c> lstPortalBoxNVIDIAandGettingStarted = [   Select Name, Presentation_Type__c, Box_Serial_Number__c, Portal_Permission_Set__r.Name 
                                                                                From Portal_Home_Page_Box__c 
                                                                                Where Presentation_Type__c = :COMM_Constants.BOX_PRESENTAIONTYPE_NVIDIA_CONTACTS
                                                                                    And Language__c = :currUserLangName];
        for(Portal_Home_Page_Box__c objnvidiaandgettingstarted  :   lstPortalBoxNVIDIAandGettingStarted){
            if(userPSAs.contains(objnvidiaandgettingstarted.Portal_Permission_Set__r.Name)){    
                wrapperMain w1 = new wrapperMain();
                w1.srno = objnvidiaandgettingstarted.Box_Serial_Number__c;
                w1.presentation_Type = objnvidiaandgettingstarted.Presentation_Type__c;
                w1.presentation_Label = objnvidiaandgettingstarted.Name;
                lstMainWrapTosort.add(w1);
                break;
            }
        }
        lstMainWrapper = sorting(lstMainWrapTosort);
        system.debug('Check-----lstMainWrapper'+lstMainWrapper);
        //--------------------------------------------------------                                     
                
    }
    //End of generatePresentationBoxes()
    //*****************************************************************************
    
    //*****************************************************************************
    // Sort the wrapper list based on the sequence number
    //*****************************************************************************  
    public list<Wrapper> sorting(list<Wrapper> currlist){
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
    //*****************************************************************************

    //*****************************************************************************
    //Sort the WrapperMain list based on the sequence number
    //*****************************************************************************
    public list<WrapperMain> sorting(list<WrapperMain> currlist){
        integer j = 0;          
        WrapperMain tmp = new WrapperMain();  
        if(currlist.size() > 1){           
            for(integer i = 0; i < currlist.size(); i++){
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
    //*****************************************************************************
    
    //========================================================================================================
    // LOG A SUPPORT REQUEST EMAIL FUNCTIONALITY
    //========================================================================================================   
    public void sendEmail_LogASupportRequest(){   
        boolean flag = false;                
        try{
            if(selectedContentType == '--None--' || selectedContentType == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Competency_Reqd));
                if(!test.isRunningTest()) return ; 
            }
            if (contactMobilePhone == null){
                if(phoneNumber == ''){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Phone_Reqd));
                    if(!test.isRunningTest()) return ;
                }     
                if(phoneNumber.length() != 10){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Phone_10_Digits));
                    if(!test.isRunningTest()) return ;
                }       
            }
            if(problemType == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Short_Desc_Reqd));
                if(!test.isRunningTest()) return ;   
            }
            
            if(problemDescription == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Problem_Desc_Reqd));
                if(!test.isRunningTest()) return ;  
            }
            if(steptoReproduceProblem == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_ERR_MSG_Steps_to_Reproduce_Reqd));
                if(!test.isRunningTest()) return ;
            }
            
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            if(Attach != null && FileName_Upload != null){
                efa.setFileName(FileName_Upload);
                efa.setBody(Attach);
                fileAttachments.add(efa);   
            }
            
            //Build the to addresses
            String[] toAddresses;
            List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
       
            if(lstCSPortalToggles != null && lstCSPortalToggles.size() > 0){
                for(Portal_Toggles__c eachPortalToggle : lstCSPortalToggles){
                    if(selectedContentType == eachPortalToggle.Name){
                        if(eachPortalToggle.Log_A_Support_Request_Email__c != null){
                            toAddresses = new String[] {eachPortalToggle.Log_A_Support_Request_Email__c};
                            break;
                        }
                    }
                }
            }
            
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
            string html = '<table width="100%"><tr><td width="30%"><b>Company Name</b></td>';        
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
            supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_FULL;
            supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_LOG_A_SUPPORT_REQ;
            supportRec.Competency__c = selectedContentType;
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
        selectedContentType='';
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
        selectedContentType='';
        email = '';
        contactName = '';
        phoneNumber = '';   
        problemType = '';
        problemDescription = '';
        companyName = '';
        showContentType();
        Attach = null;
        FileName_Upload = null;
    }
    //End: LOG A SUPPORT REQUEST EMAIL FUNCTIONALITY
    //========================================================================================================  
    
    //========================================================================================================
    // ASK A QUESTION EMAIL FUNCTIONALITY
    //========================================================================================================   
    public void sendEmail_AskAQuestion(){
        boolean flag = false; 
        try{
            if(selectedContentType=='--None--' ||selectedContentType==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_MSG_Competency_Reqd));
                if(!test.isRunningTest()) return ; 
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
            String[] toAddresses;
            List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
       
            if(lstCSPortalToggles != null && lstCSPortalToggles.size()>0){
                for(Portal_Toggles__c eachPortalToggle: lstCSPortalToggles){
                    if(selectedContentType == eachPortalToggle.Name){
                        if(eachPortalToggle.Ask_A_Question_Email__c != null){
                            toAddresses = new String[] {eachPortalToggle.Ask_A_Question_Email__c};
                            break;
                        }
                    }
                }
            }
        
            mail.setToAddresses(toAddresses);                
            mail.setSubject('Ask a Question: ' + subject + ' | Competency = ' + selectedContentType );
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
            supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_FULL;
            supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_ASK_A_QUESTION;
            supportRec.Competency__c = selectedContentType;
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
        selectedContentType = '';  
    }
    
    public void showPopup_AskAQuestion() {
        DisplayPopup_AskAQuestion = true;
        subject = '';
        body = '';
        showContentType();     
    }
    //End: ASK A QUESTION EMAIL FUNCTIONALITY
    //========================================================================================================      
     
   
   // Creating a select option list on send email popup to add all content type and setting default if size is one else adding None in first record in the list. Same list using for both Email Popup Grid.
   public List<SelectOption> lstPortalContentTypes{get;set;}
   public string selectedContentType{get;set;}
   
   //***************************************************************************************
   //Build the Content Type drop down list lstPortalContentTypes
   //***************************************************************************************
   public void showContentType(){
        //initialize the list variable lstPortalContentTypes
        lstPortalContentTypes= new List<selectoption>();
        
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
            if (iTotalContentTypes > 1) lstPortalContentTypes.add(new selectOption('--None--', '--None--')); //if more than one Content Type then show this option
            for (string strContentType : contentTypes){
                lstPortalContentTypes.add(new SelectOption(strContentType, strContentType));
            }
        }
        
        //if the Content Type size = 1, set the only selected option as PRE-SELECTED
        if(iTotalContentTypes == 1){
            selectedContentType = lstPortalContentTypes[0].getValue();
        }
        
        //sort the SelectOption list
        lstPortalContentTypes.sort();
        
    }
    //***************************************************************************************
    
    //***************************************************************************************
    //It will return all Content Type for the logged-on user based on Permission Set Assignments and from Partner Portal Box (Partner_Portal_Label__c).
    //***************************************************************************************
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
    //***************************************************************************************   
    */
}