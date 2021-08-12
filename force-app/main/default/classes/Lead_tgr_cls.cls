/*
    Contains all the logic of Lead trigger "Lead_tgr"
    
    *****************************Functionality***********************************************************
    - After Insert/After Update of Lead
    - This function acts on the lead that gets originated from "EMEAI Training Web Form" and "NPN Community Web Form"
    - For NPN Leads whose account is not existing, create an Account with Record type set to "NPN Community Account"
    - Leads which are already converted (There are matching contacts based on the email and account):
        - Reset the password of the contact/customer portal user and notify contact/customer portal user
        - Update the contact to Partner Contact record type and GPU Genious field based on the lead origin
        - Delete Leads if its not converted because the contact already exists
    - Leads which needs to be converted:
        - Update is Contact with record type to Partner Contact and GPU Genious field based on the lead origin
        - Create portal user with username based on the lead origin and notify contact/customer portal user with pwd
        - Add Permission Sets (PP_NV_CONTACTS_BOX, PP_QPP_HOME_TAB) to portal user 
        - Add portal user to public groups based on the lead origin (for EMEAI Training - EMEAI Training Users, for NPN Community - Community Content))
            
    Changes:
    2015.05.26 - Set Contact.Portal_Groups__c to NVEP or Community based on the Lead Origin Web Form
    
    2016.06.20 - Remove future method from LeadRegionSubRegionTerritory and move it to Before Insert/Before Update methods

    2016.07.27 - After Insert : Leadspace Integration - Add Leads to Campaigns based on the LeadSource and Lead_Origin__c
    
    2017.03.03 - Lead Assignment Process Rules
    
    2017.07.24 - Replaced 'Account_Id__c' lookup field with the 'AccountId__c' with the text field in the Lead Assignment process.

    2017.07.10 - @Manideep - Before Insert/Update: "Country/State picklist Enablement" 
                 * Incorporated the logic in the method 'setLeadRegionSubRegionTerritory()' into 'ctryStatePicklistforMKTO()' and 'ctryStateMatchforMKTO()'.
                 * Going forward Marketo will sync MKTO_Country/MKTO_State custom fields through the 'Marketo Sync' User and then the logic in the method 'ctryStatePicklistforMKTO()'
                   will carry over the appropriate values into Country/State picklist fields.
                    MKTO_Country__c --> Country 
                    MKTO_State__c   --> State
                 * Country/State field values those are changed by non-Marketo users directly are carry over to the MKTO fields by the logic in method 'ctryStateMatchforMKTO()'.
                    Country     -->  MKTO_Country__c
                    State       -->  MKTO_State__c 
                    CountryCode -->  MKTO_Country__c
                    State       -->  MKTO_State__c
                    
    2017.08.10 - @Manideep - Before Insert/Update: "Pre-MQL Alerts for NALA" 
                 * Send email notification to LSID matched 'NALA' Account Owner for the Leads.
                 
    2017.08.28 - @Manideep - 'Region based enhancement for Lead Assignment Process Rules'
                 * Till now LSID based rules are set to run for all Accounts where where Lead's LSID is matched with all the LSID matched Accounts, but
                   with this enhancement an additional filter 'Region' is added, so that further filter the Accounts that matches with the Lead's LSID
                   also by the Region field match. Did this change in the 'leadAssignmentMethod()'.
                   Example: If a Lead has Region 'NALA' then run the LSID based rules only for the Accounts that has region 'NALA'. If the LSID of Account is
                            blank even though it matches the Lead LSID then don't filter that Account for LSID match based rules.
    
    2017.12.21 : @Manideep - Automotive Lead Conversion Validation of Open Tasks
    2017.02.27 : @Manideep - Automotive Lead Conversion Required fields Validation
    2018.04.30 : @Manideep - Removed Leads 'State' field from the "Automotive Lead Conversion Required fields Validaiton" logic.
    2018.07.05 : @Manideep - Add Country, State AND Enterprise Segment logic for the individual Country (United States) based rules.
    2018.09.12 : @Manideep - Add logic to new Lead Status value 'Request Contact' same capability as existing value 'Marketing Qualified'.
    2018.11.27 : @Manideep - Added new Lead Routing Rule logic basing on 'Industry'.
    2019.07.01 : @Manideep - Removed Leads 'Operating System' field from the "Automotive Lead Conversion Required fields Validaiton" logic. 
    2019.07.22 : @Manideep - Added Skip Validation logic based on Custom Permission 'SKIP Automotive Lead Conversion Validation'.   
    
    2018.04.26 - pjena - SDS-1116 - Old Account RecordType Cleanup (NV Customer Account, NV Marketing Partner Portal, MDF Account, EMEAI Training Account)
    
    2019.09.11 : @Manideep - Decommission of "Automotive Lead Conversion Validation of Open Tasks" as the auto creation of Tasks through Process Builder is retired.
    
    2019.09.23 : @Manideep - SDS-1692: Update routing rules to invoke routing rules for leads that don't come over as MKTO owner as well. Lead should be created by 'Marketo Sync' user
    
    2020.02.20 : @Manideep - SDS-1930: Adding new status value '6QL' to Lead Routing Rules same as 'Marketing Qualified/Request Contact'.
    
    2020.02.28 : @Manideep - SDS-2009: Deleted the below existing methods,
                             * autoConvertLead()
                             * addUsersToPublicGroup()
                             * addUsersToPortalPermissionSets()
                             
    2020.03.31 : @Manideep - SDS-2104: Remove APAC LSID and NPN Nurture Routing Rules.
    
    2020.04.06 : @Manideep - SDS-2177: Removed Leads 'Nvidia Hardware Used Vehicle Inference' field from the "Automotive Lead Conversion Required fields Validaiton" logic.
    
    2020.05.28 : @Manideep - SDS-2049: Removing three fields ((MKTO_Assigned__c,No_Sales_Email__c,No_Sales_Call__c) from Routing rules that are obsolete/affecting routing rules. 
    
    2020.06.02 : @Manideep - SDS-2049: Add new Lead Status "Analytics Qualified" to routing rules same as exisitng values 'Marketing Qualified', 'Request Contact' and '6QL'.
    
    2020.07.14 : @Manideep - SDS-2049: Reorder 'VGPU' Rules to the top.
    
    2020.07.14 : @Manideep - SDS-2276: Automotive Lead Routing basing on Product Type 'Automotive' and Company Type field.
    
    2020.07.14 : @Manideep - SDS-2277: Embedded Lead Routing.
    
    2020.07.14 : @Manideep - SDS-2278: Update Routing Rules from "Enterprise Segment" to "Product Type" Field. 
                             (But left the existing Enterprise Segment based rules as is in the code but deactivated in the custom setting, 
                              so if needed those can be turned back ON easily by simply reactivating or by adding the rows in the custom setting) 
    2020.07.17 : Rajat     - SDS-2527: Added below methods for Community Level Automation on 9-July-2020
                                * autoConvertLead()
                                * addUsersToPublicGroup()
                                * addUsersToPortalPermissionSets() 
                                
    2021.01.03 : @Manideep - SDS-2795: Delete the existing method 'Send_MKTO_PreMQL_Alerts()'
    2021.01.03 : @Manideep - SDS-2795: Delete the existing method 'leadAssignmentMethod()' 
                                  
*/

public class Lead_tgr_cls {

