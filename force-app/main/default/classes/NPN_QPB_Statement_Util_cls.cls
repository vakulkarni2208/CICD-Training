/**
 *	@name:		NPN_QPB_Statement_Util_cls
 *	@description:	Utility class contains methods for NPN QPB Statement functionality. Created for SDS-1406
 *
 */
public without sharing class NPN_QPB_Statement_Util_cls {

	/**
	 *	@name notifyPartnersForStmt
	 *	@param Set<Id> QPB_Statement__c Ids
	 *	@description	Notify the partner contacts for the newly uploaded QPB statement.
	 *  Invoked from QPB_Statement_tgr in AFTER UPDATE context
	 */
	public static void notifyPartnersForStmt(Set<Id> qpbStmtIdSet){

		Map<Id, List<Id> > accQPBIdMap = new Map<Id, List<Id> >();
		Map<Id, List<Id> > accContactIdMap = new Map<Id, List<Id> >();
		Map<Id, List<Id> > contactQPBIdLstMap = new Map<Id, List<Id> >();
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

		for(QPB_Statement__c qpbObj : [SELECT Id, Account__c, Fiscal_Year__c, Quarter__c, Type__c FROM QPB_Statement__c WHERE Id IN :qpbStmtIdSet]) {
			if(!accQPBIdMap.isEmpty() && accQPBIdMap.containsKey(qpbObj.Account__c)) {
				accQPBIdMap.get(qpbObj.Account__c).add(qpbObj.Id);
			}else{
				accQPBIdMap.put(qpbObj.Account__c, new List<Id> {qpbObj.Id});
			}
		}

		if(!accQPBIdMap.isEmpty()) {
			for (Contact pContact: [SELECT Id, AccountId, Role__c, Community_User_Active__c FROM Contact WHERE AccountId IN :accQPBIdMap.keySet() AND Role__c INCLUDES ('Partner Primary Contact') AND Community_User_Active__c = true] ) {
				contactQPBIdLstMap.put(pContact.Id, accQPBIdMap.get(pContact.AccountId));
			}
		}
		system.debug('contactQPBIdLstMap '+contactQPBIdLstMap);
		if(!contactQPBIdLstMap.isEmpty()) {

			OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'no_reply@nvidia.com'];

			EmailTemplate et = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'NPN_QPB_Statement_Notification_New' LIMIT 1];

			for(Id contactId : contactQPBIdLstMap.keySet()) {

				for(Id qpbId : contactQPBIdLstMap.get(contactId)) {

					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

					mail.setTargetObjectId(contactId);
					mail.setTreatTargetObjectAsRecipient(true);
					mail.setWhatId(qpbId); // qpb id
					mail.setTemplateId(et.id);
					mail.setOrgWideEmailAddressId(owa.id);
					messages.add(mail);
				}
			}
		}

		if(!messages.isEmpty()) {
			Messaging.reserveSingleEmailCapacity(messages.size());
			Messaging.sendEmail(messages);
		}
	}

	/**
	 * @name createContDistiForContVer
	 * RAJAT: COMMENTED THIS METHOD FOR FUTURE RELEASE ON 6-JAN-2020
	 */
	/*public static void createContDistiForContVer(Set<Id> contentVersionIds){

	        List<ContentDistribution> contDistiForInsert = new List<ContentDistribution>();

	        for(ContentVersion cvrObj : [SELECT Id, Title FROM ContentVersion WHERE Id IN :contentVersionIds]) {
	                ContentDistribution cd = new ContentDistribution();
	                cd.Name = cvrObj.Title;
	                cd.ContentVersionId = cvrObj.id;
	                cd.PreferencesAllowViewInBrowser= true;
	                cd.PreferencesLinkLatestVersion=true;
	                cd.PreferencesNotifyOnVisit=false;
	                cd.PreferencesPasswordRequired=false;
	                cd.PreferencesAllowOriginalDownload= true;
	                contDistiForInsert.add(cd);
	        }

	        system.debug('contDistiForInsert before insert : '+ contDistiForInsert);

	        if(!contDistiForInsert.isEmpty()) {
	                insert contDistiForInsert;
	        }
	   }*/

	/**
	 * @name convertFileToAttchment description
	 * @param  Set<Id> contentVersionIds description
	 * RAJAT: COMMENTED THIS METHOD FOR FUTURE RELEASE ON 6-JAN-2020
	 */
	/*
	   public static void convertFileToAttchment(Set<Id> contentVersionIds){
	       //Content Document->content version

	       System.debug('Inside convertFileToAttchment \ n contentVersionIds : '+ contentVersionIds);

	       List<Attachment> attachmentsForInsert = new List<Attachment>();
	       List<Id> contentIdsForDelete = new List<Id>();

	       for(ContentVersion cvrObj : [SELECT Id, Title, FirstPublishLocationId, IsLatest, VersionData, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds AND IsLatest = true]) {
	               Attachment sobj = new Attachment(
	                       IsPrivate = false,
	                       Name = cvrObj.Title,
	                       Body = cvrObj.VersionData,
	                       ParentId =cvrObj.FirstPublishLocationId,
	                       ContentType='application/pdf '
	                       );
	               attachmentsForInsert.add(sobj);
	               contentIdsForDelete.add(cvrObj.ContentDocumentId);
	       }
	       System.debug('attachmentsForInsert : '+ attachmentsForInsert);
	       if(!attachmentsForInsert.isEmpty()) {
	               insert attachmentsForInsert;
	       }

	       if(!contentIdsForDelete.isEmpty()) {

	               List<ContentDocument> contentForDelete = [SELECT ContentSize,CreatedDate,Description,FileExtension,FileType,Id,ParentId,Title FROM ContentDocument WHERE Id IN :contentIdsForDelete];

	               if(!contentForDelete.isEmpty()) {
	                       delete contentForDelete;
	               }
	       }
	   }*/

	/*
	 * grantCustomerAccessToContent description
	 * @param  Map<Id, ContentVersion> contentVersionForQPB description
	 * RAJAT: COMMENTED THIS METHOD FOR FUTURE RELEASE  ON 6-JAN-2020
	 */
	/*public static void grantCustomerAccessToContent(Map<Id, ContentVersion> contentVersionForQPB){

	        // get contentdocumentId from content version and query on contentdocumentlink
	        // query for the contentdocumentlink which is qpb type
	        // use the qpb id to create the share record, and contentdocumentlink record

	        Set<Id> contentDocumentIds = new Set<Id>();
	        List<ContentDocumentLink> contentDocumentLinkForUpdate = new List<ContentDocumentLink>();

	        for(ContentVersion cvObj : contentVersionForQPB.values()) {
	                contentDocumentIds.add(cvObj.ContentDocumentId);
	        }

	        if(!contentDocumentIds.isEmpty()) {

	                for(ContentDocumentLink cdlObj: [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentIds]) {

	                        if('QPB_Statement__c '.equalsIgnoreCase(cdlObj.LinkedEntityId.getSObjectType().getDescribe().getName())) {
	                                cdlObj.Visibility='AllUsers ';
	                                contentDocumentLinkForUpdate.add(cdlObj);
	                        }
	                }
	        }

	        if(!contentDocumentLinkForUpdate.isEmpty()) {
	                update contentDocumentLinkForUpdate;
	        }
	   }*/
}