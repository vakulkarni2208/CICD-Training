/*
 * 2020-02-28 Rajat Added 'Synced_with_Docusign__c = true' for inserting and updating contact SDS- & SDS-2053
 */

public class NV_DocusignAccountHelper {

/*
 * Commented by Rajat on 2019-11-01 as its invocation is also commented in NV_DocuSignStatus trigger
   public static void updateEnvelopeId(map<Id,list<String>> mapAcctIdEnvelopeIds) {
    list<NPN_PartnerAttributes_Modifiaction__c> lstPAM = [select id,Account__c, Sync__c, Program_Type__c, SubProgram_Type__c, CSP_Yes_No__c, PartnerAttributes_Modification__c, Competency_Level__c, Competency__c, DocuSign_Envelope_ID__c from NPN_PartnerAttributes_Modifiaction__c where Account__c in :mapAcctIdEnvelopeIds.keySet() and sync__c = false and DocuSign_Envelope_ID__c = ''];
    for(NPN_PartnerAttributes_Modifiaction__c objNPNPAM : lstPAM) {
        if(mapAcctIdEnvelopeIds.containsKey(objNPNPAM.Account__c)) {
            objNPNPAM.DocuSign_Envelope_ID__c = mapAcctIdEnvelopeIds.get(objNPNPAM.Account__c)[0];
        }
    }
    update lstPAM;
   }
 */
public static void processingLogic(map<Id, String> mapPAMIdEnvelopeId) {

    map<String, list<NPN_PartnerAttributes_Modifiaction__c> > mapAttributeLstPAM = new map<String, list<NPN_PartnerAttributes_Modifiaction__c> >();
    list<Id> lstAccountIds = new list<Id>();
    list<NPN_PartnerAttributes_Modifiaction__c> lstPAM = [select id,Account__c,DocuSign_Envelope_ID__c, CSP_Yes_No__c, Program_Type__c, SubProgram_Type__c, Competency__c, Competency_Level__c, PartnerAttributes_Modification__c, Sync__c from NPN_PartnerAttributes_Modifiaction__c where sync__c = false and DocuSign_Envelope_ID__c in :mapPAMIdEnvelopeId.values()];
    for(NPN_PartnerAttributes_Modifiaction__c objNPNPAM : lstPAM) {
        lstAccountIds.add(objNPNPAM.Account__c);
        if(!mapAttributeLstPAM.containsKey(objNPNPAM.PartnerAttributes_Modification__c)) {
            mapAttributeLstPAM.put(objNPNPAM.PartnerAttributes_Modification__c, new list<NPN_PartnerAttributes_Modifiaction__c> {objNPNPAM});
        } else {
            mapAttributeLstPAM.get(objNPNPAM.PartnerAttributes_Modification__c).add(objNPNPAM);
        }
        if(objNPNPAM.PartnerAttributes_Modification__c == 'Termination' || objNPNPAM.PartnerAttributes_Modification__c == 'Competency Termination') {
            objNPNPAM.termination_initiated__c = true;
        }
        objNPNPAM.sync__c = true;
    }
    map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius = NPN_Onboarding_GPU_Genius_Map__c.getAll();
    map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup = NPN_Competency_Permissions_Group_Map__c.getAll();
    //List<NPN_Onboarding_Competency_GPU_Genius_Map__mdt> ggMDList = [SELECT Id, MasterLabel, Competency__c, Role__c, DeveloperName,GPU_Genius_Group__c,Program_Type__c FROM NPN_Onboarding_Competency_GPU_Genius_Map__mdt]; //Rajat commented as it is NOT USED
    //list<RecordType> lstRT = [select id from RecordType where sObjectType = 'Contact' and developerName = 'Partner']; // Rajat Commented for SDS-2826
    // Rajat added Synced_with_Docusign__c in below query
    // Rajat added Community_User_Active__c in the below query for SDS-2826
    map<Id, Account> mapAccount = new Map<Id, Account> ([SELECT Id, OwnerId, BillingCountry, (SELECT Id, FirstName, LastName, GPU_Genius_Groups__c, Role__c, MailingCountry, Email, Phone, OwnerId, AccountId, Portal_User_Content_Type__c, Portal_Groups__c,RecordTypeId, Synced_with_Docusign__c, Community_User__c, Community_User_Active__c FROM Contacts), (SELECT Id, Partner_Competency__c, Partner_Program_Name__c, Partner_Sub_Program__c, Program_Level__c FROM Account_Attributes__r WHERE Date_Competency_Terminated__c = NULL), (SELECT Id,Name,Email__c,Job_Role__c, Leads_and_Opportunities__c,Phone__c,Sales_Training__c,Technical_Training__c FROM NPN_Key_Contacts__r WHERE synced__c = false) FROM Account WHERE Id IN: lstAccountIds]);
    for(String strPAM : mapAttributeLstPAM.keySet()) {
        if(strPAM == 'Add On Contracts Packet') {
            //addOnFlow(mapAttributeLstPAM.get(strPAM),mapAccount, mapOnboardingCompetencyGPUGenius, mapOnboardingCompetencyPermissionsAndGroup, lstRT, ggMDList); // Rajat commented for SDS-2826
            addOnFlow(mapAttributeLstPAM.get(strPAM),mapAccount, mapOnboardingCompetencyGPUGenius, mapOnboardingCompetencyPermissionsAndGroup);    //Rajat added for SDS-2826
        } else if(strPAM == 'Promotion' || strPAM == 'Demotion') {
            promotion_demotion(mapAttributeLstPAM.get(strPAM),mapAccount, mapOnboardingCompetencyPermissionsAndGroup, strPAM);
        }
    }
    update lstPAM;

}

public static void termination(list<NPN_PartnerAttributes_Modifiaction__c> lstPAM) {
    list<Id> lstAccountIds = new list<Id>();
    list<Contact> lstContact = new list<Contact>();
    list<Partner_Attribute__c> lstPartnerAttribute = new list<Partner_Attribute__c>();
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        lstAccountIds.add(objPAM.Account__c);
    }
    map<Id, Account> mapAccount = new Map<Id, Account> ([select id, NPN_Program_Termination_Date__c, ownerID, (SELECT id, FirstName, LastName, GPU_Genius_Groups__c, role__c, email, phone, ownerId, AccountId, Portal_User_Content_Type__c, Portal_Groups__c, Community_User__c, Community_User_Active__c FROM Contacts), (select id, Partner_Competency__c, partner_program_name__c, Partner_Sub_Program__c, Program_Level__c from Account_Attributes__r where Date_Competency_Terminated__c = NULL), (select id,name,Email__c,Job_Role__c, Leads_and_Opportunities__c,Phone__c,Sales_Training__c,Technical_Training__c from NPN_Key_Contacts__r where synced__c = false) from Account where id in: lstAccountIds]);
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        if(mapAccount.containsKey(objPAM.account__c)) {
            mapAccount.get(objPAM.account__c).NPN_Program_Termination_Date__c = system.today();
            for(Contact con : mapAccount.get(objPAM.account__c).Contacts) {
                con.Portal_Groups__c = '';
                con.GPU_Genius_Groups__c = '';
                con.ownerID = mapAccount.get(objPAM.account__c).ownerID;
                lstContact.add(con);
            }
            for(Partner_Attribute__c objPA : mapAccount.get(objPAM.account__c).Account_Attributes__r) {
                objPA.Date_Competency_Terminated__c = System.today();
                lstPartnerAttribute.add(objPA);
            }
        }
    }
    //Rajat commented below code for the new queuable job
    /*if(!lstPartnerAttribute.isEmpty()) {
        update lstPartnerAttribute;
       }
       if(!lstContact.isEmpty()) {
        update lstContact;
       }
       if(!mapAccount.isEmpty()) {
        update mapAccount.values();
       }*/

    System.enqueueJob(new NPN_QueableClassForDocuSignDML(lstContact, lstPartnerAttribute, mapAccount.values()));

    ID jobID = System.enqueueJob(new NV_FullTerminationClass(mapAccount.keySet()));
}

