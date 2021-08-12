public class NVErrorLogHelper {

    public static void sendEmail(List<NV_Error_Log__c> lstNVErrLog) {
        if(lstNVErrLog != null && lstNVErrLog.size() > 0) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Community_settings__c cs = Community_Settings__c.getInstance();
            String strErrorEmails  = cs.ERROR_EMAILS__c;
            string[] toAddresses = strErrorEmails.split(';');
            for (integer i=0; i < toAddresses.size(); i++){
               toAddresses[i] = toAddresses[i].trim();
            }
            mail.setToAddresses(toAddresses);
            mail.setSubject('SOEM Process failure');
            //build the email body
            string html = '<table width="100%">';
            html += '<tr><td><b>Error Description</b></td><td><b>Error Message</b></td></tr>';        
            for(NV_Error_Log__c objErrorInsert : lstNVErrLog) {
                html += '<tr><td>' + objErrorInsert.Error_Description__c + '</td><td>' + objErrorInsert.Error_Message__c+ '</td></tr>';
            }
            html += '</table>';
                
            //set html body
            mail.setHtmlbody(html);      
                
            //send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

}