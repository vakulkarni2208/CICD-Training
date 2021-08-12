/**
 * @name    NPN_Utility
 * @description     This is a utility class containing common methods. *

 * 2019-10-25   RKAMB   Added method deleteAttachmentsForParentObj

 */
public without sharing class NPN_Utility {

	@future
	public static void deleteAttachmentsForParentObj (Set<Id> parentIdSet){

		List<Attachment> listAttachmentsForDeletion =[SELECT Id FROM Attachment WHERE ParentId IN :parentIdSet];

		if(!listAttachmentsForDeletion.isEmpty()) {
			delete listAttachmentsForDeletion;
		}
	}
}