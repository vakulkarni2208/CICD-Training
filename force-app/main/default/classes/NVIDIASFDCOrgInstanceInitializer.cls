/*
	2019.08.14 - Sandbox Initializer - runs automatic after the completion of sandbox referesh
		- Sets the NVIDIASFDCOrgInstanceInfo custom settings with Sandbox Name
		- Upates all email addresses of User and Contact records

*/

global class NVIDIASFDCOrgInstanceInitializer implements SandboxPostCopy{
	global void runApexClass(SandboxContext context) {
		
		Organization org = [SELECT IsSandbox FROM Organization];
		
		NVIDIASFDCOrgInstanceInfo__c oSFDCOrgInfo = new NVIDIASFDCOrgInstanceInfo__c();
		oSFDCOrgInfo.Name = 'NVIDIASFDCOrgInstanceInfo';
		oSFDCOrgInfo.IsSandbox__c = org.IsSandbox;
		oSFDCOrgInfo.OrgId__c = context.organizationId();
		oSFDCOrgInfo.RefreshDateTime__c = Datetime.now();
		oSFDCOrgInfo.SandboxId__c = context.sandboxId();
		oSFDCOrgInfo.SandboxName__c = context.sandboxName();
		system.debug('***oSFDCOrgInfo: ' + oSFDCOrgInfo);
		insert oSFDCOrgInfo;
		
		//set all admin emails back to regular emails
		system.debug('***Begin Call: revertAdminEmails()');
		revertAdminEmails();
		system.debug('***End Call: revertAdminEmails()');
		
		//invoke batch job to update email address in contact and user record
		system.debug('***Begin Batch Call: NVIDIASFDCOrgInstanceInitializer_batch');
		NVIDIASFDCOrgInstanceInitializer_batch oNVUsrConBatch = new NVIDIASFDCOrgInstanceInitializer_batch();
		database.executeBatch(oNVUsrConBatch, 100);
		system.debug('***End Batch Call: NVIDIASFDCOrgInstanceInitializer_batch');
		
    }
    
    global static void revertAdminEmails(){
		list<User> adminUserEmailList = [select Email from User where profile.name in ('System Administrator', 'Data Administrator', 'Sales Profile - Partner Admin') and isactive = true];
		list<User> adminUserEmailList_upd = new list<User>();
		for(User uc : adminUserEmailList){
			//to remove appended domain 
			string addedPhrase = '.invalid';
			uc.Email = uc.Email.remove(addedPhrase);
			adminUserEmailList_upd.add(uc);
		}
		system.debug('***adminUserEmailList_upd : ' + adminUserEmailList_upd);
        if(adminUserEmailList_upd.size() > 0){
             database.update(adminUserEmailList_upd, false);
		}
    }
    
    
}