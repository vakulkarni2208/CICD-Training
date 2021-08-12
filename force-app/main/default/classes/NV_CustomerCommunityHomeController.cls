/*
   Controller for NV_CustomerCommunityHomePage.page

   Change Lists:
   2015.09.10 - add MDFV2 of MDFV3 flags.
   If the user's PS is having "MKTG : MDF Portal : READ : CHANNEL" then isMDFV2User
   If the user's PS is having "MKTG : MDFV3 : VIEWER"  then isMDFV3User

   2015.09.23 - Ask A Question section
   - Change Ask a Question to Getting Started/Need Help
   - Change it to drop down
   - Add How to Navigate the portal, MDF Training and Ask a Question options in the dropdown

   2016.04.01 - Inception Partners related changes

   2017.01.10 - PJENA - Spring 17 release bug - change set to List in soql IN clauses

   2017.05.19 - VKULK- LOG A SUPPORT REQUEST validations & attachments
   2017.05.24 - PJENA - Log A Support Problem, Ask A Question subject changes
   2019-03-04 - Rajat - Commented code to remove preset filters from Lite Portal Marketing Assets box (SDS-1125)
   2019-11-15 - Rajat - Added changes for SDS-1808 Provide NFR SW License link to SOEMs
   2020.01.09 - Rajat - Added Entitlements link tab for SDS-1920
   2020.01.13 - Rajat - Added POS Submission tab for EAR Restricted partners SDS-1958
   2020.10.05 - Rajat - SDS-2707 Changes for Portal Lite Training Only Partners
   2021.01.31 - Rajat - SDS-2695 Changes for Widen access for Tier 1 OEMs.
 */