public static void competencyTermination(list<NPN_PartnerAttributes_Modifiaction__c> lstPAM) {
    map<Id,Boolean> mapAccountIDFullTermination = new Map<Id, Boolean>();
    list<Contact> lstContact = new list<Contact>();
    list<Id> lstAccountIds = new list<Id>();
    list<Partner_Attribute__c> lstPartnerAttribute = new list<Partner_Attribute__c>();
    map<Id, map<String, list<String> > > mapAccIdLstPermissionsRemoved = new map<Id, map<String, list<String> > >();
    map<Id, map<String, Map<String, list<String> > > > mapAccIdMapPCLLstPermissionsAdded = new map<Id, map<String, Map<String, list<String> > > >();
    Map<String, list<String> > mapRoleLstPermissionsToBeAdded = new Map<String, list<String> >();
    Map<String, list<String> > mapRoleLstPermissionsToBeRemoved = new Map<String, list<String> >();
    map<Id, Map<String, list<String> > > mapAccIdLstGPUGeniusRemoved = new map<Id, Map<String, list<String> > >();
    map<Id, map<String, Map<String, list<String> > > > mapAccIdMapPCLLstGPUGeniusAdded = new map<Id, map<String, Map<String, list<String> > > >();
    Map<String, list<String> > mapRoleLstGPUGeniusToBeAdded = new Map<String, list<String> >();
    Map<String, list<String> > mapRoleLstGPUGeniusToBeRemoved = new Map<String, list<String> >();
    Id partnerContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(); // Added for SDS-2826
    String strRole ='';
    map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius = NPN_Onboarding_GPU_Genius_Map__c.getAll();
    map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup = NPN_Competency_Permissions_Group_Map__c.getAll();
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        lstAccountIds.add(objPAM.Account__c);
        mapAccountIDFullTermination.put(objPAM.Account__c, true);
    }
    map<Id, Account> mapAccount = new Map<Id, Account> ([select id, ownerID, (SELECT id, FirstName, LastName, GPU_Genius_Groups__c, role__c, email, phone, ownerId, AccountId, Portal_User_Content_Type__c, Portal_Groups__c, RecordTypeId, Community_User__c, Community_User_Active__c FROM Contacts), (select id, Partner_Competency__c, partner_program_name__c, Partner_Sub_Program__c, Program_Level__c from Account_Attributes__r where Date_Competency_Terminated__c = NULL), (select id,name,Email__c,Job_Role__c, Leads_and_Opportunities__c,Phone__c,Sales_Training__c,Technical_Training__c from NPN_Key_Contacts__r where synced__c = false) from Account where id in: lstAccountIds]);
    for(Account acc : mapAccount.values()) {
        for(Partner_Attribute__c objPA : acc.Account_Attributes__r) {
            mapRoleLstPermissionsToBeAdded = new Map<String, list<String> >();
            for(NPN_Competency_Permissions_Group_Map__c objNPNCPGV : mapOnboardingCompetencyPermissionsAndGroup.values()) {
                if(
                    (String.isEmpty(objNPNCPGV.program_type__c) || objNPNCPGV.program_type__c == objPA.partner_program_name__c) &&
                    (String.isEmpty(objNPNCPGV.competency__c) || objPA.partner_competency__c == objNPNCPGV.competency__c) &&
                    (String.isEmpty(objNPNCPGV.program_level__c ) || objNPNCPGV.program_level__c == objPA.program_level__c) &&
                    (String.isEmpty(objNPNCPGV.Sub_Program_Type__c) || objNPNCPGV.Sub_Program_Type__c == objPA.Partner_Sub_Program__c)) {
                    strRole = String.isEmpty(objNPNCPGV.Role__c) ? 'Default' : objNPNCPGV.Role__c;
                    if(mapRoleLstPermissionsToBeAdded.containsKey(strRole)) {
                        if(objNPNCPGV.permissions_and_group__c.contains(';')) {
                            mapRoleLstPermissionsToBeAdded.get(strRole).addAll(objNPNCPGV.permissions_and_group__c.split(';'));
                        } else {
                            mapRoleLstPermissionsToBeAdded.get(strRole).add(objNPNCPGV.permissions_and_group__c);
                        }
                    } else {
                        if(objNPNCPGV.permissions_and_group__c.contains(';')) {
                            list<String> lstPermissionsToBeAdded =  new list<String>();
                            lstPermissionsToBeAdded.addAll(objNPNCPGV.permissions_and_group__c.split(';'));
                            mapRoleLstPermissionsToBeAdded.put(strRole, lstPermissionsToBeAdded);
                        } else {
                            mapRoleLstPermissionsToBeAdded.put(strRole,  new list<String> {objNPNCPGV.permissions_and_group__c});
                        }
                    }
                }
            }
            for(NPN_Onboarding_GPU_Genius_Map__c objOnboardingCompetencyGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {
                if((String.isEmpty(objOnboardingCompetencyGPUGenius.Competency__c) || (objPA.Partner_Competency__c == objOnboardingCompetencyGPUGenius.Competency__c)) &&
                   (String.isEmpty(objOnboardingCompetencyGPUGenius.Program_Type__c) || (objPA.Partner_Program_Name__c == objOnboardingCompetencyGPUGenius.Program_Type__c)) &&
                   (String.isEmpty(objOnboardingCompetencyGPUGenius.subprogram_type__c) || (objPA.Partner_Sub_Program__c == objOnboardingCompetencyGPUGenius.subprogram_type__c))) {
                    strRole = String.isEmpty(objOnboardingCompetencyGPUGenius.Role__c) ? 'Default' : objOnboardingCompetencyGPUGenius.Role__c;
                    if(mapRoleLstGPUGeniusToBeAdded.containsKey(strRole)) {
                        if(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.contains(';')) {
                            mapRoleLstGPUGeniusToBeAdded.get(strRole).addAll(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.split(';'));
                        } else {
                            mapRoleLstGPUGeniusToBeAdded.get(strRole).add(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c);
                        }
                    } else {
                        if(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.contains(';')) {
                            list<String> lstGPUGeniusToBeAdded =  new list<String>();
                            lstGPUGeniusToBeAdded.addAll(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.split(';'));
                            mapRoleLstGPUGeniusToBeAdded.put(strRole, lstGPUGeniusToBeAdded);
                        } else {
                            mapRoleLstGPUGeniusToBeAdded.put(strRole,  new list<String> {objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c});
                        }
                    }
                }
            }
            if(!mapRoleLstPermissionsToBeAdded.isEmpty()) {
                if(mapAccIdMapPCLLstPermissionsAdded.containsKey(acc.id)) {
                    mapAccIdMapPCLLstPermissionsAdded.get(acc.id).put(objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c, mapRoleLstPermissionsToBeAdded);
                }else{
                    mapAccIdMapPCLLstPermissionsAdded.put(acc.id, new Map<String,Map<String, list<String> > > {objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c=> mapRoleLstPermissionsToBeAdded});
                }
            }
            if(!mapRoleLstGPUGeniusToBeAdded.isEmpty()) {
                if(mapAccIdMapPCLLstGPUGeniusAdded.containsKey(acc.id)) {
                    mapAccIdMapPCLLstGPUGeniusAdded.get(acc.id).put(objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c, mapRoleLstGPUGeniusToBeAdded);
                }else{
                    mapAccIdMapPCLLstGPUGeniusAdded.put(acc.id, new Map<String,Map<String, list<String> > > {objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c=> mapRoleLstGPUGeniusToBeAdded});
                }
            }
        }
    }
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        mapRoleLstPermissionsToBeRemoved = new Map<String, list<String> >();
        Set<String> objPAMCompetencies = splitStringToSet(objPAM.competency__c,';');
        for(NPN_Competency_Permissions_Group_Map__c objNPNCPGV : mapOnboardingCompetencyPermissionsAndGroup.values()) {
            if(
                (String.isEmpty(objNPNCPGV.program_type__c) || objNPNCPGV.program_type__c == objPAM.program_type__c) &&
                (String.isEmpty(objNPNCPGV.competency__c) || objPAMCompetencies.contains(objNPNCPGV.competency__c)) &&
                (String.isEmpty(objNPNCPGV.program_level__c ) || objNPNCPGV.program_level__c == objPAM.competency_level__c ) &&
                (String.isEmpty(objNPNCPGV.Sub_Program_Type__c) || objNPNCPGV.Sub_Program_Type__c == objPAM.subprogram_type__c)) {
                strRole = String.isEmpty(objNPNCPGV.Role__c) ? 'Default' : objNPNCPGV.Role__c;
                if(mapRoleLstPermissionsToBeRemoved.containsKey(strRole)) {
                    if(objNPNCPGV.permissions_and_group__c.contains(';')) {
                        mapRoleLstPermissionsToBeRemoved.get(strRole).addAll(objNPNCPGV.permissions_and_group__c.split(';'));
                    } else {
                        mapRoleLstPermissionsToBeRemoved.get(strRole).add(objNPNCPGV.permissions_and_group__c);
                    }
                } else {
                    if(objNPNCPGV.permissions_and_group__c.contains(';')) {
                        list<String> lstPermissionsToBeRemoved =  new list<String>();
                        lstPermissionsToBeRemoved.addAll(objNPNCPGV.permissions_and_group__c.split(';'));
                        mapRoleLstPermissionsToBeRemoved.put(strRole, lstPermissionsToBeRemoved);
                    } else {
                        mapRoleLstPermissionsToBeRemoved.put(strRole,  new list<String> {objNPNCPGV.permissions_and_group__c});
                    }
                }
            }
        }
        for(NPN_Onboarding_GPU_Genius_Map__c objNPNGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {
            if((String.isEmpty(objNPNGPUGenius.Competency__c) || (objPAMCompetencies.contains(objNPNGPUGenius.Competency__c))) &&
               (String.isEmpty(objNPNGPUGenius.Program_Type__c) || (objPAM.Program_Type__c == objNPNGPUGenius.Program_Type__c)) &&
               (String.isEmpty(objNPNGPUGenius.subprogram_type__c) || (objPAM.subprogram_type__c == objNPNGPUGenius.subprogram_type__c))) {
                strRole = String.isEmpty(objNPNGPUGenius.Role__c) ? 'Default' : objNPNGPUGenius.Role__c;
                if(mapRoleLstGPUGeniusToBeRemoved.containsKey(strRole)) {
                    if(objNPNGPUGenius.GPU_Genius_Group__c.contains(';')) {
                        mapRoleLstGPUGeniusToBeRemoved.get(strRole).addAll(objNPNGPUGenius.GPU_Genius_Group__c.split(';'));
                    } else {
                        mapRoleLstGPUGeniusToBeRemoved.get(strRole).add(objNPNGPUGenius.GPU_Genius_Group__c);
                    }
                } else {
                    if(objNPNGPUGenius.GPU_Genius_Group__c.contains(';')) {
                        list<String> lstGGToBeRemoved =  new list<String>();
                        lstGGToBeRemoved.addAll(objNPNGPUGenius.GPU_Genius_Group__c.split(';'));
                        mapRoleLstGPUGeniusToBeRemoved.put(strRole, lstGGToBeRemoved);
                    } else {
                        mapRoleLstGPUGeniusToBeRemoved.put(strRole,  new list<String> {objNPNGPUGenius.GPU_Genius_Group__c});
                    }
                }
            }
        }
        //lstAccountIds.add(objPAM.Account__c);
        mapAccIdLstPermissionsRemoved.put(objPAM.Account__c, mapRoleLstPermissionsToBeRemoved);
        mapAccIdLstGPUGeniusRemoved.put(objPAM.Account__c, mapRoleLstGPUGeniusToBeRemoved);
        system.debug('mapAccIdLstPermissionsRemoved = '+mapAccIdLstPermissionsRemoved);
        system.debug('mapAccIdLstGPUGeniusRemoved = '+mapAccIdLstGPUGeniusRemoved);
    }
    //map<Id, Account> mapAccount = new Map<Id, Account> ([select id, (SELECT id, FirstName, LastName, GPU_Genius_Groups__c, role__c, email, phone, ownerId, AccountId, Portal_User_Content_Type__c, Portal_Groups__c from Contacts), (select id, Partner_Competency__c , partner_program_name__c, Partner_Sub_Program__c, Program_Level__c from Account_Attributes__r where Date_Competency_Terminated__c != NULL), (select id,name,Email__c,Job_Role__c, Leads_and_Opportunities__c,Phone__c,Sales_Training__c,Technical_Training__c from NPN_Key_Contacts__r where synced__c = false) from Account where id in :lstAccountIds]);
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        Set<String> objPAMCompetencies = splitStringToSet(objPAM.competency__c,';');
        if(mapAccount.containsKey(objPAM.account__c)) {
            for(Contact con : mapAccount.get(objPAM.account__c).Contacts) {
                if(con.Community_User_Active__c && partnerContactRT.equals(con.RecordTypeId)) { //Added for SDS-2826
                    Set<String> permValSet = splitStringToSet(con.Portal_Groups__c,';');
                    Set<String> ggValSet = splitStringToSet(con.GPU_Genius_Groups__c,';');
                    con.ownerID = mapAccount.get(objPAM.account__c).ownerID;
                    if(mapAccIdLstPermissionsRemoved.containsKey(con.AccountId)) {
                        for(String strRoleItr : mapAccIdLstPermissionsRemoved.get(con.accountId).keyset()) {
                            if(strRoleItr == 'Default' || (con.role__c!= null && con.role__c.contains(strRoleItr))) {
                                for(String strPermissionToBeRemoved : mapAccIdLstPermissionsRemoved.get(con.accountId).get(strRoleItr)) {
                                    permValSet.remove(strPermissionToBeRemoved.trim());
                                }
                            }
                        }
                    }
                    if(mapAccIdLstGPUGeniusRemoved.containsKey(con.AccountId)) {
                        for(String strRoleItr : mapAccIdLstGPUGeniusRemoved.get(con.accountId).keyset()) {
                            if(strRoleItr == 'Default' || (con.role__c!= null && con.role__c.contains(strRoleItr))) {
                                for(String strPermissionToBeRemoved : mapAccIdLstGPUGeniusRemoved.get(con.accountId).get(strRoleItr)) {
                                    ggValSet.remove(strPermissionToBeRemoved.trim());
                                }
                            }
                        }
                    }
                    con.Portal_Groups__c = implodeSetToString(con.Portal_Groups__c, permValSet, ';');
                    con.GPU_Genius_Groups__c = implodeSetToString(con.GPU_Genius_Groups__c, ggValSet, ';');
                    system.debug('con.id= '+con.id);
                    system.debug('con.Portal_Groups__c= '+con.Portal_Groups__c);
                    system.debug('con.GPU_Genius_Groups__c = '+con.GPU_Genius_Groups__c );
                    lstContact.add(con);
                }
            }

            for(Partner_Attribute__c objPA : mapAccount.get(objPAM.account__c).Account_Attributes__r) {
                //if(objPA.Partner_Program_Name__c == objPAM.program_type__c && objPAM.competency__c.contains(objPA.Partner_Competency__c) && objPA.program_level__c == objPAM.competency_level__c && objPA.Partner_Sub_Program__c == objPAM.SubProgram_Type__c) {
                if(objPA.Partner_Program_Name__c == objPAM.program_type__c && (!objPAMCompetencies.isEmpty() && objPAMCompetencies.contains(objPA.Partner_Competency__c)) && objPA.program_level__c == objPAM.competency_level__c && objPA.Partner_Sub_Program__c == objPAM.SubProgram_Type__c) {
                    objPA.Date_Competency_Terminated__c = System.today();
                    lstPartnerAttribute.add(objPA);
                    if(mapAccIdMapPCLLstPermissionsAdded.containsKey(objPAM.account__c) && mapAccIdMapPCLLstPermissionsAdded.get(objPAM.account__c).containskey(objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c)) {
                        mapAccIdMapPCLLstPermissionsAdded.get(objPAM.account__c).remove(objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c);
                        if(mapAccIdMapPCLLstPermissionsAdded.get(objPAM.account__c).isEmpty()) {
                            mapAccIdMapPCLLstPermissionsAdded.remove(objPAM.account__c);
                        }
                    }
                    if(mapAccIdMapPCLLstGPUGeniusAdded.containsKey(objPAM.account__c) && mapAccIdMapPCLLstGPUGeniusAdded.get(objPAM.account__c).containskey(objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c)) {
                        mapAccIdMapPCLLstGPUGeniusAdded.get(objPAM.account__c).remove(objPA.partner_program_name__c+objPA.partner_competency__c+objPA.Partner_Sub_Program__c);
                        if(mapAccIdMapPCLLstGPUGeniusAdded.get(objPAM.account__c).isEmpty()) {
                            mapAccIdMapPCLLstGPUGeniusAdded.remove(objPAM.account__c);
                        }
                    }

                } else {
                    mapAccountIDFullTermination.remove(objPAM.account__c);
                }
            }
        }
    }
    system.debug('mapAccIdMapPCLLstPermissionsAdded = '+mapAccIdMapPCLLstPermissionsAdded);
    if(!mapAccIdMapPCLLstPermissionsAdded.isEmpty()) {
        for(Contact con: lstContact) {
            if(con.Community_User_Active__c && partnerContactRT.equals(con.RecordTypeId)) {        //Added for SDS-2826
                Set<String> permValSet = splitStringToSet(con.Portal_Groups__c,';');
                if(mapAccIdMapPCLLstPermissionsAdded.containsKey(con.accountId)) {
                    for(Map<String, list<String> > mapRoleLstPermissionsToBeAddedIterator : mapAccIdMapPCLLstPermissionsAdded.get(con.accountId).values() ) {
                        for(String strRoleItr : mapRoleLstPermissionsToBeAddedIterator.keySet()) {
                            if(strRoleItr == 'Default' || (con.role__c!= null && con.role__c.contains(strRoleItr))) {
                                for(String strPermissionsToBeAdded : mapRoleLstPermissionsToBeAddedIterator.get(strRoleItr)) {
                                    if(strPermissionsToBeAdded.contains(';')) {
                                        for(String eachPermissionAndGroup : strPermissionsToBeAdded.split(';')) {
                                            if(!permValSet.contains(eachPermissionAndGroup.trim())) {
                                                permValSet.add(eachPermissionAndGroup.trim());
                                            }
                                        }
                                    } else if(!permValSet.contains(strPermissionsToBeAdded.trim())) {
                                        permValSet.add(strPermissionsToBeAdded.trim());
                                    }
                                }
                            }
                        }
                    }
                }
                con.Portal_Groups__c = implodeSetToString(con.Portal_Groups__c, permValSet, ';');
            }
        }
    }

    if(!mapAccIdMapPCLLstGPUGeniusAdded.isEmpty()) {
        for(Contact con: lstContact) {
            if(con.Community_User_Active__c && partnerContactRT.equals(con.RecordTypeId)) {        //Added for SDS-2826
                Set<String> ggValSet = splitStringToSet(con.GPU_Genius_Groups__c,';');
                system.debug('con.id= '+con.id);
                system.debug('con.GPU_Genius_Groups__c= '+con.Portal_Groups__c);
                if(mapAccIdMapPCLLstGPUGeniusAdded.containsKey(con.accountId)) {
                    for(Map<String, list<String> > mapRoleLstGPUGeniusToBeAddedIterator : mapAccIdMapPCLLstGPUGeniusAdded.get(con.accountId).values() ) {
                        for(String strRoleItr : mapRoleLstGPUGeniusToBeAddedIterator.keySet()) {
                            if(strRoleItr == 'Default' || (con.role__c!= null && con.role__c.contains(strRoleItr))) {
                                for(String strGPUGeniusToBeAdded : mapRoleLstGPUGeniusToBeAddedIterator.get(strRoleItr)) {
                                    system.debug('strGPUGeniusToBeAdded = '+strGPUGeniusToBeAdded);
                                    if(strGPUGeniusToBeAdded.contains(';')) {
                                        for(String eachGPUGenius : strGPUGeniusToBeAdded.split(';')) {
                                            system.debug('eachGPUGenius = '+eachGPUGenius);
                                            if(!ggValSet.contains(eachGPUGenius.trim())) {
                                                system.debug('con.GPU_Genius_Groups__c before = '+con.Portal_Groups__c);
                                                ggValSet.add(eachGPUGenius.trim());
                                                system.debug('con.GPU_Genius_Groups__c after = '+con.Portal_Groups__c);
                                            }
                                        }
                                    } else if(!ggValSet.contains(strGPUGeniusToBeAdded.trim())) {
                                        system.debug('con.GPU_Genius_Groups__c before = '+con.Portal_Groups__c);
                                        ggValSet.add(strGPUGeniusToBeAdded.trim());
                                        system.debug('con.GPU_Genius_Groups__c after = '+con.Portal_Groups__c);
                                    }
                                }
                            }
                        }
                    }
                }
                con.GPU_Genius_Groups__c = implodeSetToString(con.GPU_Genius_Groups__c, ggValSet, ';');
            }
        }
    }
    //Rajat commented below code for the new queuable job
    /*if(!lstPartnerAttribute.isEmpty()) {
        update lstPartnerAttribute;
       }
       if(!lstContact.isEmpty()) {
        update lstContact;
       }*/

    System.enqueueJob(new NPN_QueableClassForDocuSignDML(lstContact, lstPartnerAttribute, null));

    if(!mapAccountIDFullTermination.isEmpty()) {
        ID jobID = System.enqueueJob(new NV_FullTerminationClass(mapAccountIDFullTermination.keySet()));
    }
}

