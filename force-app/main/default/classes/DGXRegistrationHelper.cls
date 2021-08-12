/**************************************************************************************************
* Name       : DGXRegistrationHelper
* Purpose    : Helper class for DGXRegistration Lightning component
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/11/2017      | Initial Draft
*Perficient         | 2.0        | 03/27/2018      | Final Draft
*PJENA              | 2.1        | 04/07/2018      | SN# matchup without leading zeros
*Perficient         | 2.2        | 05/04/2018      | Registration status entries
*AKHILESH GUPTA     | 2.3        | 09/12/2018      | Trim Blank Spaces from SN#
*PJENA              | 2.4        | 02/12/2019      | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
*PJENA              | 2.5        | 03/04/2019      | Licensing 2.0 Changes
*AKHILESH GUPTA     | 3.0        | 11/01/2019      | Licensing 2.0 changes, most of code is move to AddUserHelper and RenewEntitlementHelper.
													 Removed obsolete code, 
													 Moved Createuser code to Test_COMM_Utility class.
													 Removed use of PRFT_DomainLayer class
**************************************************************************************************/
global without sharing class DGXRegistrationHelper { //extends PRFT_DomainLayer{
    ///* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    //Fetch Contact RecordType Id
    public DGXRegistrationHelper() {} 
    /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    static Id contactRTId {
        get{
            if(contactRTId == null){
                contactRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'SalesContact'].Id;
            }
            return contactRTId;
        }
    }
    */
    /**************************************************************************************************
    * Input Parameters: con1 (primary site contact)
    *                   con2 (secondary site contact)
    *                   sNo, sNo1, sNo2 (Entered serial numbers)
    *                   sNo3 (Service Entitlement Number)
    *                   salesOrder (Sales Order Number)
    *                   firstName, lastName, emmail, company, phone (DGX Container Registry Administrator information)
    * Output:   On registration processed successfully return 'SUCCESS'
    *           a) If no entitlement found for any of the serial numbers
    *                   return 'No related Entitlements for the Serial Number were found.'
    *           b) If any one user exists, then the return is a User creation message for the one that did not exist prior to registration
    *           c) if a User exists for the e-mail, but the contact on the user record is not the Contact for the input e-mail, 
    *              then the return message states that a User already exists and could not be created in the system   
    * Purpose:  Implement the DGX Registration submission
    *           Step 1: Collect all the serial numbers and remove all the leading zeroes
    *           Step 2: Retrieve the entitlements for the input serial numbers
    *           Step 3: Identity the first valid serial number (among sNo, sNo1, sNo2) with an entitlement and use the account from that entitlement
    *           Step 4: For valid serial number, prepare for insert/update of contact records and the possible creation of user record. 
    *                   Input e-mail is used to determine if associated contacts and users already exist. 
    *           Step 5: Insert a record into the DGX_Registry_Container__c object for the captured registry admin information
    *           Step 6: Write into the ESP_DGX_Registration_Status__c object, the status of the registration and relevant contact attributes
    *           Step 7: Set the registration status to Failure if an error is recorded. The workflow alert associated with this object will send 
    *                   an internal and external e-mail 
    ***************************************************************************************************/    

