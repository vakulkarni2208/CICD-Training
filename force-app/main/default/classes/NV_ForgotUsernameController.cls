/*

	//2017.03.24 - Partner Community Named/Login license rollout
*/
global class NV_ForgotUsernameController {
    public string email {get; set;}
    public string PortalForgotUserNameUrl {get;set;}
    public string portalLoginUrl {get;set;}
    public string fromPage {get;set;}
    @TestVisible private static boolean isCustomerUser {get;set;}
	@TestVisible private static boolean isMultiCustomerUser {get;set;}
	@TestVisible private static boolean isPartnerUser {get;set;}
	@TestVisible private static boolean isMultiPartnerUser {get;set;}
	@TestVisible private static boolean isEmailSentToPortalUser{get;set;}
	@TestVisible private static boolean isEmailSentNVPartnerAdmin{get;set;}
	
	global class ForgotUsernameConfirmWrapper {
		PageReference objPR;
		String errorMsg;
		Boolean isError;
		Boolean isIncorrectPortalUser;
		public ForgotUsernameConfirmWrapper() {
		}
	}
	
	global NV_ForgotUsernameController(){
		
    	//Collect the parameters or build it in case of exceptions
    	fromPage = Apexpages.currentpage().getParameters().get('FromPage');
    	email = Apexpages.currentpage().getParameters().get('email');
    	
    	string showMessageFromURL = Apexpages.currentpage().getParameters().get('nousersmsg');
    	if (showMessageFromURL != null || showMessageFromURL == 'true'){
    		//string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Username_NoUser_Err_Msg__c;
    		string errMsg = System.Label.COMM_LOGIN_MSG_Invalid_User;
    		ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
        	ApexPages.addMessage(errMessage);
    	}
    	
    	string showCustomerMessageFromURL = Apexpages.currentpage().getParameters().get('customerusermsg');
    	if (showCustomerMessageFromURL != null || showCustomerMessageFromURL == 'true'){
    		//string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Username_SingleUser_Err_Msg__c;
    		string errMsg = System.Label.COMM_LOGIN_MSG_Forgot_Username_Email_Sent;
    		ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.Info, errMsg);
        	ApexPages.addMessage(errMessage);
    	}
    	
    	string showPartnerMessageFromURL = Apexpages.currentpage().getParameters().get('partnerusermsg');
    	if (showPartnerMessageFromURL != null || showPartnerMessageFromURL == 'true'){
    		//string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Username_SingleUser_Err_Msg__c;
    		string errMsg = System.Label.COMM_LOGIN_MSG_Forgot_Username_Email_Sent;
    		ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.Info, errMsg);
        	ApexPages.addMessage(errMessage);
    	}
    	
    	string showMultiUserMessageFromURL = Apexpages.currentpage().getParameters().get('multiusermsg');
    	if (showMultiUserMessageFromURL != null || showMultiUserMessageFromURL == 'true'){
    		//string errMsg = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Username_MultiUser_Err_Msg__c;
    		string errMsg = System.Label.COMM_LOGIN_MSG_Forgot_Username_Multi_User_Err;
    		ApexPages.Message errMessage = new ApexPages.Message(ApexPages.Severity.Info, errMsg);
        	ApexPages.addMessage(errMessage);
    	}
    	
    	//Set the URLs from Custom Settings
    	if (fromPage == 'qpp'){
        	PortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
        	PortalForgotUserNameUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_UserName_URL__c;
    	} else if (fromPage == 'partner'){
    		Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
	    	PortalLoginURL = constantFields.get('CommunityLoginURL').Values__c;
	    	PortalForgotUserNameUrl = constantFields.get('CommunityForgotUserNameURL').Values__c;
    	}
    	
	}
	
	@RemoteAction
	global static ForgotUsernameConfirmWrapper forgotUsername(String email, String strPortalLoginURL, String strPortalForgotUserNameUrl, String strFromPage) {
		
		ForgotUsernameConfirmWrapper objForgotUsernameConfirmWrapper = new ForgotUsernameConfirmWrapper();
		//set the flags to false
		isCustomerUser = false;
		isMultiCustomerUser = false;
		isPartnerUser = false;
		isMultiPartnerUser = false;
		isEmailSentToPortalUser = false;
		isEmailSentNVPartnerAdmin = false;
				
		try{
				
				list<User> lstCustomerUsers;
				list<User> lstPartnerUsers;
				
				lstCustomerUsers = [Select Username, FirstName, LastName, Email, ContactId, Profile.Name From User Where email = :email And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where (UserLicense.name = :COMM_Constants.USERLICENSE_CP_OCPMC Or UserLicense.name = :NV_Constants.USERLICENSE_CP_CCPL))];
				system.debug('lstCustomerUsers ->'+lstCustomerUsers);
				//2017.03.24 - Partner Community Named/Login license rollout
				//lstPartnerUsers = [Select Username, FirstName, LastName, Email, ContactId, Profile.Name From User Where email = :email And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :COMM_Constants.USERLICENSE_PP_GP)];
				lstPartnerUsers = [Select Username, FirstName, LastName, Email, ContactId, Profile.Name From User Where email = :email And IsActive = true And ContactId != null And ProfileId in (SELECT Id FROM Profile Where UserType = :COMM_Constants.USER_USERTYPE_POWERPARTNER)];
				system.debug('lstPartnerUsers ->'+lstPartnerUsers);
				if (lstCustomerUsers != null && lstCustomerUsers.size() == 1){
					isCustomerUser = true;
				} else if (lstCustomerUsers != null && lstCustomerUsers.size() > 1){
					isMultiCustomerUser = true;
				}

				if (lstPartnerUsers != null && lstPartnerUsers.size() == 1){
					isPartnerUser = true;
				} else if (lstPartnerUsers != null && lstPartnerUsers.size() > 1){
					isMultiPartnerUser = true;
				}

				PageReference pr = new PageReference(strPortalForgotUserNameUrl);
	        	pr.setRedirect(true);
	        	pr.getParameters().put('FromPage', strFromPage);
	        	pr.getParameters().put('email', email);
	        	pr.getParameters().put('retUrl', strPortalLoginUrl);
	        	
				if (isCustomerUser && !isPartnerUser){
	        		pr.getParameters().put('customerusermsg', 'true');
	        		objForgotUsernameConfirmWrapper.isError = true;
	        		objForgotUsernameConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Forgot_Username_Email_Sent;
	        		//send email
	        		//----------------------------------------
	        		EmailWhatId_Helper__c tempAcc;
	        		try{
	        			//create a temp account and fill the details like First Name and Username in EmailWhatId_Helper__c's FirstName and UserName fields
	        			//This will be used in Email Template as merge fields
		        		tempAcc = new EmailWhatId_Helper__c();
		        		tempAcc.FirstName__c = lstCustomerUsers[0].FirstName;
		        		tempAcc.UserName__c = lstCustomerUsers[0].UserName;
		        		insert tempAcc;
		        		
			        	Contact userContact = [Select LastName, FirstName, Email From Contact Where id = :lstCustomerUsers[0].ContactId];
			        		
			        	List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
			        	Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
			        	string strCustomerUserEmailTemplate = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Username_Customer_Email_Template__c;
						msg.setTemplateId( [select id from EmailTemplate where DeveloperName= :strCustomerUserEmailTemplate].id );
						
						msg.setWhatId(tempAcc.Id);
						
						msg.setTargetObjectId(userContact.Id);
						msg.setSaveAsActivity(false);
						lstMsgs.add(msg);
						Messaging.sendEmail(lstMsgs);
						
						isEmailSentToPortalUser = true;
						
						//delete the temp EmailWhatId_Helper
						delete tempAcc;
						
	        		} catch (Exception ex){
	        			//Delete the EmailWhatId_Helper which could not have been deleted because of exceptions during send email process 
	        			if (tempAcc != null && tempAcc.Id != null){
	        				list<EmailWhatId_Helper__c> lstTempAccount = [Select Id From EmailWhatId_Helper__c Where Id = :tempAcc.Id];
	        				list<Database.DeleteResult> lstDR = Database.delete(lstTempAccount);
	        			}
	        		}
					//----------------------------------------
					
				} else if (isPartnerUser && !isCustomerUser){
	        		pr.getParameters().put('partnerusermsg', 'true');
	        		objForgotUsernameConfirmWrapper.isError = true;
	        		objForgotUsernameConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Forgot_Username_Email_Sent;
					//send email
	        		//----------------------------------------
	        		EmailWhatId_Helper__c tempAcc;
	        		try{
	        			//create a temp EmailWhatId_Helper__c and fill the details like First Name and Username in EmailWhatId_Helper__c's FirstName and UserName fields
	        			//This will be used in Email Template as merge fields
	        			tempAcc = new EmailWhatId_Helper__c();
	        			tempAcc.FirstName__c = lstPartnerUsers[0].FirstName;
	        			tempAcc.UserName__c = lstPartnerUsers[0].UserName;
	        			insert tempAcc;

			        	Contact userContact = [Select LastName, FirstName, Email From Contact Where id = :lstPartnerUsers[0].ContactId];
			        		
			        	List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
			        	Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
			        	
		        		string strPartnerUserEmailTemplate = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Username_Partner_Email_Template__c;
						msg.setTemplateId( [select id from EmailTemplate where DeveloperName= :strPartnerUserEmailTemplate].id );
						
						msg.setWhatId(tempAcc.Id);
						
						msg.setTargetObjectId(userContact.Id);
						msg.setSaveAsActivity(false);
						lstMsgs.add(msg);
						Messaging.sendEmail(lstMsgs);
						
						isEmailSentToPortalUser = true;
						
						//delete the temp EmailWhatId_Helper
						delete tempAcc;
						
	        		} catch (Exception ex){
	        			//Delete the EmailWhatId_Helper which could not have been deleted because of exceptions during send email process 
	        			if (tempAcc != null && tempAcc.Id != null){
	        				list<EmailWhatId_Helper__c> lstTempAccount = [Select Id From EmailWhatId_Helper__c Where Id = :tempAcc.Id];
	        				list<Database.DeleteResult> lstDR = Database.delete(lstTempAccount);
	        			}
	        		}
					//----------------------------------------
				} else if (!isCustomerUser && !isMultiCustomerUser && !isPartnerUser && !isMultiPartnerUser){
	        		pr.getParameters().put('nousersmsg', 'true');
	        		objForgotUsernameConfirmWrapper.isError = true;
	        		objForgotUsernameConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Invalid_User;
				} else if (isMultiCustomerUser || isMultiPartnerUser || (isPartnerUser && isCustomerUser)) {
	        		pr.getParameters().put('multiusermsg', 'true');
	        		objForgotUsernameConfirmWrapper.isError = true;
	        		objForgotUsernameConfirmWrapper.errorMsg = System.Label.COMM_LOGIN_MSG_Forgot_Username_Multi_User_Err;
	        		
	        		//send email
	        		//----------------------------------------
	        		//Get all the Contact Ids. we need it to query their Accounts along with other Contact fields
	        		set<Id> setPartnerAndCustomerUsers = new set<Id>();
	        		map<id, string> mapContactIdUserName = new map<Id, string>();
	        		//map<id, string> mapContactIdUserLicenseName = new map<Id, string>();
	        		map<id, string> mapContactIdUserProfileName = new map<Id, string>();
	        		
	        		for (User partnerUser : lstPartnerUsers){
	        			setPartnerAndCustomerUsers.add(partnerUser.ContactId);
	        			mapContactIdUserName.put(partnerUser.ContactId, partnerUser.userName);
	        			//mapContactIdUserLicenseName.put(partnerUser.ContactId, COMM_Constants.USERLICENSE_PP_GP);
	        			mapContactIdUserProfileName.put(partnerUser.ContactId, partnerUser.Profile.Name);
	        		}
	        		for (User customerUser : lstCustomerUsers){
	        			setPartnerAndCustomerUsers.add(customerUser.ContactId);
	        			mapContactIdUserName.put(customerUser.ContactId, customerUser.userName);
	        			//mapContactIdUserLicenseName.put(customerUser.ContactId, COMM_Constants.USERLICENSE_CP_OCPMC);
	        			mapContactIdUserProfileName.put(customerUser.ContactId, customerUser.Profile.Name);
	        		}
	        		
	        		list<Contact> lstPortalContacts = [	Select LastName, FirstName, Email, Account.Name 
	        											From Contact 
	        											Where Id = :setPartnerAndCustomerUsers];

	        		if (lstPortalContacts != null && !lstPortalContacts.isEmpty()){
	        			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        			//get the NVIDIA Partner Admin email address from custom settings
		        		string strPartnerAdminEmail = Customer_Portal_QPP__c.getOrgDefaults().Forgot_Username_Email_PartnerAdmin__c;
		        		List<String> sendTo = new List<String>();
						sendTo.add(strPartnerAdminEmail);
						mail.setToAddresses(sendTo);
						mail.setSubject('Multiple Portal Users found for Email: ' + email);
		        		
		        		string strHTMLBody = '<br/><br/><table width="80%"><tr><td width="15%"><b>Email</b></td><td width="15%"><b>UserName</b></td><td width="20%"><b>Profile</b></td><td width="10%"><b>FirstName</b></td><td width="10%"><b>LastName</b></td><td width="20%"><b>Account</b></td></tr>';  
		        		
	        			for (Contact con : lstPortalContacts) {  
				            strHTMLBody += '<tr>' + '<td>' + con.email + '</td>' + '<td>' + mapContactIdUserName.get(con.Id) + '</td>' + '<td>' + mapContactIdUserProfileName.get(con.Id) + '</td>' + '<td>' + con.firstName + '</td>' + '<td>' + con.lastName + '</td>' + '<td>' + con.Account.Name + '</td>' + '</tr>';
						}
						strHTMLBody += '</table>';
						mail.setHtmlbody(strHTMLBody);
						Messaging.sendEmail(new Messaging.SingleEmailmessage[] {mail});
						isEmailSentNVPartnerAdmin = true;
	        		}
	        		//----------------------------------------
				}
				objForgotUsernameConfirmWrapper.objPR = pr;
				return objForgotUsernameConfirmWrapper;
		}catch(exception ex){
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
			objForgotUsernameConfirmWrapper.isError = true;
			objForgotUsernameConfirmWrapper.errorMsg = ex.getMessage();
			return objForgotUsernameConfirmWrapper;
		}
		
	}
}