global without sharing class NV_CustomerCommunityHomeController {
    public string strGGGroups {get; set;}
    public string ContactName {get; set;}
    public Contact contactDetail {get; set;}
    public string emeai_training_username_extn {get; private set;}
    public string brainshark_url {get; set;}
    public string strTabName {get; set;}
    public string strImageiframeName {get; set;}
    public string currUserLangName {get; set;}
    public String accountId {get; set;}     // Added for SDS-2695
  
    // Declaring varibale for each text box on visualforce page.
    public string email {get; set;}
    public string emailReportAProblem {get; set;}
    public string subject {get; set;}
    public string body {get; set;}
    public string contactfirstlastname {get; set;}
    public string contactEmail {get; set;}
    public string contactMobilePhone {get; set;}
    public string contactPhone {get; set;}

    //Variable for report an email thing
    public boolean DisplayPopup_LogASupportRequest {get; set;}
    public boolean DisplayPopup_AskAQuestion {get; set;}
    public blob Attach {get; set;}
    public string problemType {get; set;}
    public string companyName {get; set;}
    public string phoneNumber {get; set;}
    public string problemDescription {get; set;}
    public string shortDescription {get; set;}
    public string steptoReproduceProblem {get; set;}
    public String FileName_Upload {get; set;}

    //Main wrapper class to cosolidate all required object data into single unit. It pass on the VF page.
    public String strLstParentPresentationWrapper {get; set;}
    public List<ParentPresentationWrapper> lstParentPresentationWrapper {get; set;}
    public class ParentPresentationWrapper {
        public string presentation_Label {get; set;}
        public string presentation_Type {get; set;}
        public decimal srno {get; set;}
        public boolean displayborder {get; set;}
        public string displayboxtitle {get; set;}
        public boolean displayTitle {get; set;}
        public List<ChildPresentationWrapper> lstW {get; set;}
        public ParentPresentationWrapper(){
            lstW = new List<ChildPresentationWrapper>();
        }
    }

    // Wrapper class to consolidate Portal_Home_Page_Box__c data.
    public List<ChildPresentationWrapper> lstChildPresentationWrapper {get; set;}
    public class ChildPresentationWrapper {
        public decimal serialNo {get; set;}
        public string presentation_Name {get; set;}
        public string presentation_text {get; set;}
        public string presentation_URL {get; set;}
        public string image_URL {get; set;}
        public boolean isLink {get; set;}
        public string imageLocation {get; set;}
        public ChildPresentationWrapper(){
            serialNo = 0;
        }
    }

    public List<NV_UtilityClass.NVIDIAContactsWrapper> lstNVIDIAContactsWrapper {get; set;}
    public list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper {get; set;}
    public string strNVContacts {get; set;}

    public List<String> lstLPCompetencies {get; set;}
    public string selectedLPCompetency {get; set;}
    public string entitlementTabURL {get; set;}

    //Wrapper class to hold Lite_Portal_Competencies__c custom settings records
    public class LitePortalCompetenciesWrapper {
        public string competencyName {get; set;}
        public string askAQuestionRecipients {get; set;}
        public string logASupportRequestRecipients {get; set;}
        public LitePortalCompetenciesWrapper(string competencyName, string askAQuestionRecipients, string logASupportRequestRecipients){
            this.competencyName = competencyName;
            this.askAQuestionRecipients = askAQuestionRecipients;
            this.logASupportRequestRecipients = logASupportRequestRecipients;
        }
    }

    public class BoolWrapper {
        public boolean isMDFV2User {get; set;}
        public boolean isMDFV3User {get; set;}
        public boolean isNVEPUser {get; set;}
        public boolean isNPNCommunityUser {get; set;}
        public boolean isPortalLiteUser {get; set;}
        public boolean isInceptionPartnerUser {get; set;}
        public boolean isNFRUser {get; set;} //Added for SDS-1808
        public boolean isEntitlementsUser {get; set;} //Added for SDS-1920
        public boolean isPOSUser {get; set;} //Added for SDS-1958
        public boolean isTrainingOnlyUser {get; set;} // Added for SDS-2707
    }
    public BoolWrapper objBoolWrapper {get; set;}

    public map<string, LitePortalCompetenciesWrapper> mapLitePortalCompetenciesWrapper {get; set;}

    //Constructor
    public NV_CustomerCommunityHomeController() {
        try {
            objBoolWrapper = new BoolWrapper();
            set < string > setContactUserPortalGroups = new set < string > ();
            emeai_training_username_extn = COMM_Constants.USRNAME_EXTN_EMEAI_TRAIN;
            //set the user type based on the user name extension, this will not be required later when all old contacts will have the Permissions & Group Assignments field set their respective values
            if (UserInfo.getUserName().toLowerCase().contains(COMM_Constants.USRNAME_EXTN_EMEAI_TRAIN.toLowerCase())) {
                objBoolWrapper.isNVEPUser = true;
            }

            if (UserInfo.getUserName().toLowerCase().contains(COMM_Constants.USRNAME_EXTN_NPN_COMM.toLowerCase())) {
                objBoolWrapper.isNPNCommunityUser = true;
            }
            //End: set th user type

            brainshark_url = Community_Settings__c.getOrgDefaults().BRAINSHARK_URL__c;
            lstParentPresentationWrapper = new List < ParentPresentationWrapper > ();
            lstChildPresentationWrapper = new List < ChildPresentationWrapper > ();
            lstNVIDIAContactsWrapper = new List < NV_UtilityClass.NVIDIAContactsWrapper > ();
            lstNVIDIAContactsProductWiseWrapper = new list < NV_UtilityClass.NVIDIAContactsProductWiseWrapper > ();
            //Logic: If the user records langauge is found in the Community_User_Local_Settings__c then user the use the matching record otherwise default it to English
            currUserLangName = COMM_Utility.getUserLanguage(UserInfo.getLanguage());

            //set contactDetail object
            String contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            if (contactId != null && contactId != '') {
                contactDetail = [Select FirstName, LastName, Email, Portal_User_Content_Type__c, Portal_Groups__c, MobilePhone, Phone,
                         AccountId, Account.Name, Account.Owner.Name, Account.Owner.email, Account.Owner.Phone, Account.BillingCountry,
                         Account.BillingState, Account.Billing_Region__c, Account.Billing_Sub_Region__c, GPU_Genius_Groups__c, EAR_Restricted__c
                         From Contact
                         Where Id =: contactId];            
                accountId = contactDetail.AccountId; // Added for SDS-2695
                system.debug('----> Assingnment of accountId: '+ accountId);
            }
            
            //set lstMainWrapper and lstWrapper
            generatePresentationBoxes();

            //set lstLPCompetencies, selectedLPCompetency, mapLitePortalCompetenciesWrapper
            buildCompetencyTypes();

            //2015.09.10 - add MDFV2 of MDFV3 flags - Set the isMDFV2User and isMDFV3User based on the Permission Set
            //get user's Permission Sets from PermissionSetAssignments object
            //--------------------------------------------------------------------------
            set < string > userPermisionSets = new set < string > ();
            list < PermissionSetAssignment > lstUserPSs = [Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId()];
            if (!lstUserPSs.isEmpty()) {
                for (PermissionSetAssignment psa: lstUserPSs) {
                    userPermisionSets.add(psa.PermissionSet.Name);
                }
            }
            if (userPermisionSets.contains(COMM_Constants.PS_MKTG_MDF_PORTAL_READ_CHANNEL)) {
                objBoolWrapper.isMDFV2User = true;
            }
            if (userPermisionSets.contains(COMM_Constants.PS_MKTG_MDFV3_VIEWER)) {
                objBoolWrapper.isMDFV3User = true;
            }
            /* Changes for SDS-1808 START */
            if (userPermisionSets.contains(COMM_Constants.PS_PORTAL_PP_NPN_NFR_Request)) {
                objBoolWrapper.isNFRUser = true;
            }
            /* Changes for SDS-1808 END */
            /* Changes for SDS-1920 START */
            entitlementTabURL = '';
            if (userPermisionSets.contains(COMM_Constants.PS_PORTAL_PP_Channel_Portal_Access)) {
                objBoolWrapper.isEntitlementsUser = true;
                NPN_Community_Home_Page_Link__c hpLinkObj =[SELECT Id, CustomPermissionName__c, Link_URL__c FROM NPN_Community_Home_Page_Link__c WHERE CustomPermissionName__c = 'SWEntitlementForCommunityHomePage' LIMIT 1];
                if(hpLinkObj != null) {
                    entitlementTabURL = String.isNotBlank(hpLinkObj.Link_URL__c) ? hpLinkObj.Link_URL__c : '';
                }
            }
            /* Changes for SDS-1920 END */

            //-------   -------------------------------------------------------------------

            if(contactDetail != null){
                contactfirstlastname = contactDetail.firstname + ' ' + contactDetail.lastname;
                contactEmail = contactDetail.Email;
                contactMobilePhone = contactDetail.MobilePhone;
                contactPhone = contactDetail.Phone;
                string contactUserPortalGroups = contactDetail.Portal_Groups__c;
                
                list < string > lstContactUserPortalGroups;

                /* Changes for SDS-1958 START */
                if (contactDetail.EAR_Restricted__c && userPermisionSets.contains(COMM_Constants.PS_PORTAL_PP_NPN_Submit_POS)) {
                objBoolWrapper.isPOSUser = true;
                }
                /* Changes for SDS-1958 END */

                if (contactUserPortalGroups != null) {
                    lstContactUserPortalGroups = contactUserPortalGroups.split(';');
                    if (lstContactUserPortalGroups != null) {
                        for (string strContactUserPortalGroup: lstContactUserPortalGroups) {
                            setContactUserPortalGroups.add(strContactUserPortalGroup.trim());
                        }
                        if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_PORTAL_LITE)) { //'Portal Lite'
                            objBoolWrapper.isPortalLiteUser = true;
                        }
                        if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_NVEP)) { //'NVEP'
                            objBoolWrapper.isNVEPUser = true;
                        }
                        if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_COMMUNITY)) { //'Community'
                            objBoolWrapper.isNPNCommunityUser = true;
                        }
                        if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_INCEPTION_PARTNERS)) { //'Inception Partners'
                            objBoolWrapper.isInceptionPartnerUser = true;
                        }
                        /* Changes for SDS-2707 Start */
                        if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_TRAINING_ONLY)) { //'Training Only Partners'
                            objBoolWrapper.isTrainingOnlyUser = true;
                        }            
                        /* Changes for SDS-2707 End */
                        /*
                        //2015.09.10 - add MDFV2 of MDFV3 flags.
                        if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_MDFV2)){ //'MDF'
                        isMDFV2User = true;
                        }
                        if (setContactUserPortalGroups.contains(COMM_Constants.CON_PSANDGROUP_MDFV3)){ //'MDFV3'
                        isMDFV3User = true;
                        }
                        //End: 2015.09.10 - add MDFV2 of MDFV3 flags.
                        */
                    }
                }
            }
            //set strGGGroups. These will be passed a query string parameters to the Learning Locker iFrame
            //-----------------------------------------------
            if (contactDetail.GPU_Genius_Groups__c != null) {
                List < string > lstGGGroups = contactDetail.GPU_Genius_Groups__c.split(';');
                for (string s: lstGGGroups) {
                    List < string > ss = s.split(':');
                    if (strGGGroups == null) {
                        strGGGroups = ss[1];
                    } else {
                        strGGGroups = strGGGroups + ',' + ss[1];
                    }
                }
            }
            //-----------------------------------------------

            set < string > contentTypes = returnContentTypeSet(setContactUserPortalGroups);
            //set lstNVIDIAContactsWrapper list of objects
            lstNVIDIAContactsProductWiseWrapper = NV_UtilityClass.putAllNVIDIACONTACTDetail(contactDetail, contentTypes);
            strNVContacts = String.escapeSingleQuotes(JSON.serialize(lstNVIDIAContactsProductWiseWrapper));
            system.debug(strNVContacts );
        }
        catch(Exception ee) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ee.getMessage() + '-' + ee.getLineNumber());
            ApexPages.addMessage(myMsg);
        }
    }


    //--------------------------------------------------------------------------------------------------------

    //--------------------------------------------------------------------------------------------------------
    //Build the wrapper objects lstMainWrapper, lstWrapper
    //--------------------------------------------------------------------------------------------------------
    public void generatePresentationBoxes() {
        //Portal_Home_Page_Box__c = Portal Home Page Box
        //Portal_Presentation__c = Portal Home Page Box Content
        Map < string, Portal_Home_Page_Box__c > mapHPBoxNameAndHPBoxDetail = new Map < string, Portal_Home_Page_Box__c > ();
        Map < string, List < Portal_Presentation__c > > mapHPBoxNameAndListOfHPBoxContents = new Map < string, List < Portal_Presentation__c > > ();
        Map<String, String>  homePageBoxWidenLinkMap = new Map<String, String>();   // Added for SDS-2695
        
        // Added for SDS-2695
        system.debug('---> accountId : '+accountId);
        if(String.isNotBlank(accountId)){
            for(NPN_SOEM_Widen_Link__mdt mdtRec : [SELECT Id, MasterLabel, DeveloperName, AccountId__c, Portal_Home_Page_Box_Name__c, Redirection_URL__c FROM NPN_SOEM_Widen_Link__mdt WHERE AccountId__c = :accountId]){
                homePageBoxWidenLinkMap.put(mdtRec.Portal_Home_Page_Box_Name__c, mdtRec.Redirection_URL__c);
            }
        }
        system.debug('--> homePageBoxWidenLinkMap: '+ homePageBoxWidenLinkMap);

        //get user's Permission Sets from PermissionSetAssignments object
        set < string > userPermisionSets = new set < string > ();
        list < PermissionSetAssignment > lstUserPSs = [Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId()];
        if (!lstUserPSs.isEmpty()) {
          for (PermissionSetAssignment psa: lstUserPSs) {
            userPermisionSets.add(psa.PermissionSet.Name);
          }
        }

        set < Id > portalPermissionSets = new set < Id > ();
        for (Portal_Permission_Sets__c portalPSet: [Select Name From Portal_Permission_Sets__c Where Name in: userPermisionSets]) {
          portalPermissionSets.add(portalPSet.id);
        }

        //Fill mapHPBoxNameAndHPBoxDetail
        //---------------------------------------------------------------------------------------------------
        //get the country filter of the logged on user,
        /*
           Logic: If the user langauge is found in the Community_User_Local_Settings__c then use the matching record otherwise default it to English
         */
        //string currUserLocaleLangKey = UserInfo.getLanguage();
        //string currUserLangName = COMM_Utility.getUserLanguage(currUserLocaleLangKey);

        /** RAJAT commented below block for SDS-1125 START **/
        //get the Content Language filter
        /*string strUserContentLanguageSearchFilter = COMM_Utility.getUserContentLanguageSearchFilter(UserInfo.getLanguage());
           system.debug('***strUserContentLanguageSearchFilter: ' + strUserContentLanguageSearchFilter);*/
        /** RAJAT commented above block for SDS-1125 END **/

        set < Id > portalHomeBoxId = new set < Id > ();
        for (Portal_Home_Page_Box__c PortalHomePageBox: [Select Name, Display_Border__c, Display_Title__c, Display_Box_Title__c, Presentation_Type__c
                                                         From Portal_Home_Page_Box__c
                                                         Where Portal_Permission_Set__c in: portalPermissionSets
                                                         And Language__c =: currUserLangName
             ]) {
          portalHomeBoxId.add(PortalHomePageBox.Id);
          mapHPBoxNameAndHPBoxDetail.put(PortalHomePageBox.Presentation_Type__c, PortalHomePageBox);
        }

        List < Portal_Presentation__c > lstPortal_Presentation = [Select Id, Name, Image_URL_1__c, Image_URL__c, Portal_Profile__c, Presentation_Type__c, Presentation_URL__c,
                                                                  Content_Serial_Number__c, Image_Location__c, Is_Link__c, Permission_Set__c, Permission_Set__r.Name,
                                                                  Portal_Home_Page_Box__c, Portal_Home_Page_Box__r.Name, Portal_Home_Page_Box__r.Box_Serial_Number__c,
                                                                  Portal_Home_Page_Box__r.Display_Box_Title__c, Portal_Home_Page_Box__r.Display_Border__c, Portal_Home_Page_Box__r.Display_Title__c,
                                                                  Portal_Home_Page_Box__r.Presentation_Type__c, Community_Presentation_Text__c, Presentation_Text__c
                                                                  From Portal_Presentation__c
                                                                  Where Portal_Home_Page_Box__c in: portalHomeBoxId
        ];
        //---------------------------------------------------------------------------------------------------

        //Fill mapHPBoxNameAndListOfHPBoxContents
        set < string > portal_presentation_Sets = new set < string > ();
        Map < string, decimal > mapPresentationTypeAndSerialNumber = new Map < string, decimal > ();
        for (Portal_Presentation__c presentation: lstPortal_Presentation) {
          if (mapHPBoxNameAndListOfHPBoxContents.get(presentation.Portal_Home_Page_Box__r.Presentation_Type__c) == null) {
            mapHPBoxNameAndListOfHPBoxContents.put(presentation.Portal_Home_Page_Box__r.Presentation_Type__c, new List < Portal_Presentation__c > ());
          }
          mapHPBoxNameAndListOfHPBoxContents.get(presentation.Portal_Home_Page_Box__r.Presentation_Type__c).add(presentation);
          portal_presentation_Sets.add(presentation.Permission_Set__r.Name);
          mapPresentationTypeAndSerialNumber.put(presentation.Portal_Home_Page_Box__r.Presentation_Type__c, presentation.Portal_Home_Page_Box__r.Box_Serial_Number__c);

        }

        //2017.01.10 - PJENA- Spring 17 release bug - change set to List in soql IN clauses
        List<String> lst_portal_presentation_Sets = new List<String>(portal_presentation_Sets);
        set < string > portal_presentation_Assigned_To_User_Sets = new set < string > ();
        for (PermissionSetAssignment psa: [Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId =: UserInfo.getUserId() And PermissionSet.Name IN :lst_portal_presentation_Sets]) {
          portal_presentation_Assigned_To_User_Sets.add(psa.PermissionSet.Name);
        }

        List < ParentPresentationWrapper > lstMailWrapTosort = new List < ParentPresentationWrapper > ();

        for (string presentationType: mapHPBoxNameAndListOfHPBoxContents.keyset()) {
            List < ChildPresentationWrapper > lstwrapperToSort = new List < ChildPresentationWrapper > ();
            ParentPresentationWrapper objParentPresentationWrapper = new ParentPresentationWrapper();
            objParentPresentationWrapper.presentation_Label = mapHPBoxNameAndHPBoxDetail.get(presentationType).Name;
            objParentPresentationWrapper.presentation_Type = mapHPBoxNameAndHPBoxDetail.get(presentationType).Presentation_Type__c;
            //w.presentation_Type = presentationType;
            system.debug('***objParentPresentationWrapper.presentation_Type = ' + objParentPresentationWrapper.presentation_Type);
            objParentPresentationWrapper.displayborder = mapHPBoxNameAndHPBoxDetail.get(presentationType).Display_Border__c;
            objParentPresentationWrapper.displayboxtitle = mapHPBoxNameAndHPBoxDetail.get(presentationType).Display_Box_Title__c;
            objParentPresentationWrapper.displayTitle = mapHPBoxNameAndHPBoxDetail.get(presentationType).Display_Title__c;
            objParentPresentationWrapper.srno = mapPresentationTypeAndSerialNumber.get(presentationType);

            for (Portal_Presentation__c presentation: mapHPBoxNameAndListOfHPBoxContents.get(presentationType)) {
                if (portal_presentation_Assigned_To_User_Sets.contains(presentation.Permission_Set__r.Name)) {
                    ChildPresentationWrapper objChildPresentationWrapper = new ChildPresentationWrapper();
                    objChildPresentationWrapper.serialNo = presentation.Content_Serial_Number__c;
                    //ww.presentation_URL = presentation.Presentation_URL__c;
                    //if the presentation URL is Salesforce Content, then pass the user local language filter
                    //--------------------------------------------------------------------------------------                    
                    /** RAJAT commented below block for SDS-1125 START **/
                    //string strPresentationURL = presentation.Image_URL_1__c;  // SDS-2695 Rajat : replace the URL here
                    //String strSFCSearchURLToken = COMM_Constants.CONTENT_SEARCH_URLTOKEN; //'sfc/#search'  // Unused variable 
                    /*if (strPresentationURL != null && strPresentationURL.toLowerCase().endsWith(strSFCSearchURLToken.toLowerCase()) && strUserContentLanguageSearchFilter.length() > 0) {
                        strPresentationURL = strPresentationURL + '?' + COMM_Constants.CONTENT_SEARCH_FILTER_PARAMETER_KEY + '=' + strUserContentLanguageSearchFilter;
                    }*/
                    //objChildPresentationWrapper.presentation_URL = strPresentationURL;
                    /** RAJAT commented above block for SDS-1125 END **/
                    //--------------------------------------------------------------------------------------
                    
                    objChildPresentationWrapper.presentation_URL = presentation.Image_URL_1__c;
                    // Added for SDS-2695 START
                    if(!homePageBoxWidenLinkMap.isEmpty()){
                        objChildPresentationWrapper.presentation_URL = homePageBoxWidenLinkMap.get(presentationType);
                    }
                    // Added for SDS-2695 END
                    objChildPresentationWrapper.image_URL = presentation.Image_URL__c;
                    objChildPresentationWrapper.presentation_Name = presentation.Name;
                    objChildPresentationWrapper.presentation_Text = StripBGColor(presentation.Community_Presentation_Text__c); //change the bgcolor to none
                    if(objChildPresentationWrapper.presentation_Text != null){
                        objChildPresentationWrapper.presentation_Text = objChildPresentationWrapper.presentation_Text.unescapeHtml4();
                    }
                    system.debug(objChildPresentationWrapper.presentation_Text);
                    objChildPresentationWrapper.isLink = presentation.Is_Link__c;
                    objChildPresentationWrapper.ImageLocation = presentation.Image_Location__c;
                    lstwrapperToSort.add(objChildPresentationWrapper);
                }
            }
            objParentPresentationWrapper.lstW = sorting(lstwrapperToSort);
            lstMailWrapTosort.add(objParentPresentationWrapper);
        }

        //Add the NVIDIA CONTACTS Box
        //---------------------------------------------------------------------------------------------------
        List < Portal_Home_Page_Box__c > lstPHBoxNVIDIAContacts = [Select Name, Presentation_Type__c, Box_Serial_Number__c, Portal_Permission_Set__r.Name
                                                                   From Portal_Home_Page_Box__c
                                                                   Where Presentation_Type__c =: COMM_Constants.BOX_PRESENTAIONTYPE_NVIDIA_CONTACTS
                                                                                                And Language__c =: currUserLangName
        ];
        for (Portal_Home_Page_Box__c PHBoxNVIDIAContact: lstPHBoxNVIDIAContacts) {
            if (userPermisionSets.contains(PHBoxNVIDIAContact.Portal_Permission_Set__r.Name)) {
                ParentPresentationWrapper w1 = new ParentPresentationWrapper();
                w1.srno = PHBoxNVIDIAContact.Box_Serial_Number__c;
                w1.presentation_Type = PHBoxNVIDIAContact.Presentation_Type__c;
                w1.presentation_Label = PHBoxNVIDIAContact.Name;
                lstMailWrapTosort.add(w1);
                break;
            }
        }
        //---------------------------------------------------------------------------------------------------

        //sort the list of MainWrapper
        lstParentPresentationWrapper = sorting(lstMailWrapTosort);
        strLstParentPresentationWrapper = String.escapeSingleQuotes(JSON.serialize(lstParentPresentationWrapper));
        //system.debug('***lstMainWrapper: ' + lstMainWrapper);
    }
    //--------------------------------------------------------------------------------------------------------

  //--------------------------------------------------------------------------------------------------------
  //Sorting of list of Wrapper objects
  //--------------------------------------------------------------------------------------------------------
  public list < ChildPresentationWrapper > sorting(list < ChildPresentationWrapper > currlist) {
    integer j = 0;
    ChildPresentationWrapper tmp = new ChildPresentationWrapper();
    if (currlist.size() > 1) {
      for (integer i = 0; i < currlist.size(); i++) {
        j = i;
        for (integer k = i; k < currlist.size(); k++) {
          if (currlist[j].serialNo > currlist[k].serialNo) {
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
  public list < ParentPresentationWrapper > sorting(list < ParentPresentationWrapper > currlist) {
    integer j = 0;
    ParentPresentationWrapper tmp = new ParentPresentationWrapper();
    if (currlist.size() > 1) {
      for (integer i = 0; i < currlist.size(); i++) {
        j = i;
        for (integer k = i; k < currlist.size(); k++) {
          if (currlist[j].srno > currlist[k].srno) {
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
  private string StripBGColor(string strInput) {
    if (strInput != null) {
      strInput = strInput.replace('background-color: rgb(255, 255, 255);', '');
    }
    return strInput;
  }
  //--------------------------------------------------------------------------------------------------------

  //========================================================================================================
  // LOG A SUPPORT REQUEST EMAIL FUNCTIONALITY
  //========================================================================================================
  @RemoteAction
  global static Boolean sendEmail_LogASupportRequest(String logASupportRequest){
    boolean flag = false;
    system.debug('logASupportRequest'+logASupportRequest);
    Map<String, Object> mapLogASupportRequest = (Map<String, Object>) JSON.deserializeUntyped(logASupportRequest);
    system.debug('mapLogASupportRequest'+mapLogASupportRequest);
    //Map<String, Object> mapContactData = (Map<String, Object>) JSON.deserializeUntyped((String)mapLogASupportRequest.get('contact'));
    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
    if(mapLogASupportRequest.get('FileBody') != null && mapLogASupportRequest.get('FileBody') != '') {
      efa.setFileName((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('name'));
      if(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body')).contains(',')) {
        efa.setBody(EncodingUtil.base64Decode(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body')).split(',')[1]));
      } else {
        efa.setBody(EncodingUtil.base64Decode(((String)((Map<String,Object>)mapLogASupportRequest.get('FileBody')).get('body'))));
      }
      fileAttachments.add(efa);
    }

    //Build the to addresses from Lite_Portal_Competencies__c custom settings based on the selected Competency
    string[] toAddresses;
    string strLogASupportRequestRecipients;
    map < string, LitePortalCompetenciesWrapper > mapLitePortalCompetenciesWrapper = new map < string, LitePortalCompetenciesWrapper > ();
    //query all data from Lite_Portal_Competency__c
    list < Lite_Portal_Competency__c > lstCSLitePortalCompetency = Lite_Portal_Competency__c.getAll().values();
    if (lstCSLitePortalCompetency != null && !lstCSLitePortalCompetency.isEmpty()) {
      for (Lite_Portal_Competency__c competency: lstCSLitePortalCompetency) {
        if (mapLitePortalCompetenciesWrapper.get(competency.name) == null) {
          mapLitePortalCompetenciesWrapper.put(competency.name, new LitePortalCompetenciesWrapper(competency.name, competency.Ask_A_Question_Recipients__c, competency.Log_A_Support_Request_Recipients__c));
        }
      }
    }
    LitePortalCompetenciesWrapper lpcWrapper = mapLitePortalCompetenciesWrapper.get((String)((Map<String, Object>)mapLogASupportRequest.get('selectedLPCompetency')).get('value'));
    if (lpcWrapper != null) {
      strLogASupportRequestRecipients = lpcWrapper.logASupportRequestRecipients;
      if (strLogASupportRequestRecipients != null && strLogASupportRequestRecipients != '') {
        toAddresses = strLogASupportRequestRecipients.split(',');
        for (integer i=0; i < toAddresses.size(); i++) {
          toAddresses[i] = toAddresses[i].trim();
        }
      }
    }

    mail.setToAddresses(toAddresses);
    DateTime d = System.now();
    mail.setSubject(COMM_Constants.LOG_A_SUPPORT_SUBJECT + UserInfo.getFirstName() +' '+ UserInfo.getLastName() + ' on ' + d.month() + '/' + d.day() + '/' + d.year() + '/' + d.time() + ' on ' + mapLogASupportRequest.get('problemType'));
    mail.setBccSender(false);
    if(fileAttachments.size() > 0) {
      mail.setFileAttachments(fileAttachments);
    }

    //contact phone
    string strContactPhone = '';
    if(((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone') != null && ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone') != '') {
      strContactPhone = (String) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('MobilePhone');
    } else{
      strContactPhone = (String) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Phone');
    }

    //build the email body
    string html = '<table width="100%">';
    html += '<tr><td width="30%"><b>Competency</b></td>';
    html += '<td>' + (String)((Map<String, Object>)mapLogASupportRequest.get('selectedLPCompetency')).get('value') + '</td></tr>';
    html += '<tr><td width="30%"><b>Company Name</b></td>';
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
    supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_LITE;
    supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_LOG_A_SUPPORT_REQ;
    supportRec.Competency__c = (String)((Map<String, Object>)mapLogASupportRequest.get('selectedLPCompetency')).get('value');
    supportRec.Contact_Phone_Number__c = (String) ((Map<String, Object>)mapLogASupportRequest.get('contact')).get('Phone');
    supportRec.Short_Description__c = (String) mapLogASupportRequest.get('problemType');
    supportRec.Problem_Description__c = (String) mapLogASupportRequest.get('problemDescription');
    supportRec.Steps_to_Reproduce_Problem__c = (String) mapLogASupportRequest.get('stepToReproduce');
    supportRec.AAQ_Subject__c = null;
    supportRec.AAQ_Body__c = null;
    insert supportRec;

    //insert the attachment if any
    if(fileAttachments.size() > 0) {
      Attachment oAttachment = new Attachment();
      /*oAttachment.Body = (Blob) mapLogASupportRequest.get('fileBody');
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
  /*public void sendEmail_AskAQuestion() {
     boolean flag = false;
     try {
     if (selectedLPCompetency == '--None--' || selectedLPCompetency == '') {
     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_MSG_Competency_Reqd));
     if (!test.isRunningTest()) return;
     }
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

     string[] toAddresses;
     string strAskAQuestionRecipients;
     LitePortalCompetenciesWrapper lpcWrapper = mapLitePortalCompetenciesWrapper.get(selectedLPCompetency);
     if (lpcWrapper != null) {
     strAskAQuestionRecipients = lpcWrapper.askAQuestionRecipients;
     if (strAskAQuestionRecipients != null && strAskAQuestionRecipients != '') {
     toAddresses = strAskAQuestionRecipients.split(',');
     for (integer i = 0; i < toAddresses.size(); i++) {
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
     if (contactMobilePhone != null && contactMobilePhone != '') {
     strContactPhone = contactMobilePhone;
     } else {
     strContactPhone = contactPhone;
     }

     //send email
     Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
     mail
     });

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

     }
     Catch(Exception ee) {
     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, System.Label.COMM_CP_VF_EMAIL_MSG_Send_Failure));
     system.debug('***Error: ' + ee.getStackTraceString());
     }

     }*/

  //========================================================================================================
  // ASK A QUESTION EMAIL FUNCTIONALITY
  //========================================================================================================
  @RemoteAction
  global static Boolean sendEmail_askAQuestion(String askAQuestion){
    boolean flag = false;
    system.debug('askAQuestion'+askAQuestion);
    Map<String, Object> mapAskAQuestion = (Map<String, Object>) JSON.deserializeUntyped(askAQuestion);
    system.debug('mapAskAQuestion'+mapAskAQuestion);

    //Build the to addresses from Lite_Portal_Competencies__c custom settings based on the selected Competency
    string[] toAddresses;
    string strLogASupportRequestRecipients;
    map < string, LitePortalCompetenciesWrapper > mapLitePortalCompetenciesWrapper = new map < string, LitePortalCompetenciesWrapper > ();
    //query all data from Lite_Portal_Competency__c
    list < Lite_Portal_Competency__c > lstCSLitePortalCompetency = Lite_Portal_Competency__c.getAll().values();
    if (lstCSLitePortalCompetency != null && !lstCSLitePortalCompetency.isEmpty()) {
      for (Lite_Portal_Competency__c competency: lstCSLitePortalCompetency) {
        if (mapLitePortalCompetenciesWrapper.get(competency.name) == null) {
          mapLitePortalCompetenciesWrapper.put(competency.name, new LitePortalCompetenciesWrapper(competency.name, competency.Ask_A_Question_Recipients__c, competency.Log_A_Support_Request_Recipients__c));
        }
      }
    }
    LitePortalCompetenciesWrapper lpcWrapper = mapLitePortalCompetenciesWrapper.get((String)((Map<String, Object>)mapAskAQuestion.get('selectedLPCompetency')).get('value'));
    if (lpcWrapper != null) {
      strLogASupportRequestRecipients = lpcWrapper.logASupportRequestRecipients;
      if (strLogASupportRequestRecipients != null && strLogASupportRequestRecipients != '') {
        toAddresses = strLogASupportRequestRecipients.split(',');
        for (integer i=0; i < toAddresses.size(); i++) {
          toAddresses[i] = toAddresses[i].trim();
        }
      }
    }


    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toAddresses);
    mail.setSubject(COMM_Constants.ASK_A_QUESTION_SUBJECT + (String)mapAskAQuestion.get('emailSubject') + ' | Competency = ' + (String)((Map<String, Object>)mapAskAQuestion.get('selectedLPCompetency')).get('value'));
    mail.setBccSender(false);
    mail.setPlainTextBody((String)mapAskAQuestion.get('emailBody'));

    //contact phone
    string strContactPhone = '';
    if(((Map<String, Object>)mapAskAQuestion.get('contact')).get('MobilePhone') != null && ((Map<String, Object>)mapAskAQuestion.get('contact')).get('MobilePhone') != '') {
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
    supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_LITE;
    supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_ASK_A_QUESTION;
    supportRec.Competency__c = (String)((Map<String, Object>)mapAskAQuestion.get('selectedLPCompetency')).get('value');
    supportRec.Contact_Phone_Number__c =  (String) ((Map<String, Object>)mapAskAQuestion.get('contact')).get('Phone');
    supportRec.Short_Description__c = null;
    supportRec.Problem_Description__c = null;
    supportRec.Steps_to_Reproduce_Problem__c = null;
    supportRec.AAQ_Subject__c = (String) mapAskAQuestion.get('emailSubject');
    supportRec.AAQ_Body__c = (String) mapAskAQuestion.get('emailBody');
    //insert supportRec;

    return true;

  }

  //End: ASK A QUESTION EMAIL FUNCTIONALITY
  //========================================================================================================

  //***************************************************************************************
  //It will build the lstLPCompetencies SelectOption list
  //  public List<SelectOption> lstLPCompetencies{get;set;}
  //  public string selectedLPCompetency{get;set;}
  //***************************************************************************************
  private void buildCompetencyTypes() {
    set < string > setLPComptencyTypes = new set < string > ();
    //initialize the mapLitePortalCompetenciesWrapper and lstLPCompetencies
    mapLitePortalCompetenciesWrapper = new map < string, LitePortalCompetenciesWrapper > ();
    lstLPCompetencies = new List < String > ();

    //query all data from Lite_Portal_Competency__c
    list < Lite_Portal_Competency__c > lstCSLitePortalCompetency = Lite_Portal_Competency__c.getAll().values();

    if (lstCSLitePortalCompetency != null && !lstCSLitePortalCompetency.isEmpty()) {
      for (Lite_Portal_Competency__c competency: lstCSLitePortalCompetency) {
        if (mapLitePortalCompetenciesWrapper.get(competency.name) == null) {
          mapLitePortalCompetenciesWrapper.put(competency.name, new LitePortalCompetenciesWrapper(competency.name, competency.Ask_A_Question_Recipients__c, competency.Log_A_Support_Request_Recipients__c));
        }
      }
    }

    setLPComptencyTypes = mapLitePortalCompetenciesWrapper.keySet();
    list < string > lstLPComptencyTypes = new list < string > (setLPComptencyTypes);
    //sort the competency types
    lstLPComptencyTypes.sort();

    //add a blank option
    lstLPCompetencies.add('--None--');
    for (string strCompetencyType: lstLPComptencyTypes) {
      lstLPCompetencies.add(strCompetencyType);
    }
  }
  //***************************************************************************************

  //***************************************************************************************
  //It will return all Content Type for the logged-on user based on Permission Set Assignments and from Partner Portal Box (Partner_Portal_Label__c).
  //***************************************************************************************
  public set < string > returnContentTypeSet(set < string > setContactUserPortalGroups) {
    set < string > contentTypes = new set < string > ();
    list < NV_Permissions_and_PCL_Mapping__c > lstNV_Permissions_and_PCL_Mapping = NV_Permissions_and_PCL_Mapping__c.getall().values();
    for (NV_Permissions_and_PCL_Mapping__c objNV_Permissions_and_PCL_Mapping: lstNV_Permissions_and_PCL_Mapping) {
      if (setContactUserPortalGroups.contains(objNV_Permissions_and_PCL_Mapping.combination__c)) {
        String subProgram = objNV_Permissions_and_PCL_Mapping.Sub_Program__c==null ? '' : objNV_Permissions_and_PCL_Mapping.Sub_Program__c;
        String strProgramNameCompetencyType = objNV_Permissions_and_PCL_Mapping.Program_Name__c + subProgram + objNV_Permissions_and_PCL_Mapping.Competency__c;
        contentTypes.add(strProgramNameCompetencyType);
      }
    }
    return contentTypes;
  }
  //***************************************************************************************

}