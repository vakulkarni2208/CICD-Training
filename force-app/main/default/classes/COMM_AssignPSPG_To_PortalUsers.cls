/*
Schedulable Apex Class
-----------------------
1 - Assigns Permission Sets to the Contact User from Portal Permission Sets object records and Contact's Permission Set Groups field value
2 - Assigns Public Groups to the Contact User from Portal Public Groups object records and Contact's Permission Set Groups field value 
3 - Resets Contact Users attributes as 
	Salesforce1 User = True, 
	Salesforce CRM Content User = True, 
	Chatter Answers User = false, 
	Receive Salesforce CRM Content Email Alerts = false, 
	Receive Salesforce CRM Content Alerts as Daily Digest = false

It needs to be scheduled manually from Dev Console for the first time and afterwards it will run from the configuration present in Custom Settings named Community_Settings__c
Community_Settings__c.PS_PG_ASSIGN_LKBK_TIME__c - Defines the lookback time in minutes. 
				All the Contacts/Users that got created or modified from this lookback time till current time are processed by this job
Community_Settings__c.PS_PG_ASSIGN_RECUR__c - Defines recurring frequency in minutes. 
				The job repeats execution based on this time gap.
Community_Settings__c.PS_PG_ENABLE_SCHDULED_JOB__c - Flag to enable or disable the job.
				This is an automatic way to abort the scheduled job. Once it is aborted the job needs to be sc manually thru the Dev Console.
				
Commad to schedule the apex through Developer Console

COMM_AssignPSPG_To_PortalUsers p = new COMM_AssignPSPG_To_PortalUsers();
DateTime currDT = DateTime.now().addMinutes(2);
integer sec = currDT.second();
integer min = currDT.minute();
String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
system.debug('sch: ' + sch);
system.schedule('Exec of COMM_AssignPSPG_To_PortalUsers', sch, p);

Change list:
3/31/2015 - Raj - Do not remove any public groups. 
3/31/2015 - Tracy - When Users are modified, make sure the checkbox also gets set/unset (previously it was only set/unset during new user creation).
3/31/2015 - Paresh - Removed references to COMM_Constants.cls and COMM_Utility.cls. 
		Added the utility methods and Constants native to this class so it can stay independent.
4/22/2015 - Paresh - Dedupe of PermissionSetAssignment list and GroupMember list. 
		If a contact was having two Portal Public Groups, then associated Permission Sets were added the list as duplicates and none of the duplicates were getting inserted because of SFDC governance.
7/7/2015 - If it is a CP user then set userPermissionsSFContentUser = false, otherwise it is true
		Resets Contact Users attributes as 
			Salesforce1 User = False, 
			Salesforce CRM Content User = True (Only for Partner Portal Users), 
			Chatter Answers User = false, 
			Receive Salesforce CRM Content Email Alerts = false, 
			Receive Salesforce CRM Content Alerts as Daily Digest = false

9/10/2015 - Add the MDFv3 permission set as part of MDF related permission set
4/8/2016 - 	Unsubscribing users from Public Groups - Raj, Tracy, Brenda
			If portal contacts are removed from any Permissions & Group Assignments, they need to be removed from the respective Public Groups 
			(on 3/31/2015 this functionality was blocked by Raj)

2017.11.29 - PJENA - Code Cleanup - ready to be deleted

*/

public class COMM_AssignPSPG_To_PortalUsers {
	
	//constructor
	public COMM_AssignPSPG_To_PortalUsers(){
		
	}
}