public without sharing class NV_CommunityHomePageContactUsController {
    
    @AuraEnabled
    public static list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper{get;set;}
    
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = new Attachment();
        a.parentId = parentId;
 
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        
        insert a;
        
        return a.Id;
    }
    
    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update a;
    }
    
    
    @AuraEnabled
    public static list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper> getNVContacts() {
        set<String> setContactUserPortalGroups = new set<String>();
        //string contactId;
        string contactId = [select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
        Contact contactDetail = [Select FirstName, LastName, Email, Phone, MobilePhone, Portal_User_Content_Type__c, Account.name, Account.Owner.Name, Account.Owner.email,
                                Account.Owner.Phone,Account.BillingCountry, Account.BillingState, Account.Billing_Region__c, Account.Billing_Sub_Region__c, Portal_Groups__c
                            From Contact 
                            Where Id =:contactId];
        if(contactDetail.Portal_Groups__c != '')
            setContactUserPortalGroups.addAll(contactDetail.Portal_Groups__c.split(';'));
        set<string> contentTypes = returnContentTypeSet(setContactUserPortalGroups);
        lstNVIDIAContactsProductWiseWrapper = new list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper>();
        lstNVIDIAContactsProductWiseWrapper = NV_UtilityClass.putAllNVIDIACONTACTDetail(contactDetail, contentTypes);
        system.debug(lstNVIDIAContactsProductWiseWrapper);
        return lstNVIDIAContactsProductWiseWrapper;
    }
    
    @AuraEnabled
    public static NV_CommunityHomePageContactUsController.ContactUsData getContactUsData() {
        //string contactId;
        string contactId = [select ContactId from user where Id=:UserInfo.getUserId()].ContactId;
        Contact contactDetail = [Select FirstName, LastName, Email, Phone, MobilePhone, Portal_User_Content_Type__c, Account.name, AccountId, Account.Owner.Name, Account.Owner.email,
                                Account.Owner.Phone,Account.BillingCountry, Account.BillingState, Portal_Groups__c, account.EAR_Restricted__c
                            From Contact 
                            Where Id =:contactId];
        if(contactDetail.account.EAR_Restricted__c) 
            return new NV_CommunityHomePageContactUsController.ContactUsData(false, new NV_CommunityHomePageContactUsController.LogASupportRequest('',contactDetail.Account.Name, contactDetail.AccountId, contactDetail.FirstName +' '+ contactDetail.LastName  , contactDetail.Email, contactDetail.Phone,'','',''), new NV_CommunityHomePageContactUsController.AskAQuestion(contactDetail.AccountId, contactDetail.Account.Name), new NV_CommunityHomePageContactUsController.TrainingRequest(contactDetail.AccountId, contactDetail.Account.Name));
        return new NV_CommunityHomePageContactUsController.ContactUsData(true, new NV_CommunityHomePageContactUsController.LogASupportRequest('',contactDetail.Account.Name, contactDetail.AccountId, contactDetail.FirstName +' '+ contactDetail.LastName  , contactDetail.Email, contactDetail.Phone,'','',''), new NV_CommunityHomePageContactUsController.AskAQuestion(contactDetail.AccountId, contactDetail.Account.Name), new NV_CommunityHomePageContactUsController.TrainingRequest(contactDetail.AccountId, contactDetail.Account.Name));            
    }
    
    public static set<string> returnContentTypeSet(set<string> setContactUserPortalGroups){
        set<string> contentTypes = new set<string>();
        list<NV_Permissions_and_PCL_Mapping__c> lstNV_Permissions_and_PCL_Mapping = NV_Permissions_and_PCL_Mapping__c.getall().values();
        for(NV_Permissions_and_PCL_Mapping__c objNV_Permissions_and_PCL_Mapping : lstNV_Permissions_and_PCL_Mapping) {
          if(setContactUserPortalGroups.contains(objNV_Permissions_and_PCL_Mapping.combination__c)) {
            String subProgram = objNV_Permissions_and_PCL_Mapping.Sub_Program__c==null?'':objNV_Permissions_and_PCL_Mapping.Sub_Program__c ;
            String strProgramNameCompetencyType = objNV_Permissions_and_PCL_Mapping.Program_Name__c + subProgram + objNV_Permissions_and_PCL_Mapping.Competency__c;
            //String strProgramNameCompetencyType = objNV_Permissions_and_PCL_Mapping.Program_Name__c + objNV_Permissions_and_PCL_Mapping.Competency__c;
            contentTypes.add(strProgramNameCompetencyType);
          }
        }
        return contentTypes;
    }
    
    @AuraEnabled        
    public static Boolean sendEmail_askAQuestion(String strCompetency, String emailSubject, String emailBody, String strStepsToReproduce, String attachmentId){
        User usr = [select id,name, accountId, contactId, contact.phone,contact.mobilephone from user where id=:UserInfo.getUserId()];
        system.debug(strCompetency + '' + emailBody);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>(); 
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();        
        String[] toAddresses;
        if(attachmentId != null && attachmentId != '') {
            Attachment att = [select id,name,body from Attachment where id =:attachmentId];
            efa.setFileName(att.name);
            efa.setBody(att.body);
            fileAttachments.add(efa);
        }
        List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
        
        if(lstCSPortalToggles != null && lstCSPortalToggles.size()>0){
            for(Portal_Toggles__c eachPortalToggle: lstCSPortalToggles){
                if(strCompetency == eachPortalToggle.Name){
                    if(eachPortalToggle.Ask_A_Question_Email__c != null){
                        toAddresses = new String[] {eachPortalToggle.Ask_A_Question_Email__c};
                        break;
                    }
                }
            }
        }
        if(fileAttachments.size() > 0){    
            mail.setFileAttachments(fileAttachments);
        } 
        mail.setToAddresses(toAddresses);                
        //mail.setSubject('Ask a Question: ' + (String)mapAskAQuestion.get('emailSubject') + ' | Competency = ' + (String)((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value') );
        mail.setSubject(COMM_Constants.ASK_A_QUESTION_SUBJECT +' '+ emailSubject + ' | Competency = ' + strCompetency );
        mail.setBccSender(false);       
        mail.setPlainTextBody(emailBody + '\n\n\n' + strStepsToReproduce);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        Support_Request_And_Question__c supportRec = new Support_Request_And_Question__c();
        supportRec.Account__c = usr.AccountId;
        supportRec.Contact__c = usr.contactId;
        supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_FULL;
        supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_ASK_A_QUESTION;
        supportRec.Competency__c = strCompetency;
        supportRec.Contact_Phone_Number__c =  usr.contact.Phone;
        supportRec.Short_Description__c = null;
        supportRec.Problem_Description__c = null;
        supportRec.Steps_to_Reproduce_Problem__c = strStepsToReproduce;
        supportRec.AAQ_Subject__c = emailSubject;
        supportRec.AAQ_Body__c = emailBody;
        insert supportRec;
        
        return true;
    }
    
    @AuraEnabled        
    public static Boolean sendEmail_TrainingRequest(String strCompetency, String emailSubject, String emailBody, String strStepsToReproduce, String attachmentId){
        User usr = [select id,name, accountId, contactId, contact.phone,contact.mobilephone from user where id=:UserInfo.getUserId()];
        system.debug(strCompetency + '' + emailBody);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>(); 
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();        
        String[] toAddresses;
        if(attachmentId != null && attachmentId != '') {
            Attachment att = [select id,name,body from Attachment where id =:attachmentId];
            efa.setFileName(att.name);
            efa.setBody(att.body);
            fileAttachments.add(efa);
        }
        List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();
        
        if(lstCSPortalToggles != null && lstCSPortalToggles.size()>0){
            for(Portal_Toggles__c eachPortalToggle: lstCSPortalToggles){
                if(strCompetency == eachPortalToggle.Name){
                    if(eachPortalToggle.GPU_Genius_Training_Email__c!= null){
                        toAddresses = new String[] {eachPortalToggle.GPU_Genius_Training_Email__c};
                        break;
                    }
                }
            }
        }
        if(fileAttachments.size() > 0){    
            mail.setFileAttachments(fileAttachments);
        } 
        mail.setToAddresses(toAddresses);                
        //mail.setSubject('Ask a Question: ' + (String)mapAskAQuestion.get('emailSubject') + ' | Competency = ' + (String)((Map<String, Object>)mapAskAQuestion.get('selectedContentType')).get('value') );
        mail.setSubject('Training Request' +' '+ emailSubject + ' | Competency = ' + strCompetency );
        mail.setBccSender(false);       
        mail.setPlainTextBody(emailBody + '\n\n\n' + strStepsToReproduce);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        Support_Request_And_Question__c supportRec = new Support_Request_And_Question__c();
        supportRec.Account__c = usr.AccountId;
        supportRec.Contact__c = usr.contactId;
        supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_FULL;
        supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_ASK_A_QUESTION;
        supportRec.Competency__c = strCompetency;
        supportRec.Contact_Phone_Number__c =  usr.contact.Phone;
        supportRec.Short_Description__c = null;
        supportRec.Problem_Description__c = null;
        supportRec.Steps_to_Reproduce_Problem__c = strStepsToReproduce;
        supportRec.AAQ_Subject__c = emailSubject;
        supportRec.AAQ_Body__c = emailBody;
        insert supportRec;
        
        return true;
    }
    
    @AuraEnabled        
    public static Boolean sendEmail_LogASupportRequest(LogASupportRequest objLSR){
        User usr = [select id,name, accountId, contactId, contact.phone,contact.mobilephone from user where id=:UserInfo.getUserId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>(); 
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();        
        String[] toAddresses;
        
        system.debug(objLSR.attachmentId );
        if(objLSR.attachmentId != null && objLSR.attachmentId != '') {
            Attachment att = [select id,name,body from Attachment where id =:objLSR.attachmentId];
            efa.setFileName(att.name);
            efa.setBody(att.body);
            fileAttachments.add(efa);
        }
        
        List<Portal_Toggles__c> lstCSPortalToggles = Portal_Toggles__c.getAll().values();        
        if(lstCSPortalToggles != null && lstCSPortalToggles.size()>0){
            for(Portal_Toggles__c eachPortalToggle: lstCSPortalToggles){
                if(objLSR.strCompetency == eachPortalToggle.Name){
                    if(eachPortalToggle.Log_A_Support_Request_Email__c != null){
                        toAddresses = new String[] {eachPortalToggle.Log_A_Support_Request_Email__c};
                        break;
                    }
                }
            }
        }
        mail.setToAddresses(toAddresses);        
         if(fileAttachments.size() > 0){    
            mail.setFileAttachments(fileAttachments);
        }         
        DateTime d = System.now();
        mail.setSubject(COMM_Constants.LOG_A_SUPPORT_SUBJECT + UserInfo.getFirstName() +' '+ UserInfo.getLastName() + ' on ' + d.month() + '/' + d.day() + '/' + d.year() + '/' + d.time() + ' on ' + objLSR.strProblemType);
        mail.setBccSender(false);       
         //build the email body
        string html = '<table width="100%"><tr><td width="30%"><b>Company Name</b></td>';        
        html += '<td>' + objLSR.strAccountName + '</td></tr>';        
        html += '<tr><td><b>Contact Name</b></td>';
        html += '<td>' + objLSR.strName + '</td></tr>';
        html += '<tr><td><b>Contact Email Address</b></td>';
        html += '<td>' + objLSR.strEmail + '</td></tr>';
        html += '<tr><td><b>Contact Phone Number</b></td>';
        html += '<td>' + objLSR.strPhone + '</td></tr>';  
        html += '<tr><td><b>Short Description</b></td>';
        html += '<td>' + objLSR.strProblemType + '</td></tr>';
        html += '<tr><td><b>Problem Description</b></td>';
        html += '<td>' + objLSR.strProblemDescription + '</td></tr>';
        html += '<tr><td><b>Steps to Reproduce Problem</b></td>';
        html += '<td>' + objLSR.strStepsToReproduce + '</td></tr></table>';
            
        //set html body
        mail.setHtmlbody(html);      
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        Support_Request_And_Question__c supportRec = new Support_Request_And_Question__c();
        supportRec.Account__c = usr.AccountId;
        supportRec.Contact__c = usr.contactId;
        supportRec.Portal_Type__c = COMM_Constants.PORTAL_TYPE_FULL;
        supportRec.Request_Type__c = COMM_Constants.SUPPORT_REQTYPE_LOG_A_SUPPORT_REQ;
        supportRec.Competency__c = objLSR.strCompetency;
        supportRec.Contact_Phone_Number__c =  usr.contact.Phone;
        supportRec.Short_Description__c = objLSR.strProblemType;
        supportRec.Problem_Description__c = objLSR.strProblemDescription;
        supportRec.Steps_to_Reproduce_Problem__c = objLSR.strStepsToReproduce;
        insert supportRec;
        
        return true;
    }
    
    public class LogASupportRequest {
        @AuraEnabled public String strCompetency { get; set; }
        @AuraEnabled public String strAccountName { get; set; }
        @AuraEnabled public String strAccountId { get; set; }
        @AuraEnabled public String strName { get; set; }
        @AuraEnabled public String strEmail { get; set; }
        @AuraEnabled public String strPhone { get; set; }
        @AuraEnabled public String strProblemType { get; set; }
        @AuraEnabled public String strProblemDescription { get; set; }
        @AuraEnabled public String strStepsToReproduce { get; set; }
        @AuraEnabled public String attachmentId { get; set; }
        public LogASupportRequest(String strCompetency, String strAccountName, String strAccountId, String strName, String strEmail, String strPhone, String strProblemType, String strProblemDescription, String strStepsToReproduce) {
            this.strCompetency = strCompetency;
            this.strAccountName = strAccountName;
            this.strAccountId = strAccountId;
            this.strName = strName;
            this.strEmail = strEmail;
            this.strPhone = strPhone;
            this.strProblemType = strProblemType;
            this.strProblemDescription = strProblemDescription;
            this.strStepsToReproduce = strStepsToReproduce ;
        }
        public LogASupportRequest() {
        }
    }
    
    public class TrainingRequest {
        @AuraEnabled public String strCompetency { get; set; }
        @AuraEnabled public String strAccountName { get; set; }
        @AuraEnabled public String strAccountId { get; set; }
        @AuraEnabled public String strEmailSubject { get; set; }
        @AuraEnabled public String strQuestion { get; set; }
        @AuraEnabled public String strStepsToReproduce { get; set; }
        @AuraEnabled public String attachmentId { get; set; }
        public TrainingRequest(String strAccountId, String strAccountName) {
            this.strAccountId = strAccountId;
            this.strAccountName = strAccountName;
        }
    }        
    
    public class AskAQuestion {
        @AuraEnabled public String strCompetency { get; set; }
        @AuraEnabled public String strAccountName { get; set; }
        @AuraEnabled public String strAccountId { get; set; }
        @AuraEnabled public String strEmailSubject { get; set; }
        @AuraEnabled public String strQuestion { get; set; }
        @AuraEnabled public String strStepsToReproduce { get; set; }
        @AuraEnabled public String attachmentId { get; set; }
        public AskAQuestion(String strAccountId, String strAccountName) {
            this.strAccountId = strAccountId;
            this.strAccountName = strAccountName;
        }
    }
    
    public class ContactUsData {
        @AuraEnabled public Boolean bUnRestricted {get;set;}
        @AuraEnabled public TrainingRequest objTrainingRequest;
        @AuraEnabled public LogASupportRequest objLogASupportRequest;
        @AuraEnabled public AskAQuestion objAskAQuestion;
        public ContactUsData(Boolean bUnRestricted, LogASupportRequest objLogASupportRequest, AskAQuestion objAskAQuestion, TrainingRequest objTrainingRequest) {
            this.bUnRestricted = bUnRestricted;
            this.objLogASupportRequest = objLogASupportRequest;
            this.objTrainingRequest = objTrainingRequest;
            this.objAskAQuestion = objAskAQuestion;
        }
    }
    
}