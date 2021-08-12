/*
 * @name 			NPN_DemoUnitReqController
 * @description 	Created for SDS-891.
 * @author 			Rajat Kamble
 *
 * Changelog:
 *
 * 2021-06-09	Rajat SDS-3278 Update vDWS to vWS
 */
public without sharing class NPN_DemoUnitReqController {

	public Id acctId {get; set;}
	public Id rqstrId {get; set;}
	public Id accOwnrId {get; set;}
	public String reqstrName {get; set;}
	public String pbmEmail {get; set;}
	public String email {get; set;}
	public String accountName {get; set;}
	public String billingAddress {get; set;}
	public String reqTitleStr {get; set;}
	public List<String> licenseNameList {get; set;}
	public List<SwReqWrapper> softwareList {get; set;}
	public Map<String, String> metaRecordsMap {get; set;}
	public NPN_NFR_Software_Request__c softwareReq {get; set;}

	/**
	 * @name 	NPN_DemoUnitReqController
	 * @description 	Constructor
	 */
	public NPN_DemoUnitReqController() {

		metaRecordsMap = new Map<String, String>();

		for(NPN_NFR_Request_Data__mdt mdRec : [SELECT Id, DeveloperName, MasterLabel, Value__c FROM NPN_NFR_Request_Data__mdt]) {
			metaRecordsMap.put(mdRec.DeveloperName, mdRec.Value__c);
		}

		if(!metaRecordsMap.isEmpty()) {
			licenseNameList = metaRecordsMap.get('Softwares').split(';');
			//licenseNameList.sort();
		}
		initValues();
	}

	/**
	 * @name 	initValues
	 * @description    	Initialize values for the page.

	 */
	public void initValues() {

		User rqstr = [SELECT Id, Name, Contact.Title, Contact.FirstName, ContactId, Contact.Name, Contact.Email, AccountId, Account.Name,
		              Account.BillingStreet, Account.BillingCity, Account.BillingState,
		              Account.BillingPostalCode, Account.BillingCountry, Account.OwnerId, Account.Owner.Email FROM User WHERE Id = :UserInfo.getUserId()];

		acctId                  =       rqstr.AccountId;
		rqstrId                 =       rqstr.ContactId;
		accOwnrId               =       rqstr.Account.OwnerId;
		reqstrName              =       rqstr.Contact.Name;
		email                   =       rqstr.Contact.Email;
		accountName             =       rqstr.Account.Name;
		pbmEmail                =       rqstr.Account.Owner.Email;
		reqTitleStr             =       rqstr.Contact.Title;
		billingAddress          =       '';


		billingAddress += String.isNotBlank(rqstr.Account.BillingStreet) ?
		                  rqstr.Account.BillingStreet+ ', '  : '';
		billingAddress += String.isNotBlank(rqstr.Account.BillingCity) ?
		                  rqstr.Account.BillingCity+ ', '  : '';
		billingAddress += String.isNotBlank(rqstr.Account.BillingState) ?
		                  rqstr.Account.BillingState+ ', '  : '';
		billingAddress += String.isNotBlank(rqstr.Account.BillingPostalCode) ?
		                  rqstr.Account.BillingPostalCode+ ', '  : '';
		billingAddress += String.isNotBlank(rqstr.Account.BillingCountry) ?
		                  rqstr.Account.BillingCountry : '';

		softwareList = new List<SwReqWrapper>();
		for(String sw : licenseNameList) {
			SwReqWrapper srwObj = new SwReqWrapper();
			srwObj.swName = sw;
			srwObj.swComment = '';
			srwObj.swQuantity = null;

			if(!metaRecordsMap.isEmpty() && String.isNotBlank(metaRecordsMap.get(sw))) {
				srwObj.swDescription = metaRecordsMap.get(sw);
			}

			srwObj.serialNo = String.valueOf(softwareList.size()+1);
			softwareList.add(srwObj);
		}

		softwareReq = new NPN_NFR_Software_Request__c();
		softwareReq.Requested_By__c = rqstrId;
		softwareReq.Address__c = billingAddress;
		softwareReq.Company_Name__c = Id.valueOf(acctId);
		softwareReq.Email__c = email;
		softwareReq.Title__c = reqTitleStr;
		softwareReq.Status__c = 'Pending';
		softwareReq.Approver__c = accOwnrId;

	}

	/**
	 * saveRequest description
	 * @return   PageReference
	 */
	public PageReference saveRequest(){
		List<NPN_NFR_Software__c> softwareForInsert = new List<NPN_NFR_Software__c>();

		try{
			for(SwReqWrapper nsWrpObj : softwareList) {
				if(nsWrpObj.swQuantity != null && Integer.valueOf (nsWrpObj.swQuantity) < 0) {
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
				}
				else{
					if(nsWrpObj.swQuantity != null && Integer.valueOf (nsWrpObj.swQuantity) >= 0) {
						if('vWS'.equalsIgnoreCase(nsWrpObj.swName)) {   //metadata name changed for SDS-3278
							softwareReq.VDWS__c = nsWrpObj.swQuantity;
						}
						if('vPC'.equalsIgnoreCase(nsWrpObj.swName)) {
							softwareReq.VPC__c = nsWrpObj.swQuantity;
						}
						if('vCS'.equalsIgnoreCase(nsWrpObj.swName)) {
							softwareReq.vCS__c = nsWrpObj.swQuantity;
						}
					}
				}
			}

			insert softwareReq;

		}catch(DmlException dme) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Error creating the request : '+ dme.getMessage()));
		}

		if(!softwareList.isEmpty()) {
			for(SwReqWrapper nsWrpObj : softwareList) {
				NPN_NFR_Software__c nsObj = new NPN_NFR_Software__c();
				if(nsWrpObj.swQuantity != null && Integer.valueOf (nsWrpObj.swQuantity) < 0) {
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
				}
				else if(nsWrpObj.swQuantity != null && Integer.valueOf (nsWrpObj.swQuantity) >= 0) {
					nsObj.Software__c = nsWrpObj.swName;
					nsObj.Quantity__c = Integer.valueOf(nsWrpObj.swQuantity);
					nsObj.Comments__c = nsWrpObj.swComment;
					nsObj.NPN_NFR_Software_Request__c = softwareReq.Id;
					softwareForInsert.add(nsObj);
				}
			}
		}

		if(!softwareForInsert.isEmpty()) {
			try{
				insert softwareForInsert;

				sendApprovalMail(softwareReq.id);

				softwareReq = null;

			}catch(DmlException dme) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Error creating the request : '+ dme.getMessage()));
			}
		}

		PageReference pr = new PageReference ('/apex/NPN_DemoUnitRequest');
		pr.setRedirect(true);
		return pr;
	}

	/**
	 * @name 	sendApprovalMail
	 * @swDescription	Sends an email notification to the PBM with the approval page link.
	 */
	public void sendApprovalMail (Id recordId){

		if(String.isNotBlank(String.valueOf(recordId))) {

			String orgUrl ='';
			Organization objOrg = [SELECT Id,InstanceName,IsSandbox FROM Organization];

			if(objOrg.IsSandbox) {
				orgUrl = metaRecordsMap.get('ssoUrl_Stage');
			}else{
				orgUrl = metaRecordsMap.get('ssoUrl_Prod');
			}

			OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'no_reply@nvidia.com'];

			String html;
			List<String> toAddresses = new List<String> {pbmEmail};
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			mail.setToAddresses(toAddresses);
			mail.setOrgWideEmailAddressId(owa.id);
			mail.setSubject('NFR SW License Approval Request');
			html = '<p>'+reqstrName+' from '+accountName+'  has requested your approval for a new NFR SW License Request.</p>'+
			       '<p>Please click on the NVIDIA CRM (SFDC) link below to approve or reject the request. You will be asked to login to NVIDIA CRM (SFDC) to do this.</p>'+
			       '<p>If rejected, the partner will be notified.</p>'+
			       '<p>Once you have approved, an Order Agreement for EULA will automatically be sent to the partner for signing.</p>'+
			       '<p>'+orgUrl+'/apex/NPN_NFR_DemoUnitsApproval?id='+ recordId+'</p>';

			mail.setHtmlbody(html);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}
	/**
	 *  @name 	getswRequests
	 *  @description : Returns list of all software demo unit request records for the account
	 *  @return :   List<SwReqWrapper>
	 */
	public list<SwReqWrapper> getswRequests() {

		String dateFormat = 'dd-MMM-yy hh : mm a ';
		Map<Id, SwReqWrapper> wrpSWReqMap = new Map<Id, SwReqWrapper>();
		Map<Id, NPN_NFR_Software_Request__c> swReqMap = new Map<Id,NPN_NFR_Software_Request__c>(
			[SELECT Id, Email__c, Status__c,Company_Name__r.Name, Requested_By__r.Name, Comments_From_PBM__c, CreatedDate, LastModifiedDate,
			 (SELECT Id, Comments__c, Quantity__c, Software__c FROM NPN_NFR_Software__r) FROM NPN_NFR_Software_Request__c
			 WHERE Company_Name__c = : acctId AND (Status__c = 'Pending ' OR LastModifiedDate = LAST_N_DAYS: 30) ORDER BY LastModifiedDate DESC]);

		if(swReqMap != null && !swReqMap.isEmpty()) {

			for(NPN_NFR_Software_Request__c swReq : swReqMap.values()) {
				SwReqWrapper swReqObject = new SwReqWrapper();
				swReqObject.id = swReq.Id;
				swReqObject.name = swReq.Requested_By__r.Name;
				swReqObject.emailAddr = swReq.Email__c;
				swReqObject.status = swReq.Status__c;
				swReqObject.lastModifiedDate = swReq.LastModifiedDate.format(dateFormat,  UserInfo.getTimeZone().toString());
				swReqObject.swReqstd = ' ';
				swReqObject.commentsFromReq = '';
				swReqObject.commentsFromPBM     = swReq.Comments_From_PBM__c;

				if(swReq.NPN_NFR_Software__r != null) {
					for(NPN_NFR_Software__c nswObj : swReq.NPN_NFR_Software__r) {
						swReqObject.swReqstd += nswObj.Software__c + ' = '+ nswObj.Quantity__c +'; ';
						if(String.isNotBlank(nswObj.Comments__c)) {
							swReqObject.commentsFromReq += nswObj.Software__c + ': '+ nswObj.Comments__c +' <br/>';
						}
					}
				}
				wrpSWReqMap.put(swReqObject.Id, swReqObject);
			}
		}
		return wrpSWReqMap.values();
	}

	public class SwReqWrapper {

		public string commentsFromPBM {get; set;}
		public string commentsFromReq {get; set;}
		public string id {get; set;}
		public string name {get; set;}
		public string emailAddr {get; set;}
		public string status {get; set;}
		public string lastModifiedDate {get; set;}
		public string swReqstd {get; set;}
		public string serialNo {get; set;}
		public Integer swQuantity {get; set;}
		public string swName {get; set;}
		public string swComment {get; set;}
		public string swDescription {get; set;}
	}
}