    //Avoid future method calling future method in case of Lead.Region, Sub-Region, Territory by this flag
    public static boolean b_FUTURETRNSACTION = false;      
    /* Rajat added below for Community Level Automation on 9-July-2020 START */
    public static void autoConvertLead(list<Lead> lstLeadsInTgrNew, map<Id, Lead> mapLeadsInTgrNew){
        
        //Get all NPN and EMEAI Leads only which are not converted yet
        //Get all associated AccountID and Company Names for NPN leads
        //****************************************************************
        list<Lead> lstAllNPNLeads = new list<Lead> ();
        
        set<string> setAllNPNCompanyNames = new set<string>();
        
        set<string> setAllEMEAIAndNPNLeadEmails = new set<string>();
        set<Id> setAllEMEAIAndNPNAccountIds = new set<Id>(); 
        
        for (Lead leadInTgrNew: lstLeadsInTgrNew) {
            if ( !leadInTgrNew.isConverted && leadInTgrNew.lead_orgin__c == COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM & leadInTgrNew.Company != null 
                    && (leadInTgrNew.email != null && COMM_Utility.validateEmail(leadInTgrNew.email) )) {
                lstAllNPNLeads.add(leadInTgrNew);
                setAllNPNCompanyNames.add(leadInTgrNew.Company);
                setAllEMEAIAndNPNLeadEmails.add(leadInTgrNew.Email);
            }                
        }
        //****************************************************************
        
        //If there are no leads originated from NPN Community form, do not proceed further
        if (lstAllNPNLeads.isEmpty()){
            system.debug('****There is no NPN Lead');
        } else{
            system.debug('****This line will only come if there are NPN Leads');
            
            //Partner Contact Record Type
            map<String, Id> mapContactRT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
            set<string> setLeadEmailsOfExistingUsers = new set<string>();
                
            //Find Lead - Account map for NPN 
            //And Create the NPN accounts which are not already present
            //****************************************************************
            map<Lead, Account> mapAllNPNLeadAndItsAccount = new map<Lead, Account>();
            //Get map of Account Record Type Name and Id for NPN Community Account
            map<String, Id> mapNPNAccountRT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY);
            list<Account> lstAllNPNAccounts = COMM_Utility.getAccsByNameAndRT(setAllNPNCompanyNames, mapNPNAccountRT.get(COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY));
            
            list<Lead> lstLeadsForWhichAccToBeCreated = new list<lead>();
            
            for (Lead oNPNLead : lstAllNPNLeads){
                boolean bAccFound = false;
                for (Account oNPNAcc : lstAllNPNAccounts){
                    if (oNPNLead.Company == oNPNAcc.Name){
                        mapAllNPNLeadAndItsAccount.put(oNPNLead, oNPNAcc);
                        setAllEMEAIAndNPNAccountIds.add(oNPNAcc.Id); //add the Account Id to the set of all NPN Account Ids
                        bAccFound = true;
                        break; //if the lead's account matches with the Account's Id then break and do not search futher in the list of accounts
                    }
                }
                if (bAccFound == false){
                    lstLeadsForWhichAccToBeCreated.add(oNPNLead);
                }
            }
            
            //Create the Accounts which are not found and set it to NPN Community type
            //Use Set: this is to make sure we do not create duplicate accounts if there are multiple NPN Leads in the same trigger
            set<Account> setNewNPNAccountToBeCreated = new set<Account>(); 
            for (Lead oNPNLead : lstLeadsForWhichAccToBeCreated){
                Account oNPNAcc = new Account(name = oNPNLead.Company, RecordTypeId = mapNPNAccountRT.get(COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY));
                setNewNPNAccountToBeCreated.add(oNPNAcc);
            }
            
            list<Account> lstNewNPNAccountToBeCreated = new list<Account>();
            lstNewNPNAccountToBeCreated.addAll(setNewNPNAccountToBeCreated);
            
            
            if (!lstNewNPNAccountToBeCreated.isEmpty()){
                insert lstNewNPNAccountToBeCreated;
            }
            
            //add it to mapAllNPNLeadAndItsAccount and setAllEMEAIAndNPNAccountIds
            for (Lead oLead : lstLeadsForWhichAccToBeCreated){
                for (Account oAcc : lstNewNPNAccountToBeCreated){
                    if (oLead.Company == oAcc.Name){
                        mapAllNPNLeadAndItsAccount.put(oLead, oAcc);
                        setAllEMEAIAndNPNAccountIds.add(oAcc.Id); //add the Account Id to the set of all EMEAI and NPN Account Ids
                        break;
                    }
                }
            }
            //End of Find Lead - Account map for NPN 
            //****************************************************************
            
            //Find Lead and Its Contacts to seggreate which are the leads that needs to be converted
            //****************************************************************
            map<String, Contact> mapAllContactsByEmailAccIdKey = COMM_Utility.getAllContactsByEmailAccId(setAllEMEAIAndNPNLeadEmails, setAllEMEAIAndNPNAccountIds);
            list<Lead> lstNPNLeadsToBeConverted = new list<Lead>();
            map<Lead, Account> mapAllLeadsToBeConvertedWithAccount = new map<Lead, Account>();
            
             //Leads for which there are already Contact and does not need to be converted. But we might need to reset their password
            //map<Lead, Account> mapAllLeadsNotToBeConvertedWithAccount = new map<Lead, Account>();//Password reset needed for these contact users
            map<Lead, Id> mapNotToBeConvertedLeadToContactId = new map<Lead, Id>(); //map of not to be converted Lead to Contact Id
            list<lead> lstNPNLeadsNotToBeConverted = new list<Lead>();
            map<Id, Contact> mapNPNnotToBeConvertedLeadIdToContactId = new map<Id, Contact>();
            
            for (Lead oNPNLead : mapAllNPNLeadAndItsAccount.keySet()){
                if ( mapAllContactsByEmailAccIdKey.get(oNPNLead.email + mapAllNPNLeadAndItsAccount.get(oNPNLead).Id) == null){
                    lstNPNLeadsToBeConverted.add(oNPNLead);
                    mapAllLeadsToBeConvertedWithAccount.put(oNPNLead, mapAllNPNLeadAndItsAccount.get(oNPNLead));
                } else{//existing contact for the lead with same email and account
                    //mapAllLeadsNotToBeConvertedWithAccount.put(oNPNLead, mapAllNPNLeadAndItsAccount.get(oNPNLead));
                    mapNotToBeConvertedLeadToContactId.put(oNPNLead, mapAllContactsByEmailAccIdKey.get(oNPNLead.email + mapAllNPNLeadAndItsAccount.get(oNPNLead).Id).Id);
                    lstNPNLeadsNotToBeConverted.add(oNPNLead);
                    mapNPNnotToBeConvertedLeadIdToContactId.put(oNPNLead.Id, mapAllContactsByEmailAccIdKey.get(oNPNLead.email + mapAllNPNLeadAndItsAccount.get(oNPNLead).Id));
                }
            }
            //****************************************************************
            
            //PASSWORD Reset for the existing users for the contact having same email and account as that of Lead
            //****************************************************************************************************
            if (!mapNotToBeConvertedLeadToContactId.isEmpty()){
                Map<Contact, User> mapExistingPortalUsers = COMM_Utility.getPortalUsers(mapNotToBeConvertedLeadToContactId.values());
                list<Contact> lstAllNPNPortalContact = new list<Contact>();
                list<User> lstAllNPNPortalUsers = new list<User>();
            
                //Set the Contacts Record type and GPU_Genius field
                //-------------------------------------------------
                for (Contact oPortalContact : mapExistingPortalUsers.keyset()){
                    
                    //Search in NPN Leads
                    for (Lead oNPNLead : lstNPNLeadsNotToBeConverted){
                        
                        //If the Contact's email and account matches with that of portal user
                        if ( oPortalContact.Email == oNPNLead.Email && oPortalContact.AccountId == mapNPNnotToBeConvertedLeadIdToContactId.get(oNPNLead.Id).AccountId ){
                            
                            //get hold of the user before changing the values otherwise the key will not be matching
                            lstAllNPNPortalUsers.add(mapExistingPortalUsers.get(oPortalContact)); 
                            
                            //Set the GPU Genious Group and Record Type
                            oPortalContact.GPU_Genius_Groups__c = COMM_Constants.CON_GPUGNS_GRP_LNPNCOMM;
                            oPortalContact.RecordTypeId = mapContactRT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
                            
                            lstAllNPNPortalContact.add(oPortalContact);
                        }
                    }
                    
                }
                
                if (!lstAllNPNPortalContact.isEmpty()){
                    update lstAllNPNPortalContact;
                }
                
                //Reset the Password of the users
                //--------------------------------
                if (!lstAllNPNPortalUsers.isEmpty()){
                    for (User existingPortalUser : lstAllNPNPortalUsers){
                        if (existingPortalUser != null && existingPortalUser.isActive){//for inactive users it will raise error, so only reset for active users
                            setLeadEmailsOfExistingUsers.add(existingPortalUser.email); //add to the set so the corresponding leads will be deleted
                            //System.ResetPasswordResult rpr = system.resetPassword(existingPortalUser.Id, true); 
                        }
                    }
                }
            
            }
            //End of PASSWORD Reset 
            //********************************************************************
            
            
            //Convert the Leads which does not have any Contacts associated with it (based on its email address and Account: find the logic above)
            //****************************************************************
            list<Lead> lstAllEMEAIAndNPNLeadsToBeConverted = new list<lead>();
            lstAllEMEAIAndNPNLeadsToBeConverted.addAll(lstNPNLeadsToBeConverted);
            
            list<LeadStatus> lstLSConvertedLabel = [    Select MasterLabel
                                                        From LeadStatus
                                                        Where IsConverted = true
                                                            And MasterLabel = :COMM_Constants.LEAD_CONVERTED_STATUS_CTA ];
            
            System.debug('***lstLSConvertedLabel: ' + lstLSConvertedLabel);
            
            list<Database.LeadConvert> lstLeadToBeConverted = new List<Database.LeadConvert>();
            Database.LeadConvert oLC;
            
            for (Lead oTBCLead : lstAllEMEAIAndNPNLeadsToBeConverted){
                oLC = new Database.LeadConvert();
                oLC.setLeadId(oTBCLead.Id);
                oLC.setDoNotCreateOpportunity(true);  //do not need an apportunity
                //system.debug('***lstLSConvertedLabel[0].MasterLabel: ' + lstLSConvertedLabel[0].MasterLabel);
                oLC.setConvertedStatus(lstLSConvertedLabel[0].MasterLabel);
                oLC.setAccountId(mapAllLeadsToBeConvertedWithAccount.get(oTBCLead).Id); 
                lstLeadToBeConverted.add(oLC);
            }

            list<Contact> lstContactToBeUpdated = new list<Contact>();
            list<Id> lstLeadGotConverted = new list<Id>();
            map<Id, Map<Id, Id>> mapLeadIdToMapContactIdToAccId = new map<Id, Map<Id, Id>>(); //this holds the combiniation of Converted Lead - Its Contact - Its Account
            //Get User Locale settings and GPU Genius Group from Custom Settings
            Map<string, COMM_Utility.Community_User_Local_Settings_Wrapper>  mapCountryNameLocaleWrapper = new Map<string, COMM_Utility.Community_User_Local_Settings_Wrapper>();
            if (!lstLeadToBeConverted.isEmpty()) { //these are leads to be converted
                mapCountryNameLocaleWrapper = COMM_Utility.getCommUserLocalSettings(); //get the User Locale Settings and GPU GENIUS GROUP from Custom Settings
                list<Database.LeadConvertResult> lstLCR = Database.convertLead(lstLeadToBeConverted);
                for (Database.LeadConvertResult lcr : lstLCR){
                    if (lcr.isSuccess()){//successfully converted
                        //set the Default Content Type to Community for NPN users
                        lstContactToBeUpdated.add(new Contact(Id = lcr.getContactId(), Lead_Origin_Contact__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Portal_User_Content_Type__c = COMM_Constants.CON_DEFAULT_CONTENT_TYPE_NPN, RecordTypeID = mapContactRT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), GPU_Genius_Groups__c = COMM_Constants.CON_GPUGNS_GRP_LNPNCOMM, Portal_Groups__c = COMM_Constants.CON_PSANDGROUP_COMMUNITY));
                        
                        lstLeadGotConverted.add(lcr.getLeadId());
                        map<Id, Id> mapContactIdAccId = new map<Id, Id>();
                        mapContactIdAccId.put(lcr.getContactId(), lcr.getAccountID());
                        mapLeadIdToMapContactIdToAccId.put(lcr.getLeadId(), mapContactIdAccId);
                    } else {
                        for(Database.Error err : lcr.getErrors()) {// Operation failed, so get all errors   
                            System.debug('***Lead Conversion Error:');                    
                            System.debug('***Status Code with Message: ' + err.getStatusCode() + ' : ' + err.getMessage());
                            System.debug('***Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            
            //update the Contact of the converted Leads
            if (!lstContactToBeUpdated.isEmpty()){
                update lstContactToBeUpdated;
            }
            //End of Convert the Leads
            //****************************************************************
            
            //Portal User creation process
            //  For Contacts that got created by the Convert Lead process, check if they have already got user account associated with it.
            //  If they have user accounts, reset the password otherwise create user with notification and add to Public Groups
            //******************************************************************************
            list<string> lstUserNamesToBeSearched = new list<string>(); //list of all possible user names for the converted leads
            map<string, Id> mapUserNameLeadId = new map<string, Id>(); //map of username and lead Id
            string strUserNameExtn;
            for (Id converteLeadId : lstLeadGotConverted){
                strUserNameExtn = mapLeadsInTgrNew.get(converteLeadId).email + COMM_Constants.USRNAME_EXTN_NPN_COMM;
                lstUserNamesToBeSearched.add(strUserNameExtn);
                mapUserNameLeadId.put(strUserNameExtn, converteLeadId);
            }
            
            //get all users with the emails that might be same as the lead/contact's email address (Lead and Contact will have same email address, so either one can be used)
            //These are the users for which password need to be reset
            map<string, User> mapAllUsers = COMM_Utility.getAllUsersByUserNames(lstUserNamesToBeSearched);
            for (string userName : mapAllUsers.keySet()){
                if (mapAllUsers.get(userName) != null && mapAllUsers.get(userName).IsActive){//for inactive users it will raise error, so only reset for active users
                    setLeadEmailsOfExistingUsers.add(mapAllUsers.get(userName).email); //add to the set so the corresponding leads will be deleted
                    //System.ResetPasswordResult rpr = system.resetPassword(mapAllUsers.get(userName).Id, true);
                }
            }
            
            
            //Find the Leads whose email address combination does not match 
            //These are the Leads/Contacts for which new user to be created (Lead and Contact will have same email address, so either one can be used)
            list<Id> lstLeadForNewUserCreation = new list<Id>();
            if (!lstUserNamesToBeSearched.isEmpty()){
                for (string strUserName : lstUserNamesToBeSearched){
                    if (mapAllUsers.get(strUserName.toLowerCase()) == null){
                        lstLeadForNewUserCreation.add(mapUserNameLeadId.get(strUserName));
                    }
                }
            }
            
            //Create new User and Public Groups
            map<string, Id> mapProfQPPCPGeneric = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC);
            List<User> lstNewUsersToBeCreated = new list<User>();
            map<string, Id> mapNewUserIdLeadId = new map<string, Id>(); //map of Username to LeadId, used for assigning Public Groups
            
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail = true;
            User newUser;
            Id convertedContactId;
            
            
            for (Id leadId : lstLeadForNewUserCreation){
                //Get the Contact Id from Lead Id
                list<Id> lstContactId = new list<Id>();
                lstContactId.addAll(mapLeadIdToMapContactIdToAccId.get(leadId).keySet());
                convertedContactId = lstContactId[0];
                
                newUser = new User();

                newUser.email = mapLeadsInTgrNew.get(leadId).Email;
                newUser.firstName = mapLeadsInTgrNew.get(leadId).FirstName;
                newUser.lastname = mapLeadsInTgrNew.get(leadId).LastName;
                newUser.profileid = mapProfQPPCPGeneric.get(COMM_Constants.PROF_CP_QPP_GENERIC);
                newUser.contactId = convertedContactId;
                //newUser.userPermissionsSFContentUser=true;
                //newUser.userPreferencesContentNoEmail = true;
                //newUser.userPreferencesDisableAllFeedsEmail = true;
                //newUser.userPreferencesContentEmailAsAndWhen = true;

                newUser.alias = COMM_Constants.USER_ALIAS;
                newUser.emailencodingkey = COMM_Constants.USER_EMAILENCODEKEY;
                newUser.languagelocalekey = COMM_Constants.USER_LANGLOCALEKEY;
                newUser.localesidkey = COMM_Constants.USER_LOCALESIDKEY;
                newUser.timezonesidkey = COMM_Constants.USER_TZSIDKEY;
                newUser.username = mapLeadsInTgrNew.get(leadId).Email + COMM_Constants.USRNAME_EXTN_NPN_COMM;
                
                newUser.setOptions(dmo); //send email notification when new user created
                lstNewUsersToBeCreated.add(newUser);
                mapNewUserIdLeadId.put(newUser.username, leadId);
            }
            
            //insert the users and set Permission Sets and Public Groups
            if (!lstNewUsersToBeCreated.isEmpty()){
                
                //insert the users
                insert lstNewUsersToBeCreated;
                
                //Add Public Groups for the newly created users based on the Lead Origin
                list<string> lstPGNames = new list<string>();
                lstPGNames.add(COMM_Constants.PG_COMM_CONTENT);
                map<string, Id> mapPGs = COMM_Utility.getPGsByName(lstPGNames);
                
                map<Id, Id> mapUserIdGroupId = new map<Id, Id>(); //map of User's Id and Group Id which will be sent to future method
                for (User newCreatedUser : lstNewUsersToBeCreated){
                    //get hold of the user's LeadId to get Lead's Origin from the newMap - used to set the Public Groups accordingly
                    Id userLeadId = mapNewUserIdLeadId.get(newCreatedUser.userName);
                    string strLeadOrigin =  mapLeadsInTgrNew.get(userLeadId).lead_orgin__c;
                    mapUserIdGroupId.put(newCreatedUser.Id, mapPGs.get(COMM_Constants.PG_COMM_CONTENT));
                }
                
                //Call the future method to assign the Groups
                if (mapUserIdGroupId.keySet().size() > 0){
                    addUsersToPublicGroup(mapUserIdGroupId);
                }
                
                //Call the future method to add user to community portal permission sets
                if (mapUserIdGroupId.keySet().size() > 0){
                    addUsersToPortalPermissionSets(mapUserIdGroupId.keySet());
                }
            
            }
            //End of Portal User creation process
            //******************************************************************************
            
            
            //Delete Leads if its not converted because the contact already exists
            //******************************************************************************
            List<Lead> leadsToDelete = [Select id 
                                        From Lead 
                                        Where isConverted = false 
                                            and email in :setLeadEmailsOfExistingUsers
                                            and lead_orgin__c in (:COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM)];
            if (!leadsToDelete.isEmpty()){
                delete leadsToDelete;
            }
            //End of Delete Leads
            //******************************************************************************
        }
        
    }//end of autoConvertLead()
    
        //This function adds customer portal users to public groups specified in the map
    @future
    private static void addUsersToPublicGroup(map<Id, Id> mapUserIdGroupId){
        List<GroupMember> lstGM = new List<GroupMember>();
        GroupMember oGM;
        for (Id userId : mapUserIdGroupId.keySet()){
            oGM = new GroupMember();
            oGM.UserOrGroupId = userId;
            oGM.GroupId = mapUserIdGroupId.get(userId);
            lstGM.add(oGM);
        }
        
        //In case test class run, the Groups will not be inserted as part of the same transaction, 
        if( !lstGM.isEmpty() ) {
            //insert lstGM;
            Database.SaveResult[] lstSR = Database.insert(lstGM, false);
            for (Database.SaveResult sr : lstSR) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted GM with GM.Id: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('PG fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    
    //This function adds customer portal users specified in the set to Permission Sets
    //NVEP Users will have NVContacts and SALES Tool Box whereas Community or Lite users will have NVContacts and QPP Home Tab (Sales Tools and Marketing Assets)
    @future
    private static void addUsersToPortalPermissionSets(set<Id> setUserIds){
        list<string> lstPSNames = new list<string>();
        lstPSNames.add(COMM_Constants.PS_PORTAL_NV_CONTACTS_BOX);
        lstPSNames.add(COMM_Constants.PS_PORTAL_PP_QPP_HOME_TAB);
        lstPSNames.add(COMM_Constants.PS_PORTAL_PP_QPP_SALES_TOOLS_BOX);
        map<string, Id> mapPSs = COMM_Utility.getPSsByName(lstPSNames);
        
        list <PermissionSetAssignment> lstPSAssignments = new list <PermissionSetAssignment>();
        for (Id userId : setUserIds){
            if (mapPSs.get(COMM_Constants.PS_PORTAL_NV_CONTACTS_BOX) != null){
                lstPSAssignments.add( new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = mapPSs.get(COMM_Constants.PS_PORTAL_NV_CONTACTS_BOX) ) );
            }
            if (mapPSs.get(COMM_Constants.PS_PORTAL_PP_QPP_HOME_TAB) != null){
                lstPSAssignments.add( new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = mapPSs.get(COMM_Constants.PS_PORTAL_PP_QPP_HOME_TAB) ) );
            }
        }

        //In case test class run, the PSs will not be inserted as part of the same transaction, 
        if ( !lstPSAssignments.isEmpty() ){
            //insert lstPSAssignments;
            Database.SaveResult[] lstSR = Database.insert(lstPSAssignments, false);
            for (Database.SaveResult sr : lstSR) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted PSA. PSA ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('PSA fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    /* Rajat added for Community Level Automation on 9-July-2020 END */
              
    /*
        *****************************Functionality***********************************************************
        - Before Insert and Before Update of Lead
        - Fill Lead.lead_orgin__c to Lead.Lead_Origin_For_Contact__c
        - This function acts on the lead that gets originated from "NPN Community Web Form"
        - For Leads originated from "NPN Community Web Form, record type set to 'NPN Web Onboard Form'
    */
    public static void setRecordType(list<Lead> lstLeadsInTgrNew){
        map<string, id> mapLeadRTs = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_LEAD, '');
        
        //set the RecordTypeId based on the lead_origin__c
        for (Lead leadInTgrNew: lstLeadsInTgrNew) {
            
            //Copy Lead_Origin_For_Contact__c and Lead_Origin_For_Account__c from Lead_Orgin__c
            leadInTgrNew.Lead_Origin_For_Contact__c = leadInTgrNew.lead_orgin__c;
            leadInTgrNew.Lead_Origin_For_Account__c = leadInTgrNew.lead_orgin__c;
            
            //assign record type for NPN and EMEAIL Web Form Leads
            if ( !leadInTgrNew.isConverted && leadInTgrNew.lead_orgin__c == COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM & leadInTgrNew.Company != null 
                    && (leadInTgrNew.email != null && COMM_Utility.validateEmail(leadInTgrNew.email) )) {
                leadInTgrNew.RecordTypeId = mapLeadRTs.get(COMM_Constants.LEAD_RT_NPN_WEB_ONBOARD_FORM);
            
            } else if (!leadInTgrNew.isConverted && leadInTgrNew.lead_orgin__c == COMM_Constants.LEAD_ORIGIN_NPN_APPLICATION & leadInTgrNew.Company != null 
                    && (leadInTgrNew.email != null && COMM_Utility.validateEmail(leadInTgrNew.email) )){
                    leadInTgrNew.RecordTypeId = mapLeadRTs.get(COMM_Constants.LEAD_RT_NPN_WEB_ONBOARD_FORM);
            }
        }
    }
    
    /*
    //Date: 2015.09.02
    //Before Insert, Before Update: 
    Sets Product_Type_2__c based on Product_Type__c field value on Lead object. 
    It appends new options to Product_Type_2__c as and when the value in Product_Type__c changes but never removes any values
    Invoked from Lead Trigger
    */
    public static void setProductType2FromProductType(list<Lead> newLeadsInTgr){
        for (Lead lead : newLeadsInTgr){
            string productType = lead.Product_Type__c;
            string productType2 = lead.Product_Type_2__c;
            
            //check if the Product_Type__c field is blank, skip setting up the Product_Type_2__c
            if (String.isNotBlank(productType)){
                //if Product_Type_2__c is blank then add Product_Type__c to Product_Type_2__c
                if (String.isBlank(productType2)){
                    lead.Product_Type_2__c = lead.Product_Type__c;
                }else{
                    //if Product_Type_2__c does not contain Product_Type__c then append it with a semi-colon
                    if (!productType2.containsIgnoreCase(productType)){
                        lead.Product_Type_2__c = lead.Product_Type_2__c + ';' + lead.Product_Type__c;
                    }
                }
            }
        }
    }
    
    //Date 2016.07.27
    //After Insert : Leadspace Integration
    //Add Leads to Campaigns based on the LeadSource and Lead_Origin__c
    public static void addLSLeadsToCampaign(list<Lead> lstNewLeads){
                
        //Begin: Build LeadSource+Lead Origin to Campaign Id key value pair from custom settings
        //----------------------------------------------------------------------------------------
        //all LS Campaign Mappings from Custom Settings
        Map<String, Leadspace_Campaign_Mappings__c> mapCSAllLSCampaigns = Leadspace_Campaign_Mappings__c.getAll();
        
        //map to hold Lead_Origin to Campaign Id
        Map<String, String> mapLeadOriginNameCampaignId = new Map<String, String>();
        
        for (Leadspace_Campaign_Mappings__c cs : mapCSAllLSCampaigns.Values() ){
            if (cs.IsActive__c == true ){
                //add it to the map mapLeadOriginNameCampaignId. Key = LeadSource + Lead Origin, Value = Campaign Id
                mapLeadOriginNameCampaignId.put(cs.LeadSource__c + cs.Lead_Origin__c, cs.CampaignId__c);
            }
        }
        //End: Build LeadSource+Lead Origin to Campaign Id key value pair from custom settings
        //----------------------------------------------------------------------------------------
        
        //Begin: Process the incoming leads
        //----------------------------------------------------------------------------------------
        
        //holding are for all Campaign Members
        list <CampaignMember> lstCampaignMembers = new list<CampaignMember>(); // List containing Campaign Member records to be inserted
        
        //build the CampaignMember list
        for (Lead lead : lstNewLeads){
            if (mapLeadOriginNameCampaignId.get(lead.LeadSource + lead.Lead_Orgin__c) != null){
                lstCampaignMembers.add(new CampaignMember(LeadId = lead.Id, CampaignId = mapLeadOriginNameCampaignId.get(lead.LeadSource + lead.Lead_Orgin__c)));
            }
        }
        
        //insert the CampaignMember list
        if (!lstCampaignMembers.isEmpty()){
            list<Database.SaveResult> lsr = database.insert(lstCampaignMembers, false);
            system.debug('***Leads added to Campaigns and the details: ');
            
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('***Added to Campaign, CampaignMemberId = ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('***The following error has occurred : ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        
        //End: Process the incoming leads
        //----------------------------------------------------------------------------------------
    }
    
    // Date: 2017.07.12
    // Before Insert/Update: This is invoked by only 'Marketo Sync' User.
    // Country/State fields picklist enablement 
    public static void ctryStatePicklistforMKTO(List<Lead> leadSrcList) {
       
       list<Lead> leadsFilteredLst = new list<Lead>();
       list<Lead> leadsCtryBlankFilteredLst = new list<Lead>();
       Set<String> strCountrySet = new Set<String>();
       Set<String> strStateSet = new Set<String>();
       
       for(Lead ld: leadSrcList) {
           if(string.isNotBlank(ld.MKTO_Country__c)) {
              leadsFilteredLst.add(ld);   
              strCountrySet.add(ld.MKTO_Country__c);
              if(string.isNotBlank(ld.MKTO_State__c)) strStateSet.add(ld.MKTO_State__c);         
           } else {
               leadsCtryBlankFilteredLst.add(ld);
           }    
       }
       
       // Leads with Non-Blank Country 
       if(!leadsFilteredLst.isEmpty()) { 
          
          map<String, Country_List__c> countryNameISOCodeMap = new map<String, Country_List__c>();
          if(!strCountrySet.isEmpty()) {
             // query all Counries from CountryList object 
             for(Country_List__c ctry: [SELECT Id, Name, ISO_Code__c, Region__c, Sub_Region__c, Territory__c, (Select Id, Name, ISO_Code__c from States__r WHERE Name IN:strStateSet or ISO_Code__c IN:strStateSet)
                                        FROM Country_List__c
                                        WHERE Name IN:strCountrySet or ISO_Code__c IN:strCountrySet]) {
                 string strCtryName = string.valueOf(ctry.Name).toUpperCase(); // convert Country name to all CAPS
                 countryNameISOCodeMap.put(strCtryName, ctry);
                 string strCtryISO = string.valueOf(ctry.ISO_Code__c).toUpperCase(); // convert Country ISO Code to all CAPS
                 countryNameISOCodeMap.put(strCtryISO, ctry);
             }
          } 
                       
          // Process the Leads and populate the values in Country and State fields           
          for(Lead ld: leadsFilteredLst) {  
              String strCtryName = string.valueOf(ld.MKTO_Country__c).toUpperCase(); // convert Country Name to all CAPS
              // check and populate if value in 'MKTO_Country__c' field matches with the CountryName/Country ISO Code   
              if(!countryNameISOCodeMap.isEmpty() && countryNameISOCodeMap.containsKey(strCtryName)) {   
                  ld.Country = countryNameISOCodeMap.get(strCtryName).Name;  
                  ld.MKTO_Country__c = countryNameISOCodeMap.get(strCtryName).Name;
                  ld.Region__c = countryNameISOCodeMap.get(strCtryName).Region__c;
                  ld.Sub_Region__c = countryNameISOCodeMap.get(strCtryName).Sub_Region__c;
                  ld.Territory__c = countryNameISOCodeMap.get(strCtryName).Territory__c; 
                  if(string.isNotBlank(ld.MKTO_State__c)) {
                     for(State_List__c stateLst: countryNameISOCodeMap.get(strCtryName).States__r) {
                         if(string.valueOf(ld.MKTO_State__c).equalsIgnoreCase(stateLst.Name) || string.valueOf(ld.MKTO_State__c).equalsIgnoreCase(stateLst.ISO_Code__c)) {
                             ld.State = stateLst.Name;
                             ld.MKTO_State__c = stateLst.Name;
                             break;
                         }    
                     }
                  } else {
                     ld.State = '';
                  }  
              }           
          }   
       
       } 
       
       // Leads with blank Country 
       if(!leadsCtryBlankFilteredLst.isEmpty()) {
           for(Lead ld: leadsCtryBlankFilteredLst) {
               ld.Country = '';
               ld.State = '';
               ld.MKTO_State__c = '';
               ld.Region__c = '';
               ld.Sub_Region__c = '';
               ld.Territory__c = '';
           }
       }
           
    }  // end of 'ctryStatePicklistforMKTO()'
    
    /*  Date: 2017.07.12 - @Manideep
     *  Before Insert/Update: This is invoked by non - 'Marketo Sync' User.
     *  Country/State fields picklist Enablement 
    */
    public static void ctryStateMatchforMKTO(list<Lead> leadSrcList, map<Id, Lead> newLeadsMap, map<Id, Lead> oldLeadsMap) {
       
       // Collections for Country/State Codes Check     
       List<Lead> leadsFiltered = new List<Lead>();
       set<String> mktoCtrySet = new set<string>();
       set<String> mktoStateSet = new set<String>();
       map<String, Country_List__c> ctryCodeListMap = new map<String, Country_List__c>();
       map<String, State_List__c> stateCodeListMap = new map<String, State_List__c>();
       
       // Collections for Country/State Names Check 
       List<Lead> leadsFilteredwithNames = new List<Lead>();
       set<String> mktoCtryNameSet = new set<string>();
       set<String> mktoStateNameSet = new set<String>();
       map<String, Country_List__c> ctryNameListMap = new map<String, Country_List__c>();
       map<String, State_List__c> stateNameListMap = new map<String, State_List__c>(); 
                                  
       // for Lead 'Update'
       if(newLeadsMap!= null && oldLeadsMap != null) {  
           for(Lead ld: newLeadsMap.values()) {            
               // when 'CountryCode' field value is Changed
               if(string.isNotBlank(string.valueOf(ld.CountryCode)) && ((ld.CountryCode != oldLeadsMap.get(ld.Id).CountryCode))) {
                   mktoCtrySet.add(ld.CountryCode);
                   leadsFiltered.add(ld);   
               } else if(string.isBlank(string.valueOf(ld.CountryCode)) && ((ld.CountryCode != oldLeadsMap.get(ld.Id).CountryCode))) {
                   leadsFiltered.add(ld); 
               }
               
               // when 'StateCode' field value is Changed  
               if(string.isNotBlank(string.valueOf(ld.StateCode)) && ((ld.StateCode != oldLeadsMap.get(ld.Id).StateCode) || !mktoCtrySet.isEmpty())) {
                   mktoStateSet.add(ld.StateCode); 
                   if(mktoCtrySet.isEmpty()) mktoCtrySet.add(ld.CountryCode);
                   leadsFiltered.add(ld); 
               } else if(string.isBlank(string.valueOf(ld.StateCode)) && (ld.StateCode != oldLeadsMap.get(ld.Id).StateCode)) {
                   leadsFiltered.add(ld);  
               }   
               
               // when 'Country'/'State' field values are Changed
               if((ld.Country != oldLeadsMap.get(ld.Id).Country) || (ld.State != oldLeadsMap.get(ld.Id).State)) {
                   /*
                    if(ld.Country != ld.MKTO_Country__c)  ld.MKTO_Country__c = ld.Country;
                    if(ld.State != ld.MKTO_State__c)      ld.MKTO_State__c = ld.State;
                   */                  
                   // in this usecase only 'Country' and 'State' fields will have new values not the CountryCode/StateCode                
                   mktoCtryNameSet.add(ld.Country);
                   if(string.isNotBlank(string.valueOf(ld.State))) mktoStateNameSet.add(ld.State);
                   leadsFilteredwithNames.add(ld);   
               }   
           }
       } else if(!leadSrcList.isEmpty()) {  // for Lead 'Insert'
           for(Lead ld: leadSrcList) {
               if(string.isNotBlank(string.valueOf(ld.CountryCode))) {
                  mktoCtrySet.add(ld.CountryCode);
                  leadsFiltered.add(ld); 
                  if(string.isNotBlank(string.valueOf(ld.StateCode))) {
                     mktoStateSet.add(ld.StateCode); 
                  } 
               } else if(string.isNotBlank(string.valueOf(ld.Country))) {
                  /*
                   ld.MKTO_Country__c = ld.Country;
                   ld.MKTO_State__c = ld.State;
                  */
                  // in this usecase only 'Country' and 'State' fields will have new values not the CountryCode/StateCode  
                  mktoCtryNameSet.add(ld.Country);
                  if(string.isNotBlank(string.valueOf(ld.State))) mktoStateNameSet.add(ld.State);
                  leadsFilteredwithNames.add(ld);     
               }
           }       
       }
       
       if(!mktoCtrySet.isEmpty() || !mktoCtryNameSet.isEmpty()) {
          for(Country_List__c ctryLst: [Select Id, Name, ISO_Code__c, Region__c, Sub_Region__c, Territory__c, (Select Id, Name, ISO_Code__c from States__r WHERE ISO_Code__c IN:mktoStateSet or Name IN:mktoStateNameSet) 
                                        FROM Country_List__c 
                                        WHERE ISO_Code__c IN:mktoCtrySet or Name IN:mktoCtryNameSet]) {
              ctryCodeListMap.put(ctryLst.ISO_Code__c, ctryLst);
              ctryNameListMap.put(ctryLst.Name, ctryLst);
              for(State_List__c stateLst: ctryCodeListMap.get(ctryLst.ISO_Code__c).States__r) {
                  stateCodeListMap.put(stateLst.ISO_Code__c, stateLst);
                  stateNameListMap.put(stateLst.Name, stateLst);
              }            
          }      
       }
       
       if(!leadsFiltered.isEmpty()) {      
           for(Lead ld: leadsFiltered) {  
               // Country  
               if(string.isNotBlank(string.valueOf(ld.CountryCode)) && !ctryCodeListMap.isEmpty() && ctryCodeListMap.containsKey(ld.CountryCode)) { 
                  ld.MKTO_Country__c = ctryCodeListMap.get(ld.CountryCode).Name; 
                  ld.Region__c = ctryCodeListMap.get(ld.CountryCode).Region__c;
                  ld.Sub_Region__c = ctryCodeListMap.get(ld.CountryCode).Sub_Region__c;
                  ld.Territory__c = ctryCodeListMap.get(ld.CountryCode).Territory__c;
               } else if(string.isBlank(string.valueOf(ld.CountryCode)) && string.isNotBlank(string.valueOf(ld.MKTO_Country__c))) {
                  ld.MKTO_Country__c = '';
                  ld.Region__c = '';
                  ld.Sub_Region__c = '';
                  ld.Territory__c = '';
               }    
               // State     
               if(string.isNotBlank(string.valueOf(ld.StateCode)) && !stateCodeListMap.isEmpty() && stateCodeListMap.containsKey(ld.StateCode))   
                  ld.MKTO_State__c = stateCodeListMap.get(ld.StateCode).Name; 
               else if(string.isBlank(string.valueOf(ld.StateCode)) && string.isNotBlank(string.valueOf(ld.MKTO_State__c)))
                  ld.MKTO_State__c = '';       
           }
       }
       
       // If Country/State Name values are changed from the backend
       if(!leadsFilteredwithNames.isEmpty()) {
          for(Lead ld: leadsFilteredwithNames) {
              system.debug('ld.Country--->'+ld.Country);
              system.debug('ctryNameListMap.containsKey(ld.Country)--->'+ctryNameListMap.containsKey(ld.Country));
              // Country
              if(string.isNotBlank(string.valueOf(ld.Country)) && !ctryNameListMap.isEmpty() && ctryNameListMap.containsKey(ld.Country)) { 
                  ld.MKTO_Country__c = ctryNameListMap.get(ld.Country).Name; 
                  ld.Region__c = ctryNameListMap.get(ld.Country).Region__c;
                  ld.Sub_Region__c = ctryNameListMap.get(ld.Country).Sub_Region__c;
                  ld.Territory__c = ctryNameListMap.get(ld.Country).Territory__c;
              } else if(string.isBlank(string.valueOf(ld.Country)) && string.isNotBlank(string.valueOf(ld.MKTO_Country__c))) {
                  ld.MKTO_Country__c = '';
                  ld.Region__c = '';
                  ld.Sub_Region__c = '';
                  ld.Territory__c = '';
              } 
              // State
              if(string.isNotBlank(string.valueOf(ld.State)) && !stateNameListMap.isEmpty() && stateNameListMap.containsKey(ld.State))   
                 ld.MKTO_State__c = stateNameListMap.get(ld.State).Name; 
              else if(string.isBlank(string.valueOf(ld.State)) && string.isNotBlank(string.valueOf(ld.MKTO_State__c)))
                 ld.MKTO_State__c = '';  
          }
       }
           
    } // end of 'ctryStateMatchforMKTO()'
            
    //Date - 7/28/2017
    //SOEM related code - convert lead to contact for the SOEM account
    public static void checkSOEMLeads(list<Lead> lstLead) {
        list<Id> lstAccountIds = new list<Id>();
        map<Id, Id> mapAccountIdLeadId = new map<Id,Id>();
        map<Id, Id> mapLeadIdAccountId = new map<Id,Id>();
        list<Account> lstAccount = new list<Account>();
        for(Lead objLead : lstLead) {
            if(objLead.AccountId__c != null) {
                lstAccountIds.add(objLead.AccountId__c);
                mapAccountIdLeadId.put(objLead.AccountId__c, objLead.Id);
            }
        }
        if(lstAccountIds.size() > 0) {
            lstAccount = [select id,name from account where id in :lstAccountIds];
            if(lstAccount.size() > 0) {
                for(Account objAccount : lstAccount) {
                    if(SOEMs_Account_Mapping__c.getInstance(objAccount.Id) != null) {
                        if(mapAccountIdLeadId.containsKey(objAccount.Id)) {
                            mapLeadIdAccountId.put(mapAccountIdLeadId.get(objAccount.Id), objAccount.Id);
                        }
                    }
                }
            }
            system.debug(mapLeadIdAccountId);
            if(!mapLeadIdAccountId.isEmpty())
                convertSOEMLeadWithAccount(mapLeadIdAccountId);
        }
    }
    
    public static void convertSOEMLeadWithAccount(map<Id,Id> mapLeadIdAccountId) {
        Map<Id,Lead> mapLead = new Map<Id,Lead>([select id, isConverted, Approved_Competencies__c, Approved_Program_Type__c, Competencies_Interested_In__c, Program_Level__c, Organization_Type_select_one__c, (select id,name,Email__c,Job_Role__c, Leads_and_Opportunities__c,Phone__c,Sales_Training__c,Technical_Training__c from NPN_Key_Contacts__r) from Lead where id IN : mapLeadIdAccountId.keySet()]);
        map<Id, account> mapAccount = new Map<Id, Account>([select id, name, ownerId from Account where id in :mapLeadIdAccountId.values()]);
        map<String, Id> mapContactRT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<String, NPN_Competency_Permissions_Group_Map__c> mapOnboardingCompetencyPermissionsAndGroup = NPN_Competency_Permissions_Group_Map__c.getAll();
        list<Contact> lstContact = new list<Contact>();
        List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(Lead objLead : mapLead.values()) {
            if(!objLead.isConverted) {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(objLead.Id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setDoNotCreateOpportunity(True); 
                lc.setAccountId(mapLeadIdAccountId.get(objLead.id));
                lcList.add(lc);
            }
        }
        List<Database.LeadConvertResult> lcrList = new List<Database.LeadConvertResult>();
        if (!lcList.isEmpty()) {
            lcrList = Database.convertLead(lcList, False);
        }
        for(Database.LeadConvertResult objLcr : lcrList) {
            if(objLcr.isSuccess()) {
                Contact con = new Contact(id=objLcr.getContactId());
                con.create_user__c = true;
                con.RecordTypeId = mapContactRT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT);       
                if(mapAccount.containsKey(objLcr.getAccountId())) {         
                    con.ownerId = mapAccount.get(objLcr.getAccountId()).ownerId;
                    SOEMs_Account_Mapping__c objSOEMAccountMapping = SOEMs_Account_Mapping__c.getInstance(objLcr.getAccountId());
                    if(objSOEMAccountMapping != null) {
                        con.portal_groups__c = objSOEMAccountMapping.Permissions_Portal_Groups__c;
                        con.GPU_Genius_Groups__c = objSOEMAccountMapping.GPU_Genius_Groups__c;
                        con.Portal_User_Content_Type__c = objSOEMAccountMapping.Default_Competency__c;
                    }
                }
                /*
                for(NPN_Competency_Permissions_Group_Map__c objOnboardingCompetencyPermissionGroup : mapOnboardingCompetencyPermissionsAndGroup.values()) {
                    if(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c!=null && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyPermissionGroup.Competency__c) && (objOnboardingCompetencyPermissionGroup.program_type__c == '' || objOnboardingCompetencyPermissionGroup.program_type__c == null) &&  (objOnboardingCompetencyPermissionGroup.program_level__c == '' || objOnboardingCompetencyPermissionGroup.program_level__c == null)) {
                        con.Portal_Groups__c += objOnboardingCompetencyPermissionGroup.permissions_and_group__c + ';';
                    }
                    if(mapLead.get(objLcr.getLeadId()).Approved_Competencies__c!=null && mapLead.get(objLcr.getLeadId()).Approved_Competencies__c.contains(objOnboardingCompetencyPermissionGroup.Competency__c) && objOnboardingCompetencyPermissionGroup.program_type__c != null && mapLead.get(objLcr.getLeadId()).approved_program_type__c !=null && mapLead.get(objLcr.getLeadId()).approved_program_type__c.contains(objOnboardingCompetencyPermissionGroup.program_type__c) && objOnboardingCompetencyPermissionGroup.program_type__c != null && mapLead.get(objLcr.getLeadId()).program_level__c !=null && mapLead.get(objLcr.getLeadId()).program_level__c.contains(objOnboardingCompetencyPermissionGroup.program_level__c)) {
                        con.Portal_Groups__c += objOnboardingCompetencyPermissionGroup.permissions_and_group__c + ';';
                    }
                }
                */
                lstContact.add(con);
            }
        }
        if(lstContact.size() > 0) {
            update lstContact;
        }
    }
    
    /*  Date: 2017.12.21 - @Manideep
     *  Before Update: Automotive Lead Conversion Validation - This will be invoked either on click of 'Convert' button on Lead Conversion page or by any code that invokes conversion logic. 
     *  Restrict an Automotive Lead from Conversion process upon click of 'Convert' button if the Lead has any open Activities during the Lead is converting into
        an "exisitng Account" and a new Contact and NOT to create a new Opportunity and if that existing Account already has an Opportunity that's not 'Closed Won'.
    */
    /*
    public static void automotiveLeadConversionValidation(list<Lead> leadsList) {
       
       set<Id> leadConvAccountIdSet = new set<Id>();
       set<Id> leadConvContactIdSet = new set<Id>();
                             
       // Collect the Converted AccountId's and Converted ContactId's of each Lead              
       for(Lead ld: leadsList) {
           // If a Lead is Converted into existing Account and choosed not to create a new Opportunity upon Conversion
           if(ld.ConvertedAccountId != null && ld.ConvertedOpportunityId == null) {
              leadConvAccountIdSet.add(ld.ConvertedAccountId);  
              leadConvContactIdSet.add(ld.ConvertedContactId);                    
           }   
       }
       system.debug('leadConvAccountIdSet1---->'+leadConvAccountIdSet);
       system.debug('leadConvContactIdSet---->'+leadConvContactIdSet);   
           
       list<Opportunity> oppList = [Select Id, AccountId FROM Opportunity 
                                    WHERE AccountId IN:leadConvAccountIdSet
                                    AND RecordType.Name =: COMM_Constants.OPPTY_RT_AUTOMOTIVE_INTERNAL_OPPTY
                                    AND StageName != 'Closed Won'];
       leadConvAccountIdSet.clear();
           
       // check if the there is an Opportunity for an existing Account 
       if(!oppList.isEmpty()) {
           for(Opportunity opp: oppList) {
               leadConvAccountIdSet.add(opp.AccountId);
           }
       } 
       system.debug('leadConvAccountIdSet2---->'+leadConvAccountIdSet);
                      
       // Check if Leads in Conversion process have any 'Open' Tasks
       set<Id> tasksConvWhoIdSet = new set<Id>();
       list<Task> openTasksforLeadsList = [SELECT Id, WhoId FROM Task WHERE Status != 'Completed' AND WhoId IN:leadConvContactIdSet];
       if(!openTasksforLeadsList.isEmpty()) {
           for(Task tsk: openTasksforLeadsList) {
               tasksConvWhoIdSet.add(tsk.WhoId);
           }    
       }
       system.debug('tasksConvWhoIdSet----->'+tasksConvWhoIdSet);
           
       // Fire Validaiton if the Lead has 'Open' Tasks           
       if(!leadConvAccountIdSet.isEmpty() && !tasksConvWhoIdSet.isEmpty()) {                        
           for(Lead ld: leadsList) {
               if(leadConvAccountIdSet.contains(ld.ConvertedAccountId) && tasksConvWhoIdSet.contains(ld.ConvertedContactId)) {                        
                  system.debug('Fired Validation---->');
                  ld.addError('You cannot Convert this Lead, please either delete or move status of all Open Tasks in Activities for this Lead and try again to Convert');
               }
           }    
       }
        
    } //end of automotiveLeadConversionValidation()
    */
    
    /*  Date: 2018.1.29 - @Manideep
     *  Before Update: Automotive Lead Conversion Validation - This will be invoked either on click of 'Convert' button on Lead Conversion page or by any code that invokes conversion logic. 
     *  Restrict an Automotive Lead from Conversion process upon click of 'Convert' button and if it the Lead is mapped to an "existing Account" and not creating a new Opportunity and
        a new Contact, then throw the Validation if the specific Lead fields are blank because this Lead is considered as a Contact.
     *  Date: 2018.4.30 - @Manideep, Removed Leads 'State' field field from the "Automotive Lead Conversion Required fields Validaiton" logic below. 
     *  Date: 2019.7.22 = @Manideep, added Skip Validation logic based on Custom Permission 'SKIP Automotive Lead Conversion Validation'.
    */
    public static void automotiveLeadRequireddFieldsValidation(list<Lead> leadsList) {
       
       set<String> leadCompanySet = new set<String>();
       set<Id> existingAccountIdSet = new set<Id>(); 
       Boolean skipValidationBoolean = false;
       
       for(Lead ld: leadsList) {
           leadCompanySet.add(ld.Company);
       }
              
       if(!leadCompanySet.isEmpty()) {    
           // Collect all the existing Accounts               
           for(Account acc: [Select Id from Account Where RecordType.Name = 'New Customer Account' AND Name IN:leadCompanySet]) {
               existingAccountIdSet.add(acc.Id);
           }
       }
       
       // check if the logged in User has the Custom Permission 'SKIP Automotive Lead Conversion Validation'
       list<PermissionSetAssignment> lstPSA = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
       set<Id> setParentId = new set<Id>();
       set<Id> setCPId = new set<Id>();
       
       for(PermissionSetAssignment objPSA: lstPSA) {
           setParentId.add(objPSA.PermissionSetId);    
       }        
       setParentId.add(userinfo.getProfileId());
       
       list<CustomPermission> lstCP = [SELECT Id FROM CustomPermission WHERE DeveloperName =:Label.SKIP_Automotive_Lead_Validation];
       if(!lstCP.isEmpty()) {
          for(CustomPermission objCP: lstCP) {
              setCPId.add(objCP.Id);
          }
       }
              
       List<SetupEntityAccess> lstSE = [SELECT SetupEntityId FROM SetupEntityAccess WHERE SetupEntityId IN:setCPId AND ParentId IN:setParentId]; 
       if(!lstSE.isEmpty()) {
           skipValidationBoolean = true;
       }
       system.debug('skipValidationBoolean------>'+skipValidationBoolean); 
                     
       // Fire Validaiton if the specified fields are not populated on the Lead during Conversion           
       for(Lead ld: leadsList) {
           if(ld.IsConverted && ld.ConvertedAccountId != null 
              && !skipValidationBoolean
              && ((ld.ConvertedOpportunityId != null && existingAccountIdSet.contains(ld.ConvertedAccountId)) || (!existingAccountIdSet.contains(ld.ConvertedAccountId)))           
              && (ld.Status == 'Convert to Account'
                  && (string.isBlank(string.valueOf(ld.Industry)) || string.isBlank(string.valueOf(ld.Automotive_Segment__c)) 
                      // || string.isBlank(string.valueOf(ld.Operating_System__c))
                      // || string.isBlank(string.valueOf(ld.Auto_BU_Priority__c)) || string.isBlank(string.valueOf(ld.NVIDIA_Hardware_Used_Vehicle_Inference__c)) 
                      || string.isBlank(string.valueOf(ld.Street)) || string.isBlank(string.valueOf(ld.City)) 
                      // || string.isBlank(string.valueOf(ld.State))
                      || string.isBlank(string.valueOf(ld.Country)) || string.isBlank(string.valueOf(ld.PostalCode)) || string.isBlank(string.valueOf(ld.Website))))) {       
                 // ld.addError('You must set the mandatory fields:- Industry, Automotive Segment, Operating System, Auto BU Priority, Nvidia Hardware Used, Street, City, State, Postal Code, Country and Website to Convert this Lead');
                 ld.addError('You must set the mandatory fields:- Industry, Automotive Segment, Street, City, Postal Code, Country and Website to Convert this Lead');
           }   
       }                 
                            
    } //end of automotiveLeadConversionContactValidation()

}