/******************************************************************************
   ClassName : NV_DocusignLeadHelper
   Description: This class is used in the Lead conversion flow


   2020-03-13 - RKAMBLE - Changes for PPG & GG values automation
******************************************************************************/
public class NV_DocusignLeadHelper {

public static void changeLeadStatus(list<Id> leadIds) {
    Map<Id,Lead> mapLead = new Map<Id,Lead>([SELECT id, isConverted, Approved_Competencies__c, Approved_Program_Type__c, Competencies_Interested_In__c, Program_Level__c, Organization_Type_select_one__c, (SELECT id,name,Email__c,Job_Role__c, Leads_and_Opportunities__c,Phone__c,Sales_Training__c,Technical_Training__c FROM NPN_Key_Contacts__r) FROM Lead WHERE id in: leadIds]);
    for(Lead objLead : mapLead.values()) {
        objLead.Status = COMM_CONSTANTS.CONTRACT_PACKET_SENT;
    }
    update mapLead.values();
}

public static list<map<Id, Id> > fetchExistingAccount(Map<Id,Lead> mapLead) {
    map<Id, Id> mapLeadIdAccountId = new map<Id, Id>();
    map<Id, Id> mapLeadIdContactId = new map<Id, Id>();
    set<String> setNPNDupecatcherBypass = NPN_Dupecatcher_Bypass__c.getAll().keySet();
    list<String> lstAccountNames = new list<String>();
    map<String, Id> mapLeadCompanyToID = new map<String, Id>();
    map<String, Id> mapLeadEmailToID = new map<String, Id>();
    for(Lead objLead : mapLead.values()) {
        lstAccountNames.add(objLead.Company);
        if(!mapLeadCompanyToID.containsKey(objLead.Company)) {
            mapLeadCompanyToID.put(objLead.Company, objLead.Id);
        }
        if(!mapLeadEmailToID.containsKey(objLead.email)) {
            mapLeadEmailToID.put(objLead.email, objLead.Id);
        }
    }
    list<Account> lstAccount = [SELECT Id, name, (SELECT Id, AccountId, name, email FROM Contacts) FROM account WHERE name in :lstAccountNames and recordType.Name not in :setNPNDupecatcherBypass];
    if(lstAccount.size() > 0) {
        for(Account acc : lstAccount) {
            if(mapLeadCompanyToID.containsKey(acc.name)) {
                if(!mapLeadIdAccountId.containskey(mapLeadCompanyToID.get(acc.name))) {
                    mapLeadIdAccountId.put(mapLeadCompanyToID.get(acc.name), acc.id);
                }
            }
            for(Contact con : acc.Contacts) {
                if(mapLeadEmailToId.containsKey(con.email) && con.accountId == mapLeadIdAccountId.get(mapLeadEmailToId.get(con.email))) {
                    if(!mapLeadIdContactId.containsKey(mapLeadEmailToID.get(con.email))) {
                        mapLeadIdContactId.put(mapLeadEmailToID.get(con.email), con.id);
                    }
                }
            }
        }
    }
    return new list<map<Id,Id> > {mapLeadIdAccountId,mapLeadIdContactId};
}

public static void convertLead(list<Id> leadIds) {
    Map<Id,Lead> mapLead = new Map<Id,Lead>([SELECT id, ownerId, email, isConverted, Company, Generic_Competency__c, Generic_ProgramType__c, Approved_Competencies__c, Approved_Program_Type__c, Approved_SubProgram_Type__c, Competencies_Interested_In__c, Program_Level__c, Organization_Type_select_one__c, (SELECT id,name,Email__c,Job_Role__c, Leads_and_Opportunities__c,Phone__c,Sales_Training__c,Technical_Training__c FROM NPN_Key_Contacts__r) FROM Lead WHERE id in: leadIds]);
    list<Attachment> lstAtt = [SELECT id,parentId,Body,ContentType,Name,OwnerId FROM Attachment WHERE parentid in :leadIds];
    list<map<Id, Id> > listMapsLeadIdAccountIdContactId = fetchExistingAccount(mapLead);
    List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
    map<Id, list<Attachment> > mapLeadIDListAttachments = new map<Id, List<Attachment> >();
    map<Id, list<list<String> > > mapleadIdListListAttributes = new map<Id, list<list<String> > >();
    map<Id, list<NPN_Key_Contact__c> > mapLeadIDListKeyContacts = new map<Id, List<NPN_Key_Contact__c> >();
    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    for(Lead objLead : mapLead.values()) {
        if(!objLead.isConverted) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(objLead.Id);
            if(listMapsLeadIdAccountIdContactId.size() > 0) {
                if(listMapsLeadIdAccountIdContactId[0].containsKey(objLead.Id)) {
                    lc.setAccountId(listMapsLeadIdAccountIdContactId[0].get(objLead.Id));
                }
                if(listMapsLeadIdAccountIdContactId.size() > 1) {
                    if(listMapsLeadIdAccountIdContactId[1].containsKey(objLead.Id)) {
                        lc.setContactId(listMapsLeadIdAccountIdContactId[1].get(objLead.Id));
                    }
                }
            }
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(True);
            lcList.add(lc);
            if(!objLead.NPN_Key_Contacts__r.isEmpty()) {
                mapLeadIDListKeyContacts.put(objLead.id, objLead.NPN_Key_Contacts__r);
            }
            if(!lstAtt.isEmpty()) {
                for(Attachment att : lstAtt) {
                    if(att.parentId == objLead.id) {
                        if(mapLeadIDListAttachments.containsKey(objLead.id)) {
                            mapLeadIDListAttachments.get(objLead.id).add(att);
                        } else {
                            mapLeadIDListAttachments.put(objLead.id, new list<Attachment> {att});
                        }
                    }
                }
            }
            if(!mapleadIdListListAttributes.containsKey(objLead.id)) {
                mapleadIdListListAttributes.put(objLead.id, new list<list<String> > {});
                if(objLead.approved_competencies__c != null && objLead.approved_competencies__c != '') {
                    mapleadIdListListAttributes.get(objLead.id).add(objLead.approved_competencies__c.split(';'));
                }
                if(objLead.approved_program_type__c != null && objLead.approved_program_type__c != '') {
                    mapleadIdListListAttributes.get(objLead.id).add(objLead.approved_program_type__c.split(';'));
                }
                if(objLead.program_level__c != null && objLead.program_level__c != '') {
                    mapleadIdListListAttributes.get(objLead.id).add(objLead.program_level__c.split(';'));
                }
                if(objLead.approved_subprogram_type__c != null && objLead.approved_subprogram_type__c != '') {
                    mapleadIdListListAttributes.get(objLead.id).add(objLead.approved_subprogram_type__c.split(';'));
                }
            }
        }
    }
    List<Database.LeadConvertResult> lcrList = new List<Database.LeadConvertResult>();
    if (!lcList.isEmpty()) {
        lcrList = Database.convertLead(lcList, False);
    }
    postConversionLogic(lcrList, mapleadIdListListAttributes, mapLeadIDListAttachments, mapLeadIDListKeyContacts, mapLead );
}