/* Function not required: with Lic 2.0 DGX registration will be hosted on RWA    
@AuraEnabled
    public static String submitRegistration(Contact con1, Contact con2, String sNo, String sNo1, String sNo2, String sNo3
                                           , String salesOrder, String firstName, String lastName, String email
                                           , String company, String phone){
    
    String sNoToBeused='';
    String MSG_NOMATCH_ENT = 'No related Entitlements for the Serial Number/PAKID were found.';
    List<Contact> lstContacts = new List<Contact>();
        List<String> lstExistingEmail = new List<String>();
        List<String> lstNewEmail = new List<String>();                                       
    Set<String> emailSet = new Set<String>();
    Map<String,Contact> newcontactMap = new Map<String,Contact>();                                                 
        Map<String, Id> sNoToAccountMap = new Map<String, Id>();
        
        //SN Matchup logic
        //-------------------------------------------------------------------------------------------------------------------------------------------
    //Serial Numbers entered by User   
    list<string> SNsEnteredByUser = new list<string>{sNo,sNo1,sNo2};
    system.debug('***SN#s entered by User during registration: ' + SNsEnteredByUser);
    
        List<Entitlement> lstEntitlements = getEntitlements(SNsEnteredByUser);
        List<String> serialNos = new list<String>();
    
    //Create entitlement Serial Number Vs Account Map
    //PJENA        | 2.4     | 02/08/2019     | Accomodate PAKID based NGC Registrations with SN based DGX Registrations
        for(Entitlement ent: lstEntitlements){
            if(ent.Hardware_Serial_Number__c != null){
              sNoToAccountMap.put(ent.Hardware_Serial_Number__c, ent.AccountId);
              //add the actual SN# found from Entitlement to the User entered SN list so it can be a match up
              serialNos.add(ent.Hardware_Serial_Number__c);
            } else if (ent.PAK_ID__c != null){
              sNoToAccountMap.put(ent.PAK_ID__c, ent.AccountId);
              //add the actual PAKID# found from Entitlement to the User entered PAKID list so it can be a match up
              serialNos.add(ent.PAK_ID__c);
            }
        }
    
    //Identify a Serial Number/PAKID to be used
    for(String sNoItem :serialNos){
            if(sNoItem != null && sNoToAccountMap.get(sNoItem) !=null){
                sNoToBeused = sNoItem;
                break;
            }
        }
        
        system.debug('***SN# Matching > sNoToBeused : ' + sNoToBeused);
        system.debug('***Account Id that is matching with SN# : ' + sNoToAccountMap.get(sNoToBeused));
    //End: SN Matchup logic
        //-------------------------------------------------------------------------------------------------------------------------------------------

    //First user details
    String conString = JSON.serialize(con1);                                               
      Contact primaryContact = (Contact) JSON.deserialize(conString,Contact.class);
    addDGXRegistrationEntry(primaryContact, salesOrder, String.join(SNsEnteredByUser, ','), sNo3);
      system.debug('***Primary Contact > Last Name = ' + primaryContact.LastName + ', EMail = ' + primaryContact.Email);
    
    if(String.isBlank(sNoToBeused) ||lstEntitlements == null || lstEntitlements.size() == 0){
            //No Valid Entitlements are found. Send Error emails and notify User
            updateDGXRegistrationEntry(primaryContact.email, MSG_NOMATCH_ENT);
            String conString2 = JSON.serialize(con2);
      Contact SecContact =  (Contact) JSON.deserialize(conString2,Contact.class);
      system.debug('***Secondary Contact > Last Name = ' + SecContact.LastName + ', EMail = ' + SecContact.Email);
      
            if(SecContact != null && !String.isBlank(SecContact.lastName) && !String.isBlank(SecContact.email)){
                addDGXRegistrationEntry(SecContact, salesOrder, String.join(SNsEnteredByUser, ','), sNo3);
                updateDGXRegistrationEntry(SecContact.email, MSG_NOMATCH_ENT);
            }
            return MSG_NOMATCH_ENT;
        }else{
            try{
                emailSet.add(primaryContact.email);
                newcontactMap.put(primaryContact.email, primaryContact);
                String conString2 = JSON.serialize(con2);
                Contact SecContact =  (Contact) JSON.deserialize(conString2,Contact.class);
                system.debug('***Secondary Contact > Last Name = ' + SecContact.LastName + ', EMail = ' + SecContact.Email);
                
                if(SecContact != null && !String.isBlank(SecContact.lastName) && !String.isBlank(SecContact.email)){
                    emailSet.add(SecContact.email);
                    newcontactMap.put(SecContact.email, SecContact);
                    addDGXRegistrationEntry(SecContact, salesOrder, String.join(SNsEnteredByUser, ','), sNo3);
                }
                
                //Fetch existing users and contacts based on email Id
                Map<String,List<Contact>> contactMap = getExistingContacts(emailSet);
            Map<String,User> userMap = getExistingUsers(emailSet);
                for(String conEmail : emailSet){
                    List<Contact> lstExistingContact = contactMap.get(conEmail);
                    //Check if contact already exists for the entered email
                    Contact exisContact = findExistingContact(contactMap,conEmail, sNoToAccountMap.values());
                    if(exisContact !=null){
                        //If contact exists, check if user exists for the contact email
                        if(!userMap.keySet().contains(conEmail)){
                            //If user does not exist, add contact details to the contact for creation
                            exisContact.Sales_Order_Number__c = salesOrder;
                          exisContact.Service_Entitlement_Number__c = sNo3;
                          exisContact.is_DGX_Contact__c =true;
                          exisContact.RecordTypeId = contactRTId;
                          exisContact.is_Created__c = true;
                            lstContacts.add(exisContact);
                        }else if(userMap.get(conEmail) != null && userMap.get(conEmail).ContactId != null && userMap.get(conEmail).ContactId == exisContact.Id && exisContact.is_DGX_Contact__c == false){
                            exisContact.Sales_Order_Number__c = salesOrder;
                          exisContact.Service_Entitlement_Number__c = sNo3;
                          exisContact.is_DGX_Contact__c =true;
                            lstContacts.add(exisContact);
                        }else{
                            //If user exists, notify about user's existence
                            lstExistingEmail.add(conEmail);
                    }
                    }else{
                        if(userMap.keySet().contains(conEmail)){
                            //If user exists, notify about user's existence
                            lstExistingEmail.add(conEmail);
                        }else{
                            //If contact does not exist, add contact details for creation
                            Contact newCon = newcontactMap.get(conEmail);
                            newCon.Sales_Order_Number__c = salesOrder;
                            newCon.Service_Entitlement_Number__c = sNo3;
                            newCon.is_DGX_Contact__c =true;
                            newCon.accountId = sNoToAccountMap.get(sNoToBeused);
                            newCon.RecordTypeId = contactRTId;
                            newCon.is_Created__c = true;
                            lstContacts.add(newCon);
                        }
                    }
                }
                
                if (!lstContacts.isEmpty()){
                    // Create/Update contact and create users only if necessary
                    processContacts(lstContacts, userMap);
                    for(Contact con:lstContacts){
                        if(con.Id !=null && !userMap.keySet().contains(con.Email)){
                            lstNewEmail.add(con.Email);
                        }
                    }                    
                }

                string strAccountId;
                if(sNoToAccountMap!=null && sNoToBeused!=null && sNoToAccountMap.get(sNoToBeused)!=null)
                    strAccountId = sNoToAccountMap.get(sNoToBeused);
                //Create DGX_Registry_Container__c record if details exist 
                if(firstName !=null || lastName !=null || email!=null || phone !=null || company!=null)
                {
                    DGX_Registry_Container__c DGXContainer = new DGX_Registry_Container__c(FirstName__c =firstName,
                                                                                           Last_Name__c=lastName,
                                                                                           Email_Address__c= email,
                                                                                           Phone_Number__c= phone,
                                                                                           Company_Name__c = company,
                                                                                           Contact__c =primaryContact.Id,
                                                                                           account__c = strAccountId,
                                                                                           Hardware_Serial_Number_PAK_Id__c = sNoToBeused);
                    insert DGXContainer;
                }
                if(lstExistingEmail.size() > 0){
                    //String reStr = 'Exist';//'User for ' +String.join(lstExistingEmail,' and ')+' hasn\'t been created as it exists.';
                    String reStr = 'Exist:Thank you for your registration. It appears '
                              + String.join(lstExistingEmail,' and ')
                              + (lstExistingEmail.size() > 1 ? ' are ': ' is ')
                              + 'already registered as a user.';
                        //+ 'If you would like to open a support case, please use the link above.';
                    for (String em :  lstExistingEmail){
                        updateDGXRegistrationEntry(em, 'User for ' + em + ' hasn\'t been created as it exists.');
                    }
                    if(!lstNewEmail.isEmpty()){
                        reStr +=  ' User for '+String.join(lstNewEmail,',')+' has been created';
                    }
                    return reStr;
                }
            }catch(Exception e){
                System.debug(LOGGINGLEVEL.INFO+'Logged error in Integration Object'+e.getStackTraceString());
                System.debug('get stack trace..'+e.getStackTraceString());
        //Send error emails in case of failure                    
                updateDGXRegistrationEntry(primaryContact.email, e.getStackTraceString());
                PRFT_Error err = new PRFT_Error('DGX Registration Error',e.getStackTraceString(),String.valueof(e),null,true);
                return e.getStackTraceString();
            }
        }
    return 'SUCCESS';
    }
*/
    /**************************************************************************************************
    * Input Parameters: List of user entered serial numbers
    * Output: List of Entitlements
    * Purpose:  Retrieve the entitlements for the input serial numbers 
    
    *PJENA        | 2.4     | 02/12/2019     | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
    
    ***************************************************************************************************/       