public static void promotion_demotion(list<NPN_PartnerAttributes_Modifiaction__c> lstPAM, map<Id, Account> mapAccount, map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup, String strPAM) {
    set<String> oldLevelSet = new set<String>();
    set<String> newLevelSet = new set<String>();
    map<String, String> mapPromotionLevel = new map<String, String> {'Registered'=>'Preferred', 'Preferred'=>'Elite'};
    map<String, String> mapDemotionLevel = new map<String, String> {'Preferred'=>'Registered', 'Elite'=>'Preferred'};
    set<String> lstPermissionsToBeAdded = new set<String>();
    set<String> lstPermissionsToBeRemoved = new set<String>();
    list<Partner_Attribute__c> lstPartnerAttribute = new list<Partner_Attribute__c>();
    list<Contact> lstContact = new list<Contact>();
    Id partnerContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();         // Added for SDS-2826
    /*for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        lstPermissionsToBeAdded = new list<String>();
        lstPermissionsToBeRemoved = new list<String>();
        for(NPN_Competency_Permissions_Group_Map__c objNPNCPGV : mapOnboardingCompetencyPermissionsAndGroup.values()) {
            if(objNPNCPGV.role__c == null) {
                if(objNPNCPGV.program_type__c == objPAM.program_type__c && objPAM.competency__c.contains(objNPNCPGV.competency__c) && objNPNCPGV.program_level__c == newLevel && (objNPNCPGV.Sub_Program_Type__c==null || objNPNCPGV.Sub_Program_Type__c == objPAM.SubProgram_Type__c)) {
                    lstPermissionsToBeAdded.add(objNPNCPGV.permissions_and_group__c);
                }
                if(objNPNCPGV.program_type__c == objPAM.program_type__c && objPAM.competency__c.contains(objNPNCPGV.competency__c) && objNPNCPGV.program_level__c == oldLevel && (objNPNCPGV.Sub_Program_Type__c==null || objNPNCPGV.Sub_Program_Type__c == objPAM.SubProgram_Type__c)) {
                    lstPermissionsToBeRemoved.add(objNPNCPGV.permissions_and_group__c);
                }
            }
        }
        mapAccIdLstPermissionsAdded.put(objPAM.account__c, lstPermissionsToBeAdded);
        mapAccIdLstPermissionsRemoved.put(objPAM.account__c, lstPermissionsToBeRemoved);
       }*/
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        Set<String> objPAMCompetencies = new Set<String>();
        if(String.isNotBlank(objPAM.competency__c)) {
            for(String compVal : objPAM.competency__c.split(';')) {
                objPAMCompetencies.add(compVal.trim());
            }
        }
        if(mapAccount.containsKey(objPAM.account__c)) {
            oldLevelSet = new set<String>();
            newLevelSet = new set<String>();
            for(Partner_Attribute__c objPA : mapAccount.get(objPAM.account__c).Account_Attributes__r) {
                //if(objPA.Partner_Program_Name__c == objPAM.program_type__c && objPAM.competency__c.contains(objPA.Partner_Competency__c) && objPA.Partner_Sub_Program__c == objPAM.SubProgram_Type__c) {
                if(objPA.Partner_Program_Name__c == objPAM.program_type__c && objPAMCompetencies.contains(objPA.Partner_Competency__c) && objPA.Partner_Sub_Program__c == objPAM.SubProgram_Type__c) {
                    oldLevelSet.add(objPA.Program_Level__c);
                    if(strPAM == 'Promotion') {
                        newLevelSet.add(mapPromotionLevel.get(objPA.Program_Level__c));
                        objPA.Program_Level__c = mapPromotionLevel.get(objPA.Program_Level__c);
                    } else {
                        newLevelSet.add(mapDemotionLevel.get(objPA.Program_Level__c));
                        objPA.Program_Level__c = mapDemotionLevel.get(objPA.Program_Level__c);
                    }
                    lstPartnerAttribute.add(objPA);
                }
            }
            system.debug('newLevelSet -> '+newLevelSet);
            system.debug('oldLevelSet -> '+oldLevelSet);
            lstPermissionsToBeAdded = new set<String>();
            lstPermissionsToBeRemoved = new set<String>();
            for(NPN_Competency_Permissions_Group_Map__c objNPNCPGV : mapOnboardingCompetencyPermissionsAndGroup.values()) {
                if(objNPNCPGV.role__c == null) {
                    //if(objNPNCPGV.program_type__c == objPAM.program_type__c && objPAM.competency__c.contains(objNPNCPGV.competency__c) && newLevelSet.contains(objNPNCPGV.program_level__c) && (objNPNCPGV.Sub_Program_Type__c==null || objNPNCPGV.Sub_Program_Type__c == objPAM.SubProgram_Type__c)) {
                    if(objNPNCPGV.program_type__c == objPAM.program_type__c && (!objPAMCompetencies.isEmpty() && objPAMCompetencies.contains(objNPNCPGV.competency__c)) && newLevelSet.contains(objNPNCPGV.program_level__c) && (objNPNCPGV.Sub_Program_Type__c==null || objNPNCPGV.Sub_Program_Type__c == objPAM.SubProgram_Type__c)) {
                        lstPermissionsToBeAdded.add(objNPNCPGV.permissions_and_group__c);
                    }
                    //if(objNPNCPGV.program_type__c == objPAM.program_type__c && objPAM.competency__c.contains(objNPNCPGV.competency__c) && oldLevelSet.contains(objNPNCPGV.program_level__c) && (objNPNCPGV.Sub_Program_Type__c==null || objNPNCPGV.Sub_Program_Type__c == objPAM.SubProgram_Type__c)) {
                    if(objNPNCPGV.program_type__c == objPAM.program_type__c && (!objPAMCompetencies.isEmpty() && objPAMCompetencies.contains(objNPNCPGV.competency__c)) && oldLevelSet.contains(objNPNCPGV.program_level__c) && (objNPNCPGV.Sub_Program_Type__c==null || objNPNCPGV.Sub_Program_Type__c == objPAM.SubProgram_Type__c)) {
                        lstPermissionsToBeRemoved.add(objNPNCPGV.permissions_and_group__c);
                    }
                }
            }
            system.debug('lstPermissionsToBeRemoved -> '+lstPermissionsToBeRemoved);
            system.debug('lstPermissionsToBeAdded -> '+lstPermissionsToBeAdded);

            for(Contact con : mapAccount.get(objPAM.account__c).Contacts) {
                if(con.Community_User_Active__c && partnerContactRT.equals(con.RecordTypeId)) {        //Added for SDS-2826
                    Set<String> contactPermissionSet = new Set<String>();
                    if(String.isBlank(con.Portal_Groups__c)) {
                        con.Portal_Groups__c = '';
                    } else {
                        for(String permValStr :  con.Portal_Groups__c.split(';')) {
                            contactPermissionSet.add(permValStr.trim());
                        }
                    }
                    con.ownerID = mapAccount.get(objPAM.account__c).ownerID;
                    /*if(con.Portal_Groups__c != null && con.Portal_Groups__c != '')
                        con.Portal_Groups__c += ';';
                       else
                        con.Portal_Groups__c = '';*/
                    system.debug('contactPermissionSet before update -> '+contactPermissionSet);
                    for(String strPermissionToBeRemoved : lstPermissionsToBeRemoved) {
                        if(strPermissionToBeRemoved.contains(';')) {
                            for(String eachPermissionToBeRemoved : strPermissionToBeRemoved.split(';')) {
                                if(contactPermissionSet.contains(eachPermissionToBeRemoved.trim())) {
                                    contactPermissionSet.remove(eachPermissionToBeRemoved.trim());
                                }
                            }
                        }
                    }
                    system.debug('con.Portal_Groups__c after removing permissions -> '+con.Portal_Groups__c);
                    for(String strPermissionToBeAdded : lstPermissionsToBeAdded) {
                        if(strPermissionToBeAdded.contains(';')) {
                            for(String eachPermissionToBeAdded : strPermissionToBeAdded.split(';')) {
                                if(!contactPermissionSet.contains(eachPermissionToBeAdded.trim())) {
                                    contactPermissionSet.add(eachPermissionToBeAdded.trim());
                                }
                            }
                        }
                    }
                    if(!contactPermissionSet.isEmpty() && contactPermissionSet.size() > 0 ) {
                        con.Portal_Groups__c = '';
                        for(String permVal : contactPermissionSet) {
                            con.Portal_Groups__c += permVal + ';';
                        }
                    }
                    system.debug('con.Portal_Groups__c after removing permissions -> '+con.Portal_Groups__c);
                    lstContact.add(con);
                }
            }
        }
    }
    //Rajat commented below code for the new queuable job
    /*if(!lstPartnerAttribute.isEmpty()) {
        update lstPartnerAttribute;
       }
       if(!lstContact.isEmpty()) {
        update lstContact;
       }*/

    // Parameters for the below enqueue method
    //contactsForInsert, contactsForUpdate, partnerAttributesForInsert, NPNKCForUpdate
    System.enqueueJob(new NPN_QueableClassForDocuSignDML(lstContact, lstPartnerAttribute, null));
}


