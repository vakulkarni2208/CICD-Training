/**
 *  @name NPN_TempContactHelper
 *  @description    Created for SDS-741
 *  @author     rkamble
 */
public without sharing class NPN_TempContactHelper {

    /**
     * @name        processTempContacts
     * @description Invoked in the AFTER UPDATE of TempContact Trigger. Segregates temp contact records for processing
     * @param  triggerNewMap triggerNewMap description
     */
    public static void processTempContacts(Map<Id,Temporary_Contact__c> triggerNewMap){
        List<Temporary_Contact__c> tempToNewContactList = new List<Temporary_Contact__c>();
        List<Temporary_Contact__c> contactToUpdateList = new List<Temporary_Contact__c>();
        Map<String, String> revertContactIdsMap = new Map<String, String>();
        List<Temporary_Contact__c> deleteTempContList = new List<Temporary_Contact__c>();
        Map<Id,Id> deactivationMap = new Map<Id,Id>();

        if(!triggerNewMap.isEmpty()) {
            for(Temporary_Contact__c tempCon: triggerNewMap.values()) {
                if('Rejected'.equalsIgnoreCase(tempCon.Status__c)) {
                    if(tempCon.ContactId__c != null) {
                        revertContactIdsMap.put(tempCon.ContactId__c,tempCon.Id);
                    }else{
                        deleteTempContList.add(tempCon);
                    }
                }else if('Completed'.equalsIgnoreCase(tempCon.Status__c)) {
                    // deactivate/ deletion check
                    if(tempCon.ContactId__c != null) {
                        if('Deactivate'.equalsIgnoreCase(tempCon.Action_Requested__c)) {
                            deactivationMap.put(tempCon.ContactId__c, tempCon.Id);
                        }else{
                            contactToUpdateList.add(tempCon);
                        }
                    }else{
                        tempToNewContactList.add(tempCon);
                    }
                }
            }
        }

        if(!tempToNewContactList.isEmpty()) {
            createNewContact(tempToNewContactList);
        }

        if(!contactToUpdateList.isEmpty()) {
            updateContacts(contactToUpdateList);
        }

        if(!revertContactIdsMap.isEmpty()) {
            restoreTempContacts(revertContactIdsMap);
        }

        if(!deactivationMap.isEmpty()) {
            disableContacts(deactivationMap);
        }
    }

    /**
     * @name        disableContacts
     * @description Deactivates the contact and removes GPU Gemius values and Permissions from it.
     * @param  deactivationMap deactivationMap description
     */
    public static void disableContacts (Map<Id,Id> deactivationMap){

        List<Temporary_Contact__c> tempContactForUpdate = new List<Temporary_Contact__c>();
        List<Contact> contactForUpdate = new List<Contact>();
        Set<Id> disableUserSet = new Set<Id>();
        Map<Id, Boolean> disableUserMap = new Map<Id, Boolean>();

        for(Contact objContact : [SELECT Id, Portal_Groups__c, GPU_Genius_Groups__c, Community_User__c FROM Contact WHERE Id = :deactivationMap.keyset()]) {
            if(String.isNotBlank(objContact.Community_User__c)) {
                disableUserSet.add(objContact.Community_User__c);
            }

            objContact.Portal_Groups__c = '';
            objContact.GPU_Genius_Groups__c = '';

            contactForUpdate.add(objContact);

            if(deactivationMap.get(objContact.Id) != null) {
                Temporary_Contact__c tCont = new Temporary_Contact__c();
                tCont.Id = deactivationMap.get(objContact.Id);
                tCont.Deactivated__c = true;

                tempContactForUpdate.add(tCont);
            }
        }

        if (!disableUserSet.isEmpty()) {
            for(User usr : [SELECT Id, IsActive FROM User WHERE Id IN :disableUserSet]) {
                if(usr.IsActive) {
                    disableUserMap.put(usr.Id, false);
                }
            }
        }

        System.debug('>>> tempContactForUpdate :'+tempContactForUpdate);
        if(!tempContactForUpdate.isEmpty()) {
            Database.SaveResult[] srList = database.Update(tempContactForUpdate, false);
        }

        if(!contactForUpdate.isEmpty()) {
            Database.SaveResult[] srListContacts = database.Update(contactForUpdate, false);
        }

        if(!disableUserMap.isEmpty()) {
            System.enqueueJob(new UpdateUsers(disableUserMap));
        }
    }

    /**
     * @name        restoreTempContacts
     * @description Restores the original contact information on the temp contacts when
            the updates are rejected .
     * @param  revertContactIds revertContactIds description
     */
    public static void restoreTempContacts (Map<String, String> revertContactIdsMap){
        List<Temporary_Contact__c> tempContactForUpdate = new List<Temporary_Contact__c>();
        List<Contact> contactForUpdate = new List<Contact>();

        System.debug('>>> Inside restoreTempContacts');

        for(Contact objContact : [SELECT Id, AddEditTempContactID__c,FirstName, LastName, Role__c, Title, Phone FROM Contact WHERE Id = :revertContactIdsMap.keyset()]) {

            Temporary_Contact__c tCont = new Temporary_Contact__c ();

            if(String.isNotBlank(revertContactIdsMap.get(objContact.Id))) {
                tCont.Id = revertContactIdsMap.get(objContact.Id);

                if(String.isBlank(objContact.AddEditTempContactID__c)) {
                    objContact.AddEditTempContactID__c = revertContactIdsMap.get(objContact.Id);
                    contactForUpdate.add(objContact);
                }
            }

            tCont.First_Name__c = objContact.FirstName;
            tCont.Last_Name__c = objContact.LastName;
            tCont.Role__c = objContact.Role__c;
            tCont.Title__c = objContact.Title;
            tCont.Phone__c = objContact.Phone;
            //tCont.Reason_for_Deactivation_Deletion__c = '';
            tempContactForUpdate.add(tCont);
        }

        if(!tempContactForUpdate.isEmpty()) {
            Database.SaveResult[] srList = database.Update(tempContactForUpdate, false);
        }

        if(!contactForUpdate.isEmpty()) {
            Database.SaveResult[] srListContacts = database.Update(contactForUpdate, false);
        }
    }

    /**
     * @name        updateContacts
     * @description Updates existing contacts with requested chantges on Temp Contact.
     * @param       List<Temporary_Contact__c> contactToUpdateList
     */
    public static void updateContacts (List<Temporary_Contact__c> contactToUpdateList){

        List<Contact> contactsForUpdate = new List<Contact>();
        List<Contact> processedContacts = new List<Contact>();
        Map<Id,Contact> processedContactsMap = new Map<Id,Contact>();
        List<Contact> contactsForProcessing = new List<Contact>();
        Map<Id, Boolean> activateUsers = new Map<Id, Boolean>();
        Set<Id> activateUserSet = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        List<Temporary_Contact__c> finalUpdateTempContacts = new List<Temporary_Contact__c>();
        
        Map<Id, Id> mapContAccId = new Map<Id, Id> ();

        Map<Id,String> accountBillingCountryMap = new Map<Id, String>();
        Set<Id> accountIds = new Set<Id>();
        
        List<Id> lstAccIds = new List<Id>();
        for(Temporary_Contact__c tCont : contactToUpdateList) {     
            accountIds.add(tCont.AccountId__c);         
            mapContAccId.put(tCont.ContactId__c, tCont.AccountId__c);
        }   

        if(!accountIds.isEmpty()) {
            for(Account accObj : [SELECT Id, BillingCountry FROM Account WHERE Id IN :accountIds]) {
                accountBillingCountryMap.put(accObj.Id, accObj.BillingCountry);
            }
        }

        for(Temporary_Contact__c tCont : contactToUpdateList) {
            Contact Objcontact = new Contact();
            objContact.FirstName = tCont.First_Name__c;
            objContact.LastName = tCont.Last_Name__c;
            objContact.Role__c = tCont.Role__c;
            objContact.Title = tCont.Title__c;
            objContact.Phone = tCont.Phone__c;
            objContact.AddEditTempContactID__c = tCont.ID;
            objContact.Id = Id.valueOf(tCont.ContactId__c);
            //objContact.AccountId = tCont.Account_Id__c; // Rajat commented on 8-May-2020
            objContact.MailingCountry = accountBillingCountryMap.get(tCont.Account_Id__c);


            if(String.isNotBlank(tCont.Action_Requested__c) && tCont.Action_Requested__c.contains('Role')) {
                if(String.isNotBlank(tCont.Partner_User__c)) {
                    activateUserSet.add(tCont.Partner_User__c);
                }else{
                    contactIds.add(Id.valueOf(tCont.ContactId__c));
                }
                
                contactsForProcessing.add(objContact);

                if(tCont.Deactivated__c) {
                    Temporary_Contact__c tempContact = new Temporary_Contact__c();
                    tempContact.Id = tCont.Id;
                    tempContact.Deactivated__c = false;
                    finalUpdateTempContacts.add(tempContact);
                }

            }else{
                contactsForUpdate.add(objContact);
            }

        }

        if(!contactsForProcessing.isEmpty()) {
            processedContacts = getPermissionGeniusValuesForContacts(contactsForProcessing, mapContAccId);

            if(!processedContacts.isEmpty()) {
                for(Contact pCont : processedContacts) {
                    processedContactsMap.put(pCont.Id, pCont);
                }
            }

        }

        if(!contactIds.isEmpty()) {
            for(Contact cont : [SELECT Id, Community_User__c, Community_User_Active__c FROM Contact WHERE Id IN :contactIds]) {
                if(cont.Community_User__c != null && cont.Community_User_Active__c != null && !cont.Community_User_Active__c) {
                    activateUserSet.add(cont.Community_User__c);
                }else{
                    if(!processedContactsMap.isEmpty()) {
                        processedContactsMap.get(cont.Id).Create_Full_Portal_User__c = true;
                    }
                }
            }
        }

        if(!activateUserSet.isEmpty()) {
            for(User usr : [SELECT Id, IsActive FROM User WHERE Id IN :activateUserSet]) {
                if(!usr.IsActive) {
                    activateUsers.put(usr.Id, true);
                }
            }
        }

        if(!finalUpdateTempContacts.isEmpty()) {
            Database.SaveResult[] srList = Database.Update(finalUpdateTempContacts, false);
        }

        if(!processedContactsMap.isEmpty() && !processedContactsMap.values().isEmpty()) {
            Database.SaveResult[] srList = Database.Update(processedContactsMap.values(), false);
        }

        if(!contactsForUpdate.isEmpty()) {
            Database.SaveResult[] srList = Database.Update(contactsForUpdate, false);
        }

        if(!activateUsers.isEmpty()) {
            System.enqueueJob(new UpdateUsers(activateUsers));
        }
    }

    /**
     *  @description : This class is to enqueue the user activation or deactivation.
     */
    public without sharing class UpdateUsers implements Queueable {

    List<User> userList = new List<User>();

    public UpdateUsers (Map<Id, Boolean> updateUserMap){
        for(Id uid : updateUserMap.keyset()) {
            User userRec = new User();
            userRec.Id = uid;
            userRec.IsActive = updateUserMap.get(uid);

            userList.add(userRec);
        }
    }

    public void execute(QueueableContext context) {

        if(!userList.isEmpty()) {
            Database.SaveResult[] srListForUser = Database.Update(userList, false);
            System.debug('>>> srListForUser '+srListForUser);
        }
    }
    }

    /**
     * @name            fetchPartnerAttributes
     * @description     Get the Partner Attribute records for respective Account.
     * @param           Set<Id> accntIds
     * @return          Map<Id, List<Partner_Attribute__c> >
     */
    public static Map<Id, List<Partner_Attribute__c> > fetchPartnerAttributes(Set<Id> accntIds){

        Map<Id, List<Partner_Attribute__c> > accPartnerAttrbMap = new Map<Id, List<Partner_Attribute__c> >();

        for(Partner_Attribute__c partAtrb : [SELECT Id, Account_Name__c,Partner_Competency__c,Partner_Program_Name__c,Partner_Sub_Program__c,Program_Level__c FROM Partner_Attribute__c WHERE Account_Name__c = :accntIds AND Date_Competency_Terminated__c = null AND CALENDAR_YEAR(Date_Competency_Signed__c) != 2099]) {

            if(accPartnerAttrbMap.containsKey(partAtrb.Account_Name__c)) {
                accPartnerAttrbMap.get(partAtrb.Account_Name__c).add(partAtrb);
            }else{
                accPartnerAttrbMap.put(partAtrb.Account_Name__c, new List<Partner_Attribute__c> { partAtrb });
            }
        }
        return accPartnerAttrbMap;
    }

    /**
     * @name        getPermissionGeniusValuesForContacts
     * @description This method returns a list of contacts with the values for GPU Genius Groups and Permissions & Group Assignments populated for the provided .
     * @param       List<Contact>
     * @return      List<Contact>
     */
    //public static List<Contact> getPermissionGeniusValuesForContacts(List<Contact> contactList, boolean getPermissions){
    public static List<Contact> getPermissionGeniusValuesForContacts(List<Contact> contactList, Map<Id, Id> mapContAccId){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        List<Contact> processedContacts = new List<Contact>();
        Map<Id,Contact> contactsWithGPDataMap = new Map<Id, Contact>();
        Map<Id, List<Partner_Attribute__c> > accIdPartnerAttrbMap = new Map<Id, List<Partner_Attribute__c> >();
        Map<String, NPN_Onboarding_GPU_Genius_Map__c> mapOnboardingCompetencyGPUGenius = NPN_Onboarding_GPU_Genius_Map__c.getAll();
        Map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup = NPN_Competency_Permissions_Group_Map__c.getAll();
        Map<String, String> gpuGeniusWithRole = new Map<String, String>();
        Map<String, String> gpuGeniusWithoutRole = new Map<String, String>();
        Map<Id,List<String> > contactNewRolesMap = new Map<Id,List<String> >();
        Map<Id,String> removedRolesMap = new Map<Id,String>();
               
        for(NPN_Onboarding_GPU_Genius_Map__c objGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {
            if(String.isNotBlank(objGPUGenius.Competency__c) && String.isNotBlank(objGPUGenius.Role__c)) {
                gpuGeniusWithRole.put(objGPUGenius.Competency__c+objGPUGenius.Role__c,objGPUGenius.GPU_Genius_Group__c);            
            }
            /*else if( String.isNotBlank(objGPUGenius.Competency__c) && String.isBlank(objGPUGenius.Role__c)) {
                gpuGeniusWithoutRole.put(objGPUGenius.Competency__c, objGPUGenius.GPU_Genius_Group__c);
            }*/
        }
        system.debug('--> gpuGeniusWithRole.size(): '+ gpuGeniusWithRole.size());
        system.debug('--> gpuGeniusWithRole: '+ gpuGeniusWithRole);
        //List<NPN_Onboarding_Competency_GPU_Genius_Map__mdt> ggMDList = [SELECT Id, MasterLabel, Competency__c, Role__c, DeveloperName,GPU_Genius_Group__c,Program_Type__c FROM NPN_Onboarding_Competency_GPU_Genius_Map__mdt];

        for(Contact contactVar : contactList) {
            accountIds.add(contactVar.AccountId);
            contactIds.add(contactVar.Id);
            if(String.isNotBlank(contactVar.Role__c)) {
                contactNewRolesMap.put(contactVar.Id, contactVar.Role__c.split(';'));
            }
        }

        if(!contactIds.isEmpty()) {
            for(Contact cont : [SELECT Id, Role__c, GPU_Genius_Groups__c, Portal_Groups__c, Portal_User_Content_Type__c, Community_User_Active__c FROM Contact WHERE Id IN :contactIds]) {
                contactsWithGPDataMap.put(cont.Id, cont); // commented for latest value population.
                if(String.isNotBlank(cont.Role__c)) {
                    if(!contactNewRolesMap.isEmpty() && contactNewRolesMap.containsKey(cont.Id)) {
                        for(String newRole : contactNewRolesMap.get(cont.Id)) {
                            cont.Role__c = cont.Role__c.replace(newRole,'');
                        }
                        removedRolesMap.put(cont.Id, cont.Role__c);
                    } else {
                        removedRolesMap.put(cont.Id, cont.Role__c);
                    }
                }
            }
        }
        set<Id> accIdSet = new Set<Id>();
        if(mapContAccId != null && !mapContAccId.isEmpty()) {               
            accIdSet.addAll(mapContAccId.values());     
        }else{
            accIdSet.addAll(accountIds);
        }
        
        if(!accIdSet.isEmpty()){
            accIdPartnerAttrbMap = fetchPartnerAttributes(accIdSet);               
        }

        for(Contact objContact : contactList) {
            Set<String> portalPermissionsSet = new Set<String>();
            Set<String> gpuGenisValuesSet = new Set<String>();
            if(!contactsWithGPDataMap.isEmpty()) {
                if(String.isNotBlank(contactsWithGPDataMap.get(objContact.Id).Portal_Groups__c)) {
                    for(String permVal : contactsWithGPDataMap.get(objContact.Id).Portal_Groups__c.split(';')) {
                        portalPermissionsSet.add(permVal);
                    }                    
                }
                if(String.isNotBlank(contactsWithGPDataMap.get(objContact.Id).GPU_Genius_Groups__c)) {
                    for(String ggVal : contactsWithGPDataMap.get(objContact.Id).GPU_Genius_Groups__c.split(';')) {
                        gpuGenisValuesSet.add(ggVal.trim());
                    }                    
                }
            }
            if(!accIdPartnerAttrbMap.isEmpty()) {
                Id accountIdVar;
                if(mapContAccId != null && !mapContAccId.isEmpty() && String.isNotBlank(mapContAccId.get(objContact.Id))){              
                    accountIdVar = mapContAccId.get(objContact.Id);
                }else{
                    accountIdVar = objContact.AccountId;
                }
                for(Partner_Attribute__c ptrAttrb : accIdPartnerAttrbMap.get(accountIdVar)) {                   
                    /*if( String.isNotBlank(ptrAttrb.Partner_Competency__c)) {
                        if(!gpuGeniusWithoutRole.isEmpty()) {
                            if(String.isNotBlank(gpuGeniusWithoutRole.get(ptrAttrb.Partner_Competency__c))) { //objContact.GPU_Genius_Groups__c != null &&
                                gpuGenisValuesSet.add(gpuGeniusWithoutRole.get(ptrAttrb.Partner_Competency__c).trim());
                                if(String.isBlank(objContact.Portal_User_Content_Type__c)) { 
                                    objContact.Portal_User_Content_Type__c = ptrAttrb.Partner_Competency__c;
                                }
                            }
                        }
                        system.debug('--> gpuGenisValuesSet: '+ gpuGenisValuesSet);
                        if(!gpuGeniusWithRole.isEmpty()) {
                            if(String.isNotBlank(objContact.Role__c)){
                                for(String newRole : objContact.Role__c.split(';')) {
                                    if(gpuGeniusWithRole.containsKey(ptrAttrb.Partner_Competency__c+newRole)) {
                                        gpuGenisValuesSet.add(gpuGeniusWithRole.get(ptrAttrb.Partner_Competency__c+newRole).trim());
                                    }
                                }
                            }
                            if(!removedRolesMap.isEmpty() && removedRolesMap.containsKey(objContact.Id)) {
                                for(String oldRole :removedRolesMap.get(objContact.Id).split(';')) {
                                    if(gpuGeniusWithRole.containsKey(ptrAttrb.Partner_Competency__c+oldRole)) {
                                        gpuGenisValuesSet.remove(gpuGeniusWithRole.get(ptrAttrb.Partner_Competency__c+oldRole).trim());
                                    }
                                }
                            }
                        }
                    }*/
                    if( String.isNotBlank(ptrAttrb.Partner_Competency__c)) {
                        if(String.isBlank(objContact.Portal_User_Content_Type__c)) { 
                            objContact.Portal_User_Content_Type__c = ptrAttrb.Partner_Competency__c;
                        }
                    }
                    
                    for(NPN_Onboarding_GPU_Genius_Map__c objOnboardingCompetencyGPUGenius : mapOnboardingCompetencyGPUGenius.values()) {                        
                        if(String.isNotBlank(objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c)) {
                            if(
                                (String.isBlank(objOnboardingCompetencyGPUGenius.Role__c) || 
                                 (String.isNotBlank(objContact.Role__c) && objContact.Role__c.contains(objOnboardingCompetencyGPUGenius.role__c))) &&

                                (String.isBlank(objOnboardingCompetencyGPUGenius.Competency__c) ||
                                 (ptrAttrb.Partner_Competency__c.equalsIgnoreCase(objOnboardingCompetencyGPUGenius.Competency__c))) && 

                                (String.isBlank(objOnboardingCompetencyGPUGenius.Program_Type__c) ||
                                 (ptrAttrb.Partner_Program_Name__c.equalsIgnoreCase(objOnboardingCompetencyGPUGenius.Program_Type__c))) &&

                                (String.isBlank(objOnboardingCompetencyGPUGenius.subprogram_type__c) ||
                                 (ptrAttrb.Partner_Sub_Program__c.equalsIgnoreCase(objOnboardingCompetencyGPUGenius.subprogram_type__c)))

                            ) {
                                for(String eachGPUGenius : objOnboardingCompetencyGPUGenius.GPU_Genius_Group__c.split(';')) {
                                    gpuGenisValuesSet.add(eachGPUGenius.trim());
                                }
                            }
                            
                            if(!removedRolesMap.isEmpty() && removedRolesMap.containsKey(objContact.Id)) {
                                for(String oldRole :removedRolesMap.get(objContact.Id).split(';')) {
                                    if(gpuGeniusWithRole.containsKey(ptrAttrb.Partner_Competency__c+oldRole)) {
                                        gpuGenisValuesSet.remove(gpuGeniusWithRole.get(ptrAttrb.Partner_Competency__c+oldRole).trim());
                                    }
                                }
                            }                           
                        }                       
                    }

                    /*if(!ggMDList.isEmpty()) {
                        for(NPN_Onboarding_Competency_GPU_Genius_Map__mdt npnObj : ggMDList) {
                            if(String.isNotBlank(npnObj.GPU_Genius_Group__c)) {
                                if(
                                    (String.isBlank(npnObj.Role__c) || (String.isNotBlank(objContact.Role__c) && String.isNotBlank(npnObj.Role__c) && objContact.Role__c.contains(npnObj.role__c))) &&
                                    
                                    (String.isBlank(npnObj.Competency__c) ||
                                     String.isNotBlank(ptrAttrb.Partner_Competency__c) && ptrAttrb.Partner_Competency__c.contains(npnObj.Competency__c)) &&
                                    
                                    (String.isBlank(npnObj.Program_Type__c) ||
                                     (String.isNotBlank(npnObj.Program_Type__c) && String.isNotBlank(ptrAttrb.Partner_Program_Name__c) && ptrAttrb.Partner_Program_Name__c.contains(npnObj.Program_Type__c)))) {

                                    for(String ggVal : npnObj.GPU_Genius_Group__c.split(';')) {
                                        gpuGenisValuesSet.add(ggVal.trim());
                                    }
                                }
                            }
                        }
                    }*/
                    
                    if(mapOnboardingCompetencyPermissionsAndGroup != null && !mapOnboardingCompetencyPermissionsAndGroup.isEmpty()) {
                        for(NPN_Competency_Permissions_Group_Map__c objOnboardingCompetencyPermissionGroup : mapOnboardingCompetencyPermissionsAndGroup.values()) {

                            if(String.isNotBlank(objOnboardingCompetencyPermissionGroup.permissions_and_group__c)) {
                                if(
                                    (String.isBlank(objOnboardingCompetencyPermissionGroup.Role__c) || (String.isNotBlank(objContact.role__c) && String.isNotBlank(objOnboardingCompetencyPermissionGroup.Role__c) && objContact.role__c.contains(objOnboardingCompetencyPermissionGroup.role__c))) &&

                                    (String.isBlank(objOnboardingCompetencyPermissionGroup.Competency__c) ||
                                     String.isNotBlank(ptrAttrb.Partner_Competency__c) && ptrAttrb.Partner_Competency__c.contains(objOnboardingCompetencyPermissionGroup.Competency__c)) &&

                                    (String.isBlank(objOnboardingCompetencyPermissionGroup.program_type__c) ||
                                     (String.isNotBlank(objOnboardingCompetencyPermissionGroup.program_type__c) && String.isNotBlank(ptrAttrb.Partner_Program_Name__c) && ptrAttrb.Partner_Program_Name__c.contains(objOnboardingCompetencyPermissionGroup.program_type__c))) &&

                                    (String.isBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) || (String.isNotBlank(objOnboardingCompetencyPermissionGroup.sub_program_type__c) && String.isNotBlank(ptrAttrb.Partner_Sub_Program__c) && ptrAttrb.Partner_Sub_Program__c.contains(objOnboardingCompetencyPermissionGroup.Sub_Program_Type__c))) &&

                                    (String.isBlank(objOnboardingCompetencyPermissionGroup.program_level__c) || (String.isNotBlank(objOnboardingCompetencyPermissionGroup.program_level__c) && String.isNotBlank(ptrAttrb.Program_Level__c) && ptrAttrb.Program_Level__c.contains(objOnboardingCompetencyPermissionGroup.program_level__c)))
                                    ) {
                                    for(String eachPermissionAndGroup : objOnboardingCompetencyPermissionGroup.permissions_and_group__c.split(';')) {
                                        portalPermissionsSet.add(eachPermissionAndGroup.trim());
                                    }
                                }
                            }
                        }
                    }
                }
            }
            objContact.Portal_Groups__c = '';
            objContact.GPU_Genius_Groups__c = '';
            if(!portalPermissionsSet.isEmpty() && portalPermissionsSet.size() > 0 ) {
                for(String permVal : portalPermissionsSet) {
                    objContact.Portal_Groups__c += permVal + ';';
                }
            }
            if(!gpuGenisValuesSet.isEmpty() && gpuGenisValuesSet.size() > 0 ) {
                for(String ggVal : gpuGenisValuesSet) {
                    objContact.GPU_Genius_Groups__c += ggVal + ';';
                }
            }
            processedContacts.add(objContact);
        }
        return processedContacts;
    }

    /**
     * @name    createNewContact
     * @description Creates new contacts for new temp contact records
     * @param  tempToContactList tempToContactList description
     */
    public static void createNewContact (List<Temporary_Contact__c> tempToContactList){

        List<Contact> newContacts = new List<Contact>();
        List<Contact> processedContacts = new List<Contact>();
        List<Contact> contactsForProcessing = new List<Contact>();
        Set<Id> accIdSet = new Set<Id>();
        List<Id> lstAccIds = new List<Id>();
        Map<Id,Account> accountMap = new Map<Id, Account>();
    //  Map<Id, List<Id>> mapAccContIds = new Map<Id, List<Id>>();

        for(Temporary_Contact__c temp: tempToContactList) {
            accIdSet.add(Id.valueOf(temp.Account_Id__c));
            
            
    //      mapAccContIds.put(temp.Account_Id__c,null);
            
            
        }

        if(!accIdSet.isEmpty()) {
            accountMap = new Map<Id, Account>([SELECT Id, BillingCountry, OwnerId FROM Account WHERE Id IN: accIdSet]);
        }

        for(Temporary_Contact__c temp: tempToContactList) {
            // Create new contact record.
            Contact Objcontact = new contact ();
            objContact.FirstName = temp.First_Name__c;
            objContact.LastName = temp.Last_Name__c;
            objContact.Email = temp.Email__c;
            objContact.Phone = temp.Phone__c;
            objContact.AccountId = temp.Account_Id__c;
            objContact.Title = temp.Title__c;
            objContact.AddEditTempContactID__c = temp.ID;

            objContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

            if(!accountMap.isEmpty() && accountMap.get(objContact.AccountId) != null) {
                objContact.OwnerId = accountMap.get(objContact.AccountId).OwnerId;
                objContact.MailingCountry = accountMap.get(objContact.AccountId).BillingCountry;
            }

            System.debug('>> temp.Role__c '+ temp.Role__c);
            System.debug('>> objContact.Role__c '+ objContact.Role__c);
            if(String.isNotBlank(temp.Role__c)) {
                objContact.Role__c = temp.Role__c;
                objContact.Create_Full_Portal_User__c = true;       
                            
                contactsForProcessing.add(objContact);
            }else{
                newContacts.add(objContact);
            }
        }
    //  System.debug('>> mapAccContIds '+ mapAccContIds);
        if(!contactsForProcessing.isEmpty()) {
            processedContacts = getPermissionGeniusValuesForContacts(contactsForProcessing, null);
        }

        System.debug('>> processedContacts '+processedContacts);
        System.debug('>> newContacts '+newContacts);
        
        
        if(!processedContacts.isEmpty()) {      
            newContacts.addAll(processedContacts);
            /*Database.SaveResult[] srList = database.Insert(processedContacts, false);
            if(!srList.isEmpty()) {
                updateTempContacts(processedContacts);
            }*/
        }

        if(!newContacts.isEmpty()) {
            Database.SaveResult[] srList = database.Insert(newContacts, false);
            if(!srList.isEmpty()) {
                updateTempContacts(newContacts);
            }
        }
    }

    /**
     * @name            updateTempContacts
     * @description     Stamps the contact id on the temp contact record .
     * @param           contactsForInsert
     */
    public static void updateTempContacts (List<Contact> contactsForInsert){

        List<Temporary_Contact__c> tempContatctsForUpdate = new List<Temporary_Contact__c>();
        for(Contact newContact : contactsForInsert) {
            Temporary_Contact__c newTempCont = new Temporary_Contact__c();
            newTempCont.Id = Id.valueOf(newContact.AddEditTempContactID__c);
            newTempCont.ContactId__c = newContact.Id;
            tempContatctsForUpdate.add(newTempCont);
        }

        if(!tempContatctsForUpdate.isEmpty()) {
            Database.SaveResult[] saveResList = Database.update(tempContatctsForUpdate, false);
        }
    }
}