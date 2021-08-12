public without sharing class NPN_WidenPageRedirect_Ctrl {

public String baseURL {get; set;}
public String finalEncodedURL {get; set;}
public String company {get; set;}
public String email {get; set;}
public String firstName {get; set;}
public String guid {get; set;}
public String lastName {get; set;}
public String redirectionURL {get; set;}
public String signature {get; set;}
public String timeStamp {get; set;}
public String username {get; set;}
public String sharedSecret {get; set;}
public String roles {get; set;}
public String iFrameURL {get; set;}
public String encodedTimeStamp {get; set;}
public String encodedRedirectURL {get; set;}
public String errorMsg {get; set;}
public boolean displayPopup {get; set;}
public boolean isTegraPartner {get; set;}

public NPN_WidenPageRedirect_Ctrl() {

	String sharedSecret_BKP = '5e6a59fb-9f1d-4678-ab6b-07ca3fae70cf';   // Convert in the custom metadata
	String baseURL_BKP ='https://nvdam.nvidia.com/auth/simple?';        // Convert in a custom metadata
	String redirectionURL_BKP = '/dam/dashboard';                   // Convert in a custom metadata
	String andStr = 'and';          // Added for SDS-2820


	Map<String, String> widenDataMap = new Map<String, String>();
	for(NPN_Widen_Data__mdt wdnObj : [SELECT Id, DeveloperName, Value__c FROM NPN_Widen_Data__mdt]) {
		widenDataMap.put(wdnObj.DeveloperName, wdnObj.Value__c);
	}

	sharedSecret    = String.isNotBlank(widenDataMap.get('Shared_Secret')) ? widenDataMap.get('Shared_Secret') : sharedSecret_BKP;
	baseURL         = String.isNotBlank(widenDataMap.get('Base_URL')) ? widenDataMap.get('Base_URL') : baseURL_BKP;
	errorMsg        = widenDataMap.get('Error_Message');


	roles           = '';
	company         = '';

	if(String.isNotBlank(ApexPages.currentPage().getParameters().get('redirect_url'))) {
		redirectionURL = ApexPages.currentPage().getParameters().get('redirect_url').trim();
		redirectionURL = redirectionURL.replaceAll('\\s+','%20');
	}else{

		redirectionURL = String.isNotBlank(widenDataMap.get('Default_Redirection_URL')) ? widenDataMap.get('Default_Redirection_URL') : redirectionURL_BKP;
	}

	Contact partnerContact;

	String tegraProfileName = 'NPN Tegra Jetson Partner Community(LOGIN)';
	//partnerContact = [SELECT Id, Portal_Groups__c FROM Contact WHERE Community_User__c = :UserInfo.getUserId()];

	isTegraPartner = false;
	if(partnerContact == null) {
		User partnerUser = [SELECT Id, ContactId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
		partnerContact = [SELECT Id, Portal_Groups__c, Account.Name FROM Contact WHERE Id = :partnerUser.ContactId];

		if(tegraProfileName.equalsIgnoreCase(partnerUser.Profile.Name)) {
			isTegraPartner = true;
		}
	}
	//String orString ='%20or%20';

	if(partnerContact != null) {

		Set<String> pgValueSet = new Set<String>();
		if(String.isNotBlank(partnerContact.Portal_Groups__c)) {
			for(String pgVal : partnerContact.Portal_Groups__c.split(';')) {
				pgValueSet.add(pgVal.trim());
			}
		}

		system.debug('***** pgValueSet.size(): '+ pgValueSet.size() +'pgValueSet: '+pgValueSet);

		if(!pgValueSet.isEmpty()) {
			for(NPN_Widen_Role_Mapping__c roleObj : [SELECT Id,Name,Widen_Role__c FROM NPN_Widen_Role_Mapping__c WHERE Name IN :pgValueSet]) {
				roles += roleObj.Widen_Role__c+',';
			}
			roles = roles.removeEnd(',');

			system.debug('***** inside if roles: '+ roles);
		}

		company = String.isNotBlank(partnerContact.Account.Name) ? partnerContact.Account.Name.contains('&') ? partnerContact.Account.Name.replace('&', andStr) : partnerContact.Account.Name : '';

	}else{
		System.debug(LoggingLevel.ERROR, 'The current logged in user is not a partner user.');
	}

	system.debug('***** company: '+ company);
	system.debug('***** roles: '+ roles);
	system.debug('***** redirectionURL: '+ redirectionURL);

	if(String.isBlank(roles)) {
		finalEncodedURL = '';
		showPopup();
	}else{
		signature = '';
		timeStamp = System.now().formatGmt('EEE, d MMM yyyy HH:mm:ss z');

		// User Information
		email = UserInfo.getUserEmail();
		firstName = UserInfo.getFirstName();
		guid = UserInfo.getUserId();
		lastName = UserInfo.getLastName();
		username = UserInfo.getUserEmail();

		//Build string of all form values sorted alphabetically by key and append the shared secret.
		String signOne = company+email+firstName+guid+lastName+redirectionURL+roles+timeStamp+username+sharedSecret;

		//Calculate the MD5 hash of the concatenated string.This is the signature submitted with the request
		system.debug(signOne);
		Blob myBlob = Blob.valueOf(signOne);
		system.debug(myBlob);
		Blob md5hash = Crypto.generateDigest('MD5', myBlob);
		signature =EncodingUtil.convertToHex(md5hash);
		System.debug(md5hash);
		System.debug(signature);

		encodedTimeStamp= EncodingUtil.urlEncode(timeStamp, 'UTF-8');
		encodedRedirectURL = EncodingUtil.urlEncode(redirectionURL, 'UTF-8');


		String finalURL = 'timestamp='+encodedTimeStamp+
		                  '&signature='+signature+
		                  '&guid='+guid+
		                  '&company='+company+
		                  '&email='+email+
		                  '&username='+username+
		                  '&first_name='+firstName+
		                  '&last_name='+lastName+
		                  '&roles='+roles+
		                  '&redirection_url='+encodedRedirectURL;

		System.debug('finalURL :: '+finalURL);

		finalEncodedURL = finalURL;
		System.debug('finalEncodedURL :: '+finalEncodedURL);

		iFrameURL = baseURL+finalEncodedURL;
		System.debug('::: WIDEN LINK ::: '+ iFrameURL);
	}
}


/**
 * showPopup description
 */
public void showPopup() {
	displayPopup = true;
}

/**
 * @name closePopup
 */
public PageReference closePopup() {
	displayPopup = false;

	String tegraHomePage = '/apex/NV_PartnerCommunityHomePage';
	String ltngHomePage ='/apex/NV_Ltg_PartnerCommunityHomePage';

	String redirectPageStr = isTegraPartner ? tegraHomePage : ltngHomePage;

	PageReference page = new PageReference(redirectPageStr);
	page.setRedirect(true);
	return page;
}

public PageReference redirect(){

	if(String.isNotBlank(finalEncodedURL)) {
		PageReference request = new PageReference(baseURL+finalEncodedURL);
		return request;
	}else{
		//PageReference request = new PageReference('/apex/NV_Ltg_PartnerCommunityHomePage');
		//return request;
		return null;
	}
}
}