/* Function not required: with Lic 2.0 DGX registration will be hosted on RWA    
private static List<Entitlement> getEntitlements(list<String> SNsEnteredByUser){
      
      list<Entitlement> lstEntitlements = new list<Entitlement>();
      
        //Prepare non-leading zeroed SNs
        list<string> lstSNWithNoLeadingZeros = new list<string>();
        
        //Non-Null SNs and Matchup at least with 9 right most characters
        List<String> serialNos = new list<string>();
        for (string sn : SNsEnteredByUser){
            if (string.isNotBlank(sn)){
              sn = sn.trim();
                serialNos.add(sn);
                string SNWithNoLeadingZeroes = removeLeadingZeroes(sn);
                if (string.isNotBlank(SNWithNoLeadingZeroes) && SNWithNoLeadingZeroes.length() >= 9){
                    lstSNWithNoLeadingZeros.add(SNWithNoLeadingZeroes);
                }
            }
        }
        system.debug('***SN#s (NON-Blank) entered by User during registration: var serialNos = ' + serialNos);
        system.debug('***SN#s with Non-Leading Zeroes And more than 9 Char Long: var lstSNWithNoLeadingZeros = ' + lstSNWithNoLeadingZeros);
        
        string strEntitlementsQry = 'SELECT Id, Name, AccountId, Hardware_Serial_Number__c, Status FROM Entitlement Where ';
        string strSNLikeClause = '';
        if (!lstSNWithNoLeadingZeros.isEmpty()){
            for (integer i = 0; i < lstSNWithNoLeadingZeros.size(); i++){
                if (i == 0) strSNLikeClause += ' ( Hardware_Serial_Number__c like \'%' + lstSNWithNoLeadingZeros[i] + '\' ';  
                else strSNLikeClause += ' OR Hardware_Serial_Number__c like \'%' + lstSNWithNoLeadingZeros[i] + '\'';  
            }
            strSNLikeClause += ' ) AND ';
        } else{
            strSNLikeClause += ' Hardware_Serial_Number__c = \'INVALIDNVSN\' AND '; //invalidate if the user sends 0s only
        }
        strEntitlementsQry += strSNLikeClause + ' Status =\'Active\'';
        
        system.debug('***strEntitlementsQry for SN# matchup : ' + strEntitlementsQry);
        
        //Query the Entitlements with SN# matchup
        lstEntitlements = Database.query(strEntitlementsQry);
        
        //If the SN# matchup returns no Entitlements then assume user has input PAKIds
        if (lstEntitlements.isEmpty()){
          string strEntitlementsQryWithPAKID = 'SELECT Id, Name, AccountId, Hardware_Serial_Number__c, PAK_ID__c, Status FROM Entitlement Where ';
          string strPAKIDLikeClause = '';
          
          if (!lstSNWithNoLeadingZeros.isEmpty()){
              for (integer i = 0; i < lstSNWithNoLeadingZeros.size(); i++){
                  if (i == 0) strPAKIDLikeClause += ' ( PAK_ID__c like \'%' + lstSNWithNoLeadingZeros[i] + '\' ';  
                  else strPAKIDLikeClause += ' OR PAK_ID__c like \'%' + lstSNWithNoLeadingZeros[i] + '\'';  
              }
              strPAKIDLikeClause += ' ) AND ';
          } else{
              strPAKIDLikeClause += ' PAK_ID__c = \'INVALIDNVSN\' AND '; //invalidate if the user sends 0s only
          }
          strEntitlementsQryWithPAKID += strPAKIDLikeClause + ' Status =\'Active\'';
          
          system.debug('***strEntitlementsQry for PAKID# matchup : ' + strEntitlementsQryWithPAKID);
          
          //Query the Entitlements with SN# matchup
          lstEntitlements = Database.query(strEntitlementsQryWithPAKID);
        }
        
        //Fetch entitlements based on serial number
        return lstEntitlements; //return Database.query(strEntitlementsQry);
    }
    */
    
    /**************************************************************************************************
    * Input Parameters: List of contacts to insert/update, a user map of existing users with e-mail as the key
    * Output: None
    * Purpose: Insert/Update contacts. Create User record asynchronously if one does not exist 
    ***************************************************************************************************/ 
