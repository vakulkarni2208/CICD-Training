/*
	Trigger class for trigger Brainshark_Learning_tgr on BRNSHRK__Brainshark_Learning__c (before insert, before update) to set SFDC_Contact_ID__c and SFDC_Account_ID__c
	Logic: For all records in the trigger, set the Contact Id and Account Id with matching BRNSHRK__User_Email__c
	
	2016.02.09 : CR : Raj - update only NPN contacts in the following order of preference
		- If the contact belongs to NPN Account Registry then give it first preference and update BRNSHRK__Brainshark_Learning__c record with that contact's Id and Account Id
		- If the contact does not belong to NPN Account Registry, check if it belongs to NPN Community Account and if found update BRNSHRK__Brainshark_Learning__c record with that contact's Id and Account Id
		- If the contact does not belong to NPN Account Registry nor NPN Community Account, do nothing 
		
	2016.06.15 : CR : Raj - ignore case in email matching
	
	2017.04.25 : CR : set BRNSHRK__SFDC_ID__c field to internal nvidia SFDC user Id with email having @nvidia.com and BRNSHRK__SFDC_ID__c is not already set
	
	2017.05.25 - Add Before Update and Copy SFDC User Id to Owner Id for Inter Users
	 
	2018.08.15 - only consider Partner Contact record types for brainshark learnings
	
	2018.10.23 - Modification to 2017.04.25 : CR
	 			set BRNSHRK__SFDC_ID__c field to internal nvidia SFDC user Id with email having @nvidia.com (ignore BRNSHRK__SFDC_ID__c is already set or not)
	
*/
public with sharing class Brainshark_Learning_tgr_cls {
	
	public static string NV_EMAILDOMAIN = 'nvidia.com';
	
	public static void setAccountAndContact(list<BRNSHRK__Brainshark_Learning__c> lstNewBrainsharkLearnings){
		
		//========================Collect: Email addresses==============================================================================================
		//get all the email addresses of the triggered BRNSHRK__Brainshark_Learning__c records
		set<string> allExtBSLearningEmails = new set<string>();
		list<BRNSHRK__Brainshark_Learning__c> lstNewExtBrainsharkLearnings = new list<BRNSHRK__Brainshark_Learning__c>();
		set<string> allNVBSLearningEmails = new set<string>();
		list<BRNSHRK__Brainshark_Learning__c> lstNewNVBrainsharkLearnings = new list<BRNSHRK__Brainshark_Learning__c>();
		
		for (BRNSHRK__Brainshark_Learning__c bsLearning : lstNewBrainsharkLearnings){
			if (bsLearning.BRNSHRK__User_Email__c != null){
				//2018.10.23 - Modification to 2017.04.25 : CR - set BRNSHRK__SFDC_ID__c field to internal nvidia SFDC user Id with email having @nvidia.com (ignore BRNSHRK__SFDC_ID__c is already set or not)
				//if (bsLearning.BRNSHRK__User_Email__c.endsWithIgnoreCase(NV_EMAILDOMAIN) && bsLearning.BRNSHRK__SFDC_ID__c == null){
				if (bsLearning.BRNSHRK__User_Email__c.endsWithIgnoreCase(NV_EMAILDOMAIN) ){
					allNVBSLearningEmails.add(bsLearning.BRNSHRK__User_Email__c);
					lstNewNVBrainsharkLearnings.add(bsLearning);
				}else{
					allExtBSLearningEmails.add(bsLearning.BRNSHRK__User_Email__c);
					lstNewExtBrainsharkLearnings.add(bsLearning);
				}
			}
		}
		//========================End: Collect: Email addresses===========================================================================================
		
		
		//========================Process: Internal Users===============================================================================================
		list<User> lstNVInternalUsers = [	Select Id, Email 
											From User 
											Where Email = :allNVBSLearningEmails 
													And UserType = :COMM_Constants.USER_USERTYPE_INTERNAL
											Order By IsActive Desc]; //Active records first
											
		if (!lstNVInternalUsers.isEmpty()){
			for (BRNSHRK__Brainshark_Learning__c bsLearning : lstNewNVBrainsharkLearnings){
				for (User u : lstNVInternalUsers){
					if (bsLearning.BRNSHRK__User_Email__c == u.Email){
						bsLearning.BRNSHRK__SFDC_ID__c = u.Id;
						//2017.05.25 - Add Before Update and Copy SFDC User Id to Owner Id for Inter Users
						bsLearning.OwnerId = u.Id;
						break;
					}
				}//end inner for
			}//end outer for
		}//end If
		
		//========================Process: Internal Users===============================================================================================
		
		
		
		//========================Process: External Users===============================================================================================
		
		//Find all the ContactIds and AccountIds for the corresponding matching Brainshark_Learnings records with email address
		list<Contact> lstMatchingContacts = [	Select Email, AccountId, Account.RecordType.Name 
												From Contact
												Where Email = :allExtBSLearningEmails And RecordType.Name = :COMM_Constants.CONTACT_RT_PARTNER_CONTACT And  Account.RecordType.Name in (:COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY, :COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY)];
		
		map<string, ContactAccountWrapperWithEmail> mapContactAccountWrapperWithEmail = new map<string, ContactAccountWrapperWithEmail>();
		
		//First preference to NPN_ACCOUNT_REGISTRY then preference to NPN_COMMUNITY
		//----------------------------------------------------------------------------
		//First Pass for NPN_ACCOUNT_REGISTRY contacts
		for (Contact sfdcContact : lstMatchingContacts){
			if (sfdcContact.Account.RecordType.Name == COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY){
				if (mapContactAccountWrapperWithEmail.get(sfdcContact.email.toLowerCase()) == null){
					ContactAccountWrapperWithEmail cawwe = new ContactAccountWrapperWithEmail(sfdcContact.Id, sfdcContact.AccountId);
					mapContactAccountWrapperWithEmail.put(sfdcContact.email.toLowerCase(), cawwe);
					
				}
			}
		}
		
		//Second Pass for NPN_COMMUNITY contacts
		for (Contact sfdcContact : lstMatchingContacts){
			if (sfdcContact.Account.RecordType.Name == COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY){
				if (mapContactAccountWrapperWithEmail.get(sfdcContact.email.toLowerCase()) == null){
					ContactAccountWrapperWithEmail cawwe = new ContactAccountWrapperWithEmail(sfdcContact.Id, sfdcContact.AccountId);
					mapContactAccountWrapperWithEmail.put(sfdcContact.email.toLowerCase(), cawwe);
				}
			}
		}
		//----------------------------------------------------------------------------
		
		
		//set the ContactId and AccountId if there is a matching email key in the map mapContactAccountWrapperWithEmail
		for (BRNSHRK__Brainshark_Learning__c bsLearning : lstNewExtBrainsharkLearnings){
			if (bsLearning.BRNSHRK__User_Email__c != null && mapContactAccountWrapperWithEmail.get(bsLearning.BRNSHRK__User_Email__c.toLowerCase()) != null){
				bsLearning.SFDC_Contact_ID__c = mapContactAccountWrapperWithEmail.get(bsLearning.BRNSHRK__User_Email__c.toLowerCase()).contactId;
				bsLearning.SFDC_Account_ID__c = mapContactAccountWrapperWithEmail.get(bsLearning.BRNSHRK__User_Email__c.toLowerCase()).accountId;
			}
		}
		
		//========================End: Process: External Users===============================================================================================
		
	}
	

	//wrapper class to hold email and the corresponding ContactId and AccountId
	public class ContactAccountWrapperWithEmail{
		public string contactId{get;set;}
		public string accountId{get;set;}
		
		public ContactAccountWrapperWithEmail(string contactId, string accountId){
			this.contactId = contactId;
			this.accountId = accountId;
		}
	}
	
}