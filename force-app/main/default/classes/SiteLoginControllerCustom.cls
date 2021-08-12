global class SiteLoginControllerCustom 
{
    public String username {get; set;}
    public String password {get; set;}
    public Boolean isValid {get; set;}
    public String orgUrl {get; set;}
    public String partnerPortalId {get; set;}
    public String orgId {get; set;}
    public String portalLoginUrl {get; set;}
    public String userType{get; set;}
    public string forgotPWDUrl {get;set;}
    public string forgotUserNameUrl {get;set;}
    private string Login_Err_Msg{get;set;}
    
    public string browserAcceptLanguage{get;set;}
    
    global pageReference login(){
        
        string strUserNameFromLoginField = username;
        //If there is a valid Portal User (Partner or Customer) associated with the login username field then no changes to username
        //otherwise assume the supplied login username is actually an email address and so get hold of the username 
        //Check if the User is a Customer Portal User, redirect portal user to portal login url

        boolean isMultiUser = false;
        boolean isNotAnUser = false;
        
        list<User> lstUsersWithUserName = [Select Name, UserName, ProfileId From User Where username = :username And IsActive = true And ContactId != null];
        
        if ( lstUsersWithUserName == null || lstUsersWithUserName.isEmpty() ){
            list<User> lstUsersWithEmail = [Select Name, UserName, ProfileId From User Where email = :username And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_PP_GP)];
            
            if (lstUsersWithEmail == null || lstUsersWithEmail.isEmpty()){
                isNotAnUser = true;
            }else if ( lstUsersWithEmail != null && !lstUsersWithEmail.isEmpty() && lstUsersWithEmail.size() > 1){
                isMultiUser = true;
            } else {
                username = lstUsersWithEmail[0].userName;
            }
        }
        
        if (isMultiUser){
            PageReference page = new PageReference(portalLoginUrl + '?ShowMultiUserMessage=true');
            page.getParameters().put('username', strUserNameFromLoginField);
            page.setRedirect(true);
            return page;
        } else if (isNotAnUser){
            list<User> lstUsers = [Select Name, ProfileId From User Where (userName = :username Or email = :username) And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC)];
            PageReference page;
            if ( lstUsersWithUserName != null && !lstUsers.isEmpty() && lstUsers.size() > 1){               
                portalLoginUrl = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
                page = new PageReference(portalLoginUrl + '?ShowMultiUserMessage=true');
            } else if (lstUsersWithUserName != null && !lstUsers.isEmpty() && lstUsers.size() == 1) {
                portalLoginUrl = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
                page = new PageReference(portalLoginUrl + '?ShowRedirectionMessage=true');
            } else{
                page = new PageReference(portalLoginUrl + '?ShowNoUserMessage=true');
            }
            page.getParameters().put('username', strUserNameFromLoginField);
            page.setRedirect(true);
            return page;
        } else if (Site.Login(username, password, '/home/home.jsp') != null){
           isValid = true;
           return null;
        }else{
            //Check if the User is a Customer Portal User, redirect portal user to portal login url
            list<User> lstUsers = [Select Name, ProfileId From User Where (userName = :username Or email = :username) And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC)];
            if ( lstUsersWithUserName != null && !lstUsers.isEmpty() ){             
                portalLoginUrl = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
                PageReference page = new PageReference(portalLoginUrl + '?ShowRedirectionMessage=true');
                page.setRedirect(true);
                page.getParameters().put('username', strUserNameFromLoginField);
                return page;
            } 
            
            PageReference page = new PageReference(portalLoginUrl + '?showMessage=true');
            page.setRedirect(true);
            page.getParameters().put('username', strUserNameFromLoginField);
            return page;
        }
        
    }
    
    global SiteLoginControllerCustom () 
    {
        //set VF Page language
        //SetVFPageLanguage();
        
        isValid = false;
        orgId = [Select Id FROM Organization LIMIT 1].Id;
        Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
        orgUrl = constantFields.get('OrgUrl').Values__c;
        partnerPortalId = constantFields.get('PRMPortalId').Values__c;
        portalLoginUrl = constantFields.get('PrmPortalLoginUrl').Values__c;
        forgotPWDUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
        forgotUserNameUrl = constantFields.get('PrmPortalForgotUserNameURL').Values__c;
        
        //Login_Err_Msg     =   constantFields.get('Login_Err_Msg').Values__c;
        Login_Err_Msg   =   System.Label.COMM_LOGIN_MSG_Incorrect_Username_Pwd;
        
        string userNameFromURL = Apexpages.currentpage().getParameters().get('username');
        if (userNameFromURL != null || userNameFromURL != ''){
            username = userNameFromURL;
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
    
    @isTest(SeeAllData=True)
    global static void testSiteLoginController () 
    {
        // Instantiate a new controller with all parameters in the page
        SiteLoginControllerCustom controller = new SiteLoginControllerCustom ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
        controller.login();                           
    }
    
}