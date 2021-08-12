/**************************************************************************************************
* Name       : TriggerUserHelper
* Purpose    : Helper class for TriggerUser Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/12/2017      | Initial Draft
*Perficient         | 1.0        | 12/15/2017      | Final Draft
*Perficient         | 1.0        | 01/28/2018      | Adding condition with profile.

*PJENA				| 2.0		 | 5/27/2018	   | ESP For NPN Partners
													 Open up Service Cloud access for NPN Partners
**************************************************************************************************/
public class TriggerUserHelper extends RMA_IDM_Callouts{
   /*
    *   A static variable maintained to avoid the execution of After Update event based operation multiple times
    */
    public static Boolean ExecuteIDM = false;
   /*
    *   Purpose of this method is to
    *   - Collect the Users belonging to the profile 'ESP Community User'
    *   - Assign the appropriate RMA IDM visible permission sets to the Users (ESP Community)
    */
    public Static void AfterCreate(List<User> createdusers , Map<Id,User> CreatedUserMap){
        //Profile p = getESPCommunityProfile(); //*PJENA				| 2.0		 | 5/27/2018	   | ESP For NPN Partners
        set<Id> setESPAllowedProfileIds = getESPCommunityProfiles();
        List<User> createdESPUsers = new List<User>();
        //Creating user -> contact map
        Map<Id, Id> userContactMap = new Map<Id, Id>();
        for(User usr: createdusers){
            //if(usr.ProfileId == p.Id && usr.contactId !=null){//*PJENA				| 2.0		 | 5/27/2018	   | ESP For NPN Partners
            if( setESPAllowedProfileIds.contains(usr.ProfileId) && usr.contactId !=null ){
                userContactMap.put(usr.Id, usr.contactId);
                createdESPUsers.add(usr);
            }
        }
        if(!userContactMap.isEmpty() && !createdESPUsers.isEmpty()){
            assignPermissionSet(userContactMap,createdESPUsers);
        }
    }
   /*
    *   Input to this operation is 
    *   -   a Collection (Map) of User Id to Contact Id
    *   -   a Collection (List) of Users created
    *   Note: Users processed here belong to the profile 'ESP Community User'
    *   For the new User, appropriate permission sets need to be assigned based on entitlement to products
    *   A collection is maintained for
    *   - all permission sets as identified within the custom settings RMA_IDM_Visibility    
    *   - Map of Contact records
    *   - Holding the unique Account Identifiers
    *   - Entitlement Map with Account and Product Family information on the entitlement. 
    *     Note: Entitlements belonging to the unique Account Identifiers are the ones held in the Entitlement map container 
    *    
    *   A query is run on the custom settings namely 'RMA_IDM_Visibility', to retrieve the various permissions sets
    *   A permission is categorized based on Product Family (DGX or GRID) and whether the permission needs to be granted at the Product or entitlement level
    *   In addition, there is generic permission set entry within the custom setting that is not relevant to product or entitlement
    *
    *   For each individual User,
    *       -   Check if an entitlement exists (using the account on the User) for a Product Family 
    *           If so, the corresponding Permission Sets (read from the custom setting) are eligible for association to the User
    *       -   a new PermissionSetAssignment entry is instantiated with the AssigneeId as the User 
    *           and the Permission set id is the one found as an entry in the collection of permission sets (RMA IDM Visibility)
    *   Finally, the Collection of Permission Set Assignment entries from the previous step are inserted in the database
    */     
    public static void assignPermissionSet(Map<Id, Id> userContactMap,List<User> createdusers){
        //Values from custom Setting
        List<RMA_IDM_Visibility__c> rmavisibility = RMA_IDM_Visibility__c.getall().values();
        Map<String,RMA_IDM_Visibility__c> permissionnameVsMap = new Map<String,RMA_IDM_Visibility__c>();
        Map<String,String> permissionNameVsId = new Map<String,String>();

        //Fetching accounts related to contact
        Map<Id, Contact> contactMap = new Map<Id, Contact>
            ([SELECT Id, AccountId FROM Contact WHERE Id =:userContactMap.values()]);
        List<Id> accList = new List<Id>();
        for(Contact con : contactMap.values()){
            accList.add(con.accountId);
        }
        
        //Fetching active entitlements related to account
        Map<Id, Entitlement> entitlementMap = new Map<Id, Entitlement>
            ([SELECT Id, Product_Family__c, AccountId FROM Entitlement WHERE Status = 'Active' AND AccountId =:accList ]);
        
        //Fetching PermissionSet Id's
        Set<String> lstPermissionSetNames = new Set<String>();
        for(RMA_IDM_Visibility__c vis :rmavisibility){
            lstPermissionSetNames.add(vis.Permission_Set_Name__c);
            permissionnameVsMap.put(vis.Permission_Set_Name__c,vis);
        }
        
        List<Id> permissionGeneral = new List<Id>();
        List<Id> permissionGridMap = new List<Id>();
        List<Id> permissionDGXMap = new List<Id>();
        
        List<PermissionSet> permissionsets = [SELECT Id, Name FROM PermissionSet WHERE Name =:lstPermissionSetNames];
        for (PermissionSet permissionset : permissionsets){
            permissionNameVsId.put(permissionset.Name,permissionset.Id);
            If(permissionset.name.contains('General_Article_Visibility_for_All_Customers')){
                permissionGeneral.add(permissionset.Id);
            } 
        }

        //Creating PermissionSetAssignments for the user
        List<PermissionSetAssignment> lstPsa = new List<PermissionSetAssignment>();
        for(User usr: createdusers){
            if(usr.contactId !=null){
                Id accId = contactMap.get(usr.contactId).AccountId;
                if(permissionGeneral.size() >0)
                	lstPsa.add(new PermissionSetAssignment( PermissionSetId = permissionGeneral[0],
                                                       AssigneeId = usr.Id));

                Set<String> permissionNames = new Set<String>();
                for(Entitlement ent : entitlementMap.values()){
                    if(ent.AccountId == accId){
                        if(ent.Product_Family__c != null){
                            for(RMA_IDM_Visibility__c permissions : permissionnameVsMap.values()){
                                if(permissions.Product_Family__c!=null)
                                	if(ent.Product_Family__c.containsIgnoreCase(permissions.Product_Family__c))
                                    	permissionNames.add(permissions.Permission_Set_Name__c);
                            }
                        }
                    }
                }
                system.debug('permissionNames---------->'+permissionNames);
                if(permissionNames.size() >0){
                    for(String Name:permissionNames){
                        lstPsa.add(new PermissionSetAssignment( PermissionSetId = permissionNameVsId.get(Name),
                                                       AssigneeId = usr.Id));
                    }
                }
            }
        }
        system.debug('Users-->'+createdusers);       
        system.debug('lstPsa-->'+lstPsa);       
        if(lstPsa.size() >0){
            insert lstPsa;
        }
    }
   /*
    *   This method is fired/invoked by After update trigger event
    *   Purpose of this operaion is to
    *   -   Collect all the Contact Identifiers for the ESP Community Users
    *   -   Run an asynchronous operation to turn off the Sync flag on the corresponding DGX or GRID contact records  
    */
    //reactive ESP Community user, we need to re-sync again. 
    public Static void AfterUpdate(List<User> lstOld, Map<Id,User> oldMap, List<User> lstNew, Map<Id,User> newMap){
        //Profile p = getESPCommunityProfile(); //*PJENA				| 2.0		 | 5/27/2018	   | ESP For NPN Partners
        set<Id> setESPAllowedProfileIds = getESPCommunityProfiles();     
        Set<Id> activeContactIdSet = new Set<Id>();
        if(ExecuteIDM == true)
          return;
        for(User u : lstNew){
            if(setESPAllowedProfileIds.contains(u.ProfileId) && u.isActive && (oldMap == null || !oldMap.get(u.Id).isActive) && u.ContactId != null){
                activeContactIdSet.add(u.ContactId);
            }
        }
        ExecuteIDM = true;  
        if(!activeContactIdSet.isEmpty()){
            updateContactForActiveUsers(activeContactIdSet);
        }
    }
   /*
    *   Purpose of this operaion is to
    *   -   Collect the eligible Contact records using the input Contact record identifiers
    *   -   Ensure the Contact records have the DGX Contact or the GRID Contact flag turned on. These contacts are
    *       the ones eligible for further processing
    *   -   Turn off the Sync flag on the corresponding DGX or GRID contact records
    *   -   Perform an update on these contact records  
    */
    @future
    public static void updateContactForActiveUsers(Set<Id> activeContactIdSet){
        List<Contact> contList = [SELECT is_DGX_Contact__c, is_GRID_Contact__c 
                                  FROM Contact 
                                  WHERE Id IN :activeContactIdSet 
                                    AND (is_DGX_Contact__c = true OR is_GRID_Contact__c = true)];
        if(!contList.isEmpty()){
            for(Contact cont : contList){
                if(cont.is_DGX_Contact__c){
                    cont.Synced_IDM_DGX__c = false;
                    cont.IDM_DGX_Callout_Message__c = '';
                }
                if(cont.is_GRID_Contact__c){
                    cont.Synced_IDM_Grid__c = false;
                    cont.IDM_GRID_Callout_Message__c = '';
                }
            }
            update contList;
        }
    }
   /*
    *   Method to retrieve the 'ESP Community User' profile information
    */
    public static Profile getESPCommunityProfile(){
        Profile p = [SELECT id FROM profile WHERE name=: Label.Profile_for_DGX_Registration];
        return p;
    }
    