public static list<Partner_Attribute__c> createPartnerAttributes(Database.LeadConvertResult objLcr, map<Id, list<list<String> > > mapleadIdListListAttributes) {
    list<Partner_Attribute__c> lstPartnerAttribute = new list<Partner_Attribute__c>();
    /*** Rajat - Changes for POS Exemption (SDS-1873) START*/
    Map<String, Boolean> mapExemptPOS = new Map<String, Boolean>();
    // Excluding Partner Level FROM key generation of the below map.
    for(NPN_Exempt_from_POS_Submission__mdt exmposObj : [SELECT DeveloperName,Exempted_from_POS_Submission__c,Id,Label,Partner_Competency__c,Partner_Program_Name__c,Partner_Sub_Program__c,Program_Level__c,QualifiedApiName FROM NPN_Exempt_from_POS_Submission__mdt]) {
        mapExemptPOS.put(exmposObj.Partner_Program_Name__c+exmposObj.Partner_Sub_Program__c+exmposObj.Partner_Competency__c, exmposObj.Exempted_from_POS_Submission__c);
    }
    //map<String, Lead_Prog_Type_Map_Acc_PartnerAttribute__c> mapLeadProgramTypePartnerAttr = Lead_Prog_Type_Map_Acc_PartnerAttribute__c.getAll();
    if(mapleadIdListListAttributes.containsKey(objLcr.getLeadId()) && mapleadIdListListAttributes.get(objLcr.getLeadId()).size() >= 3) {
        for(String strCompetency : mapleadIdListListAttributes.get(objLcr.getLeadId())[0]) {
            for(String strPartnerType : mapleadIdListListAttributes.get(objLcr.getLeadId())[1]) {
                for(String strLevel : mapleadIdListListAttributes.get(objLcr.getLeadId())[2]) {
                    if(mapleadIdListListAttributes.get(objLcr.getLeadId()).size() == 4 && mapleadIdListListAttributes.get(objLcr.getLeadId())[3].size() > 0) {
                        for(String strSubProgramType : mapleadIdListListAttributes.get(objLcr.getLeadId())[3]) {
                            Partner_Attribute__c objPartnerAttribute = new Partner_Attribute__c();
                            objPartnerAttribute.account_name__c = objLcr.getAccountId();
                            objPartnerAttribute.Partner_Competency__c = strCompetency;
                            /*if(mapLeadProgramTypePartnerAttr.containsKey(strPartnerType))
                               objPartnerAttribute.Partner_Program_Name__c = mapLeadProgramTypePartnerAttr.get(strPartnerType).partner_attribute_name__c;
                               else*/
                            objPartnerAttribute.Partner_Program_Name__c = strPartnerType;
                            objPartnerAttribute.Partner_Sub_Program__c = strSubProgramType;
                            objPartnerAttribute.Program_Level__c = strLevel;
                            objPartnerAttribute.Date_Competency_Signed__c = System.today();
                            if(!mapExemptPOS.isEmpty() && mapExemptPOS.containsKey(objPartnerAttribute.Partner_Program_Name__c+objPartnerAttribute.Partner_Sub_Program__c+strCompetency)) {
                                objPartnerAttribute.Exempted_from_POS_Submission__c = mapExemptPOS.get(objPartnerAttribute.Partner_Program_Name__c+objPartnerAttribute.Partner_Sub_Program__c+objPartnerAttribute.Partner_Competency__c);
                            }
                            /*** Rajat - Changes for POS Exemption (SDS-1873) FINISH*/
                            lstPartnerAttribute.add(objPartnerAttribute);
                        }
                    } else {
                        Partner_Attribute__c objPartnerAttribute = new Partner_Attribute__c();
                        objPartnerAttribute.account_name__c = objLcr.getAccountId();
                        objPartnerAttribute.Partner_Competency__c = strCompetency;
                        /*if(mapLeadProgramTypePartnerAttr.containsKey(strPartnerType))
                           objPartnerAttribute.Partner_Program_Name__c = mapLeadProgramTypePartnerAttr.get(strPartnerType).partner_attribute_name__c;
                           else*/
                        objPartnerAttribute.Partner_Program_Name__c = strPartnerType;
                        objPartnerAttribute.Program_Level__c = strLevel;
                        objPartnerAttribute.Date_Competency_Signed__c = System.today();
                        /*** Rajat - Changes for POS Exemption (SDS-1873) START*/
                        // Replacing subprogram as NULL
                        if(!mapExemptPOS.isEmpty() && mapExemptPOS.containsKey(objPartnerAttribute.Partner_Program_Name__c+NULL+strCompetency)) {
                            objPartnerAttribute.Exempted_from_POS_Submission__c = mapExemptPOS.get(objPartnerAttribute.Partner_Program_Name__c+NULL+objPartnerAttribute.Partner_Competency__c);
                        }
                        /*** Rajat - Changes for POS Exemption (SDS-1873) FINISH*/
                        lstPartnerAttribute.add(objPartnerAttribute);
                    }
                }
            }
        }
    }
    return lstPartnerAttribute;
}