/* Function not required: with Lic 2.0 DGX registration will be hosted on RWA    
public static void processContacts(List<Contact> lstContacts, Map<String,User> userMap){
        //Create/update contacts
        List<Database.UpsertResult> lstUpdateResult = Database.upsert(lstContacts, false);
        handleErrors(lstUpdateResult);   
        
        //Create contactList for whom users need to be created
        List<Id> lstId = new List<Id>();
        for(Contact con:lstContacts){
            if(con.Id !=null && !userMap.keySet().contains(con.Email)){
                lstId.add(con.Id);
                updateDGXRegistrationEntry(con);
            }
        }

        //Call future method to create users
        if(lstId.size() > 0){
            DGXRegistrationHelper.createUser(lstId);
        }
    }
*/
    /**************************************************************************************************
    * Input Parameters: List of contact record Ids
    * Output: None
    * Purpose: Create User record(s) asynchronously for the corresponding Contact records
    * PJENA - Licensing 2.0 Changes - Should be removed from this class but it is referenced from many test classes
    ***************************************************************************************************/ 
 /* Function not required: Need to move it to Test Classes   
@future (callout=true)
    public static void createUser(List<Id> lstContactIds){
        //Fetching Contacts from Id's
        List<Contact> lstContact = [SELECT Id, firstName, lastName, email, CompanyName__c, Phone FROM Contact WHERE Id =:lstContactIds];
        List<User> lstUser = new List<User>();
        try{
            Set<String> lstEmailIds = new Set<String>();
            for(Contact con:lstContact){
                if(con.email !=null){
                    lstEmailIds.add(con.email);
                }
            }
            String ProfileId = [SELECT Id FROM Profile WHERE Name =:System.Label.Profile_for_DGX_Registration].Id;
            List<User> lstExistingUsers = [SELECT Id, UserName, Email, isActive FROM User WHERE UserName =:lstEmailIds];
            
            for(Contact con :lstContact){
                //Creating alias names
                boolean userAlreadyExists = false; 
                for(User user:lstExistingUsers){
                    if(con.email.equals(user.UserName))
                        userAlreadyExists= true;
                }
                if(!userAlreadyExists){
                    String alias ='';
                    if(con.firstName != null && con.firstName.length()>0){
                        alias =''+con.FirstName.substring(0,1);
                        if(con.LastName.length()>4)
                            alias = alias+con.LastName.substring(con.LastName.length()-4);
                    }                    
                    else if(con.lastName.length()>4)
                        alias = con.LastName.substring(con.LastName.length()-5);
                    User user = new User(
                        ProfileId = ProfileId,
                        contactId = con.Id,
                        FirstName = con.firstName,
                        LastName = con.lastName,
                        Email = con.email,
                        Username = con.email,
                        CompanyName = con.CompanyName__c,
                        Phone = con.Phone,
                        Alias = alias,
                        is_Created__c = true,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US'
                    );    
                    lstUser.add(user);    
                }
            }
            //Creating Users
            insert lstUser;

        }catch(Exception e){
            System.debug(LOGGINGLEVEL.INFO+' Logged error in DGX Registration'+e.getStackTraceString());
            System.debug('get stack trace..'+e.getStackTraceString());
            updateDGXRegistrationEntry(lstContact[0].email, e.getStackTraceString());
            if(lstContact.size() ==2){
                updateDGXRegistrationEntry(lstContact[1].email, e.getStackTraceString());    
            }
            PRFT_Error err = new PRFT_Error('DGX Registration User Creation Error',e.getStackTraceString(),String.valueof(e),null,true);
        }           
    }
    */
    /*
     * Check for user creation
     */
/* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    @AuraEnabled
    public static String checkUserCreation(String email1 , String email2){
        String[] uNames = new String[]{email1};
        if(email2 != null && email2.length() >0)
          uNames.add(email2);
        List<User> lstUsers = [SELECT Id, UserName FROM User WHERE UserName =:uNames];
        if(uNames.size() == lstUsers.size())
            return 'SUCCESS';
        return 'ERROR';
    }
*/
  /*
     * Get countries from Country_List__c object
     */
/* Function not required: Moved to AdduserHelper
  @AuraEnabled
    public static Map<String,String> getCountries(){
        List<Country_List__c> countriesDb = new List<Country_List__c>([SELECT Id, Name, ISO_Code__c FROM Country_List__c ORDER BY Name ASC]);
        Map<String,String> countries = new Map<String,String>();
        countries.put( '','');
        countries.put( 'United States', 'US');
        countries.put( 'United Kingdom', 'GB');
        for(Country_List__c c : countriesDb){
             countries.put(c.Name, c.ISO_Code__c );
        }
        return countries; 
    } 
*/  
  /*
     * Get states from State_List__c object
     */
/* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
  @AuraEnabled
    public static Map<String,String> getStates(){
        List<State_List__c> statesDb = new List<State_List__c>([SELECT Id, Name, Country__r.Name FROM State_List__c ORDER BY Name ASC]);
        Map<String,String> states = new Map<String,String>();
        for(State_List__c s : statesDb){
             states.put(s.Name, s.Country__r.Name);
        }
        return states;
    }
    */
    
    /*
     * Perform checks before sending onboarding email
     * PJENA                | 2.4        | 02/12/2019      | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
     * PJENA                | 2.5        | 03/04/2019      | Licensing 2.0 Changes
     */
     /*Moved code to renewEntitlementHelper class.
    @AuraEnabled
    public static String sendRegistrationMail(String email, String hostName, String prodFamilySelected){
        String URL = System.Label.ServiceCloud_UserRegistrationURL;
        String sNo ='';
        boolean noActiveEntitlement = false;
        User usr = [SELECT id, ContactId FROM User WHERE Id=:UserInfo.getUserId()][0];
        
        
        if(usr.ContactId !=null){
            Contact con = [SELECT Id, AccountId FROM Contact WHERE Id=:usr.ContactId][0];
            
            if(con !=null && con.AccountId !=null){
                
                /*
                //Check if an entitlement exists for the contact's account
                List<Entitlement> lstEntitlements =[SELECT Id, Name, AccountId, Hardware_Serial_Number__c, PAK_ID__c, Status 
                                  FROM Entitlement
                                                    WHERE AccountId=:con.AccountId AND Status ='Active' 
                                                      AND (Hardware_Serial_Number__c != null OR Subscription__r.SBQQ__Product__r.Family  = :System.Label.ServiceCloud_PAKIdProdFamilyForDGXFlow)];
                /*
                
                string PAKIdProdFamilyForDGXFlow = System.Label.ServiceCloud_PAKIdProdFamilyForDGXFlow;
                system.debug('***PAKIdProdFamilyForDGXFlow Expected structure - (\'NGC Support\', \'DSWS Support\') and actual value is '  + PAKIdProdFamilyForDGXFlow);
                
                string addUserEntQuery = 'SELECT Hardware_Serial_Number__c, PAK_ID__c FROM Entitlement WHERE AccountId = \''  + con.AccountId + '\' AND Status = \'Active\' ';
                if ( prodFamilySelected == 'DGX') {
                    addUserEntQuery = addUserEntQuery + ' AND (Hardware_Serial_Number__c != null ';
                    if ( string.isNotBlank(PAKIdProdFamilyForDGXFlow) )  addUserEntQuery = addUserEntQuery + ' OR Subscription__r.SBQQ__Product__r.Family in ' + PAKIdProdFamilyForDGXFlow ;
                    addUserEntQuery += ' ) ORDER BY Hardware_Serial_Number__c NULLS LAST';
                } else { //GRID use case
                    addUserEntQuery = addUserEntQuery + ' AND Hardware_Serial_Number__c = null ';
                }
                
                system.debug('***addUserEntQuery : ' + addUserEntQuery);
                
                //Query the Entitlements
                list<Entitlement> lstEntitlements = database.query(addUserEntQuery);
                
                
                if(lstEntitlements != null && lstEntitlements.size() > 0){
                    for (Entitlement oEntitlement : lstEntitlements){
                        if (oEntitlement.Hardware_Serial_Number__c != null || oEntitlement.PAK_ID__c != null ){
                            //sNo = oEntitlement.Hardware_Serial_Number__c != null ? oEntitlement.Hardware_Serial_Number__c : oEntitlement.PAK_ID__c;
                            //* PJENA               | 2.5        | 03/04/2019      | Licensing 2.0 Changes - send PAK ID (no SN#)
                            sNo = oEntitlement.PAK_ID__c;
                            if(sendonBoardingMail(email, hostName, sNo, URL, prodFamilySelected) == 'SUCCESS'){
                                return 'SUCCESS';    
                            }
                        }
                    }
                }
            }
        }
        return 'ERROR';
    } */
    
    /*
     * Send onboarding email
     * Inserts the Notification record into Service_Cloud_New_Member_Notification__c object
     * WF Rule "Service Clould: Notification to New Member" sends the notification with Email Alert named "ServiceCloud: Notification to New DGX Member"
     *  uses email alert "ServiceCloud: Notification to New DGX Member" and that uses email template "ESP Service Cloud: New DGX Member"
     * Change List: PJENA               | 2.4        | 02/12/2019      | Accommodate NGC Registrations (PAKID) with DGX Registration (SN#) Flow
     */
    /*Moved code to renewEntitlementHelper class.
    public static String sendonBoardingMail(String email, String hostName, String sNo, String URL, string prodFamilySelected){
        Service_Cloud_New_Member_Notification__c notif = new Service_Cloud_New_Member_Notification__c();
        User usr = [SELECT ContactId, Contact.AccountId, Contact.FirstName, Contact.LastName FROM User WHERE Id = :UserInfo.getUserId()];
        notif.Account__c = usr.Contact.AccountId;
        
        //build the link
        String link = URL + '?LicType=COMMERCIAL' + '&ProductFamily=' + prodFamilySelected  + '&PEC=' + usr.Contact.AccountId +  '&email=' + email  + '&PAKID=' + sNo + '&addUser=1';
        
        notif.Link__c = link;
        notif.Email__c = email;
        insert notif;
        
        return 'SUCCESS';        
    } 
    */
 
    /*
     * Fetch logger in UserName
     */
     /* No more used by DGXRegistration Page
    @AuraEnabled
    public static String getUserName() {
        return userinfo.getName();
    }
    */
    /*
     * Fetch UserType of logged in User
     * UserType values: DGX | GRID | GRID,DGX
     */
