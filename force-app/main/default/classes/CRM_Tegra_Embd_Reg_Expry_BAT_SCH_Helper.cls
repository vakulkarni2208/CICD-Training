/*
 * Batch Helper Class for the 'Opportunity' object.
 * Author: Manideep
 * Created Date: 02/14/2020
 * JIRA # SDS-1493
 * Description: This Batch Helper Class is being invoked by the Batch/Scheduler Class 'CRM_Tegra_Embd_Reg_Expry_BAT_SCH.cls' 
                * This is created as for the project 'Tegra Embedded Partner Expirations'.
                * Only the Opportunities that are child of Partner Accounts those that are tied up for the records in the object 'Tegra Embd Regstr Expiration by Partners' are 
                  considered for processing through this Batch Class.
                * This class does the following actions,
                  --> Sending the First Email Notifications
                  --> Sending the Second Email Notofications
                  --> Sending the Third Email Notifications
                  --> Updates the Opportunities to 'Expired'and assigns ownership to the PBM after sending the Third Email Notification.
                  --> Creates the Sent Email Notifications into the custom object 'Tegra Embd Regstr Expiry Notifications' for tracking the Emails being Sent.
    
  * SDS-2838: @Manideep: 12/16/2020: Replaced the DML 'Update' with 'Database.Update' for the Opportunity object only but left 
                                     TegraEmbdNotifications as is because this object doesn't have any customizations or background custom logic. 
        
*/
public class CRM_Tegra_Embd_Reg_Expry_BAT_SCH_Helper {  
    
