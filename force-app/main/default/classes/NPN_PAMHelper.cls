/**************************************************************************************************
 * @name           : NPN_PAMHelper
 */

public without sharing class NPN_PAMHelper {


	public static void linkDocuSignStatus(Map<Id, NPN_PartnerAttributes_Modifiaction__c> triggerNewMap) {

		Map<String, Id> envIdPAMIdMap = new Map<String, Id>();
		List<dsfs__DocuSign_Status__c> listDocuStatusForUpdate = new List<dsfs__DocuSign_Status__c>();

		if(!triggerNewMap.isEmpty()) {

			for(NPN_PartnerAttributes_Modifiaction__c PAM : triggerNewMap.values()) {
				if(String.isNotBlank(PAM.DocuSign_Envelope_ID__c)) {
					envIdPAMIdMap.put(PAM.DocuSign_Envelope_ID__c,PAM.Id);
				}
			}

			if(!envIdPAMIdMap.isEmpty()) {
				for(dsfs__DocuSign_Status__c dStatObj : [SELECT Id, NPN_PartnerAttributes_Modifiaction__c, dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c IN : envIdPAMIdMap.keySet()]) {

					dsfs__DocuSign_Status__c docuStatusObj = new dsfs__DocuSign_Status__c();

					docuStatusObj.Id = dStatObj.Id;
					docuStatusObj.NPN_PartnerAttributes_Modifiaction__c = envIdPAMIdMap.get(dStatObj.dsfs__DocuSign_Envelope_ID__c);
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
	                    Clones the attachments from the DocuSign Status object
	                    and adds it on the Account of the related NFR Request.

	   @param           Map<Id,Id> DSStatusNFRReqIdMap
	 */
	public static void attachToAccount(Map<Id,Id> mapDSStatusPAMId) {

		System.debug('>>> mapDSStatusPAMId.size() : '+ mapDSStatusPAMId.size() + ' :: '+ mapDSStatusPAMId);

		Map<Id, List<Attachment> > requestIdAttachmentsMap = new Map<Id, List<Attachment> >();
		List<Attachment> newAttachmentsForInsert = new List<Attachment>();
		Set<Id> deleteAttachmentsOfParentObjects = new Set<Id>();

		if(!mapDSStatusPAMId.isEmpty()) {
			for(Attachment atch : [SELECT Id, Body, Name, Description, ParentId FROM Attachment WHERE ParentId IN :mapDSStatusPAMId.values()]) {
				System.debug('>>> attachment'+atch );

				if(!requestIdAttachmentsMap.isEmpty() && !requestIdAttachmentsMap.get(atch.ParentId).isEmpty()) {
					requestIdAttachmentsMap.get(atch.ParentId).add(atch);
				}else{
					requestIdAttachmentsMap.put(atch.ParentId, new List<Attachment> {atch});
				}

				// Delete the attachments on Docusign Status records
				deleteAttachmentsOfParentObjects.addAll(mapDSStatusPAMId.keySet());
			}
		}
		System.debug('>>> requestIdAttachmentsMap.size() : '+ requestIdAttachmentsMap.size() + ' :: '+ requestIdAttachmentsMap);

		if(!requestIdAttachmentsMap.isEmpty()) {
			for(NPN_PartnerAttributes_Modifiaction__c nfrReq : [SELECT Id, Account__c FROM NPN_PartnerAttributes_Modifiaction__c WHERE Id IN :requestIdAttachmentsMap.keyset() AND Account__c != NULL]) {
				for(Attachment oldAtch : requestIdAttachmentsMap.get(nfrReq.Id)) {
					Attachment newAttachment = oldAtch.clone();
					newAttachment.ParentId = Id.valueOf(nfrReq.Account__c );
					newAttachmentsForInsert.add(newAttachment);
				}
			}

			// Delete the attachments from PAM records
			deleteAttachmentsOfParentObjects.addAll(requestIdAttachmentsMap.keySet());
		}
		System.debug('>>> newAttachmentsForInsert.size() : '+ newAttachmentsForInsert.size() + ' :: '+ newAttachmentsForInsert);
		if(!newAttachmentsForInsert.isEmpty()) {
			try{
				Database.SaveResult[] srListInsert = Database.Insert(newAttachmentsForInsert, false);
				System.debug('>>> srListInsert.size() : '+ srListInsert.size() + ' :: '+ srListInsert);

				if(!deleteAttachmentsOfParentObjects.isEmpty()) {
					NPN_Utility.deleteAttachmentsForParentObj(deleteAttachmentsOfParentObjects);
				}

			} catch (DmlException dmlEx) {
				System.debug('The following exception has occurred: ' + dmlEx.getMessage());
			}
		}

	}
}