/*
	2019.08.14 - Sandbox Initializer - runs automatic after the completion of sandbox referesh, called from NVIDIASFDCOrgInstanceInitializer
		- Upates all email addresses of external User and Contact records 
*/
		
public class NVIDIASFDCOrgInstanceInitializer_batch implements database.batchable<SObject>{
	
	//Constructor 
    public NVIDIASFDCOrgInstanceInitializer_batch(){
    	
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	system.debug('*******Entering Batch Start Method');
    	if (Test.isRunningTest()){
    		return Database.getQueryLocator([ Select Email, FederationIdentifier, (Select Email From Contacts__r) From User Where UserType <> 'Standard' limit 10]);
    	}else{
    		return Database.getQueryLocator([ Select Email, FederationIdentifier, (Select Email From Contacts__r) From User Where UserType <> 'Standard']);
    	}
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
    	system.debug('---------Entering Batch Job execute method-------------------');
		if (scope != null && !scope.isEmpty()){
			try{
				
				list<User> lstUsers = (List<User>) scope;
				list<Contact> lstContacts = new list<Contact>();	
						
				for (User usr : lstUsers){
					
					//append .inavlid to user records
					//usr.email = !string.isBlank(usr.email) ? usr.email + '.invalid' : usr.email; //it is done automatically
					usr.FederationIdentifier = !string.isBlank(usr.FederationIdentifier) ? usr.FederationIdentifier + '.invalid' : usr.FederationIdentifier;
					
					list<Contact> listContactsWithUsers = new list<Contact>();
					listContactsWithUsers = usr.Contacts__r;
					
					if (!listContactsWithUsers.isEmpty()){
						for (Contact con : listContactsWithUsers){
							//append .inavlid to contact records
							con.email = !string.isBlank(con.email) ? con.email + '.invalid' : con.email;
							lstContacts.add(con);
						}
					}
				}
				
				//update
				if (!lstUsers.isEmpty()) Database.SaveResult[] lstUserUR = database.update(lstUsers, false);
				if (!lstContacts.isEmpty()) Database.SaveResult[] lstContactUR = database.update(lstContacts, false);
				
			} catch(Exception ex){
				system.debug('***exception: ' + ex);
			}
			
		}
		system.debug('---------Exiting Batch Job execute method-------------------');
    }
    
    public void finish(Database.BatchableContext BC){
		system.debug('---------Entering Batch Job finish method-------------------');
		
		system.debug('---------Exiting Batch Job finish method-------------------');
	}
    
}