  public static void excuteBatch_Helper(list<Opportunity> opptyScope) {
    
    list<Opportunity> oppExpList = new list<Opportunity>();
    list<Opportunity> oppOwnerhsipUpdateList = new list<Opportunity>();
    list<Tegra_Embd_Regstr_Expiry_Notifications__c> TERExpNotificationsList = new list<Tegra_Embd_Regstr_Expiry_Notifications__c>();
    
    list<Opportunity> firstEmailList = new list<Opportunity>(); 
    list<Opportunity> secondEmailList = new list<Opportunity>(); 
    list<Opportunity> thirdEmailList = new list<Opportunity>();
    map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c> tegEmbRegstrExpbyPartnersMap = new map<Id, Tegra_Embd_Regstr_Expiration_by_Partners__c>();
    
    //Email Sending 'To' collection
    map<Id, list<string>> firstEmailToAddressMap = new map<Id, list<string>>();
    map<Id, list<string>> secondEmailToAddressMap = new map<Id, list<string>>();
    map<Id, list<string>> thirdEmailToAddressMap = new map<Id, list<string>>();
            
    //Email Sending 'Cc' collection
    map<Id, list<string>> firstEmailCcAddressMap = new map<Id, list<string>>();
    map<Id, list<string>> secondEmailCcAddressMap = new map<Id, list<string>>();
    map<Id, list<string>> thirdEmailCcAddressMap = new map<Id, list<string>>();
    
    // Collection of Email Sending Status
    map<Id, Messaging.SingleEmailMessage> opptyEmailMessageMap = new map<Id, Messaging.SingleEmailMessage>();
    
    // Threshold limit by each Opportunity in a map
    map<Id, integer> oppThresholdLimitMap = new map<Id, integer>();
        
    //Extract the data from the type 'Hierarchy' Custom Setting Organization level
    Tegra_Embedded_Registration_Expirations__c tegraEmbdRegExpCS = Tegra_Embedded_Registration_Expirations__c.getOrgDefaults();
    integer defaultThresholdLimit = integer.valueOf(tegraEmbdRegExpCS.Default_Threshold_for_all_Partners__c);
    integer firstNotificationDay = integer.valueOf(tegraEmbdRegExpCS.First_Reminder__c);
    integer secondNotificationDay = integer.valueOf(tegraEmbdRegExpCS.Second_Reminder__c);
    integer thirdNotificationDay = integer.valueOf(tegraEmbdRegExpCS.Third_Reminder__c);
    string defaultOwnerEmailforinActivePBM = string.valueOf(tegraEmbdRegExpCS.Default_Oppty_Owner_Email_Id__c);
    string defaultCcEmailIds = string.valueOf(tegraEmbdRegExpCS.Default_Cc_Email_Ids__c);
    string owdSenderEmail = string.valueOf(tegraEmbdRegExpCS.OWD_Sender_Email_Address__c);
    string oppDetailLinkforParterUser = string.valueOf(tegraEmbdRegExpCS.Opportunity_Detail_Link_for_Partner_User__c);
    
    system.debug('tegraEmbdRegExpCS------>'+tegraEmbdRegExpCS);     
    system.debug('defaultThresholdLimit------>'+defaultThresholdLimit);
    system.debug('firstNotificationDay------>'+firstNotificationDay);
    system.debug('secondNotificationDay------>'+secondNotificationDay);
    system.debug('thirdNotificationDay------>'+thirdNotificationDay);
    system.debug('defaultOwnerEmailforinActivePBM----->'+defaultOwnerEmailforinActivePBM);
    system.debug('defaultCcEmailIds------>'+defaultCcEmailIds);
    system.debug('owdSenderEmail------>'+owdSenderEmail);
    system.debug('oppDetailLinkforParterUser------>'+oppDetailLinkforParterUser);
    
    // fetch the userId from the Default Owner's Email Id
    User dfOwner = [SELECT Id FROM User WHERE Email =:defaultOwnerEmailforinActivePBM limit 1];
        
    // Collect the Partner Accounts(Partner Sales Rep Company) with the custom thresholds for their Opportunities from the Custom Object 'Tegra Embd Regstr Expiration by Partners'
    list<Tegra_Embd_Regstr_Expiration_by_Partners__c> tegEmbRegstrExpbyPartnersList = [SELECT Id, Name, Partner_Sales_Rep_Company__c, Default_Threshold_Limit_for_Partner__c, Do_not_Expire_Registration__c, Expire_Registration__c 
                                                                                       FROM Tegra_Embd_Regstr_Expiration_by_Partners__c
                                                                                       WHERE Expire_Registration__c = true];
    if(!tegEmbRegstrExpbyPartnersList.isEmpty()) {
        for(Tegra_Embd_Regstr_Expiration_by_Partners__c TERP: tegEmbRegstrExpbyPartnersList) {
            tegEmbRegstrExpbyPartnersMap.put(TERP.Partner_Sales_Rep_Company__c, TERP);
        }    
    }                                                                                   
                    
    // Process only the Opportunities that are child of the Partners listed in the Custom object 'Tegra Embd Regstr Expiration by Partners' 
    list<Opportunity> oppFilteredScope = new list<Opportunity>();
    for(opportunity opty: opptyScope) {
        if(tegEmbRegstrExpbyPartnersMap.containsKey(opty.DR_Partner_Sales_Rep_Company__c)) {
           oppFilteredScope.add(opty);  
        }
    }
    system.debug('oppFilteredScope------>'+oppFilteredScope);
    
    // Process all Opportunities
    for(Opportunity opp: oppFilteredScope) {   
        
        // assign the default threshold limit
        integer oppThresholdLimit = defaultThresholdLimit; 
                    
        // pull if there are any Default Threshold limits by each Partner Accounts,
        // if the Opportunity has custom Threshold by each Partner then override the default threshold value.
        if(!tegEmbRegstrExpbyPartnersMap.isEmpty() && string.isNotBlank(string.valueOf(opp.DR_Partner_Sales_Rep_Company__c)) && tegEmbRegstrExpbyPartnersMap.containsKey(opp.DR_Partner_Sales_Rep_Company__c)       
            && string.isNotBlank(string.valueOf(tegEmbRegstrExpbyPartnersMap.get(opp.DR_Partner_Sales_Rep_Company__c).Default_Threshold_Limit_for_Partner__c))) {
               oppThresholdLimit = integer.valueOf(tegEmbRegstrExpbyPartnersMap.get(opp.DR_Partner_Sales_Rep_Company__c).Default_Threshold_Limit_for_Partner__c);
               system.debug('oppThresholdLimit by Partner------>'+oppThresholdLimit);
               oppThresholdLimitMap.put(opp.Id, oppThresholdLimit); 
        } 
        system.debug('oppThresholdLimitMap------>'+oppThresholdLimitMap);
        
        // if there is no threshold Limits by Partner then assign the default threshold limit to the Opportunity level threshold
        oppThresholdLimitMap.put(opp.Id, oppThresholdLimit);        
                
        system.debug('(opp.LastModifiedDate_by_Partner__c).daysBetween(Date.Today())------->'+(opp.LastModifiedDate_by_Partner__c).daysBetween(Date.Today()));      
        
        if(((opp.LastModifiedDate_by_Partner__c).daysBetween(Date.Today())) == (integer.valueOf(oppThresholdLimitMap.get(opp.Id)) - firstNotificationDay)) {         //check if the Opportunity's 'LastModifiedDate by Partner' is equal to the 'First Notificaiton' day, example:46th day         
                        
            // Send 'T-14' Email Notification to 'To' addresses
            firstEmailList.add(opp);
            list<String> firstEmailToAddress = new list<String>();
            firstEmailToAddress.add(opp.Owner.Email);
            firstEmailToAddressMap.put(opp.Id, firstEmailToAddress);          
            
            // Send 'T-14' Email Notification to 'Cc' addresses
            list<String> firstEmailCcAddress = new list<String>();  
            
            if(string.isNotBlank(string.valueOf(opp.DR_SalesOps_Approver__c)) && opp.DR_SalesOps_Approver__r.isActive) {
               firstEmailCcAddress.add(opp.DR_SalesOps_Approver__r.Email);   // add PBM's in the 'Cc'
            } else { 
               firstEmailCcAddress.add(defaultOwnerEmailforinActivePBM);  // add the Default Owner PBM's in the 'Cc' as the PBM above is Null/inActive  
            }
                        
            if(string.isNotBlank(defaultCcEmailIds)) {
               String[] tmpStrList = defaultCcEmailIds.split(';');
               firstEmailCcAddress.addAll(tmpStrList);
            }    
            firstEmailCcAddressMap.put(opp.Id, firstEmailCcAddress);
            
            opp.Opportunity_Expiration_Date__c = Date.Today() + firstNotificationDay;        // Populate the 'Opportunity Expired Date' field even though the Oportunity is not Expired yet
            opp.Opportunity_Detail_Link_for_Partner_User__c = oppDetailLinkforParterUser;    // Populate the Opportunity Detail Link foe the Partner User 
            oppExpList.add(opp); 
               
        }
        else if(((opp.LastModifiedDate_by_Partner__c).daysBetween(Date.Today())) == (integer.valueOf(oppThresholdLimitMap.get(opp.Id)) - secondNotificationDay)) {   //check if the Opportunity's 'LastModifiedDate by Partner' is equal to the 'Second Notification' day, example:55th day
            
            // Send 'T-5' Email Notification to 'To' addresses
            secondEmailList.add(opp);
            list<String> secondEmailToAddress = new list<String>();
            secondEmailtoAddress.add(opp.Owner.Email); 
            secondEmailToAddressMap.put(opp.Id, secondEmailtoAddress); 
            
            // Send 'T-5' Email Notification to 'Cc' addresses
            list<String> secondEmailCcAddress = new list<String>();
            
            if(string.isNotBlank(string.valueOf(opp.DR_SalesOps_Approver__c)) && opp.DR_SalesOps_Approver__r.isActive) {
               secondEmailCcAddress.add(opp.DR_SalesOps_Approver__r.Email);   // add PBM's in the 'Cc'
            } else {
               secondEmailCcAddress.add(defaultOwnerEmailforinActivePBM);  // add the Default Owner PBM's in the 'Cc' as the PBM above is Null/inActive  
            }
            
            if(string.isNotBlank(defaultCcEmailIds)) {
               String[] tmpStrList = defaultCcEmailIds.split(';');
               secondEmailCcAddress.addAll(tmpStrList); 
            }  
            secondEmailCcAddressMap.put(opp.Id, secondEmailCcAddress); 
            
            opp.Opportunity_Expiration_Date__c = Date.Today() + secondNotificationDay;       // Populate the 'Opportunity Expired Date' field even though the Oportunity is not Expired yet
            opp.Opportunity_Detail_Link_for_Partner_User__c = oppDetailLinkforParterUser;    // Populate the Opportunity Detail Link foe the Partner User 
            oppExpList.add(opp); 
                 
        }
        else if(((opp.LastModifiedDate_by_Partner__c).daysBetween(Date.Today())) >= (integer.valueOf(oppThresholdLimitMap.get(opp.Id)) - thirdNotificationDay)) {    //check if the Opportunity's 'LastModifiedDate by Partner' is equal to or greater than final expiration day, example:60th day   
            
            // Send 'T-0' Email Notification to 'To' addresses
            thirdEmailList.add(opp); 
            list<String> thirdEmailToAddress = new list<String>();
            thirdEmailtoAddress.add(opp.Owner.Email);
            thirdEmailtoAddressMap.put(opp.Id, thirdEmailtoAddress);
            
            // Send 'T-0' Email Notification to 'Cc' addresses
            list<String> thirdEmailCcAddress = new list<String>();
            
            if(string.isNotBlank(string.valueOf(opp.DR_SalesOps_Approver__c)) && opp.DR_SalesOps_Approver__r.isActive) {
               thirdEmailCcAddress.add(opp.DR_SalesOps_Approver__r.Email);   // add PBM's in the 'Cc'
            } else {
               thirdEmailCcAddress.add(defaultOwnerEmailforinActivePBM);  // add the Default Owner PBM's in the 'Cc' as the PBM above is Null/inActive    
            } 
            
            if(string.isNotBlank(defaultCcEmailIds)) {
               String[] tmpStrList = defaultCcEmailIds.split(';');
               thirdEmailCcAddress.addAll(tmpStrList);  
            } 
            thirdEmailCcAddressMap.put(opp.Id, thirdEmailCcAddress); 
            
            // Flag the Opportunity as Expired, populate 'Expiration Date' and assign the Opportunity's Ownership to the PBM (Opportunity's Account Owner)
            opp.Opportunity_Expired__c = true;
            opp.Opportunity_Expiration_Date__c = Date.Today();
            opp.TE_Previous_Opportunity_Owner_Name__c = opp.Owner.Name;                      // This field will be used in the Third Email Notificaiton to show Opportunity Owner Name
            opp.Opportunity_Detail_Link_for_Partner_User__c = oppDetailLinkforParterUser;    // Populate the Opportunity Detail Link foe the Partner User
                        
            if(string.isNotBlank(string.valueOf(opp.DR_SalesOps_Approver__c)) && opp.DR_SalesOps_Approver__r.isActive) {
               opp.OwnerId = opp.DR_SalesOps_Approver__c;
            } else {
               opp.OwnerId = dfOwner.Id;
            } 
                        
            oppExpList.add(opp);  
                              
        }                       
    } // end of 'for' loop
    
    system.debug('firstEmailList----->'+firstEmailList);
    system.debug('firstEmailToAddressMap----->'+firstEmailToAddressMap);
    system.debug('firstEmailCcAddressMap----->'+firstEmailCcAddressMap);
    
    system.debug('secondEmailList----->'+secondEmailList);
    system.debug('secondEmailToAddressMap----->'+secondEmailToAddressMap);
    system.debug('secondEmailCcAddressMap----->'+secondEmailCcAddressMap);
    
    system.debug('thirdEmailList----->'+thirdEmailList);
    system.debug('thirdEmailtoAddressMap----->'+thirdEmailtoAddressMap);
    system.debug('thirdEmailCcAddressMap----->'+thirdEmailCcAddressMap);
    
    // Update the qualified Opportunities as 'Expired' and populate the 'Opportunity Expired Date' field
    if(!oppExpList.isEmpty()) {
        system.debug('oppExpList---->'+oppExpList);
        //update oppExpList; 
        Database.update(oppExpList, false);  // Update the remaining records in the batch even if there are some failures
    } 
    
    /*
     * Sending the Reminder Email notifications
     * Because we cannot send the emails direclty using Email Templates (WhatId doesn't accept OpportunityId), so lets use a dummy contact Id in the WhatId and attempt to send email using Database.savepoint. 
       Thenafter collect the details generated by the Salesforce Email and this time send the actual email. Through this way we can use the all the subject, body, etc., full content populated by from
       the Email template itself. otherwise we would have to send email through the Apex hardcoding. 
    */
    OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE Address =: owdSenderEmail];
    