public static list<Account> updateAccountNPNSignedDate(list<Database.LeadConvertResult> lcrList) {
    list<Id> accountIds = new list<Id>();
    list<Id> contactIds = new list<Id>();
    //list<RecordType> lstRT = [SELECT id FROM RecordType WHERE SobjectType='Account' and developerName = 'NPN_Account_Registry'];
    Id partnerAcctRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
    for(Database.LeadConvertResult objLcr : lcrList) {
        if(objLcr.isSuccess()) {
            accountIds.add(objLcr.getAccountId());
            contactIds.add(objLcr.getContactId());
        }
    }
    list<Account> lstAccount = [SELECT id,recordtypeid,NPN_Program_Signed_Date__c, BillingCountry, (SELECT id, FirstName, LastName, GPU_Genius_Groups__c, role__c, email, phone, ownerId, AccountId, Portal_User_Content_Type__c, Portal_Groups__c, Synced_with_Docusign__c, RecordTypeId FROM Contacts) FROM Account WHERE id in :accountIds];
    for(Account acc : lstAccount) {
        acc.NPN_Program_Signed_Date__c = System.today();
        /*if(lstRT.Size()>0) {
                acc.recordtypeid=lstRT[0].id;
           }*/
        acc.RecordTypeId = partnerAcctRT;
    }
    update lstAccount;
    list<Attachment> lstAtt = [SELECT Id FROM Attachment WHERE parentId in :accountIds or parentId in :contactIds];
    if(lstAtt.size() > 0) {
        delete lstAtt;
    }
    return lstAccount;
}

public static map<String, Contact> getConvertedContacts(list<Database.LeadConvertResult> lcrList) {
    list<Contact> lstContact = new list<Contact>();
    map<String, Contact> convertedContactMap = new map<String, Contact>();
    list<Id> lstContactIds = new list<Id>();
    for(Database.LeadConvertResult objLcr : lcrList) {
        if(objLcr.isSuccess()) {
            lstContactIds.add(objLcr.getContactId());
        }
    }
    if(lstContactIds.size() > 0) {
        lstContact = [SELECT id, Portal_Groups__c, email, phone, firstName, lastName, ownerId, recordTypeId, accountId, Portal_User_Content_Type__c, role__c, GPU_Genius_Groups__c, Synced_with_Docusign__c FROM Contact WHERE id in :lstContactIds ];
        for(Contact con : lstContact) {
            convertedContactMap.put(con.email, con);
        }
    }
    return convertedContactMap;
}

