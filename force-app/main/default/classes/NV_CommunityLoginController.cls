/*

    2017.03.24 - Partner Community Named/Login license rollout
    
    2017.08.30 - Varun - Fixing Content Download redirection
*/
global class NV_CommunityLoginController {

    public String username {get; set;}
    public String password {get; set;}
    public Boolean isValid {get; set;}
    public String orgUrl {get; set;}
    public String relativeUrl {get; set;}
    public String partnerPortalId {get; set;}
    public String orgId {get; set;}
    public String portalLoginUrl {get; set;}
    public String userType{get; set;}
    public string forgotPWDUrl {get;set;}
    public string forgotUserNameUrl {get;set;}
    private string Login_Err_Msg{get;set;}
    public String strErrorMsg {get;set;}
    
    public string browserAcceptLanguage{get;set;}
    
    global class LoginWrapper {
        PageReference objPR;
        String errorMsg;
        Boolean isError;
        Boolean isIncorrectPortalUser;
        public LoginWrapper() {
        }
    }
    
    @RemoteAction    
    global static LoginWrapper login(String uname, String password, String strPortalLoginURL, String currentPageURL) {
        LoginWrapper objLoginWrapper = new LoginWrapper();
        
        string strUserNameFromLoginField = uname;
        //If there is a valid Portal User (Partner or Customer) associated with the login username field then no changes to username
        //otherwise assume the supplied login username is actually an email address and so get hold of the username 
        //Check if the User is a Customer Portal User, redirect portal user to portal login url

        boolean isMultiUser = false;
        boolean isNotAnUser = false;
        
        list<User> lstUsersWithUserName = [Select Name, UserName, ProfileId From User Where username = :uname And IsActive = true And ContactId != null];
        
        if ( lstUsersWithUserName == null || lstUsersWithUserName.isEmpty() ){
            //2017.03.24 - Partner Community Named/Login license rollout
            //list<User> lstUsersWithEmail = [Select Name, UserName, ProfileId From User Where email = :uname And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = = :COMM_Constants.USERLICENSE_PP_GP OR UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC)];
            list<User> lstUsersWithEmail = [Select Name, UserName, ProfileId From User Where email = :uname And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserType = :COMM_Constants.USER_USERTYPE_POWERPARTNER OR UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC)];
            
            if (lstUsersWithEmail == null || lstUsersWithEmail.isEmpty()){
                isNotAnUser = true;
            }else if ( lstUsersWithEmail != null && !lstUsersWithEmail.isEmpty() && lstUsersWithEmail.size() > 1){
                isMultiUser = true;
            } else {
                uname = lstUsersWithEmail[0].userName;
            }
        }
        PageReference page ;
        system.debug(currentPageURL);    
        if (isMultiUser){
            page = new PageReference(strPortalLoginURL + '?ShowMultiUserMessage=true');
            page.getParameters().put('username', strUserNameFromLoginField);
            page.setRedirect(true);
            objLoginWrapper.objPR = page;
            objLoginWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Multi_User;
            objLoginWrapper.isError = true;
            return objLoginWrapper;
        } else if (isNotAnUser){        
            page = new PageReference(strPortalLoginURL + '?ShowNoUserMessage=true');
            objLoginWrapper.objPR = page;
            objLoginWrapper.isError = true;
            objLoginWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Invalid_User;
            page.getParameters().put('username', strUserNameFromLoginField);
            page.setRedirect(true);
            return objLoginWrapper;
        } else if (Site.Login(uname, password, null) != null){
        	//2017.08.30 - Fixing Content Download redirection
            if(currentPageURL.contains('startURL=')) {
                currentPageURL = currentPageURL.replaceAll('%2F','/');
                currentPageURL = currentPageURL.substring(currentPageURL.indexOf('startURL=')+9,currentPageURL.length());
                objLoginWrapper.objPR = Site.Login(uname, password, currentPageURL);
            } else {
                objLoginWrapper.objPR = Site.Login(uname, password, null);
            }
            return objLoginWrapper;
        }else{          
            page = new PageReference(strPortalLoginURL + '?showMessage=true');
            page.setRedirect(true);
            page.getParameters().put('username', strUserNameFromLoginField);
            objLoginWrapper.objPR = page;
            objLoginWrapper.isError = true;
            objLoginWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Incorrect_Username_Pwd;
            return objLoginWrapper;
        }
        
    }

    global NV_CommunityLoginController () 
    {
        //set VF Page language
        //SetVFPageLanguage();
        
        isValid = false;
        orgId = [Select Id FROM Organization LIMIT 1].Id;
        Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
        orgUrl = constantFields.get('OrgUrl').Values__c;
        relativeUrl = Apexpages.currentpage().getURL();
        system.debug(Apexpages.currentpage().getHeaders().get('Referrer'));
        partnerPortalId = constantFields.get('PRMPortalId').Values__c;
        portalLoginUrl = constantFields.get('CommunityLoginURL').Values__c;
        forgotPWDUrl = constantFields.get('CommunityForgotPWDURL').Values__c;
        forgotUserNameUrl = constantFields.get('CommunityForgotUserNameURL').Values__c;
        
        //Login_Err_Msg     =   constantFields.get('Login_Err_Msg').Values__c;
        Login_Err_Msg   =   System.Label.COMM_LOGIN_MSG_Incorrect_Username_Pwd;

        string userNameFromURL = Apexpages.currentpage().getParameters().get('username');
        if (userNameFromURL != null || userNameFromURL != ''){
            username = userNameFromURL;
        }
    }
    
}