    // Picking a dummy/temporary Contact from the system
    list<Contact> ctclist = [SELECT Id, Email FROM Contact WHERE Email != NULL limit 1];
    
    // Send 1st Email Notification for those Opportunities filtered above
    if(!firstEmailList.isEmpty()) {
        
        // Remaining days to Expire        
        integer RemainingDaystoExpire = (firstNotificationDay + defaultThresholdLimit) - defaultThresholdLimit;
        
        // Send first notification email using the Email Template
        EmailTemplate etemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'First_Expiry_Email_Notification'];
        
        List<Messaging.SingleEmailMessage> attempt1Allmsgs = new List<Messaging.SingleEmailMessage>();     // This is an failure attempt to collect the generated emails.
        List<Messaging.SingleEmailMessage> actual1AllmsgsList = new List<Messaging.SingleEmailMessage>();  // This is an actual email list for sending
               
        for(Opportunity opty: firstEmailList) {
            Messaging.SingleEmailMessage fmail = new Messaging.SingleEmailMessage();
            fmail.setTemplateID(etemplate.Id); 
            fmail.setToAddresses(firstEmailToAddressMap.get(opty.Id));
            fmail.setCcAddresses(firstEmailCcAddressMap.get(opty.Id));
            fmail.setTargetObjectId(ctclist[0].Id);
            fmail.setTreatTargetObjectAsRecipient(false);
            fmail.setWhatId(opty.Id);
            fmail.setOrgWideEmailAddressId(owa.Id);
            attempt1Allmsgs.add(fmail);
        }       
        system.debug('attempt1Allmsgs----->'+attempt1Allmsgs);   
                
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(attempt1Allmsgs);
        Database.rollback(sp);
                        