// public static void addOnFlow(list<NPN_PartnerAttributes_Modifiaction__c> lstPAM, map<Id, Account> mapAccount, map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius, map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup, list<RecordType> lstRT, List<NPN_Onboarding_Competency_GPU_Genius_Map__mdt> ggMDList) {   //Rajat commented for SDS-2826 and NPN_Onboarding_Competency_GPU_Genius_Map__mdt is NOT IN USE
public static void addOnFlow(list<NPN_PartnerAttributes_Modifiaction__c> lstPAM, map<Id, Account> mapAccount, map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius, map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup) {         //Rajat added for SDS-2826

    Id partnerContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();         // Added for SDS-2826
    Id salesContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SalesContact').getRecordTypeId();         // Added for SDS-2826
    Map<Id, Boolean> contactIdActiveUserMap = new Map<Id, Boolean>();         // Added for SDS-2826

    list<NPN_Key_Contact__c> lstNPNKC = new list<NPN_Key_Contact__c>();
    list<Partner_Attribute__c> lstPartnerAttribute = new list<Partner_Attribute__c>();
    list<Partner_Attribute__c> lstExistingPartnerAttribute = new list<Partner_Attribute__c>();
    map<String, Contact> mapContactEmailContact = new map<String, Contact>();
    Account acc;
    //list<list<Contact> > lstLstContact = new list<list<Contact> >(); // used nowhere
    map<String, Contact> existingContactMap = new map<String, Contact>();
    map<String, Contact> existingSalesContactMap = new map<String, Contact>();         //Added for SDS-2826
    list<Contact> lstContact = new list<Contact>();
    /*** Rajat - Changes for POS Exemption (SDS-1873) START*/
    Map<String, Boolean> mapExemptPOS = new Map<String, Boolean>();
    // Excluding Partner Level from key generation of the below map.
    for(NPN_Exempt_from_POS_Submission__mdt exmposObj : [SELECT DeveloperName,Exempted_from_POS_Submission__c,Id,Label,Partner_Competency__c,Partner_Program_Name__c,Partner_Sub_Program__c,Program_Level__c,QualifiedApiName FROM NPN_Exempt_from_POS_Submission__mdt]) {
        mapExemptPOS.put(exmposObj.Partner_Program_Name__c+exmposObj.Partner_Sub_Program__c+exmposObj.Partner_Competency__c, exmposObj.Exempted_from_POS_Submission__c);
    }
    /*** Rajat - Changes for POS Exemption (SDS-1873) FINISH*/
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : lstPAM) {
        Set<String> objPAMCompetencies = new Set<String>();
        if(String.isNotBlank(objPAM.competency__c)) {
            for(String compVal : objPAM.competency__c.split(';')) {
                objPAMCompetencies.add(compVal.trim());
            }
        }
        if(mapAccount.containsKey(objPAM.account__c)) {
            set<String> competencySet = new set<String>();
            map<Id, Partner_Attribute__c> existingPAMap = new map<Id, Partner_Attribute__c>();
            acc = mapAccount.get(objPAM.account__c);
            for(Partner_Attribute__c objPA : acc.Account_Attributes__r) {
                existingPAMap.put(objPA.Id, objPA);
                competencySet.add(objPA.Partner_Competency__c);
                lstExistingPartnerAttribute.add(objPA);
            }

            // Rajat changes for SDS-2826 START
            // Logic: Query on the users of the partner contact and check if they are active.
            // Only existing partner contacts with active users will get updated with latest permissions and GG
            // Need to test the scenario of the existing Sales contacts
            for(Contact con : acc.Contacts) {
                if(partnerContactRT.equals(con.RecordTypeId)) {
                    existingContactMap.put(con.email, con);
                }else if(salesContactRT.equals(con.RecordTypeId)) {
                    existingSalesContactMap.put(con.email, con);
                }
            }
            system.debug('---> existingContactMap.size() '+ existingContactMap.size()+':::'+'existingContactMap=:'+existingContactMap);
            system.debug('---> existingSalesContactMap.size() '+ existingSalesContactMap.size()+':::'+'existingSalesContactMap=:'+existingSalesContactMap);
            // Rajat changes for SDS-2826 END

            for(Contact con : existingContactMap.values()) {
                if(con.Community_User_Active__c && partnerContactRT.equals(con.RecordTypeId)) {        //Added for SDS-2826
                    //con = updateGPUGeniusForContacts(mapOnboardingCompetencyGPUGenius, con, objPAM, lstExistingPartnerAttribute, ggMDList, true);
                    con = updateGPUGeniusForContacts(mapOnboardingCompetencyGPUGenius, con, objPAM, lstExistingPartnerAttribute, true);
                    con = updatePermissionSetsAndGroupsForContacts(mapOnboardingCompetencyPermissionsAndGroup, con, objPAM, lstExistingPartnerAttribute, true);
                    con.ownerID = acc.ownerID;
                    if(String.isBlank(con.MailingCountry) && String.isNotBlank(acc.BillingCountry)) {
                        con.MailingCountry = acc.BillingCountry;
                        con.Synced_with_Docusign__c = true;         // Added by Rajat
                    }
                    existingContactMap.put(con.email, con);         // only active partner contacts are put
                }
            }
            system.debug('---> existingContactMap.size() '+ existingContactMap.size()+':::'+'existingContactMap=:'+existingContactMap);         
            for(String strCompetency : objPAM.competency__c.split(';')) {
                Partner_Attribute__c objPartnerAttribute = new Partner_Attribute__c();
                objPartnerAttribute.account_name__c = acc.Id;
                objPartnerAttribute.Partner_Competency__c = strCompetency;
                objPartnerAttribute.Partner_Program_Name__c = objPAM.program_Type__c;
                objPartnerAttribute.Program_Level__c = objPAM.competency_level__c;
                objPartnerAttribute.Partner_Sub_Program__c = objPAM.subprogram_type__c;
                objPartnerAttribute.Date_Competency_Signed__c = System.today();
                objPartnerAttribute.Primary_Program_for_POS__c = false;
                /*** Rajat - Changes for POS Exemption (SDS-1873) START*/
                if(!mapExemptPOS.isEmpty() && mapExemptPOS.containsKey(objPartnerAttribute.Partner_Program_Name__c+objPartnerAttribute.Partner_Sub_Program__c+strCompetency)) {
                    objPartnerAttribute.Exempted_from_POS_Submission__c = mapExemptPOS.get(objPartnerAttribute.Partner_Program_Name__c+objPartnerAttribute.Partner_Sub_Program__c+objPartnerAttribute.Partner_Competency__c);
                }
                /*** Rajat - Changes for POS Exemption (SDS-1873) FINISH*/
                lstPartnerAttribute.add(objPartnerAttribute);
            }
            system.debug('--> acc.NPN_Key_Contacts__r.size() :  '+ acc.NPN_Key_Contacts__r.size());
            system.debug('--> acc.NPN_Key_Contacts__r :  '+ acc.NPN_Key_Contacts__r);
            for(NPN_Key_Contact__c objNPNKeyContact : acc.NPN_Key_Contacts__r) {
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
                            if(String.isNotBlank(objOnboardingCompetencyGPUGenius.Competency__c) &&
                               (!objPAMCompetencies.isEmpty() && objPAMCompetencies.contains(objOnboardingCompetencyGPUGenius.Competency__c)) && String.isNotBlank(objOnboardingCompetencyGPUGenius.role__c) && mapContactEmailContact.get(objNPNKeyContact.Email__c).role__c.contains(objOnboardingCompetencyGPUGenius.role__c) && String.isNotBlank(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c) && !mapContactEmailContact.get(objNPNKeyContact.Email__c).GPU_Genius_Groups__c.contains(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
                                mapContactEmailContact.get(objNPNKeyContact.Email__c).GPU_Genius_Groups__c += objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c + ';';
                            }
                        }
                    }
                }
                else {
                    Contact con;
                    if(existingContactMap.containsKey(objNPNKeyContact.Email__c)) {
                        con = existingContactMap.get(objNPNKeyContact.Email__c);
                    } else if (existingSalesContactMap.containsKey(objNPNKeyContact.Email__c)) {                    //Added for SDS-2826
                        con = existingSalesContactMap.get(objNPNKeyContact.Email__c);
                    }else {
                        con = new Contact();
                    }
                    con.RecordTypeId = partnerContactRT;
                    con.email = objNPNKeyContact.Email__c;
                    con.phone = objNPNKeyContact.Phone__c;
                    con.ownerId = acc.ownerId;
                    con.AccountId = acc.id;
                    con.role__c = objNPNKeyContact.Job_Role__c;

                    if(String.isEmpty(con.Portal_User_Content_Type__c)) {
                        con.Portal_User_Content_Type__c = objPAM.Competency__c.split(';')[0];
                    }
                    if(objNPNKeyContact.name.contains(' ')) {
                        con.firstName = objNPNKeyContact.name.SubString(0, objNPNKeyContact.name.lastIndexOf(' '));
                    }
                    if(objNPNKeyContact.name.contains(' ')) {
                        con.lastName = objNPNKeyContact.name.SubString(objNPNKeyContact.name.lastIndexOf(' '), objNPNKeyContact.name.length());
                    } else {
                        con.lastName = objNPNKeyContact.name;
                    }

                    if(String.isNotBlank(acc.BillingCountry)) {
                        con.MailingCountry = acc.BillingCountry;
                        con.Synced_with_Docusign__c = true;         // Added by Rajat
                    }

                    if(objNPNKeyContact.Sales_Training__c && !con.role__c.contains(COMM_CONSTANTS.PROFILE_CATEGORY_SALES)) {
                        con.role__c += ';' + COMM_CONSTANTS.PROFILE_CATEGORY_SALES;
                    }
                    if(objNPNKeyContact.Technical_Training__c && !con.role__c.contains(COMM_CONSTANTS.PROFILE_CATEGORY_TECHNICAL)) {
                        con.role__c += ';' + COMM_CONSTANTS.PROFILE_CATEGORY_TECHNICAL;
                    }
                    //con = updateGPUGeniusForContacts(mapOnboardingCompetencyGPUGenius, con, objPAM, lstExistingPartnerAttribute, ggMDList, false);
                    con = updateGPUGeniusForContacts(mapOnboardingCompetencyGPUGenius, con, objPAM, lstExistingPartnerAttribute, false);
                    con = updatePermissionSetsAndGroupsForContacts(mapOnboardingCompetencyPermissionsAndGroup, con, objPAM, lstExistingPartnerAttribute, false);

                    system.debug('--> objNPNKeyContact.Email__c :  '+ objNPNKeyContact.Email__c);
                    system.debug('--> Is this an existing PARTNER contact? :  '+ existingContactMap.containsKey(objNPNKeyContact.Email__c));
                    system.debug('--> Is this an existing SALES contact? :  '+ existingSalesContactMap.containsKey(objNPNKeyContact.Email__c));
                    
                    if(!existingContactMap.containsKey(objNPNKeyContact.Email__c) && !existingSalesContactMap.containsKey(objNPNKeyContact.Email__c)) {
                        //New Partner Contact
                        lstContact.add(con);
                    } else {  
                        existingContactMap.put(objNPNKeyContact.Email__c, con);
                    }
                    mapContactEmailContact.put(con.email, con);
                }
                objNPNKeyContact.synced__c = true;
                lstNPNKC.add(objNPNKeyContact);
            }           
        }
        lstExistingPartnerAttribute.clear();
    }    
    system.debug('-->>> mapContactEmailContact :'+ mapContactEmailContact);
    system.debug('--->Contacts FOR INSERT lstContact.size() '+ lstContact.size()+':::'+'lstContact=:'+lstContact);
    system.debug('--->Contacts FOR UPDATE existingContactMap.values().size() '+ existingContactMap.values().size()+':::'+'existingContactMap.values()=:'+existingContactMap.values());
    system.debug('--->PA FOR INSERT lstPartnerAttribute.size() '+ lstPartnerAttribute.size()+':::'+'lstPartnerAttribute=:'+lstPartnerAttribute);
    system.debug('--->Key contacts FOR UPDATE lstNPNKC.size() '+ lstNPNKC.size()+':::'+'lstNPNKC=:'+lstNPNKC);
    
    System.enqueueJob(new NPN_QueableClassForDocuSignDML(lstContact, existingContactMap.values(), lstPartnerAttribute, lstNPNKC));
    //Rajat commented below code for the new queuable job
    /*if(!lstContact.isEmpty()) {
        system.debug('inserting contacts');
        system.debug('Limits.getCpuTime() ->'+Limits.getCpuTime());
        system.debug('Limits.getLimitCpuTime() ->'+Limits.getLimitCpuTime());
        insert lstContact;
       }
       if(!existingContactMap.isEmpty()) {
        system.debug('updating existing contacts');
        system.debug('Limits.getCpuTime() ->'+Limits.getCpuTime());
        system.debug('Limits.getLimitCpuTime() ->'+Limits.getLimitCpuTime());
        update existingContactMap.values();
       }
       if(!lstPartnerAttribute.isEmpty()) {
        system.debug('inserting partner attributes');
        system.debug('Limits.getCpuTime() ->'+Limits.getCpuTime());
        system.debug('Limits.getLimitCpuTime() ->'+Limits.getLimitCpuTime());
        insert lstPartnerAttribute;
       }
       if(!lstNPNKC.isEmpty()) {
        system.debug('inserting key contacts');
        system.debug('Limits.getCpuTime() ->'+Limits.getCpuTime());
        system.debug('Limits.getLimitCpuTime() ->'+Limits.getLimitCpuTime());
        update lstNPNKC;
       }*/
}

