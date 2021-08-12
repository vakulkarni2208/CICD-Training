/*
	NPN IDM
	2017.09.12 - pjena - Wrapper class for IDM Calls
	2018.03.22 - pjena - initialize the map before walk-thru of the xml response mapIDMResponseElements
	2018.03.29 - pjena 	- Changes related to Service Cloud -	Do not invoke IDM API calls if you find there is any active Service Cloud users
						- Used CDATA section in the company name for escaping XML special characters
						- Used the IDM_API_Call_Failure__c = false, so if the failure happens for whatever reason the IDM API call will not happen for that user again
	2019.09.04 - pjena - LICENSING-186 (SDS-1663) - Update NPN Partner onboarding API to pass Country code to IDM. Ex: CN, US, DE..
*/

public class SOCRM_IDM_Wrapper {
	
	public class IdmRequest{
		public string sfdcUserId;
		public string emailAddress;
		public string firstName;
		public string lastName;
		public string company;
		public string industry;
		public string jobRole;
		public string street1;
		public string street2;
		public string state;
		public string postalCode;
		public string country;
		public string idmRole;
		public string langCode;
		public string emailTemplateCategory;
		public string phone;
		public string userName;
		public string city;
		public string isActive;
	}
	
	public class IdmResponse{
		public string x_sfdcUserId;
		public integer x_isAPICallSucceeded;
		public string x_transaction; //in case of failure
		public string x_transactionId; //in case of success
		public string x_faultCode;
		public string x_code;
		public string x_faultString;
		public string x_name;
		public integer x_isApexException;
		public string x_ApexException;
	}
    
    public static map<string, string> mapIDMResponseElements = new map<string, string>();
    
    private static string getIDMEndPoint(){
    	return IDM_Settings__c.getOrgDefaults().API_endpoint__c;
    	//return 'callout:NPN_IDM_Endpoint';
    }
    
    private static integer getHTTPReqTimeout(){
    	return Integer.valueOf(IDM_Settings__c.getOrgDefaults().API_HTTPReq_timeout__c);
    }
    
    /*
    private static string getIDMAuthorization(){
    	return 'Basic ' + Encodingutil.base64Encode(Blob.valueOf(IDM_Settings__c.getOrgDefaults().API_username__c + ':' + IDM_Settings__c.getOrgDefaults().API_userpassword__c));
    }
    */   
    