/* Function not required: Moved to AddUserHelper 
    @AuraEnabled
    public static String UserType(){
        system.debug('Inside getUserType');
        String userType ='';
        try{
            User usr = [SELECT id, ContactId FROM User WHERE Id=:UserInfo.getUserId()];
            if(usr.ContactId ==null)
                return 'ERROR';
            Contact con = [SELECT Id, is_DGX_Contact__c, is_GRID_Contact__c FROM Contact WHERE Id=:usr.ContactId];
            if(con.is_GRID_Contact__c){
                userType ='GRID';
            }
            if(con.is_DGX_Contact__c){
                userType=userType+',DGX';
            }
            system.debug('userType-->'+userType);
        }catch(Exception e){
            System.debug(LOGGINGLEVEL.INFO+'Logged error in User/Contact Object'+e.getStackTraceString());
            System.debug('get stack trace..'+e.getStackTraceString());
            PRFT_Error err = new PRFT_Error('Add second User getuserType Error',e.getStackTraceString(),String.valueof(e),null,true);
        }
        return userType;
    }
*/  
    /*
     * Renew entitlement for given entitlement Id
     */
/* Function not required: Moved to RenewEntitlementHelper 
    @AuraEnabled
    public static String RenewEntitlement(String Id){
        system.debug('id-->'+id);
        //Fetch Parent entitlement
        Entitlement__c ent = [SELECT Id, Entitlement__c FROM Entitlement__c WHERE Id =:id];
        if(ent != null && ent.Entitlement__c !=null){
            //Update Parent entitlement renewal flag
            Entitlement parentEnt = new Entitlement(id =ent.Entitlement__c, Renew_Entitlement__c = true);
            update parentEnt;    
        }else{
            return 'ERROR';
        }
        return 'SUCCESS';
    }
  */
    /*
     * Using email address to find existing Contacts, we only check specific Record Type: SalesContact.
     */
     /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    static Map<String,List<Contact>> getExistingContacts(Set<String> emailSet){
        Map<String,List<Contact>> emailContactMap = new Map<String,List<Contact>>();
        for(Contact cont : [SELECT AccountId, Email, firstName, lastName, CompanyName__c, Phone, is_DGX_Contact__c
                            FROM Contact WHERE Email IN :emailSet AND RecordTypeId = :contactRTId]){
            if(!emailContactMap.containsKey(cont.Email)){
                emailContactMap.put(cont.Email, new List<Contact>());
            }
            emailContactMap.get(cont.Email).add(cont);
        }
        return emailContactMap;
    }
    */
  /*
     * Fetch users based on given email addresses
     */
     /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    static Map<String,User> getExistingUsers(Set<String> emailSet){
        Map<String,User> userMap = new Map<String,User>();
        for(User u : [SELECT UserName, Profile.Name, ContactId FROM User WHERE UserName IN : emailSet]){
            userMap.put(u.UserName, u);
        }
        return userMap;
    }
    */
    /*
     * Using email address to find existing Contacts in contactMap related to the accounts
     */
    
    /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    static Contact findExistingContact(Map<String,List<Contact>> contactMap, String sEmail, List<Id> acctIds){
        //Found Contact 
        if(contactMap.containsKey(sEmail)){
            List<Contact> contList = contactMap.get(sEmail);
            for(Contact cont: contList){
                for(Id acctId : acctIds){
                    if(cont.AccountId == acctId){
                        return cont;
                    }    
                }
            }
        }
        return null;
    }
    */
    
    /*
     * Save errors in Service_Cloud_Error_Log__c
     */
     /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    static void handleErrors(List<Database.UpsertResult> lstUpdate){
        List<Service_Cloud_Error_Log__c> lstErrors = new List<Service_Cloud_Error_Log__c>();
        for(Integer j = 0; j < lstUpdate.size(); j++) {
            Database.UpsertResult sr = lstUpdate[j];
            if (!sr.isSuccess()) {                
                string errorDetails = 'User Id erred = ' + lstUpdate[j].Id + ' |err.getFields() =' + sr.getErrors()[0].getFields() + ' | err.getStatusCode() = ' + sr.getErrors()[0].getStatusCode() + ' | err.getMessage() = ' +sr.getErrors()[0].getMessage();
                System.debug('***errorDetails: ' + errorDetails);
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.allowFieldTruncation = true;
                String recordUrl=   System.Url.getSalesforceBaseURL().toExternalForm() +'/'+ lstUpdate[j].Id;
                Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(Functionality_Name__c = 'Contact Upsert in DGXRegistration Page', Error_Description__c = errorDetails, Record_URL__c = recordURL, Error_Type__c = 'SALESFORCE BATCH');
                errorLog.setOptions(dml);
                lstErrors.add(errorLog);                
            }
        }
        if(!lstErrors.isEmpty()){
            Database.insert(lstErrors,false);
        }
    }
    */
    //2018.04.17 - PJENA - Helper class to get SN without nonleading zeroes
    /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
  public static string removeLeadingZeroes(string SN){
    string SNWithNonLeadingZeroes = null;
    if (string.isBlank(SN)){
      //
    } else{
      boolean keepChecking = true;
      while (keepChecking){
        if (SN.startsWith('0') && SN.length() > 1 ){
          SN = SN.substring(1);//drop first character as it contains zero
        }else{
          keepChecking = false;
        }
      }
      SNWithNonLeadingZeroes = SN;
    }
    if ( string.isBlank(SNWithNonLeadingZeroes) || SNWithNonLeadingZeroes == '0'){
      return null;
    } else{
      return SNWithNonLeadingZeroes;
    }
  }