public static void postConversionLogic(list<Database.LeadConvertResult> lcrList, map<Id, list<list<String> > > mapleadIdListListAttributes, map<Id, list<Attachment> > mapLeadIDListAttachments, map<Id,list<NPN_Key_Contact__c> > mapLeadIDListKeyContacts, Map<Id,Lead> mapLead) {
    Boolean bConvertedContactInKeyContact = false;
    Boolean bGenericPA = false;
    list<Attachment> lstAttachment = new list<Attachment>();
    list<Attachment> lstAttachmentForDelete = new list<Attachment>();
    list<Contact> lstContact = new list<Contact>();
    list<Partner_Attribute__c> lstPartnerAttribute = new list<Partner_Attribute__c>();
    map<Id, String> mapAccountIdBillingAddress = new map<Id, String>();
    map<String, Contact> mapContactEmailContact = new map<String, Contact>();
    map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius = NPN_Onboarding_GPU_Genius_Map__c.getAll();
    map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup = NPN_Competency_Permissions_Group_Map__c.getAll();
    //list<RecordType> lstRT = [SELECT id FROM RecordType WHERE SobjectType='Contact' and developerName = 'Partner'];
    Id partnerContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
    list<Account> lstConvertedAccounts = updateAccountNPNSignedDate(lcrList);
    map<String, Contact> existingContactMap = new map<String, Contact>();
    map<String, Contact> convertedContactMap = getConvertedContacts(lcrList);
    //List<NPN_Onboarding_Competency_GPU_Genius_Map__mdt> ggMDList = [SELECT Id, MasterLabel, Competency__c, Role__c, DeveloperName,GPU_Genius_Group__c,Program_Type__c FROM NPN_Onboarding_Competency_GPU_Genius_Map__mdt]; // Rajat 19-MAY-2020 Not being used.

    for(Account objAcc : lstConvertedAccounts) {
        mapAccountIdBillingAddress.put(objAcc.id, objAcc.BillingCountry);
        for(Contact objCon : objAcc.Contacts) {
            if(!existingContactMap.containsKey(objCon.Email)) {
                existingContactMap.put(objCon.Email,objCon);
            }
        }
    }
    for(Database.LeadConvertResult objLcr : lcrList) {
        if(objLcr.isSuccess()) {
            if(mapleadIdListListAttributes.containsKey(objLcr.getLeadId())) {
                lstPartnerAttribute.addAll(createPartnerAttributes(objLcr, mapleadIdListListAttributes));
            }
            if(mapLeadIDListAttachments.containsKey(objLcr.getLeadId())) {
                for(Attachment objAtt : mapLeadIDListAttachments.get(objLcr.getLeadId())) {
                    Attachment cloneAttachment = new Attachment();
                    cloneAttachment = objAtt.clone(false, true, false, false);
                    cloneAttachment.parentId = objLcr.getAccountId();
                    String day = String.valueOf(system.today().day());
                    if(system.today().day() < 10) {
                        day = '0'+ day;
                    }
                    String month = String.valueOf(system.today().month());
                    if(system.today().month() < 10) {
                        month = '0'+ month;
                    }
                    cloneAttachment.name = system.today().year()+month+day+'_'+mapLead.get(objLcr.getLeadId()).company+'_'+objAtt.name;
                    lstAttachment.add(cloneAttachment);
                    lstAttachmentForDelete.add(objAtt);
                }
            }
            if(mapLeadIDListKeyContacts.containsKey(objLcr.getLeadId())) {
                Set<String> competencies = new Set<String>();

                if(String.isNotBlank(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c)) {
                    for(String compVal : mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.split(';')) {
                        competencies.add(compVal.trim());
                    }
                }
                system.debug(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c);
                system.debug('--> competencies: '+ competencies);
                for(NPN_Key_Contact__c objNPNKeyContact : mapLeadIDListKeyContacts.get(objLcr.getLeadId())) {
                    if(mapContactEmailContact.containsKey(objNPNKeyContact.Email__c)) {
                        mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c += ';'+objNPNKeyContact.Job_Role__c;
                        if(objNPNKeyContact.Sales_Training__c && !mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c.contains(COMM_CONSTANTS.PROFILE_CATEGORY_SALES)) {
                            mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c += ';' + COMM_CONSTANTS.PROFILE_CATEGORY_SALES;
                        }
                        if(objNPNKeyContact.Technical_Training__c && !mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c.contains(COMM_CONSTANTS.PROFILE_CATEGORY_TECHNICAL)) {
                            mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c += ';' + COMM_CONSTANTS.PROFILE_CATEGORY_TECHNICAL;
                        }
                        if(objNPNKeyContact.Sales_Training__c || objNPNKeyContact.Technical_Training__c) {
                            for(NPN_Onboarding_GPU_Genius_Map__c objOnboardingCompetencyGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {
                                //if(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c!=null && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyGPUGenius.Competency__c) && objOnboardingCompetencyGPUGenius.role__c != null && mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c.contains(objOnboardingCompetencyGPUGenius.role__c) && objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c != null && !mapContactEmailContact.get(objNPNKeyContact.Email__c).GPU_Genius_Groups__c.contains(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
                                if(!competencies.isEmpty() && competencies.contains(objOnboardingCompetencyGPUGenius.Competency__c) && objOnboardingCompetencyGPUGenius.role__c != null && mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c.contains(objOnboardingCompetencyGPUGenius.role__c) && objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c != null && !mapContactEmailContact.get(objNPNKeyContact.Email__c).GPU_Genius_Groups__c.contains(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
                                    mapContactEmailContact.get(objNPNKeyContact.Email__c).GPU_Genius_Groups__c += objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c + ';';
                                }
                            }
                        }
                    } else {
                        Contact con;
                        Set<String> ggValSet = new Set<String>();
                        Set<String> permValSet = new Set<String>();
                        if(!convertedContactMap.containsKey(objNPNKeyContact.Email__c) && !(existingContactMap.containsKey(objNPNKeyContact.Email__c) && existingContactMap.get(objNPNKeyContact.Email__c).accountId == objLcr.getAccountId())) {
                            con = new Contact();
                        } else if(convertedContactMap.containsKey(objNPNKeyContact.Email__c)) {
                            con = convertedContactMap.get(objNPNKeyContact.Email__c);
                            bConvertedContactInKeyContact = true;
                        } else {
                            con = existingContactMap.get(objNPNKeyContact.Email__c);
                        }
                        /*if(lstRT.size() > 0) {        //Commented by Rajat for SDS-2826
                                con.recordTypeId = lstRT[0].id;
                           }*/
                        con.recordTypeId = partnerContactRT; // Rajat added for SDS-2826

                        system.debug(String.isEmpty(con.Portal_User_Content_Type__c));
                        system.debug(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c);
                        system.debug(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.split(';')[0]);
                        if(String.isEmpty(con.Portal_User_Content_Type__c)) {
                            con.Portal_User_Content_Type__c = mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.split(';')[0];
                        }
                        con.email = objNPNKeyContact.Email__c;
                        con.phone = objNPNKeyContact.Phone__c;
                        con.ownerId = mapLead.get(objLcr.getLeadId()).ownerId;
                        if(objNPNKeyContact.name.contains(' ')) {
                            con.firstName = objNPNKeyContact.name.SubString(0, objNPNKeyContact.name.lastIndexOf(' '));
                        }
                        if(objNPNKeyContact.name.contains(' ')) {
                            con.lastName = objNPNKeyContact.name.SubString(objNPNKeyContact.name.lastIndexOf(' '), objNPNKeyContact.name.length());
                        } else {
                            con.lastName = objNPNKeyContact.name;
                        }
                        con.AccountId = objLcr.getAccountId();
                        if(mapAccountIdBillingAddress.containsKey(objLcr.getAccountId())) {
                            con.MailingCountry = mapAccountIdBillingAddress.get(objLcr.getAccountId());
                            con.Synced_with_Docusign__c = true; // Added by Rajat for SDS-1932
                        }
                        con.role__c = objNPNKeyContact.Job_Role__c;
                        if(objNPNKeyContact.Sales_Training__c && !con.role__c.contains(COMM_CONSTANTS.PROFILE_CATEGORY_SALES)) {
                            con.role__c += ';' + COMM_CONSTANTS.PROFILE_CATEGORY_SALES;
                        }
                        if(objNPNKeyContact.Technical_Training__c && !con.role__c.contains(COMM_CONSTANTS.PROFILE_CATEGORY_TECHNICAL)) {
                            con.role__c += ';' + COMM_CONSTANTS.PROFILE_CATEGORY_TECHNICAL;
                        }

                        if(mapLead.containsKey(objLcr.getLeadId())) {
                            if(String.isNotBlank(con.GPU_Genius_Groups__c)) {
                                for(String ggValStr :  con.GPU_Genius_Groups__c.split(';')) {
                                    ggValSet.add(ggValStr.trim());
                                }
                            }
                            for(NPN_Onboarding_GPU_Genius_Map__c objOnboardingCompetencyGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {

                                if(String.isNotBlank(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
                                    if(
                                        (String.isBlank(objOnboardingCompetencyGPUGenius.Role__c) || (String.isNotBlank(con.Role__c) && String.isNotBlank(objOnboardingCompetencyGPUGenius.Role__c) && con.Role__c.contains(objOnboardingCompetencyGPUGenius.role__c))) &&

                                        (String.isBlank(objOnboardingCompetencyGPUGenius.Competency__c) ||
                                         //(String.isNotBlank(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c) && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyGPUGenius.Competency__c))) &&
                                         (!competencies.isEmpty() && competencies.contains(objOnboardingCompetencyGPUGenius.Competency__c))) &&

                                        (String.isBlank(objOnboardingCompetencyGPUGenius.Program_Type__c) ||
                                         (String.isNotBlank(objOnboardingCompetencyGPUGenius.Program_Type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).approved_program_type__c) && mapLead.get(objLcr.getLeadId()).approved_program_type__c.contains(objOnboardingCompetencyGPUGenius.Program_Type__c))) &&

                                        (String.isBlank(objOnboardingCompetencyGPUGenius.subprogram_type__c) ||
                                         (String.isNotBlank(objOnboardingCompetencyGPUGenius.subprogram_type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).Approved_SubProgram_Type__c) && mapLead.get(objLcr.getLeadId()).Approved_SubProgram_Type__c.contains(objOnboardingCompetencyGPUGenius.subprogram_type__c)))) {

                                        for(String ggVal : objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.split(';')) {
                                            ggValSet.add(ggVal.trim());
                                        }
                                    }
                                }
                            }
                            system.debug('--> ggValSet: '+ ggValSet);
                            if(!ggValSet.isEmpty() && ggValSet.size() > 0 ) {
                                con.GPU_Genius_Groups__c = '';
                                for(String ggVal : ggValSet) {
                                    con.GPU_Genius_Groups__c += ggVal + ';';
                                }
                            }

                            if(String.isNotBlank(con.Portal_Groups__c)) {
                                for(String permVal :  con.Portal_Groups__c.split(';')) {
                                    permValSet.add(permVal.trim());
                                }
                            }
                            if(mapLead.get(objLcr.getLeadId()).approved_subprogram_type__c ==null) {
                                mapLead.get(objLcr.getLeadId()).approved_subprogram_type__c ='';
                            }
                            for(NPN_Competency_Permissions_Group_Map__c objOnboardingCompetencyPermissionGroup : mapOnboardingCompetencyPermissionsAndGroup.values()) {

                                if(String.isNotBlank(objOnboardingCompetencyPermissionGroup.permissions_and_group__c)) {
                                    if((String.isBlank(objOnboardingCompetencyPermissionGroup.Role__c) || (String.isNotBlank(con.role__c) && String.isNotBlank(objOnboardingCompetencyPermissionGroup.Role__c) && con.role__c.contains(objOnboardingCompetencyPermissionGroup.role__c))) &&

                                       (String.isBlank(objOnboardingCompetencyPermissionGroup.Competency__c) ||
                                        (!competencies.isEmpty() && competencies.contains(objOnboardingCompetencyPermissionGroup.Competency__c))) &&

                                       (String.isBlank(objOnboardingCompetencyPermissionGroup.program_type__c) ||
                                        (String.isNotBlank(objOnboardingCompetencyPermissionGroup.program_type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).approved_program_type__c) && mapLead.get(objLcr.getLeadId()).approved_program_type__c.contains(objOnboardingCompetencyPermissionGroup.program_type__c))) &&

                                       (String.isBlank(objOnboardingCompetencyPermissionGroup.program_level__c) || (String.isNotBlank(objOnboardingCompetencyPermissionGroup.program_level__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).program_level__c) && mapLead.get(objLcr.getLeadId()).program_level__c.contains(objOnboardingCompetencyPermissionGroup.program_level__c))) &&

                                       (String.isBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) || (String.isNotBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).approved_subprogram_type__c) && mapLead.get(objLcr.getLeadId()).approved_subprogram_type__c.contains(objOnboardingCompetencyPermissionGroup.sub_program_type__c)))
                                       ) {
                                        for(String eachPermissionAndGroup : objOnboardingCompetencyPermissionGroup.permissions_and_group__c.split(';')) {
                                            permValSet.add(eachPermissionAndGroup.trim());
                                        }
                                    }

                                    // Generic Competency and Program Type check
                                    if(String.isBlank(objOnboardingCompetencyPermissionGroup.Role__c)) {
                                        if(mapLead.get(objLcr.getLeadId()).Generic_Competency__c!=null && mapLead.get(objLcr.getLeadId()).Generic_Competency__c.contains(objOnboardingCompetencyPermissionGroup.Competency__c) && mapLead.get(objLcr.getLeadId()).generic_programtype__c !=null && mapLead.get(objLcr.getLeadId()).generic_programtype__c.contains(objOnboardingCompetencyPermissionGroup.program_type__c)) {
                                            for(String eachPermissionAndGroup : objOnboardingCompetencyPermissionGroup.permissions_and_group__c.split(';')) {
                                                permValSet.add(eachPermissionAndGroup.trim());
                                            }
                                            if(convertedContactMap.containsKey(objNPNKeyContact.Email__c) && bGenericPA == false) {
                                                bGenericPA = true;
                                                Partner_Attribute__c objPartnerAttribute = new Partner_Attribute__c();
                                                objPartnerAttribute.account_name__c = objLcr.getAccountId();
                                                objPartnerAttribute.Partner_Competency__c = objOnboardingCompetencyPermissionGroup.Competency__c;
                                                objPartnerAttribute.Partner_Program_Name__c = objOnboardingCompetencyPermissionGroup.program_type__c;
                                                objPartnerAttribute.Date_Competency_Signed__c = System.today();
                                                lstPartnerAttribute.add(objPartnerAttribute);
                                            }
                                        }
                                    }
                                }
                            }
                            system.debug('--> permValSet: '+ permValSet);
                            if(!permValSet.isEmpty() && permValSet.size() > 0 ) {
                                con.Portal_Groups__c = '';
                                for(String permVal : permValSet) {
                                    con.Portal_Groups__c += permVal + ';';
                                }
                            }
                        }
                        if(!convertedContactMap.containsKey(objNPNKeyContact.Email__c) && !existingContactMap.containsKey(objNPNKeyContact.Email__c)) {
                            lstContact.add(con);
                        }
                        mapContactEmailContact.put(con.email, con);
                    }
                }
            }
            if(bConvertedContactInKeyContact == false) {
                if(mapLead.containsKey(objLcr.getLeadId())) {
                    Set<String> competencies = new Set<String>();
                    if(String.isNotBlank(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c)) {
                        for(String compVal : mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.split(';')) {
                            competencies.add(compVal.trim());
                        }
                    }
                    system.debug(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c);
                    system.debug('--> competencies: '+ competencies);
                    Set<String> ggValSet = new Set<String>();
                    Set<String> permValSet = new Set<String>();
                    for(Contact con : convertedContactMap.values()) {
                        if(con.id == objLcr.getContactId()) {

                            if(String.isEmpty(con.Portal_User_Content_Type__c)) {
                                con.Portal_User_Content_Type__c = mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.split(';')[0];
                            }
                            if(mapLead.containsKey(objLcr.getLeadId())) {
                                if(String.isNotBlank(con.GPU_Genius_Groups__c)) {
                                    for(String ggValStr :  con.GPU_Genius_Groups__c.split(';')) {
                                        ggValSet.add(ggValStr.trim());
                                    }
                                }
                                for(NPN_Onboarding_GPU_Genius_Map__c objOnboardingCompetencyGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {
                                    /*if(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c!=null && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyGPUGenius.Competency__c) && (objOnboardingCompetencyGPUGenius.role__c == '' || objOnboardingCompetencyGPUGenius.role__c == null)) {
                                        con.Portal_User_Content_Type__c = objOnboardingCompetencyGPUGenius.Competency__c;
                                        ggValSet.add(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c);
                                       }
                                       if(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c!=null && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyGPUGenius.Competency__c) && con.role__c != null && objOnboardingCompetencyGPUGenius.role__c != null && con.role__c.contains(objOnboardingCompetencyGPUGenius.role__c)) {
                                        ggValSet.add(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c);
                                       }*/
                                    if(String.isNotBlank(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
                                        if(
                                            (String.isBlank(objOnboardingCompetencyGPUGenius.Role__c) || (String.isNotBlank(con.Role__c) && String.isNotBlank(objOnboardingCompetencyGPUGenius.Role__c) && con.Role__c.contains(objOnboardingCompetencyGPUGenius.role__c))) &&

                                            (String.isBlank(objOnboardingCompetencyGPUGenius.Competency__c) ||
                                             //(String.isNotBlank(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c) && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyGPUGenius.Competency__c))) &&
                                             (!competencies.isEmpty() && competencies.contains(objOnboardingCompetencyGPUGenius.Competency__c))) &&

                                            (String.isBlank(objOnboardingCompetencyGPUGenius.Program_Type__c) ||
                                             (String.isNotBlank(objOnboardingCompetencyGPUGenius.Program_Type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).approved_program_type__c) && mapLead.get(objLcr.getLeadId()).approved_program_type__c.contains(objOnboardingCompetencyGPUGenius.Program_Type__c))) &&

                                            (String.isBlank(objOnboardingCompetencyGPUGenius.subprogram_type__c) ||
                                             (String.isNotBlank(objOnboardingCompetencyGPUGenius.subprogram_type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).Approved_SubProgram_Type__c) && mapLead.get(objLcr.getLeadId()).Approved_SubProgram_Type__c.contains(objOnboardingCompetencyGPUGenius.subprogram_type__c)))) {

                                            for(String ggVal : objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.split(';')) {
                                                ggValSet.add(ggVal.trim());
                                            }
                                        }
                                    }
                                }

                                system.debug('--> ggValSet: '+ ggValSet);
                                if(!ggValSet.isEmpty() && ggValSet.size() > 0 ) {
                                    con.GPU_Genius_Groups__c = '';
                                    system.debug('--> 3. con.GPU_Genius_Groups__c: '+ con.GPU_Genius_Groups__c);
                                    for(String ggVal : ggValSet) {
                                        con.GPU_Genius_Groups__c += ggVal + ';';
                                    }
                                }

                                system.debug('--> 4. con.GPU_Genius_Groups__c: '+ con.GPU_Genius_Groups__c);

                                if(String.isNotBlank(con.Portal_Groups__c)) {
                                    for(String permVal :  con.Portal_Groups__c.split(';')) {
                                        permValSet.add(permVal.trim());
                                    }
                                }
                                for(NPN_Competency_Permissions_Group_Map__c objOnboardingCompetencyPermissionGroup : mapOnboardingCompetencyPermissionsAndGroup.values()) {
                                    if(String.isNotBlank(objOnboardingCompetencyPermissionGroup.permissions_and_group__c)) {
                                        if(
                                            (String.isBlank(objOnboardingCompetencyPermissionGroup.Role__c) || (String.isNotBlank(con.role__c) && String.isNotBlank(objOnboardingCompetencyPermissionGroup.Role__c) && con.role__c.contains(objOnboardingCompetencyPermissionGroup.role__c))) &&

                                            (String.isBlank(objOnboardingCompetencyPermissionGroup.Competency__c) ||
                                             //(String.isNotBlank(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c) && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyPermissionGroup.Competency__c))) &&
                                             (!competencies.isEmpty() && competencies.contains(objOnboardingCompetencyPermissionGroup.Competency__c))) &&

                                            (String.isBlank(objOnboardingCompetencyPermissionGroup.program_type__c) ||
                                             (String.isNotBlank(objOnboardingCompetencyPermissionGroup.program_type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).approved_program_type__c) && mapLead.get(objLcr.getLeadId()).approved_program_type__c.contains(objOnboardingCompetencyPermissionGroup.program_type__c))) &&

                                            (String.isBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) || (String.isNotBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).approved_subprogram_type__c) && mapLead.get(objLcr.getLeadId()).approved_subprogram_type__c.contains(objOnboardingCompetencyPermissionGroup.sub_program_type__c))) &&

                                            (String.isBlank(objOnboardingCompetencyPermissionGroup.program_level__c) || (String.isNotBlank(objOnboardingCompetencyPermissionGroup.program_level__c) && String.isNotBlank(mapLead.get(objLcr.getLeadId()).program_level__c) && mapLead.get(objLcr.getLeadId()).program_level__c.contains(objOnboardingCompetencyPermissionGroup.program_level__c)))
                                            ) {
                                            for(String eachPermissionAndGroup : objOnboardingCompetencyPermissionGroup.permissions_and_group__c.split(';')) {
                                                permValSet.add(eachPermissionAndGroup.trim());
                                            }
                                        }

                                        // Generic Competency and Program Type check
                                        if(String.isBlank(objOnboardingCompetencyPermissionGroup.Role__c)) {
                                            if(mapLead.get(objLcr.getLeadId()).Generic_Competency__c!=null && mapLead.get(objLcr.getLeadId()).Generic_Competency__c.contains(objOnboardingCompetencyPermissionGroup.Competency__c) && mapLead.get(objLcr.getLeadId()).generic_programtype__c !=null && mapLead.get(objLcr.getLeadId()).generic_programtype__c.contains(objOnboardingCompetencyPermissionGroup.program_type__c)) {
                                                for(String eachPermissionAndGroup : objOnboardingCompetencyPermissionGroup.permissions_and_group__c.split(';')) {
                                                    permValSet.add(eachPermissionAndGroup.trim());
                                                }
                                                Partner_Attribute__c objPartnerAttribute = new Partner_Attribute__c();
                                                objPartnerAttribute.account_name__c = objLcr.getAccountId();
                                                objPartnerAttribute.Partner_Competency__c = objOnboardingCompetencyPermissionGroup.Competency__c;
                                                objPartnerAttribute.Partner_Program_Name__c = objOnboardingCompetencyPermissionGroup.program_type__c;
                                                objPartnerAttribute.Date_Competency_Signed__c = System.today();
                                                lstPartnerAttribute.add(objPartnerAttribute);
                                            }
                                        }
                                    }
                                }
                                system.debug('--> permValSet: '+ permValSet);
                                if(!permValSet.isEmpty() && permValSet.size() > 0 ) {
                                    con.Portal_Groups__c = '';
                                    for(String permVal : permValSet) {
                                        con.Portal_Groups__c += permVal + ';';
                                    }
                                }
                            }
                        }
                    }
                }
            }
            bConvertedContactInKeyContact = false;
            bGenericPA = false;
        }
    }
    // Commented on 13th May by Rajat for migration
    //System.enqueueJob(new NPN_QueableClassForDocuSignDML(null, null, lstContact, existingContactMap.values(), convertedContactMap.values(), lstPartnerAttribute));

    if(!lstAttachment.isEmpty()) {
        insert lstAttachment;
    }
    if(!lstContact.isEmpty()) {
        insert lstContact;
    }
    if(!existingContactMap.isEmpty()) {
        update existingContactMap.values();
    }
    if(!convertedContactMap.isEmpty()) {
        update convertedContactMap.values();
    }
    if(!lstPartnerAttribute.isEmpty()) {
        insert lstPartnerAttribute;
    }
}

}