    //*PJENA				| 2.0		 | 5/27/2018	   | ESP For NPN Partners
    /*
    	Method to return Profiles that are allowed to access Service Cloud Community
    */
    public static set<Id> getESPCommunityProfiles(){
    	string ESP_Allowed_Profiles = Label.ESP_Profiles;
	    system.debug('***ESP_Allowed_Profiles Names From Custom Label: ' + ESP_Allowed_Profiles);
	    list<string> lstESPAllowedProfileNames = ESP_Allowed_Profiles.split(';');
	    list<string> lstESPAllowedProfileNamesAfterTrim = new list<string>();
	    for (string s : lstESPAllowedProfileNames){
	      string strProfName = s.trim();
	      lstESPAllowedProfileNamesAfterTrim.add(strProfName);
	    }
    	system.debug('***lstESPAllowedProfileNamesAfterTrim: ' + lstESPAllowedProfileNamesAfterTrim);
        map<Id, Profile> mapESPAllowedProfiles = new map<Id, Profile>([SELECT id, Name FROM profile WHERE Name in : lstESPAllowedProfileNamesAfterTrim]);
        set<Id> setESPAllowedProfileIds = new set<Id>();
        setESPAllowedProfileIds = mapESPAllowedProfiles.keyset();
		return setESPAllowedProfileIds;
    }
}