        // For each SingleEmailMessage that was just populated by the sendEmail() method above, copy its contents to a new SingleEmailMessage. Then send those new messages.
        for(Messaging.SingleEmailMessage email : attempt1Allmsgs) {
            Messaging.SingleEmailMessage fEmailtoSend = new Messaging.SingleEmailMessage();
            fEmailtoSend.setToAddresses(email.getToAddresses());            
            fEmailtoSend.setCcAddresses(email.getCcAddresses());
            fEmailtoSend.setPlainTextBody(email.getPlainTextBody());
            fEmailtoSend.setHTMLBody(email.getHTMLBody());
            string strSubj = email.getSubject() + ' ' + RemainingDaystoExpire + ' days';
            fEmailtoSend.setSubject(strSubj);
            fEmailtoSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
            actual1AllmsgsList.add(fEmailtoSend);
            opptyEmailMessageMap.put(email.getWhatId(), fEmailtoSend);    // collecting all the email messages in a map
        }
        system.debug('actual1AllmsgsList------->'+actual1AllmsgsList);
        //Messaging.sendEmail(actual1AllmsgsList);     // Sending the First Reminder Email notification
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(actual1AllmsgsList);     // Sending the First Reminder Email notification
        
        system.debug('opptyEmailMessageMap before remove 1---->'+opptyEmailMessageMap);
        
