/*

	//2017.03.24 - Partner Community Named/Login license rollout
*/

global class NV_ForgotPasswordController {
    public static String username {get; set;} 
    public static String strErrorMsg {get; set;}   
    public static String orgID {get; set;}
    public static String PortalID {get; set;}
    public static String PortalLoginURL {get; set;}
    public static String PortalForgotPwdUrl {get;set;}
    public static String fromPage {get;set;}
    @TestVisible private static boolean isValidUser {get;set;}
    public static  boolean isPartnerUser {get;set;}
    public static boolean isCustomerUser {get;set;}
    public static boolean incorrectPortalUser {get;set;}
    @TestVisible private static boolean isMultiUser {get;set;}
    @TestVisible private static boolean isNotAnUser {get;set;}
    @TestVisible private static boolean isEmailSentToPortalUser{get;set;}
    
    
    global class ForgotPasswordConfirmWrapper {
        PageReference objPR;
        String errorMsg;
        Boolean isError;
        Boolean isIncorrectPortalUser;
        public ForgotPasswordConfirmWrapper() {
        }
    }
    
    global NV_ForgotPasswordController() {
        string userNameFromURL = Apexpages.currentpage().getParameters().get('username');
        if (userNameFromURL != null || userNameFromURL != ''){
            username = userNameFromURL;
        }
        
        if(Apexpages.currentpage().getParameters().get('incorrectPortal')=='true'){
            strErrorMsg = System.Label.COMM_LOGIN_MSG_Redirection;
        }
        
        //Collect the parameters or build it in case of exceptions
        fromPage = Apexpages.currentpage().getParameters().get('FromPage');
        if (fromPage == 'qpp'){
            orgID = [Select Id FROM Organization LIMIT 1].Id;
            //orgURL = Customer_Portal_QPP__c.getOrgDefaults().ORG_URL__c;
            PortalID = Customer_Portal_QPP__c.getOrgDefaults().ID__c;
            PortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
            PortalForgotPwdUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_PWD_URL__c;
        } else if (fromPage == 'partner'){
            orgID           = [Select Id FROM Organization LIMIT 1].Id;
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            //orgUrl = constantFields.get('OrgUrl').Values__c;
            PortalID = constantFields.get('PRMPortalId').Values__c;
            portalLoginUrl = constantFields.get('CommunityLoginURL').Values__c;
            PortalForgotPwdUrl = constantFields.get('CommunityForgotPWDURL').Values__c;
        }
        
    }
    
    @RemoteAction    
    global static ForgotPasswordConfirmWrapper forgotPassword(String uname, String strPortalLoginURL, String strPortalId, String strPortalForgotPwdUrl, String strOrgId, String strFromPage) {
        ForgotPasswordConfirmWrapper objForgotPasswordConfirmWrapper = new ForgotPasswordConfirmWrapper();
        try{
            
            if(uname != null && uname.trim() != ''){
                //Redirect the user to correct Forgot Password page with message
                isValidUser = false;
                isPartnerUser = false;
                isCustomerUser = false;
                isMultiUser = false;
                isNotAnUser = false;
                isEmailSentToPortalUser = false;
                incorrectPortalUser = false;
                
                list<User> lstUsers = [Select Name, UserName, ProfileId From User Where (UserName = :uname Or email = :uname) And IsActive = true And ContactId != null];
                
                if ( !lstUsers.isEmpty() && lstUsers.size() > 1){
                    isMultiUser = true;
                } else if (!lstUsers.isEmpty() && lstUsers.size() == 1){
                	//2017.03.24 - Partner Community Named/Login license rollout     
                    //List<Profile> lstPartnerProfs = [SELECT UserLicense.Name FROM Profile Where Id = :lstUsers[0].ProfileId And UserLicense.name = :COMM_Constants.USERLICENSE_PP_GP];
                    List<Profile> lstPartnerProfs = [SELECT UserLicense.Name FROM Profile Where Id = :lstUsers[0].ProfileId And UserType = :COMM_Constants.USER_USERTYPE_POWERPARTNER];
                    List<Profile> lstCustomerProfs = [SELECT UserLicense.Name FROM Profile Where Id = :lstUsers[0].ProfileId And (UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC Or UserLicense.name = :NV_Constants.USERLICENSE_CP_CCPL)];
                    system.debug(lstPartnerProfs +'=='+fromPage);
                    if ((lstPartnerProfs != null && !lstPartnerProfs.isEmpty()) || (lstCustomerProfs != null && !lstCustomerProfs.isEmpty()) ){
                        isValidUser = true; 
                    }
                    /*else if (lstPartnerProfs != null && !lstPartnerProfs.isEmpty() && strFromPage == 'qpp'){
                        //Partner User but came from QPP login
                        //Redirect it to Partner Login with Error Message
                        isPartnerUser = true;
                        incorrectPortalUser = true;
                        strOrgID            = [Select Id FROM Organization LIMIT 1].Id;
                        Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
                        strPortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
                        strPortalID = constantFields.get('PRMPortalId').Values__c;
                        strPortalLoginUrl = constantFields.get('PrmPortalLoginUrl').Values__c;
                        strPortalForgotPwdUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
                        strFromPage = 'partner';
                    } else if (lstCustomerProfs != null && !lstCustomerProfs.isEmpty() && strFromPage == 'partner'){
                        //Customer User but came from Partner login
                        //Redirect it to Customer Login with Error Message
                        isCustomerUser = true;
                        incorrectPortalUser = true;
                        strOrgID            = [Select Id FROM Organization LIMIT 1].Id;
                        strPortalID        = Customer_Portal_QPP__c.getOrgDefaults().ID__c;
                        strPortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
                        strPortalForgotPwdUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_PWD_URL__c;
                        strFromPage = 'qpp';
                        isValidUser = true; 
                    } */
                    
                } else{
                    isNotAnUser = true;
                } 
                
                //set the messages and login url 
                //-------------------------------------
                if (isValidUser){
                    string strUserName = lstUsers[0].UserName;
                    boolean success = Site.forgotPassword(strUserName);
                    isEmailSentToPortalUser = true; //assume it got sent as SFDC does return anything from forgotPassword method
                    PageReference pr = Page.NV_ForgotPasswordConfirmation;
                    pr.setRedirect(true);
                    pr.getParameters().put('retUrl', strPortalLoginURL);
                    objForgotPasswordConfirmWrapper.objPR = pr;
                    objForgotPasswordConfirmWrapper.isError= false;
                    return objForgotPasswordConfirmWrapper;
                    
                } else{
                    //PageReference pr = Page.ForgotPassword;
                    PageReference pr = new PageReference(strPortalForgotPwdUrl);
                    pr.setRedirect(true);
                    pr.getParameters().put('retUrl', strPortalLoginUrl);
                    pr.getParameters().put('orgId', strOrgID);
                    pr.getParameters().put('portalId', strPortalId);
                    pr.getParameters().put('FromPage', strFromPage);
                    pr.getParameters().put('UserName', uname);
                    /*if(incorrectPortalUser) {
                        pr.getParameters().put('incorrectPortal', 'true');
                        objForgotPasswordConfirmWrapper.objPR = pr;
                        objForgotPasswordConfirmWrapper.isError= true;
                        objForgotPasswordConfirmWrapper.isIncorrectPortalUser = true;
                        objForgotPasswordConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Redirection;
                    }else*/
                    if (isMultiUser){
                        objForgotPasswordConfirmWrapper.objPR = pr;
                        objForgotPasswordConfirmWrapper.isError= true;
                        objForgotPasswordConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Multi_User;
                    } else if (isNotAnUser){
                        objForgotPasswordConfirmWrapper.objPR = pr;
                        objForgotPasswordConfirmWrapper.isError= true;
                        objForgotPasswordConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Invalid_User;
                    } else{
                        objForgotPasswordConfirmWrapper.objPR = pr;
                        objForgotPasswordConfirmWrapper.isError= true;
                        objForgotPasswordConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Forgot_Password_Err_Msg;
                    }                   
                    return objForgotPasswordConfirmWrapper;
                }
                //-------------------------------------
                
            }  else {
                objForgotPasswordConfirmWrapper.isError= true;
                objForgotPasswordConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Required_field_Username_or_Email; 
                return objForgotPasswordConfirmWrapper;    
            }
            
        }catch(exception ex){
            objForgotPasswordConfirmWrapper.isError= true;
            objForgotPasswordConfirmWrapper.errorMsg = ex.getMessage(); 
            return objForgotPasswordConfirmWrapper; 
        }
        return null;
    }
}