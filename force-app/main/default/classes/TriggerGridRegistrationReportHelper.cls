/**************************************************************************************************
* Name       : TriggerGridRegistrationReportHelper
* Purpose    : Helper class for TriggerGridRegistrationReport Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/19/2017      | Final Draft
*Perficient         | 2.0        | 1/31/2018       | Remove External id, using logic to avoiding duplication.
*Perficient         | 3.0        | 2/12/2018       | Change to using Renewed_PAK_ID__c field instead of PAK_ID__c in Entitlement.
*Perficient         | 4.0        | 2/20/2018       | Add Contact RecordT ype.
*Perficient         | 5.0        | 3/19/2018       | Updated getExistingContacts method. 
*                                                    When searching for existing Contact should also involving recordType.

*NVIDIA|PJENA		| 6.0		 | 4/13/2018       | Big fix for failure cases, remove address update during update of contacts
*NVIDIA|PJENA		| 6.0		 | 4/14/2018       | Updated the failure error email subject and template
*NVIDIA|AkhileshG   | 7.0        | 8/01/2018       | Change to use PAK_ID instead of Renewed PAK ID.
**************************************************************************************************/
public class TriggerGridRegistrationReportHelper {
   /*
    *   Get and Set the Contact 'Sales Contact' record type on the local variable caseRTIdSet
    */    
    static Id contactRTId {
        get{
            if(contactRTId == null){
                contactRTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'SalesContact'].Id;
            }
            return contactRTId;
        }
    }
   /*
    *   A common method to collect all the error records (Service_Cloud_Error_Log__c) 
    *   Input to this method are
    *   - lstErrors (current collection of error records)
    *   - errorDetails (Error details for the new error record (i.e. Service_Cloud_Error_Log__c))
    *   - errorType (Error type for the new error record (i.e. Service_Cloud_Error_Log__c))
    *   - recordURL (Record UL for the new error record (i.e. Service_Cloud_Error_Log__c)))
    *   Method will add a new error record to the existing collection of error records namely lstErrors
    */    
    static void reportError(list<Service_Cloud_Error_Log__c> lstErrors,String errorDetails, String errorType,String recordURL){
        Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(  
                                Functionality_Name__c = 'TriggerGridRegistrationReportHelper', 
                                Error_Description__c = errorDetails,  
                                Record_URL__c = recordURL,
                                Error_Type__c = errorType);
        lstErrors.add(errorLog);
    }
   /*
    *   This method takes in the following input parameters
    *   contactMap - A map collection with email as the key and the value as a list of contact records that share the same eamil address
    *   sEmail - Email of the contact record to find within the Contact record collection
    *   acctId - Account to which the contact record must belong, an additional criteria used to match up on the target contact record
    *   A contact record is returned upon finding a match on e-mail and the account 
    */
    static Contact findExistingContact(Map<String,List<Contact>> contactMap, String sEmail, Id acctId){
        //Found Contact 
        if(contactMap.containsKey(sEmail)){
            List<Contact> contList = contactMap.get(sEmail);
            for(Contact cont: contList){
                if(cont.AccountId == acctId){
                    return cont;
                }
            }
        }
        return null;
    }
   /*
    *   This is the main method invoked by the TriggerGridRegistrationReport trigger
    *   This method is invoked/fired on Before Insert trigger event 
    *   Input to this method are as follows
    *   lstGrids - A Collection (List) of Grid_Registration_Report__c records
    *   Purpose of this main operation
    *   - Read the individual input Grid_Registration_Report__c records
    *   - Establish if an existing contact exists for the Grid_Registration_Report__c record
    *       - Criteria to determine an existing contact is
    *           a) Input e-mail on the Grid_Registration_Report__c record
    *           b) Use the PAK Activation Id on the Grid_Registration_Report__c record to match up on an entitlement record
    *              And use the Account from the entitlement as the other factor for determining an existing contact record
    *   - Collect all the existing contact and new contacts to be updated in the Contact object
    *   - Issue an upsert DML statement for persisting Contacts
    *   - Invoke the Create User operation asynchronously to insert associated contacts
    *
    */
    public static void GridInsertUpdates(List<Grid_Registration_Report__c> lstGrids, Map<Id,Grid_Registration_Report__c> gridMap){
        List<Contact> lstContact = new List<Contact>();
        Map<String, Id> sNoToAccountMap = getSNoAcctIdMapping(lstGrids);
        Set<String> emailSet = getEmailSet(lstGrids);
        Map<String,List<Contact>> contactMap = getExistingContacts(emailSet);
        Map<String,User> userMap = getExistingUsers(emailSet);
        list<Service_Cloud_Error_Log__c> lstErrors = new  list<Service_Cloud_Error_Log__c>();
        //if email+accountid in same load, that is duplicate, will discard second one.
        Set<String> uniqueIdForCurrentLoad = new Set<String>();

        for(Grid_Registration_Report__c grid :lstGrids){
            if(!sNoToAccountMap.keySet().contains(grid.Pak_Id__c)){
                //report error
                reportError(lstErrors, 'Account not found','Data issue','');
            }else{
                Id acctId = sNoToAccountMap.get(grid.Pak_Id__c);
                String sEmail = grid.Email_Address__c;
                String uniqueId = grid.Email_Address__c;
                if(uniqueIdForCurrentLoad.contains(uniqueId)){
                    reportError(lstErrors, 'Duplicate data in same load, Pak_Id__c:' + grid.Pak_Id__c + ', AccountId: ' + sNoToAccountMap.get(grid.Pak_Id__c) + ', Email: ' + grid.Email_Address__c,'Data issue','');
                    continue;
                }else{
                    uniqueIdForCurrentLoad.add(uniqueId);
                }
                Contact foundContact = findExistingContact(contactMap, sEmail, acctId);
                //Found Contact 
                if(foundContact != null){
                    //check user
                    if(userMap.containsKey(sEmail)){
                        User usr = userMap.get(sEmail);
                        if(usr.ContactId == foundContact.Id){
                            //existing one,update Contact
                            updateContact(foundContact,grid);
                            lstContact.add(foundContact);
                        }else{
                            //report error
                            reportError(lstErrors, 'User already exists but without Contact','Data issue','');
                        }
                    }else{
                        //update contact, create new user
                        updateContact(foundContact,grid);
                        lstContact.add(foundContact);
                    }
                }else{
                    //Contact not found, check user
                    if(!userMap.containsKey(sEmail)){
                        //user does not exist, great, create new Contact
                        Contact con = newContact(grid,sNoToAccountMap);
                        lstContact.add(con);
                    }else{
                        //report error
                        reportError(lstErrors, 'User already exists but without Contact','Data issue','');
                    }
                }
            }
        }

        //Schema.SObjectField f = Contact.Fields.IDM_ExternalId__c;        
        List<Database.UpsertResult> lstUpdateResult = Database.upsert(lstContact,false);
        handleErrors(lstUpdateResult, lstErrors);        

        system.debug('lstContacts-->'+lstContact.size());
        List<Id> lstId = new List<Id>();
        for(Contact con:lstContact){
            if(con.Id !=null)
                lstId.add(con.Id);
        }

        System.debug('***Calling future method');
        if(lstId.size() > 0){
        	system.debug('***Contact Ids > lstId: ' + lstId);
        	//Commented the code a the method DGXRegistrationHelper.Createuser fails as a batch
            //DGXRegistrationHelper.Createuser(lstId);
            system.debug('***Begin: Calling Createuser');
            CreateUser(lstId);
            system.debug('***End: Calling Createuser');
        }
    }
   /*
    *   In this method a new Contact record is created using the information from the 'Grid Registration Report' record.
    *   Contact attributes set from the 'Grid Registration Report' record are as follows:
    *   - First Name
    *   - Last Name
    *   - Email
    *   - is_GRID_Contact__c - Is the Contact a Grid registered contact? Set to true
    *   - is_Created__c - Is the Contact created successfully? Set to true
    *   - Account Identifier
    *   - Mailing Address, Postal Code, Phone etc.
    *   - Contact record type (set as Sales Contact record type) 
    */
    static Contact newContact(Grid_Registration_Report__c grid, Map<String, Id> sNoToAccountMap){
        Contact con = new Contact();
        con.firstName = grid.FirstName__c;
        con.lastName = grid.Last_Name__c;
        con.Email = grid.Email_Address__c;
        con.is_Created__c = true;
        con.MailingStreet = grid.Street1__c;
        con.Mailing_Street_2__c = grid.Street2__c;
        con.MailingCity = grid.City__c;
        con.MailingState = grid.State__c;        
        con.MailingCountry = grid.Country__c;
        con.MailingPostalCode = grid.Postal_Code__c;
        con.Phone = grid.Phone__c;
        //con.IDM_ExternalId__c = sNoToAccountMap.get(grid.Pak_Id__c)+'-'+grid.Email_Address__c;
        con.AccountId = sNoToAccountMap.get(grid.Pak_Id__c);
        con.is_GRID_Contact__c =true;
        con.RecordTypeId = contactRTId;
        return con;
    }
   /*
    *   In this method specific attributes on the Contact record are updated from the 'Grid Registration Report' record.
    *   Updated Contact attributes are
    *   - First Name
    *   - Last Name
    *   - is_GRID_Contact__c - Is the Contact a Grid registered contact? Set to true
    *   - is_Created__c - Is the Contact created successfully? Set to true
    */
    static void updateContact(Contact foundContact, Grid_Registration_Report__c grid){
        foundContact.is_GRID_Contact__c =true;
        foundContact.firstName = grid.FirstName__c;
        foundContact.lastName = grid.Last_Name__c;
        foundContact.is_Created__c = true;
        //NVIDIA|PJENA		| 6.0		 | 4/13/2018       | Big fix for failure cases, remove address update during update of contacts
        //foundContact.MailingStreet = grid.Street1__c;
        //foundContact.Mailing_Street_2__c = grid.Street2__c;
        //foundContact.MailingCity = grid.City__c;
        //foundContact.MailingState = grid.State__c;        
        //foundContact.MailingCountry = grid.Country__c;
        //foundContact.MailingPostalCode = grid.Postal_Code__c;
        //foundContact.Phone = grid.Phone__c;
    }
   /*
    *   This method prepares a Map collection of 'PAK Activation Id' to Account Id
    *   Input to this operation is a collection of Grid_Registration_Report__c records
    *   Each Grid Report Registration record has a reference to the PAK Activation Identifier
    *   Using the collection PAK Activation Identifiers
    *   - Entitlement records are queried/filtered based on PAK Activation Id. 
    *   - Field Renewed_PAK_ID__c on the Entitlement object is used as the filter
    *   - And the entitlements must also be active in the system
    *   - Resulting entitlement records are associated to a customer account
    *   - A new collection is prepared where in each PAK Activation Id is mapped to the Account Id (from the Entitlement rec)
    *   - Finally the collection of PAK Activation Id to Account Id is return to the caller
    */
    static Map<String, Id> getSNoAcctIdMapping(List<Grid_Registration_Report__c> lstGrids){
        List<String> lstPakIds = new List<String>();
        for(Grid_Registration_Report__c grid :lstGrids){
            lstPakIds.add(grid.Pak_Id__c);
        }
        List<Entitlement> lstEntitlements =[SELECT Id, Name, AccountId, PAK_ID__c, Status FROM Entitlement
                                           	WHERE PAK_ID__c =:lstPakIds AND Status ='Active'];
        system.debug('lstEntitlements-->'+lstEntitlements);
        Map<String, Id> sNoToAccountMap = new Map<String, Id>();  
        if(lstEntitlements !=null && lstEntitlements.size() >0){
            for(Entitlement ent: lstEntitlements){
                if(ent.PAK_ID__c != null)
                    sNoToAccountMap.put(ent.PAK_ID__c, ent.AccountId);
            }    
        }
        system.debug('sNoToAccountMap-->'+sNoToAccountMap);
        return sNoToAccountMap;
    }
   /*
    *   Walkthrough the Grid_Registration_Report__c records to extract a unique Collection (set) of email addresses
    */
    static Set<String> getEmailSet(List<Grid_Registration_Report__c> lstGrids){
        Set<String> emailSet = new Set<String>();
        for(Grid_Registration_Report__c grid :lstGrids){
            emailSet.add(grid.Email_Address__c);
        }
        return emailSet;
    }
   /*
    *   Purpose of this method is to find existing contacts records for the input collection of email addresses
    *   Contact records used in this operation are of record type 'Sales Contact'
    */
    static Map<String,List<Contact>> getExistingContacts(Set<String> emailSet){
        Map<String,List<Contact>> emailContactMap = new Map<String,List<Contact>>();
        for(Contact cont : [SELECT AccountId, Email FROM Contact WHERE Email IN :emailSet AND RecordTypeId = :contactRTId]){
            if(!emailContactMap.containsKey(cont.Email)){
                emailContactMap.put(cont.Email, new List<Contact>());
            }
            emailContactMap.get(cont.Email).add(cont);
        }
        return emailContactMap;
    }
   /*
    *   Purpose of this method is to find existing User records for the input collection of email addresses
    */
    static Map<String,User> getExistingUsers(Set<String> emailSet){
        Map<String,User> userMap = new Map<String,User>();
        for(User u : [SELECT UserName, Profile.Name, ContactId FROM User WHERE UserName IN : emailSet]){
            userMap.put(u.UserName, u);
        }
        return userMap;
    }
   /*
    *   Retrieve the error details from the Database UpsertResult collection object
    *   Write the errors to the Service_Cloud_Error_Log__c object
    */
    static void handleErrors(List<Database.UpsertResult> lstUpdate,list<Service_Cloud_Error_Log__c> lstErrors){
        for(Integer j = 0; j < lstUpdate.size(); j++) {
            Database.UpsertResult sr = lstUpdate[j];
            if (!sr.isSuccess()) {                
                string errorDetails = 'User Id erred = ' + lstUpdate[j].Id + ' |err.getFields() =' + sr.getErrors()[0].getFields() + ' | err.getStatusCode() = ' + sr.getErrors()[0].getStatusCode() + ' | err.getMessage() = ' +sr.getErrors()[0].getMessage();
                System.debug('***errorDetails: ' + errorDetails);
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.allowFieldTruncation = true;
                String recordUrl=   System.Url.getSalesforceBaseURL().toExternalForm() +'/'+ lstUpdate[j].Id;
                Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(  
                                                    Functionality_Name__c = 'Contact Batch Upsert in TriggerGridRegistrationReportHelper', 
                                                    Error_Description__c = errorDetails,  
                                                    Record_URL__c = recordURL,
                                                    Error_Type__c = 'SALESFORCE BATCH');
                errorLog.setOptions(dml);
                lstErrors.add(errorLog);                
            }
        }
        if(!lstErrors.isEmpty()){
            Database.insert(lstErrors,false);
        }
    }
   /*
    *   Pupose of this method is to create User records in the User Object
    *   Input to this operation is a collection of Contact record Ids
    *   Following attributes are copied over from the Contact record to the User record
    *   - First Name
    *   - Last Name
    *   - Email (set on email and user name of the User record)
    *   - Company Name
    *   - Phone
    *   Note: the Profile on the created user record is 'ESP Community User' 
    */
    //NVIDIA|PJENA		| 6.0		 | 4/13/2018       | Big fix for failure cases, remove address update during update of contacts
    @future (callout=true)
    public static void CreateUser(List<Id> lstContactIds){
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
            for(Contact con :lstContact){
                //Creating alias names
                String alias ='';
                if(con.firstName != null && con.firstName.length()>0){
                    alias =''+con.FirstName.substring(0,1);
                    if(con.LastName.length()>4)
                        alias = alias+con.LastName.substring(con.LastName.length()-4);
                }                    
                else if(con.lastName.length()>4){
                    alias = con.LastName.substring(con.LastName.length()-5);
                }
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
            //Creating Users
            //database.insert(lstUser, false);
            Database.SaveResult[] lstSR = Database.Insert(lstUser, false);
			for (integer i = 0; i < lstSR.size(); i++){
				Database.SaveResult sr = lstSR[i];
				if (!sr.isSuccess()){
					// Operation failed, so get all errors 
					system.debug('The following error has occurred.');
					PRFT_DomainLayer.PRFT_Error err = new PRFT_DomainLayer.PRFT_Error('TriggerGridRegistrationReportHelper', sr.getErrors()[0].getMessage(), sr.getErrors()[0].getMessage(), null, true);
					sendInternalEmail(lstContact[0].FirstName + ' '+lstContact[0].LastName, lstContact[0].Phone, lstContact[0].Email, sr.getErrors()[0].getMessage());
				}else{
					// Operation was successful, so get the ID of the record that was processed
					system.debug('***Successfully Updated User with User.Id: ' + sr.getId());
				}
			}
				
        }catch(Exception e){
            System.debug(LOGGINGLEVEL.INFO+' Logged error in GRID Registration'+e.getStackTraceString());
            System.debug('get stack trace..'+e.getStackTraceString());
            PRFT_DomainLayer.PRFT_Error err = new PRFT_DomainLayer.PRFT_Error('Trigger Exception From TriggerGridRegistrationReportHelper',e.getStackTraceString(),String.valueof(e),null,true);
            //sendEmail(lstContact[0].email, lstContact[0].FirstName + ' '+lstContact[0].LastName);
            sendInternalEmail('', null, null, 'Trigger Exception From TriggerGridRegistrationReportHelper - ' + e.getMessage() + e.getStackTraceString());
        }           
    }
   /*
    *   Purpose of this method is to send an internal e-mail with the System Exception encountered during DGX Registration process
    */ 
    //NVIDIA|PJENA		| 6.0		 | 4/13/2018       | Big fix for failure cases, remove address update during update of contacts
    //PJENA: This needs improvement as it is pulled from DGX Registration page
    public static void sendInternalEmail(String name, String phone, String email, String error){
        EmailTemplate  eTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :System.Label.ESP_GRID_Registration_Failure_Internal_Email_Template];
        //Dummy contact to be set as setTargetObjectId
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        String[] supportEmails = (System.Label.ESP_GRID_User_Registration_Support_Email_Recipient).split(';');
        Messaging.reserveSingleEmailCapacity(supportEmails.size());
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = supportEmails; 
        mail.setToAddresses(toAddresses);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setTemplateId(eTemplate.Id);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(con.Id);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSubject(eTemplate.Subject);
        String body = eTemplate.HtmlValue;
        body=body.replace('{CustomerName}', name==null?'':name);
        body=body.replace('{ContactNumber}', phone==null?'':phone);
        body=body.replace('{Email}', email==null?'':email);
        body=body.replace('{Error}', error==null?'':error);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}