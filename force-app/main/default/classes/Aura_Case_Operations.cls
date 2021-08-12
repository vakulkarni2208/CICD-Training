/*
This class is called by Lightning components operating on Case

Version    Date            Modified By            Description
--------   ----------     -----------------      ---------------------------------------------------------------------------------------------------
1.0        04/04/2021      Nilesh Adkar            
--------------------------------------------------------------------------------------------------------------------------------------------------    
*/
public without sharing class Aura_Case_Operations {

    @AuraEnabled
    public static Case getContactLookup() {
        Case cse = new Case();
        return cse;
    }

    @AuraEnabled
    public static string addCommunityCaseTeamMember(string strCaseId, string strContactId) {
        system.debug('**strCaseId**strEmail**strAccessType**' + strCaseId);

        string strMemberId;
        List<User>lstUser = [select id from User where contactId =: strContactId and IsActive = true and IsPortalEnabled = true limit 1];
        if (lstUser.isEmpty()) {
            strMemberId = strContactId;
        } else {
            strMemberId = lstUser.get(0).id;
        }
        List<CaseTeamRole>lstCaseTeamRole = [select Id from CaseTeamRole where Name = 'Customer'
            limit 1
        ];
        CaseTeamMember ctm = new CaseTeamMember();
        ctm.MemberId = strMemberId;
        ctm.ParentId = strCaseId;
        if (!lstCaseTeamRole.isEmpty())
            ctm.TeamRoleId = lstCaseTeamRole.get(0).id;
        try {
            insert ctm;
            EmailTemplate templateId = [Select DeveloperName, Id, subject from EmailTemplate where DeveloperName = 'Service_Cloud_Notify_Contact_Added_as_Case_Collaborator'
                limit 1
            ];
            OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where Address = 'no_reply@nvidia.com'
                limit 1
            ];
            List<Messaging.SingleEmailMessage>lstMessages = new List<Messaging.SingleEmailMessage>();
            List<string>lstToAddresses = new List<string>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(owa.id);
            mail.setTemplateID(templateId.Id);
            mail.setTargetObjectId(strContactId);
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setWhatId(strCaseId);
            lstMessages.add(mail);
            if (!lstMessages.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMessages, false);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +
                        results[0].errors[0].message);
                }
            }
        } catch (Exception ex) {
            system.debug('**ex**' + ex.getMessage() + '**' + ex.getMessage().contains('DUPLICATE_VALUE'));
            if (ex.getMessage().contains('DUPLICATE_VALUE'))
                return 'Duplicate';
            else
                return 'Failed';
        }
        return 'Success';
    }

    @AuraEnabled
    public static list<CaseTeamMember>getCaseTeamMembers(string strCaseId) {
        List<CaseTeamMember>lstFilteredTeamMember = new List<CaseTeamMember>();
        List<CaseTeamMember>lstTeamUsers = [select id, MemberId, Member.Name from CaseTeamMember where ParentId =: strCaseId];
        set<Id>setUserId = new set<Id>();
        for (CaseTeamMember tmpctm: lstTeamUsers) {
            if (string.valueOf(tmpctm.memberId).startsWith('005')) {
                setUserId.add(tmpctm.memberId);
            } else {
                lstFilteredTeamMember.add(tmpctm);
            }
        }
        List<User>lstCommUsers = [select id from User where id in: setUserId and IsActive = true and IsPortalEnabled = true];
        for (CaseTeamMember tmpctm: lstTeamUsers) {
            for (User tmpUser: lstCommUsers) {
                if (tmpctm.MemberId == tmpUser.id) {
                    lstFilteredTeamMember.add(tmpctm);
                    break;
                }
            }
        }
        return lstFilteredTeamMember;
    }

    @AuraEnabled
    public static void removeCaseTeamMember(string strContactId, string strCaseId) {
        set<Id>setIds = new set<Id>();
        List<User>lstUser = [select id from User where contactId =: strContactId];
        for (User tmpUser: lstUser) {
            setIds.add(tmpUser.id);
        }
        if (setIds != null && setIds.isEmpty()) {
            setIds.add(strContactId);
        }
        List<CaseTeamMember>lstCtm = [select id from CaseTeamMember where ParentId =: strCaseId and MemberId =: setIds];
        delete lstctm;
        //Database.delete(lstCtm,false);
    }
}