*/
    /*
     * Create ESP_DGX_Registration_Status__c record with input data
     */
     /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    public static ESP_DGX_Registration_Status__c addDGXRegistrationEntry(Contact con, String soNumber, String sNo, String serviceEntNo){
  
        ESP_DGX_Registration_Status__c regStatus = new ESP_DGX_Registration_Status__c();
        regStatus.First_Name__c = con.FirstName;
        regStatus.Last_Name__c = con.LastName;
        regStatus.Email__c = con.Email;
        regStatus.Company_Name__c = con.CompanyName__c;
        regStatus.Phone_Number__c = con.Phone;
    regStatus.Street1__c = con.Mailingstreet;
        regStatus.Street2__c = con.Mailing_Street_2__c;
        regStatus.City__c = con.Mailingcity;
        regStatus.State__c = con.MailingState;
        regStatus.Country__c = con.IDM_CountryCode__c;
        regStatus.Postal_Code__c = con.MailingPostalCode;
        regStatus.Serial_Number__c = sNo;
        regStatus.Sales_Order_Number__c = soNumber;
        regStatus.Service_Entitlement_Number__c = serviceEntNo;
        insert regStatus;
        return regStatus;
    }
    */
    /*
     * Update ESP_DGX_Registration_Status__c record with Contact reference
     */
     /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    static void updateDGXRegistrationEntry(Contact con){
        if(con !=null && con.Email !=null ){
            String email = con.Email;
            ESP_DGX_Registration_Status__c regStatus =[SELECT Id, Email__c FROM ESP_DGX_Registration_Status__c WHERE Email__c = :email ORDER By Lastmodifieddate DESC][0];
            regStatus.Created_Contact__c = con.Id;
            regStatus.Registration_Status__c = 'Success';
            update regStatus;    
        }
    }
    */
    /*
     * Update ESP_DGX_Registration_Status__c record with error message
     *  PJENA - Licensing 2.0 Changes - remove it when CreateUser class is removed
     */
     /* Function not required: with Lic 2.0 DGX registration will be hosted on RWA
    static void updateDGXRegistrationEntry(String email, String msg){
        ESP_DGX_Registration_Status__c regStatus =[SELECT Id, Email__c FROM ESP_DGX_Registration_Status__c WHERE Email__c = :email ORDER By Lastmodifieddate DESC][0];
        if(msg.length() > 255){
            msg =msg.left(255);
        }
        regStatus.Error_Message__c = msg;
        regStatus.Registration_Status__c = 'Failure';
        update regStatus;
    }
    */
}