	public static IdmResponse callout_CreateSOCRMIDMUser(IdmRequest oIdmReq){
		IdmResponse oIdmResponse = new IdmResponse();
		oIdmResponse.x_sfdcUserId =  oIdmReq.sfdcUserId;
		
		try{
			system.debug('***Begin: SOCRM_IDM_Wrapper > callout_CreateSOCRMIDMUser');
			system.debug('=======================================================');
			
			string CALLOUT_REQUEST_x = 	'<?xml version=\"1.0\" encoding=\"UTF-8\"?>' + 
						'<env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">' +
						'<env:Header /><env:Body><SalesOpsSFDCCreateUser xmlns="http://tews6/wsdl">' +
						'<SalesOpsSFDCCreateUserObjectProfileTab>' +
						'<_BAR_eMailAddress_BAR_>' + oIdmReq.emailAddress + '</_BAR_eMailAddress_BAR_>' + 
						'<_BAR_firstName_BAR_><![CDATA[' + oIdmReq.firstName + ']]></_BAR_firstName_BAR_>' + 
						'<_BAR_lastName_BAR_><![CDATA[' + oIdmReq.lastName + ']]></_BAR_lastName_BAR_>'+ 
						'<_BAR_company_BAR_><![CDATA[' + oIdmReq.company + ']]></_BAR_company_BAR_>' + 
						'<_BAR_industry_BAR_>' + oIdmReq.industry + '</_BAR_industry_BAR_>' + 
						'<_BAR_jobRole_BAR_>' + oIdmReq.jobRole + '</_BAR_jobRole_BAR_>' + 
						'<_BAR_street1_BAR_>' + oIdmReq.street1 + '</_BAR_street1_BAR_>' + 
						'<_BAR_street2_BAR_>' + oIdmReq.street2 + '</_BAR_street2_BAR_>' + 
						'<_BAR_state_BAR_>' + oIdmReq.state + '</_BAR_state_BAR_>' + 
						'<_BAR_postalCode_BAR_>' + oIdmReq.postalCode + '</_BAR_postalCode_BAR_>' + 
						'<_BAR_country_BAR_>' + oIdmReq.country + '</_BAR_country_BAR_>' + 
						'<_BAR_sfdcRole_BAR_>' + oIdmReq.idmRole + '</_BAR_sfdcRole_BAR_>' + 
						'<_BAR_gridEval_BAR_></_BAR_gridEval_BAR_>' + 
						'<_BAR_language_BAR_>' + oIdmReq.langCode + '</_BAR_language_BAR_>' + 
						'<_BAR_sfdcMailTemplate_BAR_>' + oIdmReq.emailTemplateCategory + '</_BAR_sfdcMailTemplate_BAR_>' + 
						'<_BAR_phone_BAR_>' + oIdmReq.phone + '</_BAR_phone_BAR_>' + 
						'<_BAR_sfdcUserID_BAR_>' + oIdmReq.userName + '</_BAR_sfdcUserID_BAR_>' + 
						'<_BAR_city_BAR_>' +  oIdmReq.city + '</_BAR_city_BAR_>' + 
						'<_BAR_isActive_BAR_>' + oIdmReq.isActive + '</_BAR_isActive_BAR_>' + 
						'</SalesOpsSFDCCreateUserObjectProfileTab></SalesOpsSFDCCreateUser></env:Body></env:Envelope>';
	     	
	     	string endpoint_x = getIDMEndPoint();
			//string auth_x = getIDMAuthorization();
			integer timeout_x = getHTTPReqTimeout();
			
			system.debug('***CALLOUT_REQUEST_x: ' + CALLOUT_REQUEST_x);
			system.debug('***endpoint_x: ' + endpoint_x);
			system.debug('***timeout_x: ' + timeout_x);
	     	
	     	//Prepare the Request
	     	HttpRequest httpReq = new HttpRequest();
	     	httpReq.setEndpoint(endpoint_x);
	     	httpReq.setMethod('POST');
	     	//httpReq.setHeader('Authorization', auth_x);
	     	httpReq.setHeader('content-type', 'application/xml');
	     	httpReq.setHeader('Connection','keep-alive');
	     	httpReq.setTimeout(timeout_x);
	     	httpReq.setBody(CALLOUT_REQUEST_x);
	     	
	     	
	     	//Make the Callout
	    	Http http = new Http();
	     	HTTPResponse httpRes = http.send(httpReq);
	     	string strHttpRes = httpRes.getBody();
	     	system.debug('***strHttpRes: ' + strHttpRes);
			
			//2018.03.22
			//initialize the map before walk-thru of the xml response mapIDMResponseElements
			mapIDMResponseElements = new map<string, string>();
			
	     	//Parse the Callout Response
	     	Dom.Document docx = new Dom.Document();
	     	docx.load(strHttpRes);
	     	dom.XmlNode xroot = docx.getrootelement() ;
			walkThrough(xroot);
			system.debug('***mapIDMResponseElements:' + mapIDMResponseElements);
			
			if (mapIDMResponseElements.get('faultcode') == null){
				system.debug('***IDM User Creation Succeeded');
				oIdmResponse.x_isAPICallSucceeded = 1;
				system.debug('***mapIDMResponseElements.transactionId: ' + mapIDMResponseElements.get('transactionId'));
				oIdmResponse.x_transactionId = mapIDMResponseElements.get('transactionId');
			}else{
				system.debug('***IDM User Creation failed');
				oIdmResponse.x_isAPICallSucceeded = 0;
				system.debug('***mapIDMResponseElements.code: ' + mapIDMResponseElements.get('code'));
				oIdmResponse.x_faultCode = mapIDMResponseElements.get('faultcode');
				oIdmResponse.x_code = mapIDMResponseElements.get('code');
				system.debug('***mapIDMResponseElements.faultstring: ' + mapIDMResponseElements.get('faultstring'));
				oIdmResponse.x_faultString = mapIDMResponseElements.get('faultstring');
				system.debug('***mapIDMResponseElements.name: ' + mapIDMResponseElements.get('name'));
				oIdmResponse.x_name = mapIDMResponseElements.get('name');
				system.debug('***mapIDMResponseElements.transaction: ' + mapIDMResponseElements.get('transaction'));
				oIdmResponse.x_transaction = mapIDMResponseElements.get('transaction');
			}
	     	
	     	system.debug('***End: SOCRM_IDM_Wrapper > callout_CreateSOCRMIDMUser');
	     	system.debug('=======================================================');
	     	
		}catch(Exception ex){
     		system.debug('*********Apex Exception:' + ex);
     		oIdmResponse.x_isApexException = 1;
     		oIdmResponse.x_ApexException = 'Apex Exception::[getCause=' + ex.getCause()  + '], [ExceptionType=  ' + ex.getTypeName() +'], [message=  ' + ex.getMessage()  +'],  [StackTraceString ='+ ex.getStackTraceString();
     	}
     	return oIdmResponse;
	}
	
	//Parsing of IDM API Response
	private static void walkThrough(DOM.XMLNode node) {
		if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
			string nodeName = node.getName();
			if (node.getText().trim() != '') {
				string nodeText = node.getText().trim();
				mapIDMResponseElements.put(nodeName, nodeText);
			}
			for (Dom.XMLNode child: node.getChildElements()) {
				walkThrough(child);
			}
		}
	}
	
}