public static Contact updatePermissionSetsAndGroupsForContacts(map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup, Contact con, NPN_PartnerAttributes_Modifiaction__c objPAM, list<Partner_Attribute__c> lstExistingPartnerAttribute, Boolean onlyExisting) {
    Set<String> permValSet = new Set<String>();

    if(String.isNotBlank(con.Portal_Groups__c)) {
        for(String permVal :  con.Portal_Groups__c.split(';')) {
            permValSet.add(permVal.trim());
        }
    }

    Set<String> objPAMCompetencies = new Set<String>();
    if(String.isNotBlank(objPAM.competency__c)) {
        for(String compVal : objPAM.competency__c.split(';')) {
            objPAMCompetencies.add(compVal.trim());
        }
    }

    for(NPN_Competency_Permissions_Group_Map__c objOnboardingCompetencyPermissionGroup : mapOnboardingCompetencyPermissionsAndGroup.values()) {
        if(String.isNotBlank(objOnboardingCompetencyPermissionGroup.permissions_and_group__c)) {
            if(!onlyExisting) {
                for(Partner_Attribute__c objPA : lstExistingPartnerAttribute) {
                    if(
                        (String.isBlank(objOnboardingCompetencyPermissionGroup.Role__c) ||
                         (String.isNotBlank(con.role__c) && con.role__c.contains(objOnboardingCompetencyPermissionGroup.role__c))) &&

                        (String.isBlank(objOnboardingCompetencyPermissionGroup.Competency__c) ||
                         (objPA.Partner_Competency__c == objOnboardingCompetencyPermissionGroup.Competency__c)) &&

                        (String.isBlank(objOnboardingCompetencyPermissionGroup.program_type__c) ||
                         (objPA.Partner_Program_Name__c == objOnboardingCompetencyPermissionGroup.program_type__c)) &&

                        (String.isBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) ||
                         (objPA.Partner_Sub_Program__c == objOnboardingCompetencyPermissionGroup.sub_program_type__c)) &&

                        (String.isBlank(objOnboardingCompetencyPermissionGroup.program_level__c) ||
                         (objPA.Program_Level__c == objOnboardingCompetencyPermissionGroup.program_level__c))
                        ) {
                        for(String eachPermission : objOnboardingCompetencyPermissionGroup.permissions_and_group__c.split(';')) {
                            permValSet.add(eachPermission );
                        }
                    }
                }
            }
            if(
                (String.isBlank(objOnboardingCompetencyPermissionGroup.Role__c) ||
                 (String.isNotBlank(con.role__c) && con.role__c.contains(objOnboardingCompetencyPermissionGroup.role__c))) &&

                (String.isBlank(objOnboardingCompetencyPermissionGroup.Competency__c) ||
                 (objPAMCompetencies.contains(objOnboardingCompetencyPermissionGroup.Competency__c))) &&

                (String.isBlank(objOnboardingCompetencyPermissionGroup.program_type__c) ||
                 (objPAM.program_type__c == objOnboardingCompetencyPermissionGroup.program_type__c)) &&

                (String.isBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) ||
                 (objPAM.subprogram_type__c == objOnboardingCompetencyPermissionGroup.sub_program_type__c)) &&

                (String.isBlank(objOnboardingCompetencyPermissionGroup.program_level__c) ||
                 (objPAM.Competency_Level__c == objOnboardingCompetencyPermissionGroup.program_level__c))
                ) {
                for(String eachPermission : objOnboardingCompetencyPermissionGroup.permissions_and_group__c.split(';')) {
                    permValSet.add(eachPermission );
                }
            }
        }
    }
    con.Portal_Groups__c = '';
    if(!permValSet.isEmpty() && permValSet.size() > 0 ) {
        for(String permVal : permValSet) {
            if(!con.Portal_Groups__c.contains(permVal.trim())) {
                con.Portal_Groups__c += permVal.trim() + ';';
            }
        }
    }
    return con;
}

