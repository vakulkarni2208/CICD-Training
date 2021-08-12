global class Customer_Portal_QPP_Login 
{
    public String UID {get; set;}
    public String PWD {get; set;}
    
    public String orgURL {get; set;}
    public String orgID {get; set;}
    public String PortalID {get; set;}
    public String PortalLoginURL {get; set;}
    public string PortalForgotPwdUrl {get;set;}
    public string PortalForgotUserNameUrl {get;set;}

    public Boolean isValid {get; set;}
    private string Login_Err_Msg {get;set;}
    
    public string browserAcceptLanguage{get;set;}

    global pageReference login() {
        
                
        string strUserNameFromLoginField = UID;
        //If there is a valid Portal User (Partner or Customer) associated with the login username field then no changes to username
        //otherwise assume the supplied login username is actually an email address and so get hold of the username 
        //Check if the User is a Customer Portal User, redirect portal user to portal login url
        boolean isMultiUser = false;
        boolean isNotAnUser = false;
        
        list<User> lstUsersWithUserName = [Select Name, UserName, ProfileId From User Where username = :UID And IsActive = true And ContactId != null];
        
        if (lstUsersWithUserName == null || lstUsersWithUserName.isEmpty()){
            list<User> lstUsersWithEmail = [Select Name, UserName, ProfileId From User Where email = :UID And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC)];
            if (lstUsersWithEmail == null || lstUsersWithEmail.isEmpty()){
                isNotAnUser = true;
            }else if ( lstUsersWithEmail != null && !lstUsersWithEmail.isEmpty() && lstUsersWithEmail.size() > 1){
                isMultiUser = true;
            } else {
                this.UID = lstUsersWithEmail[0].userName;
            }
        }
        
      
        if (isMultiUser){
            PageReference page = new PageReference(portalLoginUrl + '?ShowMultiUserMessage=true');
            page.getParameters().put('username', strUserNameFromLoginField);
            page.setRedirect(true);
            return page;
        } else if (isNotAnUser){
            //Check if the user is a portal  user
            list<User> lstUsers = [Select Name, ProfileId From User Where (username = :UID Or Email = :UID) And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_PP_GP)];
            PageReference page;
            if ( lstUsers != null && !lstUsers.isEmpty() && lstUsers.size() > 1){
                Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
                portalLoginUrl = constantFields.get('PrmPortalLoginUrl').Values__c;
                page = new PageReference(portalLoginUrl + '?ShowMultiUserMessage=true');
            } else if ( lstUsers != null && !lstUsers.isEmpty() && lstUsers.size() == 1){
                Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
                portalLoginUrl = constantFields.get('PrmPortalLoginUrl').Values__c;
                page = new PageReference(portalLoginUrl + '?ShowRedirectionMessage=true');
            } else {
                page = new PageReference(portalLoginUrl + '?ShowNoUserMessage=true');
            }
            page.getParameters().put('username', strUserNameFromLoginField);
            page.setRedirect(true);
            return page;
        } else if (Site.Login(UID, PWD, '/home/home.jsp') != null){
            isValid = true;
            return null;
        } else{
            //string portalLoginUrl = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c; 
            //Check if the User is a Partner Portal User, redirect portal user to portal login url
            list<User> lstUsers = [Select Name, ProfileId From User Where (username = :UID Or Email = :UID) And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_PP_GP)];
            if ( lstUsers != null && !lstUsers.isEmpty() ){
                Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
                portalLoginUrl = constantFields.get('PrmPortalLoginUrl').Values__c;
                PageReference page = new PageReference(portalLoginUrl + '?ShowRedirectionMessage=true');
                page.getParameters().put('username', strUserNameFromLoginField);
                page.setRedirect(true);
                return page;
            } 
            
            PageReference page = new PageReference(portalLoginUrl + '?showMessage=true');
            page.getParameters().put('username', strUserNameFromLoginField);
            page.setRedirect(true);
            return page;
        }
    }
   
    global Customer_Portal_QPP_Login(){
        
        //set VF Page language
        //SetVFPageLanguage();
        
        isValid = false;
        
        orgID           = [Select Id FROM Organization LIMIT 1].Id;
        orgURL          = Customer_Portal_QPP__c.getOrgDefaults().ORG_URL__c;
        PortalID        = Customer_Portal_QPP__c.getOrgDefaults().ID__c;
        PortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
        PortalForgotPwdUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_PWD_URL__c;
        PortalForgotUserNameUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_UserName_URL__c;
        //Login_Err_Msg     =   Customer_Portal_QPP__c.getOrgDefaults().Login_Err_Msg__c;
        Login_Err_Msg   =   System.Label.COMM_LOGIN_MSG_Incorrect_Username_Pwd;
        
        
        string userNameFromURL = Apexpages.currentpage().getParameters().get('username');
        if (userNameFromURL != null || userNameFromURL != ''){
            UID = userNameFromURL;
        }
        
        //Collect the showMessage parameter and assign it to showPageMessage
        string paramShowMessage = ApexPages.currentPage().getParameters().get('showMessage');
        if (paramShowMessage == 'true'){
            ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.ERROR, Login_Err_Msg);
            ApexPages.addMessage(errMessage);
        }
        
        string showMultiUserMessageFromURL = Apexpages.currentpage().getParameters().get('ShowMultiUserMessage');
        if (showMultiUserMessageFromURL != null || showMultiUserMessageFromURL == 'true'){
            //string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Password_MultiUser_Err_Msg__c;
            string errMsg = System.Label.COMM_LOGIN_MSG_Multi_User;
            ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
            ApexPages.addMessage(errMessage);
        }
        
        string showNoUserMessageFromURL = Apexpages.currentpage().getParameters().get('ShowNoUserMessage');
        if (showNoUserMessageFromURL != null || showNoUserMessageFromURL == 'true'){
            //string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Password_NoUser_Err_Msg__c;
            string errMsg = System.Label.COMM_LOGIN_MSG_Invalid_User;
            ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
            ApexPages.addMessage(errMessage);
        }
        
        string showRedirectionMessageFromURL = Apexpages.currentpage().getParameters().get('ShowRedirectionMessage');
        if (showRedirectionMessageFromURL != null || showRedirectionMessageFromURL == 'true'){
            //string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Password_MultiUser_Err_Msg__c;
            string redirectionMsg = System.Label.COMM_LOGIN_MSG_Redirection;
            ApexPages.Message redirectionMessage = new ApexPages.Message(ApexPages.Severity.ERROR, redirectionMsg);
            ApexPages.addMessage(redirectionMessage);
        }
        
        
    }
    
    /*
    global void SetVFPageLanguage(){
        String strBrowserAcceptLangs = ApexPages.currentPage().getHeaders().get('Accept-Language');
        browserAcceptLanguage = 'en-US';//default language = English
        if (strBrowserAcceptLangs != null){
            list<string> lstBrowserAcceptedLangs = strBrowserAcceptLangs.split(',');
            if (lstBrowserAcceptedLangs[0] != null && lstBrowserAcceptedLangs[0].trim() != ''){
                browserAcceptLanguage = lstBrowserAcceptedLangs[0].trim();
            }
        }
    }
    */
    
    @isTest
    global static void testCustomer_Portal_QPP_Login() 
    {
        Customer_Portal_QPP_Login controller = new Customer_Portal_QPP_Login ();
        controller.UID = 'test@salesforce.com';
        controller.PWD = '123456'; 
        try{
            controller.login();  
        } catch(Exception ex){
            system.debug('***Expected error during test method execution only: ' + ex);
        }                         
    }   
}