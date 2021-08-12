global class ContactToUserCreationUpdateBatch implements Database.Batchable<sObject>{

    global final String Query;
    global String strIds = '(';
    global list<Id> lstContactId;
    global list<ContactToUserCreationBatch.ErrorInsert> lstErrorInsert;
    
    global ContactToUserCreationUpdateBatch(list<Id> lstContactId, list<ContactToUserCreationBatch.ErrorInsert> lstErrorInsert){
       
       this.lstContactId = lstContactId;
       this.lstErrorInsert = lstErrorInsert;
       for(Id contactId : lstContactId) {
           strIds += '\''+contactId + '\',';
       }
       strIds = strIds.subString(0,strIds.length()-1);
       strIds += ')'; 
       Query = 'select id,Create_User__c, create_full_portal_user__c from Contact where id in :lstContactId';
    }
   
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<Contact> lstContact = (list<Contact>)scope;
        for(Contact con : lstContact) {
            con.Create_User__c = false;
            con.create_full_portal_user__c = false;
        }
        update lstContact;
    }
    
    global void finish(Database.BatchableContext BC){
       
        if(lstErrorInsert != null && lstErrorInsert.size() > 0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Community_settings__c cs = Community_Settings__c.getInstance();
            String strErrorEmails  = cs.ERROR_EMAILS__c;
            string[] toAddresses = strErrorEmails.split(';');
            for (integer i=0; i < toAddresses.size(); i++){
               toAddresses[i] = toAddresses[i].trim();
            }
            mail.setToAddresses(toAddresses);
            mail.setSubject('Contacts not inserted by batch process');
            //build the email body
            string html = '<table width="100%">';
            html += '<tr><td><b>ContactIds</b></td><td><b>Reason</b></td></tr>';        
            for(ContactToUserCreationBatch.ErrorInsert objErrorInsert : lstErrorInsert) {
                html += '<tr><td>' + objErrorInsert.contactId + '</td><td>' + objErrorInsert.strErrorMessage + '</td></tr>';
            }
            html += '</table>';
                
            //set html body
            mail.setHtmlbody(html);      
                
            //send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}