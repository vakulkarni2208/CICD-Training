/**
 *  @name : NV_ListContactExtension
 *  @description :    This class is the controller extension of apex page : NV_ListPartnerContacts
 */
global without sharing class NV_ListContactExtension {

	public Id acctId {get; set;}
	public String actionToPerform {get; set;}
	public String contactId {get; set;}
	public boolean displayPopup {get; set;}
	public String resonForRemoval {get; set;}
	public Temporary_Contact__c tempContactForUpdate {get; set;}
	public Integer contactCount {get; set;}

	/**
	 *  @description : initialization of temp contact list and fetch the account Id of logged in user.
	 */
	public NV_ListContactExtension() {
		acctId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
		//getTemporaryContacts();
	}

	public ApexPages.StandardSetController contactRecords {
		get {
			if(contactRecords == null) {
				contactRecords = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name, Email, Title, Phone, Role__c, Community_User_Active__c, Community_User__r.IsActive, Portal_Groups__c, RecordType.DeveloperName, Partner_Request_for_Deletion__c FROM Contact WHERE AccountId = : acctId AND RecordType.DeveloperName = 'Partner' AND Partner_Request_for_Deletion__c = false ORDER BY Name]));
			}
			return contactRecords;
		}
		private set;
	}

	/**
	 *  @description : Returns list of valid and active contacts contact records for the account
	 *  @return : List<Contact>
	 */
	public list<Contact> getContacts() {
		contactRecords.setPageSize(contactRecords.getResultSize());
		contactCount = contactRecords.getRecords().size();
		return (list<Contact>) contactRecords.getRecords();
	}

	/**
	 *  @description : Returns list of all temp contact records for the account
	 *  @return :   List<Temporary_Contact__c>
	 */
	public list<TempContactWrapper> getTemporaryContacts() {
		Map<Id, TempContactWrapper> tempContWrpMap = new Map<Id, TempContactWrapper>();
		Map<Id, Temporary_Contact__c> tpMap = new Map<Id, Temporary_Contact__c>([SELECT Id, First_Name__c, Last_Name__c, Email__c, Title__c, Role__c, Status__c, CreatedDate,LastModifiedDate, Action_requested__c, Reason_for_Deactivation_Deletion__c FROM Temporary_Contact__c WHERE Account_Id__c = : acctId AND (Status__c = 'Pending' OR LastModifiedDate = LAST_N_DAYS: 30) ORDER BY LastModifiedDate DESC]);

		if(tpMap != null && !tpMap.isEmpty()) {
			for(Temporary_Contact__c tpCon : tpMap.values()) {
				TempContactWrapper tcwObject = new TempContactWrapper();
				tcwObject.id = tpCon.Id;
				tcwObject.name = tpCon.First_Name__c +' '+ tpCon.Last_Name__c;
				tcwObject.emailAddr = tpCon.Email__c;
				tcwObject.title = tpCon.Title__c;
				tcwObject.role  = tpCon.Role__c;
				tcwObject.status = tpCon.Status__c;
				tcwObject.lastModifiedDate = tpCon.LastModifiedDate.format('dd-MMM-yy hh:mm a',  UserInfo.getTimeZone().toString());
				tcwObject.actionRequested = tpCon.Action_requested__c;
				tcwObject.reasonForDeletion = tpCon.Reason_for_Deactivation_Deletion__c;

				tempContWrpMap.put(tcwObject.Id, tcwObject);
			}
		}

		map<String, String>  tempProcMap = new map<String, String>();
		map<String, String>  piCommentsMap = new map<String, String>();
		if(!tempContWrpMap.isEmpty()) {

			for (ProcessInstance pi : [SELECT Id, TargetObjectId, createdDate FROM ProcessInstance WHERE TargetObjectId IN :tempContWrpMap.keyset() ORDER BY CreatedDate DESC]) {
				if(!tempProcMap.containsKey(pi.TargetObjectId) ) {
					tempProcMap.put(pi.TargetObjectId, pi.Id);
				}
			}

			if(!tempProcMap.isEmpty()) {
				for (ProcessInstanceStep pi : [SELECT Id, StepStatus,ProcessInstanceId, Comments, CreatedDate FROM ProcessInstanceStep WHERE ProcessInstanceId IN :tempProcMap.values() ORDER BY CreatedDate DESC]) {
					if(!piCommentsMap.containsKey(pi.ProcessInstanceId)) {
						piCommentsMap.put(pi.ProcessInstanceId, pi.Comments);
					}
				}
			}

			if(!piCommentsMap.isEmpty()) {
				for(String idStr : tempProcMap.keyset()) {
					tempContWrpMap.get(idStr).comment = piCommentsMap.get(tempProcMap.get(idStr));
				}
			}
		}

		return tempContWrpMap.values();
	}


	/**
	 *  @description : Returns list of all temp contact records for the account
	 *  @return :   List<NPN_Bulk_Contact_Request__c>
	 */
	public list<BulkContacReqWrapper> getBulkContactRequests() {
		Map<Id, BulkContacReqWrapper> blkReqWrpMap = new Map<Id, BulkContacReqWrapper>();
		Map<Id, NPN_Bulk_Contact_Request__c> blkRequestMap = new Map<Id, NPN_Bulk_Contact_Request__c>(
			[SELECT Id, Account_Name__c, CreatedDate, LastModifiedDate, Requested_By__c, Requested_By__r.Name, Status__c
			 FROM NPN_Bulk_Contact_Request__c WHERE Account_Name__c = : acctId AND (Status__c = 'Pending' OR LastModifiedDate = LAST_N_DAYS: 30) ORDER BY LastModifiedDate DESC]);

		if(blkRequestMap != null && !blkRequestMap.isEmpty()) {
			for(NPN_Bulk_Contact_Request__c blkReqVar : blkRequestMap.values()) {
				BulkContacReqWrapper bcrObject = new BulkContacReqWrapper();
				bcrObject.id = blkReqVar.Id;
				bcrObject.status = blkReqVar.Status__c;
				bcrObject.requestedBy = blkReqVar.Requested_By__r.Name;
				bcrObject.createdDate = blkReqVar.CreatedDate.format('dd-MMM-yy hh:mm a',  UserInfo.getTimeZone().toString());

				blkReqWrpMap.put(bcrObject.Id, bcrObject);
			}
		}

		system.debug('--> blkReqWrpMap: '+ blkReqWrpMap);
		return blkReqWrpMap.values();
	}

	/**
	 *  @description : Redirect to NV_AddEditContact Page
	 *  @return :   PageReference
	 */
	public PageReference addContact() {
		return new PageReference('/apex/NV_AddEditContact');
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
		PageReference page = new PageReference('/apex/NV_ListPartnerContacts');
		page.setRedirect(true);
		return page;
	}

	/**
	 * @name    checkContactStatus
	 * @description : Verifies the status of the contact request and shows appropriate messages on the page .
	 * @return   PageReference
	 */
	public PageReference checkContactStatus(){
		actionToPerform = ApexPages.currentPage().getParameters().get('actionToPerform').escapeHtml4();
		contactId = ApexPages.currentPage().getParameters().get('contactId').escapeHtml4();

		if(String.isNotBlank(contactId)) {
			List<Temporary_Contact__c> tempContactForUpdateList = [SELECT Id, ContactId__c, Status__c, Action_requested__c, Reason_for_Deactivation_Deletion__c FROM Temporary_Contact__c WHERE ContactId__c =: Id.valueOf(contactId) LIMIT 1];
			if(!tempContactForUpdateList.isEmpty()) {
				tempContactForUpdate =  tempContactForUpdateList[0];
				if('Pending'.equalsIgnoreCase(tempContactForUpdate.Status__c) || Approval.isLocked(tempContactForUpdate.id)) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Contact '+tempContactForUpdate.Action_requested__c.toLowerCase()+' request is already in process'));
				} else {
					if('Edit'.equalsIgnoreCase(actionToPerform)) {
						PageReference pg = new PageReference('/apex/NV_AddEditContact?id='+contactId);
						return pg;
					} else {
						showPopup();
					}
				}
			} else if('Edit'.equalsIgnoreCase(actionToPerform)) {
				PageReference pg = new PageReference('/apex/NV_AddEditContact?id='+contactId);
				return pg;
			} else {
				showPopup();
			}
		}

		PageReference pg = new PageReference('/apex/NV_ListPartnerContacts');
		return pg;
	}

	/**
	 * @name    removeContact
	 * @return   PageReference
	 */
	public PageReference removeContact(){

		if(String.isNotBlank(contactId)) {

			if(String.isBlank(resonForRemoval)) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Reason cannot be blank'));
				PageReference pg = new PageReference('/apex/NV_ListPartnerContacts');
				return pg;
			}

			if(tempContactForUpdate != null) {
				List<Contact> contactLst = [SELECT Id, Community_User__c, FirstName, LastName, Role__c, Title, Phone FROM Contact WHERE Id = :contactId ];

				tempContactForUpdate.Action_requested__c = actionToPerform;
				tempContactForUpdate.Status__c = 'Pending';
				tempContactForUpdate.Reason_for_Deactivation_Deletion__c = resonForRemoval;
				tempContactForUpdate.Requested_By__c = UserInfo.getUserId();
				tempContactForUpdate.OwnerId = UserInfo.getUserId();

				if(!contactLst.isEmpty()) {
					tempContactForUpdate.First_Name__c = contactLst[0].FirstName;
					tempContactForUpdate.Last_Name__c = contactLst[0].LastName;
					tempContactForUpdate.Role__c = contactLst[0].Role__c;
					tempContactForUpdate.Title__c = contactLst[0].Title;
					tempContactForUpdate.Phone__c = contactLst[0].Phone;
					if(contactLst[0].Community_User__c != null) {
						tempContactForUpdate.Partner_User__c = contactLst[0].Community_User__c;
					}
				}

				update tempContactForUpdate;
				NV_AddEditContactController.submitForApproval(tempContactForUpdate.id);
			}
			// Existing contact without temporary contact record.
			else{
				List<Contact> contactLst = [SELECT Id, FirstName, LastName, Email, Phone, Title, Role__c, AccountId, Community_User__c FROM Contact WHERE Id = :contactId ];
				if(!contactLst.isEmpty()) {
					Temporary_Contact__c tempForExContact = new Temporary_Contact__c();
					tempForExContact.ContactId__c = contactId;
					tempForExContact.Status__c = 'Pending';
					tempForExContact.First_Name__c = contactLst[0].FirstName;
					tempForExContact.Last_Name__c = contactLst[0].LastName;
					tempForExContact.Email__c = contactLst[0].Email;
					tempForExContact.Phone__c = contactLst[0].Phone;
					tempForExContact.Account_ID__c = contactLst[0].AccountId;
					tempForExContact.Role__c = contactLst[0].Role__c;
					tempForExContact.Title__c = contactLst[0].Title;
					tempForExContact.Action_requested__c= actionToPerform;
					tempForExContact.Reason_for_Deactivation_Deletion__c = resonForRemoval;
					tempForExContact.Requested_By__c = UserInfo.getUserId();
					tempForExContact.OwnerId = UserInfo.getUserId();
					if(!contactLst.isEmpty() && contactLst[0].Community_User__c != null) {
						tempForExContact.Partner_User__c = contactLst[0].Community_User__c;
					}

					insert tempForExContact;
					NV_AddEditContactController.submitForApproval(tempForExContact.id);
				}
			}
		}

		closePopup();

		PageReference pg = new PageReference('/apex/NV_ListPartnerContacts');
		return pg;
	}

	/**
	 *  @name : attachBlob
	 *  @description :
	 *  @param :    String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue
	 *  @return :   String
	 */
	@RemoteAction
	global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){

		Blob cryptoKey = Blob.valueOf('12345678901234561234567890123456');



		//If recordId is blank this is the first part of a multi piece upload
		if(attachmentId == '' || attachmentId == null) {

			// Create a bulk contact request.
			NPN_Bulk_Contact_Request__c bcrObj = new NPN_Bulk_Contact_Request__c(
				Account_Name__c = parentId,
				Status__c = 'Pending',
				Requested_By__c = UserInfo.getUserId()
				);
			insert bcrObj;

			Attachment att = new Attachment(
				ParentId = bcrObj.Id,
				Body = EncodingUtil.Base64Decode(base64BlobValue),
				Name = fileName,
				ContentType = contentType
				);
			insert att;

			//Return the new attachment Id
			return att.Id;

		}else{
			for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]) {
				update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
			}

			//Return the Id of the attachment we are currently processing
			return attachmentId;
		}
	}

	/**
	 *  @name : sendEmail
	 *  @description : Processes the contact removal request.
	 *  @param :    String
	 *  @return :   String
	 */
	@RemoteAction
	global static String sendEmail(String attachmentId) {
		Organization org = [SELECT InstanceName FROM Organization];
		List<String> toAddresses = new List<String>(System.Label.NPN_Onboarding_Email.split(','));
		for (integer i=0; i < toAddresses.size(); i++) {
			toAddresses[i] = toAddresses[i].trim();
		}
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
		Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();

		mail.setToAddresses(toAddresses);
		mail.setSubject('Contacts Creation');

		//build the email body
		string html = '<html><body><table width="100%">';
		if(attachmentId != '' && attachmentId != null) {
			list<Attachment> lstAtt = [select id,body,name from Attachment where id=:attachmentId];
			html += '<tr><td><b>Contacts to be created:</b></td></tr>';
			if(lstAtt.size() > 0) {
				efa.setFileName('NPN_NVD_Add_Contacts.'+lstAtt[0].name.split('\\.')[1]);
				efa.setBody(lstAtt[0].body);
			}
			html += '<tr><td><b>Attachment Link:</b> '+'https://'+org.InstanceName+'.salesforce.com/'+lstAtt[0].id+'</td></tr>';
			html += '</table></body></html>';
			//set html body
			mail.setHtmlbody(html);
			fileAttachments.add(efa);
			mail.setFileAttachments(fileAttachments);
			mail.setSaveAsActivity(false);
			//send email
			Messaging.SendEmailResult[] lstMSER = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		return null;
	}

	public class TempContactWrapper {

		public string comment {get; set;}
		public string id {get; set;}
		public string name {get; set;}
		public string emailAddr {get; set;}
		public string title {get; set;}
		public string role {get; set;}
		public string status {get; set;}
		public string lastModifiedDate {get; set;}
		public string actionRequested {get; set;}
		public string reasonForDeletion {get; set;}
	}

	public class BulkContacReqWrapper {

		public string id {get; set;}
		public string requestedBy {get; set;}
		public string status {get; set;}
		public string createdDate {get; set;}
	}
}