//public static Contact updateGPUGeniusForContacts(map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius, Contact con, NPN_PartnerAttributes_Modifiaction__c objPAM, list<Partner_Attribute__c> lstExistingPartnerAttribute, List<NPN_Onboarding_Competency_GPU_Genius_Map__mdt> ggMDList, Boolean onlyExisting) { // Rajat commented as NPN_Onboarding_Competency_GPU_Genius_Map__mdt is NOT IN USE
public static Contact updateGPUGeniusForContacts(map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius, Contact con, NPN_PartnerAttributes_Modifiaction__c objPAM, list<Partner_Attribute__c> lstExistingPartnerAttribute, Boolean onlyExisting) {
    Set<String> ggValSet = new Set<String>();
    if(String.isNotBlank(con.GPU_Genius_Groups__c)) {
        for(String ggValStr :  con.GPU_Genius_Groups__c.split(';')) {
            ggValSet.add(ggValStr.trim());
        }
    }

    Set<String> objPAMCompetencies = new Set<String>();
    if(String.isNotBlank(objPAM.competency__c)) {
        for(String compVal : objPAM.competency__c.split(';')) {
            objPAMCompetencies.add(compVal.trim());
        }
    }

    for(NPN_Onboarding_GPU_Genius_Map__c objOnboardingCompetencyGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {
        if(!onlyExisting) {
            for(Partner_Attribute__c objPA : lstExistingPartnerAttribute) {

                if(String.isNotBlank(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
                    if(
                        (String.isBlank(objOnboardingCompetencyGPUGenius.Role__c) ||
                         (String.isNotBlank(con.Role__c) && con.Role__c.contains(objOnboardingCompetencyGPUGenius.role__c))) &&

                        (String.isBlank(objOnboardingCompetencyGPUGenius.Competency__c) ||
                         (objPA.Partner_Competency__c == objOnboardingCompetencyGPUGenius.Competency__c)) &&

                        (String.isBlank(objOnboardingCompetencyGPUGenius.Program_Type__c) ||
                         (objPA.Partner_Program_Name__c == objOnboardingCompetencyGPUGenius.Program_Type__c)) &&

                        (String.isBlank(objOnboardingCompetencyGPUGenius.subprogram_type__c) ||
                         (objPA.Partner_Sub_Program__c == objOnboardingCompetencyGPUGenius.subprogram_type__c))) {
                        for(String eachGPUGenius : objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.split(';')) {
                            ggValSet.add(eachGPUGenius);
                        }
                    }
                }
            }
        }
        if(String.isNotBlank(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
            if(
                (String.isBlank(objOnboardingCompetencyGPUGenius.Role__c) ||
                 (String.isNotBlank(con.Role__c) && con.Role__c.contains(objOnboardingCompetencyGPUGenius.role__c))) &&

                (String.isBlank(objOnboardingCompetencyGPUGenius.Competency__c) ||
                 (objPAMCompetencies.contains(objOnboardingCompetencyGPUGenius.Competency__c))) &&

                (String.isBlank(objOnboardingCompetencyGPUGenius.Program_Type__c) ||
                 (objPAM.Program_Type__c == objOnboardingCompetencyGPUGenius.Program_Type__c)) &&

                (String.isBlank(objOnboardingCompetencyGPUGenius.subprogram_type__c) ||
                 (objPAM.subprogram_type__c == objOnboardingCompetencyGPUGenius.subprogram_type__c))

                ) {
                for(String eachGPUGenius : objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.split(';')) {
                    ggValSet.add(eachGPUGenius.trim());
                }
            }
        }
    }

    con.GPU_Genius_Groups__c = '';
    if(!ggValSet.isEmpty() && ggValSet.size() > 0 ) {
        for(String ggVal : ggValSet) {
            if(!con.GPU_Genius_Groups__c.contains(ggVal.trim())) {
                con.GPU_Genius_Groups__c += ggVal.trim() + ';';
            }
        }
    }
    return con;
}

public static Set<String> splitStringToSet(String strSplitToSet, String separator) {
    Set<String> setStringValues = new Set<String>();
    if(String.isNotBlank(strSplitToSet)) {
        for(String str : strSplitToSet.split(separator)) {
            setStringValues.add(str.trim());
        }
    }
    return setStringValues;
}

public static String implodeSetToString(String stringField, Set<String> setStringToImplode, String separator) {
    stringField = '';
    if(!setStringToImplode.isEmpty() && setStringToImplode.size() > 0 ) {
        for(String stringToImplode : setStringToImplode) {
            stringField  += stringToImplode.trim() + ';';
        }
    }
    return stringField;
}

}