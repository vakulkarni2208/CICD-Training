/**
 *  @name           : NPN_SubmitPosReminder_Batch
 *  @author         : rkamble
 *  @description : Created for SDS-1169. This is a schedular class for NPN_SubmitPosReminder_Batch, which is scheduled from developer console with the below script for the first time.
 *  CRON EXPRESSION :        At 00 : 00 : 00am, on the 11th and 21st day, every month  {0 0 0 11,21 * ? *}

    //script
        NPN_SubmitPosReminder_Batch sch = new NPN_SubmitPosReminder_Batch();
        string cronexp='0 0 0 11,21 * ? *';
        System.schedule('NPN_SubmitPosReminder',cronexp,sch);
 *  2019-11-13      RKAMB   SDS-1820 Updated the logic to exclude recently signed partners from notifications.
 *  2020-07-25      Rajat   SDS-1873 Changes for remider notification for registered level
 *  2020-08-28      Rajat   SDS-2638 Changes to exclude Distributor
 */

global class NPN_SubmitPosReminder_Batch implements Database.Batchable<sObject>, System.Schedulable {

    Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
    Id ptnrContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

    Date dtToday = System.today().addMonths(-1); // Added for bug fix
    Integer month = dtToday.month();
    Integer year = dtToday.year();
    Integer yearMonth = Integer.valueOf(String.valueOf(year).right(2) + (String.valueOf(month).length() == 2 ? String.valueOf(month) : '0'+String.valueOf(month)));
    String yearMonthStr = String.valueOf(yearMonth);

    Integer batchSize = 50;
    Integer firstDate = 11;
    Integer lastDate  = 21;
    String agreementDateThreshold = '60';
    String cronExpression   = '';
    String firstRemBody     = '';
    String firstRemSub      = '';
    String lastRemBody      = '';
    String lastRemSub       = '';
    String query            = '';

    // Constructor
    public NPN_SubmitPosReminder_Batch(){

        Map<String, String> posNotifyDataMap = new Map<String, String>();
        for(NPN_POS_Notify_Data__mdt pndObj : [SELECT Id, DeveloperName, Value__c FROM NPN_POS_Notify_Data__mdt]) {
            posNotifyDataMap.put(pndObj.DeveloperName, pndObj.Value__c);
        }
        System.debug('--> posNotifyDataMap.size() '+posNotifyDataMap.size());

        firstRemSub     =   posNotifyDataMap.get('First_Reminder_Subject');
        lastRemSub      =   posNotifyDataMap.get('Last_Reminder_Subject');
        firstRemBody    =   posNotifyDataMap.get('First_Reminder_Body');
        lastRemBody     =   posNotifyDataMap.get('Last_Reminder_Body');
        cronExpression  =   posNotifyDataMap.get('Cron_Expression');
        batchSize       =   String.isNotBlank(posNotifyDataMap.get('Batch_Size')) ? Integer.valueOf(posNotifyDataMap.get('Batch_Size')) : 50;
        firstDate       =   String.isNotBlank(posNotifyDataMap.get('First_Notification_Date')) ? Integer.valueOf(posNotifyDataMap.get('First_Notification_Date')) : 11;
        lastDate        =   String.isNotBlank(posNotifyDataMap.get('Last_Notification_Date')) ? Integer.valueOf(posNotifyDataMap.get('Last_Notification_Date')) : 21;


        agreementDateThreshold = String.isNotBlank(posNotifyDataMap.get('NPN_Agreement_Signed_Date_Threshold')) ? posNotifyDataMap.get('NPN_Agreement_Signed_Date_Threshold') : '60';

        if(System.Today().day() > firstDate) {
            agreementDateThreshold =  String.valueOf((lastDate - firstDate) + Integer.valueOf(agreementDateThreshold));
        }
        System.debug('agreementDateThreshold : '+ agreementDateThreshold);

        if(String.isNotBlank(posNotifyDataMap.get('Query_String'))) {
            query   = posNotifyDataMap.get('Query_String');
            query += ' AND NPN_Program_Signed_Date__c < LAST_N_DAYS :'+ agreementDateThreshold;
        }else{
            // If no POS submission record found for the specified YEAR_MONTH; implies that account should be selected for notification.
            query = 'SELECT Id, Name,  Owner.Email, Count_NonExmptd_Non_Registered__c,'+
                    '(SELECT Id, Email, Name, AccountId, Role__c, Community_User__c, Community_User_Active__c FROM Contacts WHERE RecordTypeId = :ptnrContRecTypeId AND Community_User_Active__c = true AND Role__c INCLUDES (\'POS \',\'Partner Primary Contact \')), '+
                    '(SELECT Account_Id__c,Id,MonthYearFormula__c FROM POS_Submissions__r WHERE MonthYearFormula__c = :yearMonth ORDER BY MonthYearFormula__c DESC LIMIT 1), '+
                    '(SELECT Id, Account__c, First_Reminder__c, Last_Reminder__c,YearMonth__c, Email_Sent_To__c FROM POS_Notifications_History__r WHERE YearMonth__c = :yearMonthStr AND CreatedDate = THIS_MONTH) '+
                    ' (SELECT Account_Name__c,Exempted_from_POS_Submission__c,Id,Partner_Competency__c,Partner_Program_Name__c,Partner_Sub_Program__c,Program_Level__c FROM Account_Attributes__r WHERE Exempted_from_POS_Submission__c = false AND Date_Competency_Terminated__c = NULL AND (NOT Partner_Program_Name__c IN (\'Distributor\',\'Tegra Embedded\'))) '+
                    'FROM Account WHERE RecordTypeId = :accRecTypeId AND NPN_Program_Termination_Date__c = NULL AND Inactive__c = FALSE AND POS_Portal_Submission__c = true AND NPN_Program_Signed_Date__c != 2099-12-31 AND NPN_Program_Signed_Date__c < LAST_N_DAYS:'+agreementDateThreshold+
                    'AND NPN_Active_Program_Competency__c != null AND ((NOT NPN_Active_Program_Competency__c LIKE \'%Distributor%\') OR ((NPN_Active_Program_Competency__c LIKE \'%Distributor%\') AND ((NPN_Active_Program_Competency__c LIKE \'%Solution Provider%\') OR (NPN_Active_Program_Competency__c LIKE \'%Solutions Integration Partner%\') OR (NPN_Active_Program_Competency__c LIKE \'%Cloud Service Provider%\') OR (NPN_Active_Program_Competency__c LIKE \'%OEM%\'))))';
        }

        System.debug('query String : '+ query + '\n');
    }

    /**
        @method name: execute
        @param SchedulableContext
        @return none
        @description : Schedular execute method
     */
    global void execute(SchedulableContext sc) {

        NPN_SubmitPosReminder_Batch batchName = new NPN_SubmitPosReminder_Batch();
        Database.executeBatch(batchName,batchSize);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){

        Map<Id, String> accIdOwnerEmailMap = new Map<Id, String>();
        Map<Id, Map<String, String> > accIdContactMap = new Map<Id, Map<String, String> >();
        List<POS_Notification_History__c> newNotificationList = new List<POS_Notification_History__c>();
        List<POS_Notification_History__c> updateNotificationList = new List<POS_Notification_History__c>();
        Map<Id,POS_Notification_History__c> accNotificationMap = new Map<Id, POS_Notification_History__c>();

        POS_Notification_History__c posObj;

        System.debug('scope.size() '+scope.size());

        for(Account acnt : scope) {
            System.debug('acnt.Account_Attributes__r.size() '+acnt.Account_Attributes__r.size());
            System.debug('acnt.POS_Submissions__r.size() '+acnt.POS_Submissions__r.size());
            System.debug('acnt.POS_Notifications_History__r.size() '+acnt.POS_Notifications_History__r.size());

            // Check if the account has any non exempted partner attributes  :: Added for SDS-2638
            if(!acnt.Account_Attributes__r.isEmpty()){
                
                // Check if a reminder is sent in the current month for this Account
                if(!acnt.POS_Notifications_History__r.isEmpty()) {
                    accNotificationMap.put(acnt.Id, acnt.POS_Notifications_History__r[0]);
                }


                /* If POS submission records are not present for current month AND
                   (If POS History records are not present for current month OR
                    If the first notification is not sent for the current month OR
                    If the first notification is sent but last is not sent for the current month.) 
                    
                    Rajat 20-May-2020 Added changes for SDS-1873 Registered level partners should only receive first reminder email.
                    Count_NonExmptd_Non_Registered__c
                */
                
                
                if( acnt.POS_Submissions__r.size() == 0 &&
                    (acnt.POS_Notifications_History__r.size() == 0 ||
                        (!acnt.POS_Notifications_History__r.isEmpty() && !acnt.POS_Notifications_History__r[0].First_Reminder__c && dtToday.day() <= firstDate) ||
                        (!acnt.POS_Notifications_History__r.isEmpty() && !acnt.POS_Notifications_History__r[0].Last_Reminder__c && dtToday.day() >= lastDate && acnt.Count_NonExmptd_Non_Registered__c > 0))) {

                    System.debug('acnt.Contacts.size() '+acnt.Contacts.size());
                
                    if(!acnt.Contacts.isEmpty()) {

                        // POS contact email mapping.
                        for(Contact cont : acnt.Contacts) {
                            if(!accIdContactMap.isEmpty() && accIdContactMap.containsKey(acnt.Id)) {
                                accIdContactMap.get(acnt.Id).put(cont.Email, cont.Name);
                            }else{
                                accIdContactMap.put(acnt.Id, new Map<String, String> {cont.Email => cont.Name});
                            }
                        }

                        // PBM email mapping
                        if(String.isNotBlank(acnt.Owner.Email)) {
                            accIdOwnerEmailMap.put(acnt.Id, acnt.Owner.Email);
                        }
                    }
                }
            }
        }

        System.debug('--> accIdOwnerEmailMap.size() '+ accIdOwnerEmailMap.size());
        System.debug('--> accIdContactMap.size() '+ accIdContactMap.size());

        if(!accIdContactMap.isEmpty()) {

            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Map<Integer, String> monthMap = new Map<Integer, String> {  1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June',
                                                                    7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'};
            String partnerUserName = '';
            String month = monthMap.get(dtToday.month());
            Date dtToday = System.today();

            OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'no_reply@nvidia.com'];

            for(Id actId : accIdContactMap.keySet()) {

                String emailSentTo = '';
                String pbmEmail = '';

                if(accNotificationMap.get(actId) == null ) {
                    posObj  = new POS_Notification_History__c();
                    posObj.Account__c = actId;
                    posObj.YearMonth__c = String.valueOf(yearMonth);
                }

                if(accIdOwnerEmailMap.get(actId) != null) {
                    pbmEmail = String.valueOf(accIdOwnerEmailMap.get(actId));
                    if(!emailSentTo.contains(pbmEmail)) {
                        emailSentTo += pbmEmail +';';
                    }
                }

                system.debug('--> accIdContactMap.get(actId).keySet() '+ accIdContactMap.get(actId).keySet());
                for(String eml : accIdContactMap.get(actId).keyset()) {

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    mail.setToAddresses(new String[] {eml});
                    mail.setOrgWideEmailAddressId(owa.id);
                    mail.setCcAddresses(new List<String> {pbmEmail});

                    if(!emailSentTo.contains(eml)) {
                        emailSentTo += eml +';';
                    }

                    partnerUserName = accIdContactMap.get(actId).get(eml);

                    // to send the reminder before 11th of the month
                    if(dtToday.day() <= firstDate) {
                        mail.setSubject(firstRemSub);

                        String firstFortnightHtmlBody = firstRemBody.replace('+partnerUserName+',partnerUserName).replace('+month+',month);
                        mail.setHtmlbody(firstFortnightHtmlBody);
                    }else{
                        mail.setSubject(lastRemSub);

                        String lastFortnightHtmlBody = lastRemBody.replace('+partnerUserName+',partnerUserName).replace('+month+',month);
                        mail.setHtmlbody(lastFortnightHtmlBody);
                    }
                    messages.add(mail);
                }

                if(dtToday.day() <= firstDate) {
                    if(accNotificationMap.get(actId) != null) {
                        accNotificationMap.get(actId).First_Reminder__c = true;
                        accNotificationMap.get(actId).Email_Sent_To__c = emailSentTo;
                        updateNotificationList.add(accNotificationMap.get(actId));
                    }else{
                        if(posObj != null) {
                            posObj.First_Reminder__c = true;
                            posObj.Email_Sent_To__c = emailSentTo;
                        }
                    }
                }else{
                    if(accNotificationMap.get(actId) != null && !updateNotificationList.contains(accNotificationMap.get(actId))) {
                        accNotificationMap.get(actId).Last_Reminder__c = true;
                        accNotificationMap.get(actId).Email_Sent_To__c = emailSentTo;
                        updateNotificationList.add(accNotificationMap.get(actId));
                    }else{
                        if(posObj != null) {
                            posObj.Last_Reminder__c = true;
                            posObj.Email_Sent_To__c = emailSentTo;
                        }
                    }
                }

                if(accNotificationMap.get(actId) == null) {
                    newNotificationList.add(posObj);
                }
            }

            try{
                System.debug('--> messages.size() '+ messages.size());
                if(!messages.isEmpty()) {
                    Messaging.reserveSingleEmailCapacity(messages.size());
                    Messaging.sendEmail(messages);
                }

                System.debug('--> newNotificationList.size() '+ newNotificationList.size());
                System.debug('--> updateNotificationList.size() '+ updateNotificationList.size());

                if(!newNotificationList.isEmpty()) {
                    System.debug('--> newNotificationList ::: '+ newNotificationList);
                    Database.SaveResult[] srListInsert = Database.Insert(newNotificationList, false);
                    System.debug('--> srListInsert ::: '+ srListInsert);
                }

                if(!updateNotificationList.isEmpty()) {
                    System.debug('--> updateNotificationList ::: '+ updateNotificationList);
                    Database.SaveResult[] srListUpdate = Database.Update(updateNotificationList, false);
                    System.debug('--> srListUpdate ::: '+ srListUpdate);
                }

            } catch (DmlException dmlEx) {
                System.debug('The following exception has occurred: ' + dmlEx.getMessage());
            } catch (Exception e) {
                System.debug('You have used up your daily allowance of mails');
            }
        }
    }

    global void finish(Database.BatchableContext bc){

        List<AsyncApexJob> existingJob = [SELECT Id,JobType,Status FROM AsyncApexJob WHERE ApexClass.Name ='NPN_SubmitPosReminder_Batch' AND JobType ='ScheduledApex' AND Status ='Queued'];

        if(existingJob.isEmpty()) {
            NPN_SubmitPosReminder_Batch sch = new NPN_SubmitPosReminder_Batch();
            String cronexp = String.isNotBlank(cronExpression) ? cronExpression : '0 0 0 11,21 * ? *';
            
            System.schedule('NPN_SubmitPosReminder_Batch',cronexp,sch);
        }
    }
}