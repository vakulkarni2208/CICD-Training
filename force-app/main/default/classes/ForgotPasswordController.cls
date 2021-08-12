/**
 * An apex page controller that exposes the site forgot password functionality
 */
public class ForgotPasswordController {
    public String username {get; set;}   
    public String orgID {get; set;}
    public String PortalID {get; set;}
    public String PortalLoginURL {get; set;}
    public string PortalForgotPwdUrl {get;set;}
    public string fromPage {get;set;}
    @TestVisible private static boolean isValidUser {get;set;}
    private boolean isPartnerUser {get;set;}
    private boolean isCustomerUser {get;set;}
	@TestVisible private static boolean isMultiUser {get;set;}
	@TestVisible private static boolean isNotAnUser {get;set;}
	@TestVisible private static boolean isEmailSentToPortalUser{get;set;}
		
    public ForgotPasswordController() {
    	string userNameFromURL = Apexpages.currentpage().getParameters().get('username');
    	if (userNameFromURL != null || userNameFromURL != ''){
    		username = userNameFromURL;
    	}
    	
    	string showMessageFromURL = Apexpages.currentpage().getParameters().get('ShowMessage');
    	if (showMessageFromURL != null || showMessageFromURL == 'true'){
    		//string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Password_Err_Msg__c;
    		string errMsg = System.Label.COMM_LOGIN_MSG_Forgot_Password_Err_Msg;
    		ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
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
    	
    	
    	//Collect the parameters or build it in case of exceptions
    	fromPage = Apexpages.currentpage().getParameters().get('FromPage');
    	if (fromPage == 'qpp'){
			orgID = [Select Id FROM Organization LIMIT 1].Id;
        	//orgURL = Customer_Portal_QPP__c.getOrgDefaults().ORG_URL__c;
        	PortalID = Customer_Portal_QPP__c.getOrgDefaults().ID__c;
        	PortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
        	PortalForgotPwdUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_PWD_URL__c;
    	} else if (fromPage == 'partner'){
    		orgID			= [Select Id FROM Organization LIMIT 1].Id;
			Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
			PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
			//orgUrl = constantFields.get('OrgUrl').Values__c;
	    	PortalID = constantFields.get('PRMPortalId').Values__c;
	    	portalLoginUrl = constantFields.get('PrmPortalLoginUrl').Values__c;
	    	PortalForgotPwdUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
    	}
    	
    }
        
	public PageReference forgotPassword() {
		try{
			if(username != null && username.trim() != ''){
				//Redirect the user to correct Forgot Password page with message
				isValidUser = false;
				isPartnerUser = false;
				isCustomerUser = false;
				isMultiUser = false;
				isNotAnUser = false;
				isEmailSentToPortalUser = false;
				
				list<User> lstUsers = [Select Name, UserName, ProfileId From User Where (UserName = :username Or email = :username) And IsActive = true And ContactId != null];
				
		        if ( !lstUsers.isEmpty() && lstUsers.size() > 1){
		        	isMultiUser = true;
		        } else if (!lstUsers.isEmpty() && lstUsers.size() == 1){        		
					List<Profile> lstPartnerProfs = [SELECT UserLicense.Name FROM Profile Where Id = :lstUsers[0].ProfileId And UserLicense.name = :COMM_Constants.USERLICENSE_PP_GP];
			       	List<Profile> lstCustomerProfs = [SELECT UserLicense.Name FROM Profile Where Id = :lstUsers[0].ProfileId And UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC];
				    
				    if ((lstPartnerProfs != null && !lstPartnerProfs.isEmpty() && fromPage == 'partner') || (lstCustomerProfs != null && !lstCustomerProfs.isEmpty() && fromPage == 'qpp') ){
				    	isValidUser = true; 
				    }
				    else if (lstPartnerProfs != null && !lstPartnerProfs.isEmpty() && fromPage == 'qpp'){
				       	//Partner User but came from QPP login
				       	//Redirect it to Partner Login with Error Message
				       	isPartnerUser = true;
				       	orgID			= [Select Id FROM Organization LIMIT 1].Id;
				       	Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
				       	PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
	    				PortalID = constantFields.get('PRMPortalId').Values__c;
	    				portalLoginUrl = constantFields.get('PrmPortalLoginUrl').Values__c;
	    				PortalForgotPwdUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
	    				fromPage = 'partner';
				    } else if (lstCustomerProfs != null && !lstCustomerProfs.isEmpty() && fromPage == 'partner'){
				    	//Customer User but came from Partner login
				    	//Redirect it to Customer Login with Error Message
				    	isCustomerUser = true;
				       	orgID			= [Select Id FROM Organization LIMIT 1].Id;
        				PortalID        = Customer_Portal_QPP__c.getOrgDefaults().ID__c;
        				PortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
        				PortalForgotPwdUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_PWD_URL__c;
        				fromPage = 'qpp';
					} 
					
				} else{
					isNotAnUser = true;
				} 
		        
		        //set the messages and login url 
		        //-------------------------------------
				if (isValidUser){
					string strUserName = lstUsers[0].UserName;
			       	boolean success = Site.forgotPassword(strUserName);
			       	isEmailSentToPortalUser = true; //assume it got sent as SFDC does return anything from forgotPassword method
					PageReference pr = Page.ForgotPasswordConfirm;
		        	pr.setRedirect(true);
		        	pr.getParameters().put('retUrl', PortalLoginURL);
		           	return pr;
			    } else{
			       	//PageReference pr = Page.ForgotPassword;
			       	PageReference pr = new PageReference(PortalForgotPwdUrl);
		        	pr.setRedirect(true);
		        	pr.getParameters().put('retUrl', portalLoginUrl);
		        	pr.getParameters().put('orgId', orgID);
		        	pr.getParameters().put('portalId', portalId);
		        	pr.getParameters().put('FromPage', fromPage);
		        	if (isMultiUser){
		        		pr.getParameters().put('ShowMultiUserMessage', 'true');
		        	} else if (isNotAnUser){
		        		pr.getParameters().put('ShowNoUserMessage', 'true');
		        	} else{
		        		pr.getParameters().put('ShowMessage', 'true');
		        	}
		        	pr.getParameters().put('UserName', username);
					return pr;
			    }
			    //-------------------------------------
				
			}  else {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, System.label.COMM_LOGIN_MSG_Required_field_Username_or_Email);
				ApexPages.addMessage(myMsg);             
				return null;    
			}
			
		}catch(exception ex){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
			ApexPages.addMessage(myMsg);  
			return null;
		}
		return null;
	}
   
}