/*
 * Author: Manideep
 * Date: 8/24/2018
 * Description:
     * This Batch class is scheduled to run daily at once to process all the Users Deactivated 'yesterday'.
     * If a User is deactivated in Salesforce the the 'Deactivated Date' field will be populated by the trigger on User object. All Users those are deactivated 
       on each day are processed daily by this Batch and the Case will be created if the deactivated User owns any records in various objects like on Accounts,
       Opportunities, Leads, Contacts, TAM, Account team Member, Opportunity Team member, Tasks etc.,
  
  * @Manideep: 02/05/2019 - Added a new field 'HR_Active__c' in the query and in code to display in the Case description.
  * SDS:2024 - @Manideep: 03/20/2019: Added field 'HR_Active__c' to the Case subject line. 
*/
public class UserDeactivatedCaseBatchClass implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
  
  public final String Query;
  
  // Constructor
  public UserDeactivatedCaseBatchClass() {
    Query = runquery();
  }
  
  // method to form Dynamic SOQL query.
  public string runquery() {       
    String queryString;
    queryString = 'Select Id, Name, UserType, Email, Manager.Name, Manager.Email, HRActive__c FROM User WHERE UserType = \'Standard\' AND DeactivatedDate__c = Yesterday';              
    system.debug('queryString---->'+queryString);  
    return queryString;
  }
    
  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(Query); 
  }
  
  public void execute(Database.BatchableContext info, List<User> userScope) {
    
    // Fetch values from Custom MetaData Type                                                                
    map<String, User_Deactivation_Case_Schedule__mdt> uDCS_mdt_Map = new map<String, User_Deactivation_Case_Schedule__mdt>();
    for(User_Deactivation_Case_Schedule__mdt uMDT: [SELECT Id, MasterLabel, DeveloperName, Value__c FROM User_Deactivation_Case_Schedule__mdt]) {
        uDCS_mdt_Map.put(uMDT.DeveloperName, uMDT);                                                         
    }
    
    map<Id, User> userMap = new map<Id, User>();
    map<Id, list<Account>> userAcctMap = new map<Id, list<Account>>();
    map<Id, list<Opportunity>> userOppMap = new map<Id, list<Opportunity>>();
    map<Id, list<Contact>> userCtcMap = new map<Id, list<Contact>>();
    map<Id, list<Lead>> userLeadMap = new map<Id, list<Lead>>();
    map<Id, list<Territory_Mapping__c>> userTamMap = new map<Id, list<Territory_Mapping__c>>();
    map<Id, list<AccountTeamMember>> userAtmMap = new map<Id, list<AccountTeamMember>>();
    map<Id, list<OpportunityTeamMember>> userOtmMap = new map<Id, list<OpportunityTeamMember>>();
    map<Id, list<Task>> userTaskMap = new map<Id, list<Task>>();    
        
    for(User usr: userScope) {
        userMap.put(usr.Id, usr);
    }
    
    // Account - Check if deactivated Users own any records which are Active.
    list<String> accRTNameList = string.valueOf(uDCS_mdt_Map.get('Account_Record_Types_to_Avoid').Value__c).split(';');        
            
    list<Account> accList = [SELECT Id, OwnerId, Name 
                             FROM Account 
                             WHERE OwnerId IN:userMap.keySet() 
                                   AND RecordType.Name IN:accRTNameList
                                   AND Inactive__c = false];
    if(!accList.isEmpty()) {
        for(Account acc: accList) {
            if(!userAcctMap.isEmpty()) {   // Map already contains Accounts owned by this User
                if(userAcctMap.containsKey(acc.OwnerId)) {
                   list<Account> accListTemp = userAcctMap.get(acc.OwnerId);
                   accListTemp.add(acc);                   
                   userAcctMap.put(acc.OwnerId, accListTemp);
                } else {                  // Map does not contain Accounts owned by this User
                   list<Account> accListTemp = new list<Account>();
                   accListTemp.add(acc);
                   userAcctMap.put(acc.OwnerId, accListTemp);   
                }  
            } else {                       // Map does not contain any Accounts 
                list<Account> accListTemp = new list<Account>();
                accListTemp.add(acc);
                userAcctMap.put(acc.OwnerId, accListTemp);  
            }   
        }
    }
    
    // Opportunity - Check if deactivated User own any records which are Active.
    list<String> oppRTList = string.valueOf(uDCS_mdt_Map.get('Opportunity_RecordTypes_to_Avoid').Value__c).split(';');
    list<String> oppStageList = string.valueOf(uDCS_mdt_Map.get('Opportunity_Stages_to_Avoid').Value__c).split(';');
        
    list<Opportunity> oppList = [SELECT Id, OwnerId, Name 
                                 FROM Opportunity 
                                 WHERE OwnerId IN:userMap.keySet() 
                                       AND RecordType.Name NOT IN:oppRTList
                                       AND StageName NOT IN:oppStageList
                                       AND Account.Inactive__c = false
                                       AND Probability > 1 
                                       AND Probability < 100];
    if(!oppList.isEmpty()) {
        for(Opportunity opp: oppList) {
            if(!userOppMap.isEmpty()) {    // Map already contains Opportunities owned by this User
                if(userOppMap.containsKey(opp.OwnerId)) {
                   list<Opportunity> oppListTemp = userOppMap.get(opp.OwnerId);
                   oppListTemp.add(opp);                   
                   userOppMap.put(opp.OwnerId, oppListTemp);
                } else {                   // Map does not contain Opportunities owned by this User
                   list<Opportunity> oppListTemp = new list<Opportunity>();
                   oppListTemp.add(opp);
                   userOppMap.put(opp.OwnerId, oppListTemp);    
                }   
            } else {                       // Map does not contain any Opportunities 
                list<Opportunity> oppListTemp = new list<Opportunity>();
                oppListTemp.add(opp);
                userOppMap.put(opp.OwnerId, oppListTemp);   
            }   
        }
    }
    
    // Contacts - Check if deactivated User own any records which are Active.
    list<Contact> ctcList = [SELECT Id, OwnerId, Name 
                             FROM Contact 
                             WHERE OwnerId IN:userMap.keySet() 
                                   AND Account.RecordType.Name IN:accRTNameList
                                   AND Account.Inactive__c = false];
    if(!ctcList.isEmpty()) {
        for(Contact ctc: ctcList) {
            if(!userCtcMap.isEmpty()) {    // Map already contains Contacts owned by this User
                if(userCtcMap.containsKey(ctc.OwnerId)) {
                   list<Contact> ctcListTemp = userCtcMap.get(ctc.OwnerId);
                   ctcListTemp.add(ctc);                   
                   userCtcMap.put(ctc.OwnerId, ctcListTemp);
                } else {                   // Map does not contain Contacts owned by this User
                   list<Contact> ctcListTemp = new list<Contact>();
                   ctcListTemp.add(ctc);
                   userCtcMap.put(ctc.OwnerId, ctcListTemp);    
                }   
            } else {                       // Map does not contain any Contacts
                list<Contact> ctcListTemp = new list<Contact>();
                ctcListTemp.add(ctc);
                userCtcMap.put(ctc.OwnerId, ctcListTemp);   
            }   
        }
    }
    
    // Leads - Check if deactivated User own any records.
    list<String> leadStatusList = string.valueOf(uDCS_mdt_Map.get('Lead_Status_to_Avoid').Value__c).split(';');
        
    list<Lead> leadList = [SELECT Id, OwnerId, Name 
                           FROM Lead 
                           WHERE OwnerId IN:userMap.keySet()
                                 AND isConverted = false
                                 AND Status NOT IN:leadStatusList];
    if(!leadList.isEmpty()) {
        for(Lead ld: leadList) {
            if(!userLeadMap.isEmpty()) {    // Map already contains Leads owned by this User
                if(userLeadMap.containsKey(ld.OwnerId)) {
                   list<Lead> leadListTemp = userLeadMap.get(ld.OwnerId);
                   leadListTemp.add(ld);                   
                   userLeadMap.put(ld.OwnerId, leadListTemp);
                } else {                   // Map does not contain Leads owned by this User
                   list<Lead> leadListTemp = new list<Lead>();
                   leadListTemp.add(ld);
                   userLeadMap.put(ld.OwnerId, leadListTemp);   
                }   
            } else {                       // Map does not contain any Leads
                list<Lead> leadListTemp = new list<Lead>();
                leadListTemp.add(ld);
                userLeadMap.put(ld.OwnerId, leadListTemp);  
            }   
        }
    }
    
    // Territory Mapping - Check if deactivated User own any records.
    list<Territory_Mapping__c> tamList = [SELECT Id, Territory_Account_Manager__c, Name 
                                          FROM Territory_Mapping__c 
                                          WHERE Territory_Account_Manager__c IN:userMap.keySet()];
    if(!tamList.isEmpty()) {
        for(Territory_Mapping__c tam: tamList) {
            if(!userTamMap.isEmpty()) {    // Map already contains TAM's owned by this User
                if(userTamMap.containsKey(tam.Territory_Account_Manager__c)) {
                   list<Territory_Mapping__c> tamListTemp = userTamMap.get(tam.Territory_Account_Manager__c);
                   tamListTemp.add(tam);                   
                   userTamMap.put(tam.Territory_Account_Manager__c, tamListTemp);
                } else {                   // Map does not contain TAM's owned by this User
                   list<Territory_Mapping__c> tamListTemp = new list<Territory_Mapping__c>();
                   tamListTemp.add(tam);
                   userTamMap.put(tam.Territory_Account_Manager__c, tamListTemp);   
                }   
            } else {                       // Map does not contain any TAM's
                list<Territory_Mapping__c> tamListTemp = new list<Territory_Mapping__c>();
                tamListTemp.add(tam);
                userTamMap.put(tam.Territory_Account_Manager__c, tamListTemp);  
            }   
        }
    }
    
    // AccountTeamMember - Check if deactivated User is part of any Account Teams.
    list<AccountTeamMember> atmList = [SELECT Id, UserId 
                                       FROM AccountTeamMember 
                                       WHERE UserId IN:userMap.keySet()
                                             AND Account.Inactive__c = false];
    if(!atmList.isEmpty()) {
        for(AccountTeamMember atm: atmList) {
            if(!userAtmMap.isEmpty()) {    // Map already contains AccountTeams owned by this User
                if(userAtmMap.containsKey(atm.UserId)) {
                   list<AccountTeamMember> atmListTemp = userAtmMap.get(atm.UserId);
                   atmListTemp.add(atm);                   
                   userAtmMap.put(atm.UserId, atmListTemp);
                } else {                   // Map does not contain AccountTeams owned by this User
                   list<AccountTeamMember> atmListTemp = new list<AccountTeamMember>();
                   atmListTemp.add(atm);
                   userAtmMap.put(atm.UserId, atmListTemp);     
                }   
            } else {                       // Map does not contain any AccountTeams
                list<AccountTeamMember> atmListTemp = new list<AccountTeamMember>();
                atmListTemp.add(atm);
                userAtmMap.put(atm.UserId, atmListTemp);    
            }   
        }
    }
    
    // OpportunityTeamMember - Check if deactivated User is part of any Opportunity Teams.
    list<OpportunityTeamMember> otmList = [SELECT Id, UserId 
                                           FROM OpportunityTeamMember 
                                           WHERE UserId IN:userMap.keySet()
                                                 AND Opportunity.Account.Inactive__c = false];
    if(!otmList.isEmpty()) {
        for(OpportunityTeamMember otm: otmList) {
            if(!userOtmMap.isEmpty()) {    // Map already contains OpportunityTeams owned by this User
                if(userOtmMap.containsKey(otm.UserId)) {
                   list<OpportunityTeamMember> otmListTemp = userOtmMap.get(otm.UserId);
                   otmListTemp.add(otm);                   
                   userOtmMap.put(otm.UserId, otmListTemp);
                } else {                   // Map does not contain OpportunityTeams owned by this User
                   list<OpportunityTeamMember> otmListTemp = new list<OpportunityTeamMember>();
                   otmListTemp.add(otm);
                   userOtmMap.put(otm.UserId, otmListTemp);     
                }   
            } else {                       // Map does not contain any OpportunityTeams
                list<OpportunityTeamMember> otmListTemp = new list<OpportunityTeamMember>();
                otmListTemp.add(otm);
                userOtmMap.put(otm.UserId, otmListTemp);    
            }   
        }
    }
    
    // Tasks (Activities) - Check if deactivated User own any Tasks.
    list<String> taskStatusList = string.valueOf(uDCS_mdt_Map.get('Task_Status').Value__c).split(';');
        
    list<Task> taskList = [SELECT Id, OwnerId 
                           FROM Task 
                           WHERE OwnerId IN:userMap.keySet()
                                 AND Status IN: taskStatusList];
    if(!taskList.isEmpty()) {
        for(Task tsk: taskList) {
            if(!userTaskMap.isEmpty()) {    // Map already contains Tasks owned by this User
                if(userTaskMap.containsKey(tsk.OwnerId)) {
                   list<Task> taskListTemp = userTaskMap.get(tsk.OwnerId);
                   taskListTemp.add(tsk);                  
                   userTaskMap.put(tsk.OwnerId, taskListTemp);
                } else {                   // Map does not contain Tasks owned by this User
                   list<Task> taskListTemp = new list<Task>();
                   taskListTemp.add(tsk);
                   userTaskMap.put(tsk.OwnerId, taskListTemp);  
                }   
            } else {                       // Map does not contain any Tasks
                list<Task> taskListTemp = new list<Task>();
                taskListTemp.add(tsk);
                userTaskMap.put(tsk.OwnerId, taskListTemp);     
            }   
        }
    }
    
    // Create a Case for each User if owns any of the records in the objects checked above.
    if(!userMap.isEmpty()) {
        
        list<Case> newCaseList = new list<Case>();
        
        // Account Admin Queue
        list<Group> caseQueueList = [Select Id, Name from Group Where Type = 'Queue' and Name = 'Account Admin Case Queue' LIMIT 1];
        
        // RecordType Id of Account Record Type 'NVIDIA Internal Case'
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NVIDIA Internal Case').getRecordTypeId();
        
        // Create Case for each User
        for(Id uId: userMap.keySet()) {
                            
             integer intUserAcctSize = 0;
             integer intUserOppSize = 0;
             integer intUserCtcSize = 0;
             integer intUserLeadSize = 0;
             integer intUserTamSize = 0;
             integer intUserAtmSize = 0;
             integer intUserOtmSize = 0;
             integer intUserTaskSize = 0;
             
             if(!userAcctMap.isEmpty() && userAcctMap.containsKey(uId))    intUserAcctSize = userAcctMap.get(uId).Size();
             if(!userOppMap.isEmpty() && userOppMap.containsKey(uId))      intUserOppSize = userOppMap.get(uId).Size(); 
             if(!userCtcMap.isEmpty() && userCtcMap.containsKey(uId))      intUserCtcSize = userCtcMap.get(uId).Size();
             if(!userLeadMap.isEmpty() && userLeadMap.containsKey(uId))    intUserLeadSize = userLeadMap.get(uId).Size();
             if(!userTamMap.isEmpty() && userTamMap.containsKey(uId))      intUserTamSize = userTamMap.get(uId).Size();  
             if(!userAtmMap.isEmpty() && userAtmMap.containsKey(uId))      intUserAtmSize = userAtmMap.get(uId).Size(); 
             if(!userOtmMap.isEmpty() && userOtmMap.containsKey(uId))      intUserOtmSize = userOtmMap.get(uId).Size();
             if(!userTaskMap.isEmpty() && userTaskMap.containsKey(uId))    intUserTaskSize = userTaskMap.get(uId).Size();
             
             if(!caseQueueList.isEmpty()
                 && (intUserAcctSize > 0 || intUserOppSize > 0 || intUserCtcSize > 0 || intUserLeadSize > 0 || intUserTamSize > 0 || intUserAtmSize > 0 || intUserOtmSize > 0 || intUserTaskSize > 0)) { 
                            
                string strDesc = 'User details: ' + userMap.get(uId).Name + ' ('  + userMap.get(uId).Email + ', ' + uId + ')' + '\r\n'
                                 + 'Manager details: ' + userMap.get(uId).Manager.Name + ' (' + userMap.get(uId).Manager.Email + ')' + '\r\n' 
                                 /* + 'HR Active: ' + userMap.get(uId).HRActive__c + '\r\n' + '\r\n' */
                                 + 'Records owned by the inactive user that are eligible for transition: ' + '\r\n' + '\r\n'
                                 + 'Leads: ' + intUserLeadSize + '\r\n'
                                 + 'Accounts: ' + intUserAcctSize + '\r\n'
                                 + 'Contacts: ' + intUserCtcSize + '\r\n'
                                 + 'Open Opportunities: ' + intUserOppSize + '\r\n'
                                 + 'Activities/Tasks: ' + intUserTaskSize + '\r\n'
                                 + 'Territory Account Managers: ' + intUserTamSize + '\r\n'
                                 + 'Account Team Members: ' + intUserAtmSize + '\r\n'
                                 + 'Opportunity Team Members: ' + intUserOtmSize + '\r\n';                               
                                                
                Case cse = new Case();
                cse.OwnerId = caseQueueList[0].Id;   
                cse.RecordTypeId = caseRTId;
                cse.Status = 'New';
                cse.Priority = 'Medium';
                cse.Type = 'Inactive User Cleanup';  
                cse.Subject = 'SFDC WWFO Deactivation Alert - ' + userMap.get(uId).Name + ' [HR Active: ' + userMap.get(uId).HRActive__c + ']';             
                cse.Description = strDesc;
                newCaseList.add(cse); 
                
             }  // end of checking if User owned any records by each object        
        }  // end of looping over each deactivated User 
        
        // DML
        if(!newCaseList.isEmpty()) {
            system.debug('newCaseList------>'+newCaseList);
            insert newCaseList;
        }    
            
    } // end of Case Creation process.
        
  }  // end of execute() method.
  
  public void finish(Database.BatchableContext BC) {}
  
  // execute method of Schedule class
  public void execute(SchedulableContext sc) {
    //invoke Batch class
    UserDeactivatedCaseBatchClass deactivatedUserCasebatch = new UserDeactivatedCaseBatchClass();
    Id batchinstanceid = database.executeBatch(deactivatedUserCasebatch);
  }
    
}