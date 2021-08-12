/**************************************************************************************************
* @name       		: NPN_NFR_DemoUnitsApprovalCtrl
* @description   	: Controller for NFR SW License Request Approval page. Created for SDS-891
***************************************************************************************************
* Author            | Created Date    | Description
***************************************************************************************************
* Rajat K           | July 31 ,2019   | Initial
**************************************************************************************************/
public without sharing class NPN_NFR_DemoUnitsApprovalCtrl {


	public String accountName {get; set;}
	public String billingAddress {get; set;}
	public String reasonForRejection {get; set;}
	public String recordId {get; set;}
	public String reqstrName {get; set;}
	public String reqstrFName {get; set;}
	public String reqstrLName {get; set;}
	public String rqstrEmail {get; set;}
	public String status {get; set;}
	public String strBillingRegion {get; set;}
	public String strPBMfullName {get; set;}
	public boolean displayPopup {get; set;}
	public boolean successPopup {get; set;}

	public NPN_NFR_Software_Request__c licenseRequest {get; set;}
	public List<SoftwareWrapper> softwareList {get; set;}
	Map<String, String> metaRecordsMap {get; set;}

	/**
	 * @name 		NPN_NFR_DemoUnitsApprovalCtrl
	 * @description controller
	 */
	public NPN_NFR_DemoUnitsApprovalCtrl(ApexPages.StandardController controller) {
		recordId = ApexPages.CurrentPage().getParameters().get('id');

		metaRecordsMap = new Map<String, String>();

		for(NPN_NFR_Request_Data__mdt mdRec : [SELECT Id, DeveloperName, MasterLabel, Value__c FROM NPN_NFR_Request_Data__mdt]) {
			metaRecordsMap.put(mdRec.DeveloperName, mdRec.Value__c);
		}

		licenseRequest = [SELECT Id, Name, Company_Name__c, Company_Name__r.Owner.Name, Company_Name__r.Name, Company_Name__r.Billing_Region__c, Address__c, Requested_By__c, Requested_By__r.Name, Requested_By__r.FirstName,Requested_By__r.LastName, Email__c, Status__c, Comments_From_PBM__c,(SELECT Id, Comments__c, NPN_NFR_Software_Request__c, Quantity__c, Software__c FROM NPN_NFR_Software__r) FROM NPN_NFR_Software_Request__c WHERE Id =:recordId];

		reqstrName = licenseRequest.Requested_By__r.Name;
		rqstrEmail = licenseRequest.Email__c;
		reqstrFName = licenseRequest.Requested_By__r.FirstName;
		reqstrLName = licenseRequest.Requested_By__r.LastName;
		accountName = licenseRequest.Company_Name__r.Name;
		billingAddress = licenseRequest.Address__c;
		status = licenseRequest.Status__c;
		strBillingRegion = licenseRequest.Company_Name__r.Billing_Region__c;
		strPBMfullName = licenseRequest.Company_Name__r.Owner.Name;

		if(!licenseRequest.NPN_NFR_Software__r.isEmpty()) {

			softwareList = new List<SoftwareWrapper>();

			for(NPN_NFR_Software__c softVar : licenseRequest.NPN_NFR_Software__r) {
				SoftwareWrapper wrpObj = new SoftwareWrapper();

				wrpObj.softwareName =   softVar.Software__c;
				wrpObj.quantity =       Integer.valueOf(softVar.Quantity__c);
				wrpObj.comments =       softVar.Comments__c;
				if(!metaRecordsMap.isEmpty() && String.isNotBlank(metaRecordsMap.get(softVar.Software__c))) {
					wrpObj.description = metaRecordsMap.get(softVar.Software__c);
				}
				wrpObj.serialNum =      softwareList.size() +1;
				softwareList.add(wrpObj);
			}
		}
	}

	/**
	 * approveRequest description
	 */
	public PageReference approveRequest(){

		PageReference docuSignPage;
		boolean isApproved = false;

		if(!'Pending'.equalsIgnoreCase(licenseRequest.Status__c)) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The request is already '+licenseRequest.Status__c.toLowerCase()+'.'));
			return null;
		}else{
			String npnOnboardingEmail = metaRecordsMap.get('NPN_Onboarding');

			licenseRequest.Status__c = 'Approved';
			try{
				update licenseRequest;
				isApproved = true;
			}catch(DmlException dme) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error updating the request : '+ dme.getMessage()));
			}

			if(isApproved) {
				notifyPricingOps();
				showSuccessPopup();
			}
		}

		return null;
	}

	/**
	 *	@name 			rejectReason
	 *	@description	displays a popup for the user to enter rejection reason.
	 */
	public void rejectReason(){

		if('Approved'.equalsIgnoreCase(licenseRequest.Status__c)  || 'Rejected'.equalsIgnoreCase(licenseRequest.Status__c)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'The request is already '+licenseRequest.Status__c.toLowerCase()+'.'));
		}else{
			showPopup();
		}
	}

	/**
	 * @name 			rejectRequest
	 * @description		Updates the status of the request to 'Rejected' and redirects to the approval page.
	 * @return			PageReference
	 */
	public PageReference rejectRequest(){

		PageReference page = new PageReference('/'+recordId);
		page.setRedirect(true);

		if('Approved '.equalsIgnoreCase(licenseRequest.Status__c)  || 'Rejected'.equalsIgnoreCase(licenseRequest.Status__c)) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The request is already'+licenseRequest.Status__c.toLowerCase()+'.'));
			return null;
		}else{
			if(String.isBlank(reasonForRejection)) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Reason cannot be blank'));
				return null;
			}else {
				licenseRequest.Comments_From_PBM__c = reasonForRejection;
				licenseRequest.Status__c = 'Rejected';
				update licenseRequest;

				displayPopup = false;
				showSuccessPopup();

				//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The request is '+licenseRequest.Status__c.toLowerCase()+'.'));
			}
		}
		//return page;
		return null;
	}


	/**
	 * showPopup description
	 */
	public void showPopup() {
		displayPopup = true;
	}

	/**
	 * showSuccessPopup description
	 */
	public void showSuccessPopup() {
		successPopup = true;
	}

	/**
	 * @name 			closePopup
	 * @description 	Close the popup and redirect to the approval page.
	 * @return 			PageReference
	 */
	public PageReference closePopup() {
		displayPopup = false;
		PageReference page = new PageReference('/apex/NPN_NFR_DemoUnitsApproval?id='+recordId);
		page.setRedirect(true);
		return page;
	}

	/**
	 * @name 			redirectHome
	 * @description 	Close the popup and redirect to the home page.
	 * @return 			PageReference
	 */
	public PageReference redirectHome() {
		successPopup = false;
		PageReference page = new PageReference ('/home/home.jsp');
		page.setRedirect(true);
		return page;
	}

	/**
	 * @name 	notifyPricingOps
	 * @Description	Sends an email notification to the Pricing Ops after PBM approves the request.
	 */
	public void notifyPricingOps (){

		if(String.isNotBlank(String.valueOf(recordId))) {

			String orgUrl =' ';
			Organization objOrg = [SELECT Id,InstanceName,IsSandbox FROM Organization];

			orgUrl = objOrg.IsSandbox ? metaRecordsMap.get('ssoUrl_Stage') : metaRecordsMap.get('ssoUrl_Prod');

			OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'no_reply@nvidia.com'];

			String pricingOpsEmail = metaRecordsMap.get('WWFO_Pricing_Operations');

			String html;
			List<String> toAddresses = new List<String> {pricingOpsEmail};
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			mail.setToAddresses(toAddresses);
			mail.setOrgWideEmailAddressId(owa.id);
			mail.setSubject('NFR SW License Request Approved');
			html = '<p>'+strPBMfullName+' has approved an NFR Request for '+accountName+'.</p>'+
			       '<p>Please click on the NVIDIA CRM (SFDC) link below to send the Order Agreement for EULA for signature via DocuSign.</p>'+
			       '<p>You will be asked to login to NVIDIA CRM (SFDC) to do this. Once logged in, click on “Send via DocuSign" then click on “Send Now”</p>'+
			       '<p>'+orgUrl+'/'+ recordId+'</p>';

			mail.setHtmlbody(html);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

	public class SoftwareWrapper {

		public Integer serialNum {get; set;}
		public string softwareName {get; set;}
		public Integer quantity {get; set;}
		public string comments {get; set;}
		public string description {get; set;}
	}
}