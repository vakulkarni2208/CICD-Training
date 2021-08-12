/**************************************************************************************************
* @name           : NPN_NFR_SoftwareReqHelper
* @description     : Helper class for NFR_SoftwareReq_Trigger. Created for SDS-891
***************************************************************************************************
* Author            | Created Date    | Description
***************************************************************************************************
* Rajat K           | July 31 ,2019   | Initial
**************************************************************************************************/
public without sharing class NPN_NFR_SoftwareReqHelper {

	/**
	        @name           changeOwner
	        @description    Update the request' owner to the PBM.
	        @param          Map<Id, NPN_NFR_Software_Request__c> triggerNewMap
	 */
	public static void changeOwner(Map<Id, NPN_NFR_Software_Request__c> triggerNewMap) {

		if(!triggerNewMap.isEmpty()) {

			List<NPN_NFR_Software_Request__c> updateOwnerList = new List<NPN_NFR_Software_Request__c>();

			for(NPN_NFR_Software_Request__c nsr : [SELECT Id, Approver__c, Status__c, OwnerId FROM NPN_NFR_Software_Request__c WHERE Id IN :triggerNewMap.keyset() AND Status__c ='Pending']) {
				if(String.isNotBlank(nsr.Approver__c)) {
					nsr.OwnerId = Id.valueOf(nsr.Approver__c);
				}
				updateOwnerList.add(nsr);
			}

			if(!updateOwnerList.isEmpty()) {
				update updateOwnerList;
			}
		}
	}

	/**
	   @name            linkDocuSignStatus
	   @description     Updates the lookup on the DocuSign Status record to the respective NFR request
	                    using the Envelope ID.
	   @param           Map<Id, NPN_NFR_Software_Request__c> triggerNewMap
	 */
	public static void linkDocuSignStatus(Map<Id, NPN_NFR_Software_Request__c> triggerNewMap) {

		Map<String, Id> envIdReqIdMap = new Map<String, Id>();
		List<dsfs__DocuSign_Status__c> listDocuStatusForUpdate = new List<dsfs__DocuSign_Status__c>();

		if(!triggerNewMap.isEmpty()) {

			for(NPN_NFR_Software_Request__c nsr : triggerNewMap.values()) {
				if(String.isNotBlank(nsr.DocuSign_Enevelop_ID__c)) {
					envIdReqIdMap.put(nsr.DocuSign_Enevelop_ID__c,nsr.Id);
				}
			}

			if(!envIdReqIdMap.isEmpty()) {
				for(dsfs__DocuSign_Status__c dStatObj : [SELECT Id, NFR_Licenses_Request__c, dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c IN : envIdReqIdMap.keySet()]) {

					dsfs__DocuSign_Status__c docuStatusObj = new dsfs__DocuSign_Status__c();

					docuStatusObj.Id = dStatObj.Id;
					docuStatusObj.NFR_Licenses_Request__c = envIdReqIdMap.get(dStatObj.dsfs__DocuSign_Envelope_ID__c);
					listDocuStatusForUpdate.add(docuStatusObj);
				}
			}

			if(!listDocuStatusForUpdate.isEmpty()) {
				try{
					Database.SaveResult[] srListUpdate = Database.Update(listDocuStatusForUpdate, false);
				} catch (DmlException dmlEx) {
					System.debug('The following exception has occurred: ' + dmlEx.getMessage());
				}
			}
		}
	}

	/**
	   @name            attachToAccount
	   @description     Invoked from NV_DocuSignStatus Trigger.
	                    Clones the attachment from the DocuSign Status object
	                    and adds it on the Account of the related NFR Request.

	   @param           Map<Id,Id> DSStatusNFRReqIdMap
	 */
	public static void attachToAccount(Map<Id,Id> DSStatusNFRReqIdMap) {

		Map<Id, Attachment> requestIdAttachmentMap = new Map<Id, Attachment>();
		List<Attachment> newAttachmentsForInsert = new List<Attachment>();
		Set<Id> deleteAttachmentsOfParentObjSet = new Set<Id>();

		if(!DSStatusNFRReqIdMap.isEmpty()) {
			for(Attachment atch : [SELECT Id, Body, Name, Description, ParentId FROM Attachment WHERE ParentId IN :DSStatusNFRReqIdMap.values()]) {
				requestIdAttachmentMap.put(atch.ParentId, atch);
			}

			// Delete the attachments on Docusign Status records
			deleteAttachmentsOfParentObjSet.addAll(DSStatusNFRReqIdMap.keySet());
		}

		if(!requestIdAttachmentMap.isEmpty()) {
			for(NPN_NFR_Software_Request__c nfrReq : [SELECT Id, Company_Name__c FROM NPN_NFR_Software_Request__c WHERE Id IN :requestIdAttachmentMap.keyset()]) {
				if(nfrReq.Company_Name__c != null) {

					Attachment newAttachment = requestIdAttachmentMap.get(nfrReq.Id).clone();
					newAttachment.ParentId = Id.valueOf(nfrReq.Company_Name__c);

					newAttachmentsForInsert.add(newAttachment);
				}
			}
			// Delete the attachments from NFR SW License Request records
			deleteAttachmentsOfParentObjSet.addAll(requestIdAttachmentMap.keySet());
		}

		if(!newAttachmentsForInsert.isEmpty()) {
			try{
				if(!newAttachmentsForInsert.isEmpty()) {
					Database.SaveResult[] srListInsert = Database.Insert(newAttachmentsForInsert, false);

					// update the NFR request status to completed.
					updateStatusToCompleted(requestIdAttachmentMap.keyset());

					if(!deleteAttachmentsOfParentObjSet.isEmpty()) {
						NPN_Utility.deleteAttachmentsForParentObj(deleteAttachmentsOfParentObjSet);
					}
				}
			} catch (DmlException dmlEx) {
				System.debug('The following exception has occurred: ' + dmlEx.getMessage());
			}
		}
	}
	/**
	 * @name	updateStatusToCompleted description
	 * @param  completedReqSet completedReqSet description
	 */
	public static void updateStatusToCompleted(Set<Id> completedReqSet) {

		List<NPN_NFR_Software_Request__c> updateList = new List<NPN_NFR_Software_Request__c>();
		for(NPN_NFR_Software_Request__c nfrReq : [SELECT Id, Status__c FROM NPN_NFR_Software_Request__c WHERE Id IN :completedReqSet]) {
			nfrReq.Status__c = 'Completed';
			updateList.add(nfrReq);
		}

		if(!updateList.isEmpty()) {
			Database.SaveResult[] srLisUpdate = Database.Update(updateList, false);
		}
	}
}