/**
 *  @description : This class is to enqueue the DML operations for object in the DocuSign flow.
 */
public without sharing class NPN_QueableClassForDocuSignDML implements Queueable {
    List<Account> accountsForUpdate = new List<Account>();
    List<Contact> contactsForInsert = new List<Contact>();
    List<Contact> contactsForUpdate = new List<Contact>();
    List<Contact> existingContactsForUpdate = new List<Contact>();
    List<Contact> convertedContactsForUpdate = new List<Contact>();
    List<Partner_Attribute__c> partnerAttributesForInsert = new List<Partner_Attribute__c>();
    List<Partner_Attribute__c> partnerAttributesForUpdate = new List<Partner_Attribute__c>();
    list<NPN_Key_Contact__c> NPNKCForUpdate = new List<NPN_Key_Contact__c>();
    list<Attachment> attachmentsForInsert = new List<Attachment>();
    list<Attachment> attachmentsForDelete = new List<Attachment>();

    public NPN_QueableClassForDocuSignDML(List<Contact> contactsForInsert, List<Contact> contactsForUpdate,  List<Partner_Attribute__c> partnerAttributesForInsert,
                                          list<NPN_Key_Contact__c> NPNKCForUpdate ){

        if(contactsForInsert!= null && !contactsForInsert.isEmpty()) {
            this.contactsForInsert = contactsForInsert;
        }
        if(contactsForUpdate != null && !contactsForUpdate.isEmpty()) {
            this.contactsForUpdate = contactsForUpdate;
        }
        if(partnerAttributesForInsert != null && !partnerAttributesForInsert.isEmpty()) {
            this.partnerAttributesForInsert = partnerAttributesForInsert;
        }
        if(NPNKCForUpdate != null && !NPNKCForUpdate .isEmpty()) {
            this.NPNKCForUpdate = NPNKCForUpdate ;
        }
    }
    
    public NPN_QueableClassForDocuSignDML(List<Attachment> attachmentsForInsert, List<Attachment> attachmentsForDelete, List<Contact> contactsForInsert, List<Contact> existingContactsForUpdate, List<Contact> convertedContactsForUpdate, List<Partner_Attribute__c> partnerAttributesForInsert){

        if(contactsForInsert!= null && !contactsForInsert.isEmpty()) {
            this.contactsForInsert = contactsForInsert;
        }
        if(existingContactsForUpdate != null && !existingContactsForUpdate.isEmpty()) {
            this.existingContactsForUpdate = existingContactsForUpdate;
        }
        if(convertedContactsForUpdate != null && !convertedContactsForUpdate.isEmpty()) {
            this.convertedContactsForUpdate = convertedContactsForUpdate;
        }
        if(partnerAttributesForInsert != null && !partnerAttributesForInsert.isEmpty()) {
            this.partnerAttributesForInsert = partnerAttributesForInsert;
        }
        if(attachmentsForInsert != null && !attachmentsForInsert.isEmpty()) {
            this.attachmentsForInsert = attachmentsForInsert ;
        }
        if(attachmentsForDelete != null && !attachmentsForDelete.isEmpty()) {
            this.attachmentsForDelete = attachmentsForDelete ;
        }
    }
    
    public NPN_QueableClassForDocuSignDML(List<Contact> contactsForUpdate, List<Partner_Attribute__c> partnerAttributesForUpdate, List<Account> accountsForUpdate){

        if(contactsForUpdate!= null && !contactsForUpdate.isEmpty()) {
            this.contactsForUpdate = contactsForUpdate;
        }
        if(partnerAttributesForUpdate != null && !partnerAttributesForUpdate.isEmpty()) {
            this.partnerAttributesForUpdate = partnerAttributesForUpdate;
        }
        if(accountsForUpdate != null && !accountsForUpdate.isEmpty()) {
            this.accountsForUpdate = accountsForUpdate ;
        }        
    }

    public void execute(QueueableContext context) {

        if(!contactsForInsert.isEmpty()) {
            Database.SaveResult[] srListForContactInsert = Database.Insert(contactsForInsert, false);
            System.debug('>>> srListForContactInsert: '+srListForContactInsert);
        }

        if(!existingContactsForUpdate.isEmpty()) {
            Database.SaveResult[] srListForContactUpdate = Database.Update(existingContactsForUpdate, false);
            System.debug('>>> srListForContactUpdate: '+srListForContactUpdate);
        }

        if(!convertedContactsForUpdate.isEmpty()) {
            Database.SaveResult[] srListForContactUpdate = Database.Update(convertedContactsForUpdate, false);
            System.debug('>>> srListForContactUpdate: '+srListForContactUpdate);
        }

        if(!partnerAttributesForInsert.isEmpty()) {
            Database.SaveResult[] srListForPAInsert = Database.Insert(partnerAttributesForInsert, false);
            System.debug('>>> srListForPAInsert: '+srListForPAInsert);
        }

        if(!NPNKCForUpdate.isEmpty()) {
            Database.SaveResult[] srListForNPNKCUpdate = Database.Update(NPNKCForUpdate, false);
            System.debug('>>> srListForNPNKCUpdate: '+srListForNPNKCUpdate);
        }
        
        if(!attachmentsForInsert.isEmpty()) {
            Database.SaveResult[] srListForAttachmentInsert = Database.Insert(attachmentsForInsert, false);
            System.debug('>>> srListForAttachmentInsert: '+srListForAttachmentInsert);
        }

        if(!attachmentsForDelete.isEmpty()) {
            Database.DeleteResult[] drListForAttachmentDelete = Database.Delete(attachmentsForDelete, false);
            System.debug('>>> drListForAttachmentDelete: '+drListForAttachmentDelete);
        }
        
        if(!contactsForUpdate.isEmpty()) {
            Database.SaveResult[] srListForContactUpdate = Database.Update(contactsForUpdate, false);
            System.debug('>>> srListForContactUpdate: '+srListForContactUpdate);
        }
        
        if(!partnerAttributesForUpdate.isEmpty()) {
            Database.SaveResult[] srListForPAUpdate = Database.Update(partnerAttributesForUpdate, false);
            System.debug('>>> srListForPAUpdate: '+srListForPAUpdate);
        }
        
        if(!accountsForUpdate.isEmpty()) {
            Database.SaveResult[] srListForAccountUpdate = Database.Update(accountsForUpdate, false);
            System.debug('>>> srListForAccountUpdate: '+srListForAccountUpdate);
        }
    }
}