        // Check if all the Emails are sent succesfully        
        for(Messaging.SendEmailResult ser: emailResults) {
            // if Emails are NOT sent successfully
            if(!ser.isSuccess()) {
               Messaging.SendEmailError[] allErrors = ser.getErrors();
               if(!allErrors.isEmpty()) {
                   for(Messaging.SendEmailError currentError: allErrors) {
                       system.debug('Email is not sent for the Opportunity: ' + currentError.getTargetObjectId()
                                     + 'Error Message: ' + currentError.getMessage()
                                     + 'Status Code: ' + currentError.getstatusCode());
                       opptyEmailMessageMap.remove(currentError.getTargetObjectId());
                   }       
               }   
            }                        
        } 
        system.debug('opptyEmailMessageMap after remove 1------>'+opptyEmailMessageMap);
        
        // create the successfully sent emails into a new custom object, so that they can be tracked back
        if(!opptyEmailMessageMap.isEmpty()) {
            for(Opportunity opp: firstEmailList) {    
                if(opptyEmailMessageMap.containsKey(opp.Id)) {
                   
                   Tegra_Embd_Regstr_Expiry_Notifications__c fEmail = new Tegra_Embd_Regstr_Expiry_Notifications__c();
                   fEmail.Opportunity__c = opp.Id;
                   fEmail.First_Notification_Sent__c = true;
                   fEmail.First_Notification_Sent_On__c = Date.Today();
                   // assign 'To' addresses to the field, email will always have 'To' addresses             
                   list<string> tempToStr = opptyEmailMessageMap.get(opp.Id).ToAddresses;
                   fEmail.First_Notification_Sent_To_Addresses__c = string.join(tempToStr,'; ');
                   // assign 'Cc' addresses to the field, email will always have 'Cc' addresses                 
                   list<string> tempCcStr = opptyEmailMessageMap.get(opp.Id).CcAddresses;
                   fEmail.First_Notification_Sent_Cc_Addresses__c = string.join(tempCcStr,'; ');   
                   
                   TERExpNotificationsList.add(fEmail); 
                }                    
            }
        }
        system.debug('TERExpNotificationsList.size() 1------>'+TERExpNotificationsList.size());  
                 
    } // end of First email notification 
    
    // Send 2nd Email Notification for those Opportunities filtered above
    if(!secondEmailList.isEmpty()) {    
            
        // Remaining days to Expire        
        integer RemainingDaystoExpire = (secondNotificationDay + defaultThresholdLimit) - defaultThresholdLimit;
        
        // Send second notification eamil using the Email Template
        EmailTemplate etemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Second_Expiry_Email_Notification'];
        
        List<Messaging.SingleEmailMessage> attempt2Allmsgs = new List<Messaging.SingleEmailMessage>();     // This is an failure attempt to collect the generated emails.
        List<Messaging.SingleEmailMessage> actual2AllmsgsList = new List<Messaging.SingleEmailMessage>();  // This is an actual email list for sending
        
        for(Opportunity opty: secondEmailList) {
            Messaging.SingleEmailMessage secdmail = new Messaging.SingleEmailMessage();
            secdmail.setTemplateID(etemplate.Id); 
            secdmail.setToAddresses(secondEmailToAddressMap.get(opty.Id));
            secdmail.setCcAddresses(secondEmailCcAddressMap.get(opty.Id));
            secdmail.setTargetObjectId(ctclist[0].Id);
            secdmail.setTreatTargetObjectAsRecipient(false);
            secdmail.setWhatId(opty.Id);
            secdmail.setOrgWideEmailAddressId(owa.Id);
            attempt2Allmsgs.add(secdmail);            
        }
        system.debug('attempt2Allmsgs----->'+attempt2Allmsgs);
                
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(attempt2Allmsgs);
        Database.rollback(sp);
        
        // For each SingleEmailMessage that was just populated by the sendEmail() method above, copy its contents to a new SingleEmailMessage. Then send those new messages.
        for(Messaging.SingleEmailMessage email : attempt2Allmsgs) {
            Messaging.SingleEmailMessage sEmailtoSend = new Messaging.SingleEmailMessage();
            sEmailtoSend.setToAddresses(email.getToAddresses());
            sEmailtoSend.setCcAddresses(email.getCcAddresses());
            sEmailtoSend.setPlainTextBody(email.getPlainTextBody());
            sEmailtoSend.setHTMLBody(email.getHTMLBody());
            string strSubj = email.getSubject() + ' ' + RemainingDaystoExpire + ' days';            
            sEmailtoSend.setSubject(strSubj);
            sEmailtoSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
            actual2AllmsgsList.add(sEmailtoSend);
            opptyEmailMessageMap.put(email.getWhatId(), sEmailtoSend);    // collecting all the email messages in a map
        }
        system.debug('actual2AllmsgsList------->'+actual2AllmsgsList);
        //Messaging.sendEmail(actual2AllmsgsList);     // Sending the Second Reminder Email notification
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(actual2AllmsgsList);     // Sending the Second Reminder Email notification
        
        system.debug('opptyEmailMessageMap before remove 2---->'+opptyEmailMessageMap);
                 
        // Check if all the Emails are sent succesfully        
        for(Messaging.SendEmailResult ser: emailResults) {
            // if Emails are NOT sent successfully
            if(!ser.isSuccess()) {
               Messaging.SendEmailError[] allErrors = ser.getErrors();
               if(!allErrors.isEmpty()) {
                   for(Messaging.SendEmailError currentError: allErrors) {
                       system.debug('Email is not sent for the Opportunity 2: ' + currentError.getTargetObjectId()
                                     + 'Error Message: ' + currentError.getMessage()
                                     + 'Status Code: ' + currentError.getstatusCode());
                       opptyEmailMessageMap.remove(currentError.getTargetObjectId());
                   }       
               }   
            }                        
        }
        system.debug('opptyEmailMessageMap after remove 2------>'+opptyEmailMessageMap); 
        
        // create the successfully sent emails into a new custom object, so that they can be tracked back
        if(!opptyEmailMessageMap.isEmpty()) {
            for(Opportunity opp: secondEmailList) {    
                if(opptyEmailMessageMap.containsKey(opp.Id)) {
                
                   Tegra_Embd_Regstr_Expiry_Notifications__c sEmail = new Tegra_Embd_Regstr_Expiry_Notifications__c();
                   sEmail.Opportunity__c = opp.Id;
                   sEmail.Second_Notification_Sent__c = true;
                   sEmail.Second_Notification_Sent_On__c = Date.Today();
                   // assign 'To' addresses to the field, email will always have 'To' addresses                 
                   list<string> tempToStr = opptyEmailMessageMap.get(opp.Id).ToAddresses;
                   sEmail.Second_Notification_Sent_To_Addresses__c = string.join(tempToStr,'; ');
                   // assign 'Cc' addresses to the field, email will always have 'Cc' addresses             
                   list<string> tempCcStr = opptyEmailMessageMap.get(opp.Id).CcAddresses;
                   sEmail.Second_Notification_Sent_Cc_Addresses__c = string.join(tempCcStr,'; ');
                
                   TERExpNotificationsList.add(sEmail); 
                }                    
            }
        }
        system.debug('TERExpNotificationsList.size() 2------>'+TERExpNotificationsList.size());
                
    } // end of Second email notification 
    
    // Send 3rd/final Email Notification for those Opportunities filtered above
    if(!thirdEmailList.isEmpty()) {
                
        // Remaining days to Expire        
        integer RemainingDaystoExpire = (thirdNotificationDay + defaultThresholdLimit) - defaultThresholdLimit;
        
        // Send Third notification eamil using the Email Template
        EmailTemplate etemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Third_Expiry_Email_Notification'];
        
        List<Messaging.SingleEmailMessage> attempt3Allmsgs = new List<Messaging.SingleEmailMessage>();     // This is an failure attempt to collect the generated emails.
        List<Messaging.SingleEmailMessage> actual3AllmsgsList = new List<Messaging.SingleEmailMessage>();  // This is an actual email list for sending
        
        List<Messaging.SingleEmailMessage> allmsg3 = new List<Messaging.SingleEmailMessage>();
        
        for(Opportunity opty: thirdEmailList) {
            Messaging.SingleEmailMessage thrdmail = new Messaging.SingleEmailMessage();
            thrdmail.setTemplateID(etemplate.Id); 
            thrdmail.setToAddresses(thirdEmailToAddressMap.get(opty.Id));
            thrdmail.setCcAddresses(thirdEmailCcAddressMap.get(opty.Id));
            thrdmail.setTargetObjectId(ctclist[0].Id);
            thrdmail.setTreatTargetObjectAsRecipient(false);
            thrdmail.setWhatId(opty.Id);
            thrdmail.setOrgWideEmailAddressId(owa.Id);
            attempt3Allmsgs.add(thrdmail);            
        }
        system.debug('attempt3Allmsgs----->'+attempt3Allmsgs);
        
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(attempt3Allmsgs);
        Database.rollback(sp);
        
        // For each SingleEmailMessage that was just populated by the sendEmail() method above, copy its contents to a new SingleEmailMessage. Then send those new messages.
        for(Messaging.SingleEmailMessage email : attempt3Allmsgs) {
            Messaging.SingleEmailMessage tEmailtoSend = new Messaging.SingleEmailMessage();
            tEmailtoSend.setToAddresses(email.getToAddresses());
            tEmailtoSend.setCcAddresses(email.getCcAddresses());
            tEmailtoSend.setPlainTextBody(email.getPlainTextBody());
            tEmailtoSend.setHTMLBody(email.getHTMLBody());
            /*
            string strSubj = email.getSubject() + ' ' + RemainingDaystoExpire + ' days';            
            tEmailtoSend.setSubject(strSubj);
            */
            tEmailtoSend.setSubject(email.getSubject());
            tEmailtoSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
            actual3AllmsgsList.add(tEmailtoSend);
            opptyEmailMessageMap.put(email.getWhatId(), tEmailtoSend);    // collecting all the email messages in a map
        }
        system.debug('actual3AllmsgsList------->'+actual3AllmsgsList);
        //Messaging.sendEmail(actual3AllmsgsList);     // Sending the Third/Final Reminder Email notification
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(actual3AllmsgsList);     // Sending the Third/Final Reminder Email notification
        
        system.debug('opptyEmailMessageMap before remove 3---->'+opptyEmailMessageMap);
                
        // Check if all the Emails are sent succesfully        
        for(Messaging.SendEmailResult ser: emailResults) {
            // if Emails are NOT sent successfully
            if(!ser.isSuccess()) {
               Messaging.SendEmailError[] allErrors = ser.getErrors();
               if(!allErrors.isEmpty()) {
                   for(Messaging.SendEmailError currentError: allErrors) {
                       system.debug('Email is not sent for the Opportunity 3: ' + currentError.getTargetObjectId()
                                     + 'Error Message: ' + currentError.getMessage()
                                     + 'Status Code: ' + currentError.getstatusCode());
                       opptyEmailMessageMap.remove(currentError.getTargetObjectId());
                   }       
               }   
            }                        
        }
        system.debug('opptyEmailMessageMap after remove 3------>'+opptyEmailMessageMap); 
        
        // create the successfully sent emails into a new custom object, so that they can be tracked back
        if(!opptyEmailMessageMap.isEmpty()) {
            for(Opportunity opp: thirdEmailList) { 
                if(opptyEmailMessageMap.containsKey(opp.Id)) {        
                
                   Tegra_Embd_Regstr_Expiry_Notifications__c thrdEmail = new Tegra_Embd_Regstr_Expiry_Notifications__c();
                   thrdEmail.Opportunity__c = opp.Id;
                   thrdEmail.Third_Notification_Sent__c = true;
                   thrdEmail.Third_Notification_Sent_On__c = Date.Today();
                   // assign 'To' addresses to the field                
                   list<string> tempToStr = opptyEmailMessageMap.get(opp.Id).ToAddresses;
                   thrdEmail.Third_Notification_Sent_To_Addresses__c = string.join(tempToStr,'; ');
                   // assign 'Cc' addresses to the field, email will always have 'Cc' addresses             
                   list<string> tempCcStr = opptyEmailMessageMap.get(opp.Id).CcAddresses;
                   thrdEmail.Third_Notification_Sent_Cc_Addresses__c = string.join(tempCcStr,'; ');
                
                   TERExpNotificationsList.add(thrdEmail); 
                }                    
            }
        }  
        system.debug('TERExpNotificationsList.size() 3------>'+TERExpNotificationsList.size()); 
                
    }  // end of Third email notification           
        
    // Create Email notificaitons into the Custom object
    if(!TERExpNotificationsList.isEmpty()) {
        system.debug('TERExpNotificationsList------>'+TERExpNotificationsList);  
        insert TERExpNotificationsList;
    }
    
  } // end of excuteBatch_Helper()  
    
}