global without sharing class NV_FileUploadController {

    public String strPOSPartnerCode {get; set;}
    public String strPOSReporterID {get; set;}
    public String strCompanyName {get; set;}
    public String strBillingRegion {get; set;}
    public boolean isCSP {get; set;}
    public boolean isOtherThanCSP {get; set;}
    public list<POS_Submission__c> lstPOSSubmission {get; set;}
    public list<POS_Submission__c> lstLastSixPOSSubmission {get; set;}
    public String strLstPOSSubmission {get; set;}
    public String strLstLastSixPOSSubmission {get; set;}
    public String strProgramType {get; set;}
    public String strHowToDocumentId {get; set;}
    public String strPOSDocumentId {get; set;}
    public String strCSPPOSDocumentId {get; set;}
    public String strPOSTutorialDocumentId {get; set;}
    public String strPOSFAQDocumentId {get; set;}
    public list<ContentDocument> lstContentDocument;

    public NV_FileUploadController() {
        isCSP = false;
        isOtherThanCSP = false;
        lstContentDocument = new list<ContentDocument>();
        lstPOSSubmission = new list<POS_Submission__c>();
        lstLastSixPOSSubmission = new list<POS_Submission__c>();
        lstContentDocument = [select id,Title from ContentDocument where title = 'How To Submit POS' or title = 'NPN POS Instructions' or title = 'NPN CSP POS Instructions' or title ='POS Template Tutorial' or title ='NPN POS FAQ'];
        //lstContentDocument = [select id,Title from ContentDocument where name = 'How_To_Submit_POS' or name = 'NPN_POS_Instructions' or name = 'NPN_CSP_POS_Instructions'];
        system.debug(lstContentDocument);
        if(lstContentDocument.size() > 0) {
            for(ContentDocument objCD : lstContentDocument) {
                if(objCD.title == 'NPN POS Instructions') {
                    strPOSDocumentId = objCD.id;
                } else if(objCD.title == 'NPN CSP POS Instructions') {
                    strCSPPOSDocumentId = objCD.id;
                } else if(objCD.title == 'How To Submit POS') {
                    strHowToDocumentId = objCD.id;
                    } else if(objCD.title == 'POS Template Tutorial') {
                    strPOSTutorialDocumentId = objCD.id;
                }else if(objCD.title == 'NPN POS FAQ') {
                    strPOSFAQDocumentId = objCD.id;
                }
            }
        }
        list<Account> lstAcc = [select id, Name, Billing_Region__c, POS_Partner_Code__c, POS_Reporter_Id__c,(select id,Partner_Program_Name__c from Account_Attributes__r where Date_Competency_Terminated__c = NULL) from Account where id in (select accountId from User where id = :UserInfo.getUserId())];
        if(lstAcc.size() > 0) {
            strPOSPartnerCode = lstAcc[0].POS_Partner_Code__c;
            strPOSReporterID = lstAcc[0].POS_Reporter_Id__c;
            strCompanyName = lstAcc[0].Name;
            strBillingRegion = lstAcc[0].Billing_Region__c;
            for(Partner_Attribute__c objPA : lstAcc[0].Account_Attributes__r) {
                if(objPA.Partner_Program_Name__c == 'Cloud Service Provider') {
                    isCSP = true;
                  
                } else {
                    isOtherThanCSP = true;
                }
                if(isCSP && isOtherThanCSP) {
                    break;
                }
            }
            if(!isCSP) {
                strProgramType = 'Standard';
            }
            Date dtToday = System.today();
            Integer month = dtToday.month();
            Integer year = dtToday.year();
            Integer yearMonth = Integer.valueOf(String.valueOf(year).right(2) + (String.valueOf(month).length() == 2 ? String.valueOf(month) : '0'+String.valueOf(month) ));
            if(month >= 6) {
                yearMonth -= 6;
            } else {
                yearMonth -= 94;
            }

            lstPOSSubmission = [select id,Month_Year__c, Submission_Type__c, Reason_for_Revision__c, No_POS__c,Notes__c,Status__c, Attachment_Link__c, Program_Type__c, CreatedDate,Upload_Date_Time__c,MonthYearFormula__c from POS_Submission__c where account_Id__c = :lstAcc[0].id order by MonthYearFormula__c DESC];
            Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
            for(POS_Submission__c objPOSSubmission : lstPOSSubmission) {
                objPOSSubmission.Upload_Date_Time__c = DateTime.newInstance(objPOSSubmission.Upload_Date_Time__c.getTime() + tz.getOffset(objPOSSubmission.Upload_Date_Time__c));
                if(objPOSSubmission.MonthYearFormula__c > yearMonth) {
                    lstLastSixPOSSubmission.add(objPOSSubmission);
                }
            }
            strLstLastSixPOSSubmission = JSON.serialize(lstLastSixPOSSubmission);
            strLstPOSSubmission = JSON.serialize(lstPOSSubmission);
            system.debug(lstPOSSubmission);


        }
    }

    @RemoteAction
    global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
        /*
           parentId: The sfdc object Id this file will be attached to
           attachmentId: The record of the current Attachment file being processed
           fileName: Name of the attachment
           contentTye: Content Type of the file being attached
           base64BlobValue: Base64 encoded string of the file piece currently processing
         */
        /*String[] filelines = new String[]{};
           filelines = base64BlobValue.split('\n');
           system.debug(filelines);
           for (Integer i=1;i<filelines.size();i++)
           {
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');

            Account a = new Account();
            a.Name = inputvalues[0];
            a.ShippingStreet = inputvalues[1];
            a.ShippingCity = inputvalues[2];
            a.ShippingState = inputvalues[3];
            a.ShippingPostalCode = inputvalues[4];
            a.ShippingCountry = inputvalues[5];

            system.debug(a);
           }*/
        Blob cryptoKey = Blob.valueOf('12345678901234561234567890123456');
        //If recordId is blank this is the first part of a multi piece upload
        system.debug(parentId);
        if(attachmentId == '' || attachmentId == null) {
            //POS_Data__c objPOS = new POS_Data__c();
            //insert objPOS;
            Attachment att = new Attachment(
                ParentId = parentId,
                //Body = Crypto.encryptWithManagedIV('AES256', cryptoKey, EncodingUtil.Base64Decode(base64BlobValue)),
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
                );
            insert att;

            //Return the new attachment Id
            return att.Id;

        }else{
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]) {
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                //update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + EncodingUtil.Base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, EncodingUtil.base64decode(base64BlobValue)))));
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }

            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }

    private static Monthly_POS__c createPOSSubmission(String attachmentId, String month, String Year, String notes, String strProgramType, String strSubmissionType, String strReasonForRevision) {

        Id posSubmissionID;
        User currentUser = [select accountId from User where id =:UserInfo.getUserId()];
        String monthYear = month+' '+year;
        list<POS_Submission__c> lstPOSSubmission = [select id, no_pos__c, attachment_link__c, account_Id__c, month_year__c, notes__c, status__c, Upload_Date_Time__c from POS_Submission__c where account_id__c =:currentUser.accountId and month_year__c =:monthYear and program_type__c = :strProgramType];
        if(lstPOSSubmission.size() > 0) {
            lstPOSSubmission[0].Month_Year__c = monthYear;
            lstPOSSubmission[0].notes__c = notes;
            lstPOSSubmission[0].Submission_Type__c = strSubmissionType;
            lstPOSSubmission[0].Reason_For_Revision__c = strReasonForRevision;
            lstPOSSubmission[0].account_Id__c = currentUser.accountId;
            lstPOSSubmission[0].status__c = 'Submitted';
            lstPOSSubmission[0].program_type__c = strProgramType;
            lstPOSSubmission[0].Upload_Date_Time__c = System.now();
            if(attachmentId =='' || attachmentId == null) {
                lstPOSSubmission[0].No_POS__c = true;
                lstPOSSubmission[0].attachment_link__c ='';
            } else {
                lstPOSSubmission[0].No_POS__c = false;
                lstPOSSubmission[0].attachment_link__c = '/'+attachmentId;
            }
            update lstPOSSubmission;
            posSubmissionID = lstPOSSubmission[0].id;
        } else {
            POS_Submission__c objPOSSubmission = new POS_Submission__c();
            objPOSSubmission.Month_Year__c = monthYear;
            objPOSSubmission.notes__c = notes;
            objPOSSubmission.Submission_Type__c = strSubmissionType;
            objPOSSubmission.Reason_For_Revision__c = strReasonForRevision;
            objPOSSubmission.account_Id__c = currentUser.accountId;
            objPOSSubmission.status__c = 'Submitted';
            objPOSSubmission.program_type__c = strProgramType;
            objPOSSubmission.Upload_Date_Time__c = System.now();
            if(attachmentId =='' || attachmentId == null) {
                objPOSSubmission.No_POS__c = true;
            } else {
                objPOSSubmission.attachment_link__c = '/'+attachmentId;
            }
            insert objPOSSubmission;
            posSubmissionID = objPOSSubmission.id;
        }
        Monthly_POS__c objMonthlyPOS = new Monthly_POS__c();
        objMonthlyPOS.Month_Year__c = monthYear;
        objMonthlyPOS.notes__c = notes;
        objMonthlyPOS.Submission_Type__c = strSubmissionType;
        objMonthlyPOS.Reason_For_Revision__c = strReasonForRevision;
        objMonthlyPOS.POS_Submission_Id__c = posSubmissionID;
        objMonthlyPOS.status__c = 'Submitted';
        objMonthlyPOS.program_type__c = strProgramType;
        if(attachmentId =='' || attachmentId == null) {
            objMonthlyPOS.No_POS__c = true;
        } else {
            objMonthlyPOS.attachment_link__c = '/'+attachmentId;
        }
        insert objMonthlyPOS;
        return objMonthlyPOS;
    }


    public static list<Attachment> moveAttachment(list<Attachment> lstAtt, Monthly_POS__c objMonthlyPOS) {
        list<POS_Submission__c> lstPOSSubmission = [select id,attachment_link__c,link__c from POS_Submission__c where id = :objMonthlyPOS.POS_Submission_Id__c];
        Attachment objCloneAtt = lstAtt[0].clone(false, true, false, false);
        objCloneAtt.parentID = objMonthlyPOS.POS_Submission_Id__c;
        insert objCloneAtt;
        objMonthlyPOS.attachment_link__c = '/'+objCloneAtt.id;
        lstPOSSubmission[0].attachment_link__c = '/'+objCloneAtt.id;
        update objMonthlyPOS;
        update lstPOSSubmission[0];
        delete lstAtt;
        return new list<Attachment> {objCloneAtt};
    }

    /*Public class Convertdate{
         String convertedDate{get; set;}
          Public Convertdate(string mydate,POS_Submission__c objPOSSubmission){
          this.convertedDate=mydate;
               }
           }
           public List<Convertdate> Convertdatelist = new List<Convertdate>();
           public List<Convertdate> getConvertdate() {
           User currentUser = [select accountId from User where id =:UserInfo.getUserId()];
           POS_Submission__c[] lstPOSSubmission = [select id, Upload_Date_Time__c  from POS_Submission__c where account_Id__c = :currentUser.accountId];
           for (lstPOSSubmission DateList : lstPOSSubmission) {
           Datetime thisDT = lstPOSSubmission.Upload_Date_Time__c ;
           String myDate = thisDT.format('yyyy-MM-dd HH:mm:ss', 'PST');
           Convertdatelist.add(new Convertdate(String.valueOf('myDate')));
                    }
                    return Convertdatelist;
               } */

    @RemoteAction
    global static String sendEmail(String attachmentId, String month, String Year, String strPOSReporterID, String notes, String strPOSPartnerCode, String strProgramType, String strSubmissionType, String strReasonForRevision, String strBillingRegion) {

        //Blob cryptoKey = Crypto.generateAesKey(256);
        //OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address = 'vakulkarni@nvidia.com'];
        User currentUser = [select account.name from user where id = :UserInfo.getUserId()];
        OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'NVIDIA POS Submit Email'];
        Organization org = [SELECT InstanceName FROM Organization];
        Blob exampleIv = Blob.valueOf('Example of IV123');
        Blob cryptoKey = Blob.valueOf('Welcome@12312345');
        Monthly_POS__c objMonthlyPOS = createPOSSubmission(attachmentId,month,Year,notes, strProgramType, strSubmissionType, strReasonForRevision);
        /*list<User> lstUser = [select id from User where email = 'vakulkarni@nvidia.com'];
           if(strSubmissionType == 'Initial') {
            POSSubmitMappings = [SELECT MasterLabel, QualifiedApiName, POS_Emails__c, Region__c FROM POS_Submit__mdt where region__c='All'];
           } else if(strSubmissionType == 'Revision') {
            POSSubmitMappings = [SELECT MasterLabel, QualifiedApiName, POS_Emails__c, Region__c FROM POS_Submit__mdt where region__c=:strBillingRegion];
           }*/
        POS_Submit__mdt[] POSSubmitMappings = [SELECT MasterLabel, QualifiedApiName, POS_Emails__c, Region__c FROM POS_Submit__mdt where submission_type__c = :strSubmissionType and region__c=:strBillingRegion];
        String strErrorEmails  = POSSubmitMappings[0].POS_Emails__c;
        string[] toAddresses = strErrorEmails.split(';');
        for (integer i=0; i < toAddresses.size(); i++) {
            toAddresses[i] = toAddresses[i].trim();
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        //mail.setTargetObjectId(lstUser[0].id);
        //String[] toAddresses = ;
        //mail.setToAddresses(new String[]{'vakulkarni@nvidia.com','bherlihy@nvidia.com'});
        mail.setToAddresses(toAddresses);
        mail.setSubject('POS Submission');
        mail.setOrgWideEmailAddressId(owa.id);
        //build the email body
        string html = '<html><body><table width="100%">';
        html += '<tr><td><b>Partner Name:</b> '+currentUser.account.name+'</td></tr>';
        html += '<tr><td><b>Submitted By:</b> '+UserInfo.getName()+'</td></tr>';  // Added by Rajat for SDS-1612
        html += '<tr><td><b>Submitter\'s Email:</b> '+UserInfo.getUserEmail()+'</td></tr>';  // Added by Rajat for SDS-1612
        html += '<tr><td><b>Reporter Id:</b> '+strPOSReporterID+'</td></tr>';
        if(attachmentId != '' && attachmentId != null) {
            //list<POS_Submission__c> lstPOSSubmission = [select id,link__c from POS_Submission__c where id = :objMonthlyPOS.POS_Submission_Id__c];
            list<Attachment> lstAtt = [select id,body,name from Attachment where id=:attachmentId];
            lstAtt = moveAttachment(lstAtt, objMonthlyPOS);
            html += '<tr><td><b>POS Data for the Month/Year:</b> '+EncodingUtil.urlEncode(month,'UTF-8')+'-'+EncodingUtil.urlEncode(year,'UTF-8')+'</td></tr>';
            if(lstAtt.size() > 0) {
                //efa.setFileName('NPN_NVD_'+strPOSPartnerCode+'-POS-'+monthYear+'.xls');
                //efa.setFileName('NPN_NVD_'+strPOSPartnerCode+'-POS-'+monthYear+'.'+lstAtt[0].name.split('\\.')[1]);
                //efa.setFileName(lstAtt[0].name);
                //efa.setBody(Crypto.encrypt('AES256', cryptoKey, exampleIv, lstAtt[0].body));
                /******
                   For Zipping and Encryption - Phase 2

                   Zippex testZippex = new Zippex();
                   testZippex.addFile('POS/NPN_NVD_'+strPOSPartnerCode+'-POS-'+month+'.'+lstAtt[0].name.split('\\.')[1],lstAtt[0].body,null);
                   if(strProgramType == 'CSP') {
                    efa.setFileName('CSP_NVD_'+strPOSPartnerCode+'-POS-'+month+'.zip');
                   } else {
                    efa.setFileName('NPN_NVD_'+strPOSPartnerCode+'-POS-'+month+'.zip');
                   }
                   efa.setBody(Crypto.encrypt('AES128', cryptoKey, exampleIv, testZippex.getZipArchive()));
                 ********/
                if(strProgramType == 'CSP') {
                    efa.setFileName('CSP_NVD_'+strPOSPartnerCode+'-POS-'+month+'.'+lstAtt[0].name.split('\\.')[lstAtt[0].name.split('\\.').size()-1]);
                } else {
                    efa.setFileName('NPN_NVD_'+strPOSPartnerCode+'-POS-'+month+'.'+lstAtt[0].name.split('\\.')[lstAtt[0].name.split('\\.').size()-1]);
                }
                efa.setBody(lstAtt[0].body);
            }
            //html += '<tr><td><b>Attachment Link:</b> '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+attachmentId+'</td></tr>';
            html += '<tr><td><b>Attachment Link:</b> '+'https://'+org.InstanceName+'.salesforce.com/'+lstAtt[0].id+'</td></tr>';
            //html += '<tr><td><b>Attachment Link:</b> '+lstPOSSubmission[0].link__c+'</td></tr>';
            html += '<tr><td><b>POS Submission ID:</b> '+objMonthlyPOS.Id+'</td></tr>';
            html += '<tr><td><b>Submission Type:</b> '+strSubmissionType+'</td></tr>';
            html += '<tr><td><b>Notes:</b> '+notes+'</td></tr>';
            html += '</table></body></html>';
            //set html body
            mail.setHtmlbody(html);
            fileAttachments.add(efa);
            mail.setFileAttachments(fileAttachments);
            mail.setSaveAsActivity(false);
            //send email
            Messaging.SendEmailResult[] lstMSER = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug(lstMSER);
        } /*else {
             html += '<tr><td><b>No POS Data for the Month/Year: '+EncodingUtil.urlEncode(monthYear,'UTF-8')+'</b></td></tr>';
             string header = 'Record Id, Name , Created Date, Modified Date \n';
             string recordString = '0, 0, 0, 0\n';
             efa.setFileName('NPN_NVD_'+strPOSPartnerCode+'-POS-'+monthYear+'.csv');
             efa.setBody(Blob.valueOf(header + recordString));
             }*/

        return null;
    }
}