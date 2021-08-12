/**
 *  ================================================================================================
 *   Version    Date              Comment
 *  ================================================================================================
 *   v1.0      Feb-14-2016       - Created class to handle error responses of callout
 *                               - Creates CPQ Export Log object record and sends failure emails
 *                               - Updates order that are successful with Submitted to SAP as true
 */
public with sharing class CPQExportHelper {

    private static final String STR_ERROR_DATE_TIME = Label.Error_DateTime;//Error DateTime:
    private static final String STR_NUM_OF_RECS_FAILED = Label.No_of_failed_records;//No. of failed records:
    private static final String STR_ERROR_MSG = Label.Error_Message;//Error Message:
    private static final String STR_FIND_DETAILS_BELOW = Label.Find_Details_Below;//Please find the error details as below:

    /**
     * Method to insert CPQ Export Log for account errors and send email for same
     */
    public static void AccountErrors(List<Account> accounts, String errorMsg) {
        createCPQExportLog(accounts.size(),errorMsg,'Account','Failure');
        sendMail(accounts,errorMsg,'Account');
    }

    /**
     * Method to insert CPQ Export Log for Contact errors and send email for same
     */
    public static void ContactErrors(List<Contact> contacts, String errorMsg) {
        createCPQExportLog(contacts.size(),errorMsg,'Contact','Failure');
        sendMail(contacts,errorMsg,'Contact');
    }

    /**
     * Method to insert CPQ Export Log for Order errors and send email for same
     */
    public static void OrderErrors(List<Order> orders, String errorMsg) {
        createCPQExportLog(orders.size(),errorMsg,'Order','Failure');
        sendMail(orders,errorMsg,'Order');
    }

    /**
     * Method to insert CPQ Export Log for Account successes
     */
    public static void AccountSuccess(List<Account> accounts) {
        createCPQExportLog(accounts.size(),'','Account','Success');
    }

    /**
     * Method to insert CPQ Export Log for Contact successes
     */
    public static void ContactSuccess(List<Contact> contacts) {
        createCPQExportLog(contacts.size(),'','Contact','Success');
    }

    /**
     * Method to insert CPQ Export Log for Order successes, update order SAP Submission to true
     */
    public static void OrderSuccess(List<Order> orders) {
        createCPQExportLog(orders.size(),'','Order','Success');
        for(Order objOrder:orders) {
            objOrder.Submitted_to_SAP__c = true;
        }
        update orders;
    }

    /**
     * Method to insert CPQ Export Log
     */
    public static void createCPQExportLog(Integer recCount, String strMsg, String strObject, String strResult) {
        CPQ_Export_Log__c objCPQExportLog = new CPQ_Export_Log__c();
        objCPQExportLog.Message__c = strMsg;
        objCPQExportLog.Object__c = strObject;
        objCPQExportLog.Record_Count__c = recCount;
        objCPQExportLog.Result__c = strResult;
        insert objCPQExportLog;
    }

    /**
     * Method to send email
     */
    public static void sendMail(List<SObject> lstSObjects, String strMsg, String strObject) {

      // For orders, accounts and contacts, an email notification needs to be sent.
      String header = 'Record Id \n';
      String finalstr = header ;
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      for (SObject objSobject : lstSObjects) {
          String recordString = objSobject.id+'\n';
          finalstr = finalstr +recordString;
      }

      Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
      Blob csvBlob = Blob.valueOf(finalstr);
      String csvname= strObject+'.csv';
      csvAttc.setFileName(csvname);
      csvAttc.setBody(csvBlob);
      mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});

      // Set list of people who should get the email
      mail.setToAddresses(new List<String>{'tejashreep@simplus.com'});

      // The subject should be "CPQ Account [or Contact or Order] Export Error".
      mail.setSubject('CPQ '+strObject +' Export Error');
      // The body should give the date and time of the error, number of records and the error message.
      String body = 'Hi, \n\n';
      body += STR_FIND_DETAILS_BELOW+' \n\n';
      body += STR_ERROR_DATE_TIME+' '+ system.Now()+'; \n';
      body += STR_NUM_OF_RECS_FAILED+' '+ lstSObjects.size()+'; \n';
      body += STR_ERROR_MSG+' '+ strMsg+'; \n';
      mail.setPlainTextBody(body);
      // Send email
      Messaging.sendEmail( new List<Messaging.SingleEmailMessage> {mail});
    }

}