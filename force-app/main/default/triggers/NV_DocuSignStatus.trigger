/**
 * @name    NV_DocuSignStatus
 * @description     Trigger on dsfs__DocuSign_Status__c
 *

 * 2019-07-30   Rajat   Added method for SDS-891 NFR License Request

 */

trigger NV_DocuSignStatus on dsfs__DocuSign_Status__c (after insert,after update) {
	list<Id> leadIds = new list<Id>();
	list<Id> lstLeadIds = new list<Id>();
	list<Id> lstPAMId = new List<Id>();
	Map<Id,Id> DSStatusNFRReqIdMap = new Map<Id,Id>(); // Added for SDS-891
	Map<Id,Id> mapDSStatusPAMId = new Map<Id,Id>();
	map<Id,String> mapPAMIdEnvelopeId = new map<Id, String>();
	map<Id,list<String> > mapAcctIdEnvelopeIds = new map<Id,list<String> >();

	for(dsfs__DocuSign_Status__c objDSStatus : Trigger.new) {
		if((Trigger.isInsert && objDSStatus.dsfs__Envelope_Status__c == 'Completed') || (Trigger.isUpdate && Trigger.oldMap.get(objDSStatus.id).dsfs__Envelope_Status__c != Trigger.newMap.get(objDSStatus.id).dsfs__Envelope_Status__c && objDSStatus.dsfs__Envelope_Status__c == 'Completed')) {
			if(objDSStatus.dsfs__Lead__c != null) {
				leadIds.add(objDSStatus.dsfs__Lead__c);
			}
			if(objDSStatus.NPN_PartnerAttributes_Modifiaction__c != null) {
				//mapAccountIdEnvelopeId.put(objDSStatus.dsfs__Company__c, objDSStatus.dsfs__DocuSign_Envelope_ID__c);
				//lstPAMId.add(objDSStatus.NPN_PartnerAttributes_Modifiaction__c);
				mapPAMIdEnvelopeId.put(objDSStatus.NPN_PartnerAttributes_Modifiaction__c, objDSStatus.dsfs__DocuSign_Envelope_ID__c);
				mapDSStatusPAMId.put(objDSStatus.Id, objDSStatus.NPN_PartnerAttributes_Modifiaction__c);
			}
		}
		if((Trigger.isInsert && objDSStatus.dsfs__Envelope_Status__c == 'Sent') || (Trigger.isUpdate && Trigger.oldMap.get(objDSStatus.id).dsfs__Envelope_Status__c != Trigger.newMap.get(objDSStatus.id).dsfs__Envelope_Status__c && objDSStatus.dsfs__Envelope_Status__c == 'Sent')) {
			if(objDSStatus.dsfs__Lead__c != null) {
				lstLeadIds.add(objDSStatus.dsfs__Lead__c);
			}
		}

		if((Trigger.isInsert && objDSStatus.dsfs__DocuSign_Envelope_ID__c != '') || (Trigger.isUpdate && Trigger.oldMap.get(objDSStatus.id).dsfs__DocuSign_Envelope_ID__c != Trigger.newMap.get(objDSStatus.id).dsfs__DocuSign_Envelope_ID__c && objDSStatus.dsfs__DocuSign_Envelope_ID__c != '')) {
			if(objDSStatus.dsfs__Company__c != null) {
				if(!mapAcctIdEnvelopeIds.containsKey(objDSStatus.dsfs__Company__c)) {
					mapAcctIdEnvelopeIds.put(objDSStatus.dsfs__Company__c, new list<String> {objDSStatus.dsfs__DocuSign_Envelope_ID__c});
				} else {
					mapAcctIdEnvelopeIds.get(objDSStatus.dsfs__Company__c).add(objDSStatus.dsfs__DocuSign_Envelope_ID__c);
				}
			}
		}

		/* Changes for SDS-891 START */
		if((Trigger.isInsert && objDSStatus.dsfs__Envelope_Status__c == 'Completed') || (Trigger.isUpdate && Trigger.oldMap.get(objDSStatus.id).dsfs__Envelope_Status__c != Trigger.newMap.get(objDSStatus.id).dsfs__Envelope_Status__c && objDSStatus.dsfs__Envelope_Status__c == 'Completed') && objDSStatus.NFR_Licenses_Request__c != null) {
			DSStatusNFRReqIdMap.put(objDSStatus.Id, objDSStatus.NFR_Licenses_Request__c);
		}
		/* Changes for SDS-891 END */
	}
	//list<NPN_PartnerAttributes_Modifiaction__c> lstPAM = [select account__c from NPN_PartnerAttributes_Modifiaction__c where id in :lstPAMId];

	if(!leadIds.isEmpty()) {
		NV_DocusignLeadHelper.convertLead(leadIds);
	}
	if(!lstLeadIds.isEmpty()) {
		NV_DocusignLeadHelper.changeLeadStatus(lstLeadIds);
	}
	if(!mapAcctIdEnvelopeIds.isEmpty()) {
		//NV_DocusignAccountHelper.updateEnvelopeId(mapAcctIdEnvelopeIds);
	}
	if(!mapPAMIdEnvelopeId.isEmpty()) {
		NV_DocusignAccountHelper.processingLogic(mapPAMIdEnvelopeId);
	}

	/* Changes for SDS-891 START */
	if(!DSStatusNFRReqIdMap.isEmpty()) {
		system.debug('>>> DSStatusNFRReqIdMap : '+DSStatusNFRReqIdMap);
		NPN_NFR_SoftwareReqHelper.attachToAccount(DSStatusNFRReqIdMap);
	}
	/* Changes for Add On Competency, termination, promotion and demotion */
	if(!mapDSStatusPAMId.isEmpty()) {
		NPN_PAMHelper.attachToAccount(mapDSStatusPAMId);
	}
}