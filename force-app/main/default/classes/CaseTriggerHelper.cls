/**
* A helper class for Case Trigger
* @author - Santoshi (Perficient) 
* Akhilesh:        : Added new function "updateAccountRegion" to sync AccountRegion from Account to Case.
* Akhilesh: 12/31/2018: Updated code for Business Critical Requirements
* Akhilesh: 01/11/2019: Updated code to use new Trigger Framework classes
* Akhilesh: 01/16/2019: Updated Escalated
* Akhilesh: 01/16/2019: Updated code to reuse queries instead of calling same data in different methods.
* - Update Function "updateAccountRegion" to use "queryAccountDetails" method to avoid extra query.
* - "updateCustomCaseOwnerName": to use "queryOwnerDetails" method to avoid extra query.
* Akhilesh: Removed "updateCustomCaseOwnerName" function which is not used anymore.
* Manideep: 2/5/2019: Added a null check for the field and for the map 'accountByCaseIdMap' in the code as its causing the test class 'UserDeactivatedCaseBatchClassTest.cls'. 
* Akhilesh: 03/15/2019: Updates to escalateCase function to not change Owner when Ownership is already frozen.
* Akhilesh: 03/15/2019: Clean up code (all functions) to not pass Trigger.old and Trigger.new parameters and use common variables. 
* Akhilesh: 03/15/2019: Update queryOwnerDetails function to take additional parameter to decide whether to query Owner details from old records or not.
* Akhilesh: 05/15/2019: Added RecentActivityUpdates function
* Akhilesh: 05/24/2019: SDS:1408 - Update updateAccountRegion to syncAccountDetails and Add logic for TAM
* Akhilesh: 06/05/2019: Update Escalate Case to Change Owner to ESP_L3 even Ownership is Frozen
* Akhilesh: 06/11/2019: Update Escalate Case to not Change Owner to ESP_L3 when Owner is NVAgent
* Akhilesh: 06/13/2019: queryOwnerDetails function now queries all Owners even when Owner is not changed. This is because Escalate Case function needs it.
* Akhilesh: 06/27/2019: SDS-1530 - Update updateAccountRegion to syncAccountDetails and Add logic for Regional_TAM__c
* Akhilesh: 06/27/2019: SDS-1023 - added setAccount function to set account based on company/email domain
* Nilesh  : 07/18/2019: SDS-1232 - Service: CUDA Support Services : Calculate service hours on Case and Roll them up to Entitlement - updateEntitlementRollsups()
* Akhilesh: 09/18/2019: SDS-1523 - Current Owner and Case Owner Assignment Logic change. Remove use of Frozen checkbox.
* Akhilesh: 10/02/2019: SDS-1622 - TAM and Regional TAM  assignment logic update.
* Akhilesh: 10/16/2019: SDS-1774 - TAM Queue Assignment logic.
* Akhilesh: 01/10/2020: SDS-1944 - SyncAccount Details when Account is Changed on Case.
* Akhilesh: 02/26/2020: SDS-2064 - Updated logic to use new Constants framework, use ESP_Utility functions instead of ServiceCloudUtils.
* Akhilesh: 03/01/2020: SDS-2066 - Added logic for DE assignment, updated "EscalateCase" function.
* Akhilesh: 03/03/2020: SDS-1041 - Added "closeAllMilestones" function, updated "MilestoneUpdates" and "UpdateSLADetails" function.
* Akhilesh: 05/02/2020: SDS-2290 - Update SyncAccount Details function to populate ParentId.
* Akhilesh: 05/02/2020: SDS-2580 - Added updateEmailCount function to populate no. of emails on Case.
* Akhilesh: 01/20/2020: SDS-2705 - Added Queueable class and method "UpdateSLADetails_Queueable" to replace future method.
* Nilesh:   04/21/2021: SDS-3049 - Added method setProductCategory in before insert
* Nilesh    04/10/2021: SDS-2868 - Added method addCaseTeamMember
*/
public without sharing class CaseTriggerHelper extends NV_TriggerHandler {
    
    public static Boolean EXECUTE_ASSIGNMENT= false;
    public final static String STATUS_AAA   = 'Awaiting Agent Assignment';
    public final static String STATUS_ACI   = 'Awaiting Customer Information';
    public final static String STATUS_ES    = 'Enterprise Support';
    public final static String QUEUE_DEV_NAME_JTP_L2    = 'JTP_L2';
    public final static String QUEUE_DEV_NAME_NCR_L2    = 'NCR_L2';
    public final static String QUEUE_DEV_NAME_L3        = 'ESP_L3';
    //public final static String QUEUE_DEV_NAME_TAM     = 'TAM_Queue';
    public final static String QUEUE_DEV_NANE_BCS       = 'Business_Critical_Support_Queue';
    public final static String COMM_CASE_RT_DEV_NAME    = 'Community_User_Record_Type';
    public final static Set<String> CASE_RT_DEV_NAME_SET= new Set<String>{COMM_CASE_RT_DEV_NAME};
        //public static set<String> L1UserRoles = new set<String>{'NCR Agent','JTP Agent','NCR Manager','JTP Manager'};
        
    //public list<Case> newRecords;
    public list<Case> oldRecords;
    private static list<Case> triggerNewList;
    private static map<Id, Case> mapTriggerOld;
    public override void init() { 
        //System.debug('12345 12');
        OBJECT_NAME = 'Case';
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, Case>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1'); 
    }
    
    public override void beforeInsert() {
        //System.debug('12345 13');
        //ServiceCloudUtils.LogErrors('12345', 'beforeInsert: '+triggerNewList[0].CaseNumber + ' ' +triggerNewList[0].ContactId + 'UserID: ' + triggerNewList[0].Last_Activity_By_User__c);
        CaseTriggerHelper.RecentActivityUpdates();
        setAccountId();
        CaseTriggerHelper.syncAccountDetails();
        CaseTriggerHelper.updateStatus();
        CaseTriggerHelper.updateProductFamily();
        queryOwnerDetails(true, false);
        CaseTriggerHelper.updatesOnOwnerChange();
        setProductCategory(triggerNewList); // SDS-3049
    }
    public override void beforeUpdate() {
        //System.debug('12345 14');
        //ServiceCloudUtils.LogErrors('12345', 'beforeUpdate: '+triggerNewList[0].CaseNumber + ' ' +triggerNewList[0].ContactId + 'UserID: ' + triggerNewList[0].Last_Activity_By_User__c);
        CaseTriggerHelper.RecentActivityUpdates();
        CaseTriggerHelper.updateEmailCount();
        setAccountId();
        CaseTriggerHelper.syncAccountDetails();
        CaseTriggerHelper.updateStatus();
        CaseTriggerHelper.updatesOnReOpenCase();
        CaseTriggerHelper.updateProductFamily();
        queryOwnerDetails(true, false); //Passing True to query all Case Owners for Escalate Case function.
        //SDS-1043: queryOwnerDetails(true, true); //For escalateCase we need to query Owner for all cases even no Owner changed.
        CaseTriggerHelper.escalateCase();
        CaseTriggerHelper.updatesOnOwnerChange();
    }
    public override void afterInsert() {
        //System.debug('1232019 15');
        //ServiceCloudUtils.LogErrors('12345', 'afterInsert: '+triggerNewList[0].CaseNumber + ' ' +triggerNewList[0].ContactId + 'UserID: ' + triggerNewList[0].Last_Activity_By_User__c);
        //SELECT Error_Code__c,Error_Description__c,Id FROM Service_Cloud_Error_Log__c where Error_Code__c ='12345'
        if(!CaseTriggerHelper.EXECUTE_ASSIGNMENT) {
            //System.debug('1232019 16');
            CaseTriggerHelper.EXECUTE_ASSIGNMENT = true;
            CaseTriggerHelper.executeCaseAssignment();
        }
        CaseTriggerHelper.syncAccountTeamWithCaseTeam();
        addCaseTeamMember(triggerNewList);
    }
    
    public override void afterUpdate() {
        //System.debug('12345 16');
        //ServiceCloudUtils.LogErrors('12345', 'afterUpdate: '+triggerNewList[0].CaseNumber + ' ' +triggerNewList[0].ContactId + 'UserID: ' + triggerNewList[0].Last_Activity_By_User__c);
        CaseTriggerHelper.milestoneUpdates();
        updateEntitlementRollsups();
        CaseTriggerHelper.syncAccountTeamWithCaseTeam();
    }
    
    // SDS-3049 -- start
    public static void setProductCategory(List<Case> triggerNewList){
        // Get all keywords from custom settings
        Map<String, Case_Keyword_Queue_Assignment__c> mapcaseKWQueue = Case_Keyword_Queue_Assignment__c.getAll();
        string[] lstKeywords; // For splitting keywords from custom settings
        set<string> setQueuename = new set<string>(); // To store all Custom setting's queue names
        for(Case_Keyword_Queue_Assignment__c tmpQueue : mapcaseKWQueue.values())
            setQueuename.add(tmpQueue.Queue_Name__c);   // Store all Custom setting's queue names
        system.debug('**setqueue name**' + setQueuename); 

        // Get ids for Queues in Custom settings from System           
        Map<Id,QueueSobject> mapIdQueue = new Map<Id,QueueSobject>([SELECT Queueid,Queue.name FROM QueueSobject where Queue.name in : setQueuename]);
        system.debug('**mapIdQueue**' + mapIdQueue);     

        // Search for Custom setting keywords in Case subject and description 
        for(Case tmpCase: triggerNewList) {
            for(string tmpKey : mapcaseKWQueue.keySet()){
                system.debug('**mapcaseKWQueue.get(tmpKey).Keywords__c**'+ mapcaseKWQueue.get(tmpKey).Keywords__c);
                //tmpCase.adderror('test');
                if(mapcaseKWQueue.get(tmpKey).Keywords__c.contains(';')){
                    lstKeywords  = mapcaseKWQueue.get(tmpKey).Keywords__c.split(';');
                    system.debug('**lstKeywords**'+ lstKeywords);
                }
                else if(mapcaseKWQueue.get(tmpKey).Keywords__c.contains(',')){
                    lstKeywords= mapcaseKWQueue.get(tmpKey).Keywords__c.split(',');
                }
                else if(tmpCase.subject.containsIgnoreCase(mapcaseKWQueue.get(tmpKey).Keywords__c)||(tmpCase.Description!=null && tmpCase.Description.containsIgnoreCase(mapcaseKWQueue.get(tmpKey).Keywords__c))){
                    system.debug('**mapcaseKWQueue.get(tmpKey).Keywords__c**'+ mapcaseKWQueue.get(tmpKey).Keywords__c);
                    tmpCase.Product_Category__c = mapcaseKWQueue.get(tmpKey).name;
                }
                else 
                    continue;
                if(lstKeywords!=null && !lstKeywords.isEmpty()){
                    system.debug('**lstKeywords**'+ lstKeywords);
                    system.debug('**tmpCase.subject**'+ tmpCase.subject);
                    system.debug('**tmpCase.Description**'+ tmpCase.Description);
                    
                    for(string tmpKeyword : lstKeywords){
                        system.debug('**tmpCase.subject.containsIgnoreCase(tmpKeyword)**'+ tmpCase.subject.containsIgnoreCase(tmpKeyword));
                        // If keyword from custom setting found in subject or description, assign product category
                        if(tmpCase.subject.containsIgnoreCase(tmpKeyword)||(tmpCase.Description!=null && tmpCase.Description.containsIgnoreCase(tmpKeyword))){
                            tmpCase.Product_Category__c = mapcaseKWQueue.get(tmpKey).name;
                            break;
                        }
                    }
                }
                
                // If Case product category and Custom setting product category are same then
                // assign to respective queue from custom setting and skip assignment rules
                if(tmpKey==tmpCase.Product_Category__c){
                    for(QueueSobject tmpQueue : mapIdQueue.values()){
                        system.debug('**mapcaseKWQueue.get(tmpKey).Queue_Name__c**' + mapcaseKWQueue.get(tmpKey).Queue_Name__c); 
                        system.debug('**tmpQueue.Queue.name**' + tmpQueue.Queue.name); 
                        if(mapcaseKWQueue.get(tmpKey).Queue_Name__c==tmpQueue.Queue.name){
                            tmpCase.OwnerId = tmpQueue.Queueid; // Assign queue 
                            tmpCase.Is_Skip_Assignment_Rule__c=true; // Skip default system assignment rules
                            break;
                        }
                    }
                }
            }
        }
    }
    // SDS-3049 -- End

    //This function is responsible to update when a Case is re-Opened.
    public static void updatesOnReOpenCase(){
        for(Case c: triggerNewList) {
            Case oldCase = mapTriggerOld.get(c.Id);
            if(!c.isClosed && oldCase.isClosed) {
                c.Case_ReOpen_DateTime__c = datetime.now();
            }
        }
    }
    
    public static void updateEmailCount() {
        map<Id, Case> casesToUpdateMap = new map<Id, Case>();
        for(Case c : triggerNewList){
            if(c.Last_Activity_Type__c == 'Email Message' && c.Last_Activity_Date__c != mapTriggerOld.get(c.Id).Last_Activity_Date__c ) {
                casesToUpdateMap.put(c.Id, c);
            }
        }
        
        if(casesToUpdateMap.size() > 0)
          CaseTriggerHelper.updateEmailCount(casesToUpdateMap);
    }
    
    public static void updateEmailCount(map<Id, Case> casesToUpdateMap) {
        //Query Emails
        List<AggregateResult> AggregateResultLst = [SELECT count(Id)cnt, parentId FROM EmailMessage where parentId in: casesToUpdateMap.keySet() group by parentId];
        System.debug('AggregateResultLst' +AggregateResultLst);
        
        //Update Email Count on Case
        for(AggregateResult res: AggregateResultLst){
            Id cId = (Id)res.get('parentId');
            if(cId != Null && casesToUpdateMap.containsKey(cId)){
                casesToUpdateMap.get(cId).Email_Count__c = (Integer)res.get('cnt');
            }
        }
    }
    
    public static void RecentActivityUpdates(){
        for(Case c : triggerNewList){
            
            if(mapTriggerOld != null && mapTriggerOld.get(c.Id) != null) {
                //Update Case Last_Activity_Type__c and Last_Activity_User_Type__c
                system.debug('Contact Id: 12345: '+ c.ContactId);
                
                //GetHelp:00079637: Removed the condition to not populate First Response Date when Status is New 
                //if(c.First_Response_Date_Time__c == NULL && c.Last_Activity_User_Type__c == 'Agent') {//} && c.Status != 'New') {
                if(c.First_Response_Date_Time__c == NULL && c.Last_Activity_User_Type__c == 'Agent' && c.Status != 'New') {
                    c.First_Response_Date_Time__c = DateTime.now();
                }
                //if(c.isClosed && c.Last_Activity_Type__c == 'Case Comment')
                //  c.addError('This case is Closed. If you need additional help, please contact Enterprise Support');
                if(c.Last_Activity_By_User__c == ServiceCloudUtils.getSystemUserId()) {
                    system.debug('Last_Activity_By_User__c Id: 12345: '+ c.Last_Activity_By_User__c);
                    c.Last_Activity_User_Type__c = 'Customer';
                    if(c.ContactID != null) {
                        //c.Last_Activity_By_User__c = c.ContactId;
                    }
                }
                
                //Update Case Status for each case
                if(c.Last_Activity_Date__c != mapTriggerOld.get(c.Id).Last_Activity_Date__c 
                  ) {
                      if(c.Activity_on_Closed_Case__c == false 
                         && c.isClosed 
                         && c.Last_Activity_User_Type__c == 'Customer'
                        ) {
                            c.Activity_on_Closed_Case__c = true;
                        }
                      
                      if((
                          c.Last_Activity_Type__c == 'Case Comment' 
                          || c.Last_Activity_Type__c == 'Attachment'
                          || c.Last_Activity_Type__c == 'Email Message')
                         && c.Last_Activity_User_Type__c == 'Customer' 
                         && (c.Status == 'Awaiting Customer Response' 
                             || c.Status == 'Pending Close – No Customer Response'
                            )
                        )
                      {
                          c.Status = 'In Progress';
                      }
                  }
            }
        }
    }
    
    public static void updateEntitlementRollsups(){
        try {
            List<Id> lstClosedCaseEntIds = new List<Id>();
            List<Id> lstOpenCaseEntIds = new List<Id>();
            for(Case tmpCase : triggerNewList){
                if(tmpCase.EntitlementId !=null && tmpCase.status=='Closed' && tmpCase.Engineering_support_hours__c!=null){
                    lstClosedCaseEntIds.add(tmpCase.EntitlementId);
                }
                else if(tmpCase.EntitlementId !=null && tmpCase.status!='Closed' && tmpCase.Engineering_support_hours__c!=null){
                    lstOpenCaseEntIds.add(tmpCase.EntitlementId);
                }
            }
            AggregateResult[] closedCaseHours, OpenCaseHours;
            if(!lstClosedCaseEntIds.isEmpty())
                closedCaseHours  = [select sum(Engineering_support_hours__c) Hours,EntitlementId from case where status='Closed' and EntitlementId in :lstClosedCaseEntIds group by EntitlementId ];
            if(!lstOpenCaseEntIds.isEmpty())
                OpenCaseHours  = [select sum(Engineering_support_hours__c) Hours,EntitlementId from case where status !='Closed' and EntitlementId in :lstOpenCaseEntIds group by EntitlementId ];
            List<Entitlement> lstEntitlement;
            if(!lstClosedCaseEntIds.isEmpty()||!lstOpenCaseEntIds.isEmpty())
                lstEntitlement = [select id,Support_Hours_Delivered__c,Support_Hours_WIP__c from Entitlement where id in :lstClosedCaseEntIds or id in :lstOpenCaseEntIds ];
            else 
                return;
            
            Map<Id,Decimal> mapEntIdClosedHours = new Map<Id,Decimal>();
            Map<Id,Decimal> mapEntIdOpenHours = new Map<Id,Decimal>();
            if(closedCaseHours!=null)
                for (AggregateResult ar : closedCaseHours)  {
                    mapEntIdClosedHours.put((Id)ar.get('EntitlementId'),(Decimal)ar.get('Hours'));
                }
            if(openCaseHours!=null)
                for (AggregateResult ar : openCaseHours)  {
                    mapEntIdOpenHours.put((Id)ar.get('EntitlementId'),(Decimal)ar.get('Hours'));
                }
            for(Entitlement tmpEnt : lstEntitlement){
                if(mapEntIdClosedHours!=null && mapEntIdClosedHours.get(tmpEnt.Id)!=null){
                    tmpEnt.Support_Hours_Delivered__c = mapEntIdClosedHours.get(tmpEnt.Id);}
                
                if(mapEntIdClosedHours!=null && mapEntIdOpenHours.get(tmpEnt.Id)!=null)
                    tmpEnt.Support_Hours_WIP__c = mapEntIdOpenHours.get(tmpEnt.Id);
                
            }
            update lstEntitlement;
        } catch (Exception ex) {
            ESP_Utility.LogErrors(ex.getMessage(), ex.getStackTraceString());
        }
    }
    
    public static void setAccountId() {
        try {
            list<Case> casesToSetAccountIds = new list<Case>();
            set<String> domainList = new set<String>();
            set<String> domainQuery = new set<String>();
            for(Case c : triggerNewList) {
                if((c.Origin == 'Email' || c.Origin == 'Web Form') && c.ContactId == null && c.AccountId == null && c.suppliedEmail != null) {
                    casesToSetAccountIds.add(c);
                    String domain = getDomainFromEmail(c.suppliedEmail);
                    domainQuery.add('%'+domain);
                    domainList.add(domain);
                }
            }
            
            if(!casesToSetAccountIds.isEmpty()) {
                map<string, list<Account>> accountsByDomain = getAccountsbyDomain(domainList, domainQuery);
                //list<Account> accList = [select Id, website from Account where website like: domainQuery];
                for(Case c : casesToSetAccountIds) {
                    list<Account> accList = accountsByDomain.get(getDomainFromEmail(c.suppliedEmail));
                    if(accList == null) 
                        c.Generic_Queue_Reason__c = 'No Account Found';
                    else if(accList.size() > 1)
                        c.Generic_Queue_Reason__c = 'Multiple Accounts Found';
                    else if(accList.size() == 1)
                        c.AccountId = accList[0].Id;
                }
            }
        } catch (Exception ex) {
            ESP_Utility.LogErrors(ex.getMessage(), ex.getStackTraceString());
        }
    }
    
    public static string getDomainFromEmail(String email) {
        system.debug(email.substringAfterLast('@'));
        return email.substringAfterLast('@');
    }
    
    /*public static string getDomainFromWebsite(String website) {
system.debug(website.substringAfterLast('www.'));
return website.substringAfterLast('www.');
}*/
    
    //@readonly
    public static map<string, list<Account>> getAccountsbyDomain(set<String> domainList, set<String> domainQuery) {
        system.debug('domainQuery: '+domainQuery);
        map<string, list<Account>> accountsByDomain = new map<string, list<Account>>();
        list<String> accRecordTypes = System.Label.ServiceCloud_ServiceAccount_RecordType_Ids.split(',');
        list<Account> accList = [select Id, website from Account where website like : domainQuery and recordtypeId in: accRecordTypes];
        system.debug('accList: '+accList);
        if(!accList.isEmpty()) {
            for(Account acc : accList) {
                for(String domain : domainList) {
                    //String domainName = getDomainFromWebsite(acc.webSite);
                    if(!String.isBlank(acc.webSite) && acc.webSite.containsIgnoreCase(domain)) {
                        list<Account> tempAccList = new list<Account>();
                        if(accountsByDomain.containsKey(domain))
                            tempAccList = accountsByDomain.get(domain);
                        
                        tempAccList.add(acc);
                        accountsByDomain.put(domain, tempAccList);
                    }
                }
            }
        }
        return accountsByDomain;
    } 
    
    /* Set Account Region whenever a New Case is created or updated.*/
    public static void syncAccountDetails(){
        system.debug('inside syncAccountDetails: ');
        queryAccountDetails();
        for(Case c : triggerNewList){
            system.debug('inside loop: '+ c);
            //Technical_Account_Manager_TAM__c
            //if(accountByCaseIdMap != null && accountByCaseIdMap.get(c.AccountId).Billing_Region__c != null)
            if(accountByCaseIdMap != null && c.AccountId != null 
               && accountByCaseIdMap.containsKey(c.AccountId) 
              ){
                  boolean accountChanged = false; //SDS-1944
                  if(trigger.isUpdate) {
                      Case oldCase = mapTriggerOld.get(c.Id);
                      if(oldCase.AccountId != c.AccountId)
                          accountChanged = true;
                  }
                  
                  Account acc = accountByCaseIdMap.get(c.AccountId);
                  if(c.Account_Manager__c == null || accountChanged) //SDS-1622
                      c.Account_Manager__c = acc.Technical_Account_Manager_TAM__c; //SDS-1408
                  if(c.Regional_TAM__c == null || accountChanged) //SDS-1622
                      c.Regional_TAM__c = acc.Regional_TAM__c; //SDS-1530
                  
                  if(acc.Billing_Region__c != null)// || accountChanged)
                      c.Account_Region__c = acc.Billing_Region__c.toUppercase();
                  if(acc.ParentId != null)// || accountChanged)
                      c.Parent_Account__c = acc.ParentId;
                  else 
                      c.Parent_Account__c = acc.Id;
                  system.debug('inside loop: '+ acc);
                  //SDS-1039: 
                  if(    
                      //trigger.isInsert && 
                      c.EntitlementId == null
                      //&& c.Product_Category__c == 'GRID' 
                      && acc.Support_Level__c == ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c
                  ) {
                      system.debug('inside loop 2: '+ acc.Entitlements);
                      list<Entitlement> entList = acc.Entitlements;
                      if (!entList.isEmpty()){
                          c.EntitlementId = entList[0].Id;
                      }
                      system.debug('inside loop 2: '+ c.EntitlementId);
                  }
              }
        }
    }
    
    /* Set Case Status Based on Incident Status
* When Status is set to STATUS_AAA or STATUS_ACI, change Case Status to "In Progress"
*/
    public static void updateStatus(){
        //set<case> caseUpdate = new case();
        Set<Id> cRTIdSet = getCaseRTIdSet();
        for(Case c : triggerNewList){
            system.debug('1232019 1 updateStatus:'+ c);
            if(cRTIdSet.contains(c.RecordTypeId) 
               && c.Status == 'New'
               && c.Incident_Status__c != STATUS_AAA 
               && c.Incident_Status__c != STATUS_ACI
              ){
                  system.debug('1232019 2 updateStatus:'+ c);
                  if(mapTriggerOld == null) {
                      c.Status = 'In Progress';
                  }else if(mapTriggerOld != null && mapTriggerOld.get(c.Id) != null
                           && mapTriggerOld.get(c.Id).Incident_Status__c != NULL
                           && c.Incident_Status__c != mapTriggerOld.get(c.Id).Incident_Status__c 
                          ){
                              c.Status = 'In Progress';
                          }
              }
            
        }
    }
    
    /*
*   This method operates on cases prior to update or insert
*   Case must be of record type 'Community User Record Type'
*   For Updates, the following cases are eligible for processing
*       - Product Family on the Case is blank
*       - Entitlement (EntitlementId) on the Case has changed
*       - A valid value exists in the Entitlement__c for the Case
*   For Inserts, the following cases are eligible for processing
*       - Product Family on the Case is blank
*       - A valid entitlement (EntitlementId) exists on the Case
*       - A valid value exists in the Entitlement__c for the Case
*   For all the Cases where a valid Entitlement__c is populated
*       - Prepare a map collection of Entitlement__c values
*       - Use the values from the map to retrieve the entitlement records from the custom Entitlement__c object
*       - Gather the parent entitlement Ids by referring to the Entitlement__c custom field on the custom Entitlement__c object
*   Retrieve the product family values from the standard entitlement object in one go for 
*       - the Collection of Standard entitlement references on the Case records
*       - and the Collection of Standards entitlement references derived from values found in the Entitlement__c custom field on the custom Entitlement__c object
*   Finally, walk through the Cases to set the product family retrieved from the previous step
*/
    public static void updateProductFamily(){
        Set<Id> cRTIdSet = getCaseRTIdSet();
        Map<String,String> casVsEnt = new Map<String,String>();
        Map<String,String> casVsCustomEnt = new Map<String,String>();
        Map<String,String> entVsStdEnt = new Map<String,String>();
        for(Case cas : triggerNewList){
            if(cRTIdSet.contains(cas.RecordTypeId)
               && (cas.EntitlementId != null || cas.Entitlement__c != null)){
                   if(Trigger.isUpdate && Trigger.isBefore){
                       if(cas.EntitlementId != null){
                           if(String.isBlank(cas.Product_Family__c) || (cas.EntitlementId != mapTriggerOld.get(cas.Id).EntitlementId)){
                               casVsEnt.put(cas.Id,cas.EntitlementId);
                           }
                           //System.debug('casVsCustomEnt-33--'+String.isBlank(cas.Product_Family__c) +String.isBlank(cas.EntitlementId )+ !String.isBlank(cas.Entitlement__c));
                       }  
                       else if((String.isBlank(cas.Product_Family__c) || String.isBlank(cas.EntitlementId )) && !String.isBlank(cas.Entitlement__c)){
                           casVsCustomEnt.put(cas.Entitlement__c+'-'+cas.Id,cas.Entitlement__c);
                           //System.debug('casVsCustomEnt-33--'+casVsCustomEnt);
                       }
                       
                   } else if(Trigger.isInsert && Trigger.isBefore){
                       if(String.isBlank(cas.Product_Family__c) && !String.isBlank(cas.EntitlementId )){
                           casVsEnt.put(cas.Id,cas.EntitlementId);
                       } else if((String.isBlank(cas.Product_Family__c) || String.isBlank(cas.EntitlementId )) && !String.isBlank(cas.Entitlement__c)){
                           casVsCustomEnt.put(cas.Entitlement__c+'-'+cas.Id,cas.Entitlement__c);
                           //System.debug('casVsCustomEnt---'+casVsCustomEnt);
                       }
                   }
               }
        }
        
        if(!casVsCustomEnt.isEmpty()){
            Map<Id,Entitlement__c> customEntitleList = new Map<Id,Entitlement__c>([Select Id,Entitlement__c From Entitlement__c Where id in: casVsCustomEnt.values()]);
            //System.debug('custom---'+customEntitleList);
            for(String strEnt :  casVsCustomEnt.keySet()){
                List<String> entArr = strEnt.split('-');
                if(entArr != null && !entArr.isEmpty() && entArr.size() >=2  && customEntitleList.containsKey(entArr[0])){
                    Entitlement__c entObj = customEntitleList.get(entArr[0]);
                    casVsEnt.put(entArr[1],entObj.Entitlement__c);
                    entVsStdEnt.put(entObj.Id,entObj.Entitlement__c);
                    //System.debug('casVsEnt---'+casVsEnt);
                    //System.debug('entVsStdEnt---'+entVsStdEnt);
                }
            }
        }
        if(!casVsEnt.isEmpty()){
            Map<Id,Entitlement> entitleMap = new Map<Id,Entitlement>([Select Product_Family__c,Id
                                                                      FROM Entitlement WHERE Id in : casVsEnt.values() and Product_Family__c != null]);
            
            if(!entitleMap.isEmpty()){
                for(Case cas : triggerNewList){
                    if(cas.EntitlementId != null ){
                        if(entitleMap.containsKey(cas.EntitlementId )){
                            Entitlement ent = entitleMap.get(cas.EntitlementId);
                            if(!String.isBlank(ent.Product_Family__c)){
                                cas.Product_Family__c = ent.Product_Family__c;
                            }
                        }
                    } else if(cas.Entitlement__c != null){
                        if(entVsStdEnt.containsKey(cas.Entitlement__c)){
                            String entKey = entVsStdEnt.get(cas.Entitlement__c);
                            if(entitleMap.containsKey(entKey )){
                                Entitlement ent = entitleMap.get(entKey);
                                if(!String.isBlank(ent.Product_Family__c)){
                                    cas.Product_Family__c = ent.Product_Family__c;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    /*
*   Purpose of this method is to escalate the cases - either to Level 2 or Level 3. 
*   This method is invoked/fired on 'before update' event of the Case record
*   Case must be of record type 'Community User Record Type'
*   For Updates, the following cases are eligible for processing
*       - Owner on the Case must be a User (Record Id refix 005)
*       - Incident status on the Case is changed
*       - Case is associated to a valid Customer Account
*   For Case to be escalated to Level 2
*       - The incident status should have moved from 'Enterprise Support' to 'Awaiting Agent Assignment'
*   For Case to be escalated to Level 3
*       - The new incident status should be 'Enterprise Support'
*   For Level 2 escalation 
*       - If the account billing region is Japan, escalate the Case to queue 'JTP_L2'
*       - If the account billing region is not Japan, escalate the Case to queue 'NCR_L2'
*   For Level 3 escalation
*       - Escalate the Case to queue 'ESP_L3'
*/
    public static void escalateCase(){
        Set<Id> cRTIdSet = getCaseRTIdSet();
        List<Case> caseToL2List = new List<Case>();
        List<Case> caseToL3List = new List<Case>();
        Set<Id> acctIdSet = new Set<Id>();
        for(Case c : triggerNewList){
            system.debug('1232019 1 updateStatus:'+ c);
            String sOwnerId = c.OwnerId;
            if(cRTIdSet.contains(c.RecordTypeId) 
               && sOwnerId != null && sOwnerId.startsWith('005')
               && ( c.Incident_Status__c != mapTriggerOld.get(c.Id).Incident_Status__c) //|| c.Trigger_Action__c == 'Escalate Case') //SDS-2066
               && c.AccountId != null
              ){
                  if(c.Incident_Status__c == STATUS_ES ) {//|| c.Trigger_Action__c == 'Escalate Case'){ //SDS-2066
                      //move to L3
                      system.debug('1232019 3 updateStatus:'+ c);
                      caseToL3List.add(c);
                      acctIdSet.add(c.AccountId);
                  } else if(c.Incident_Status__c == STATUS_AAA && mapTriggerOld.get(c.Id).Incident_Status__c != STATUS_ES){
                      //move to L2
                      system.debug('1232019 2 updateStatus:'+ c);
                      caseToL2List.add(c);
                      acctIdSet.add(c.AccountId);
                  }
              }
        }
        
        //Future enhancements: Remove this query and utilize a utility function
        if(!acctIdSet.isEmpty()){
            Map<Id,Account> acctMap = new Map<Id, Account>([SELECT Billing_Region__c, Support_Level__c, Designated_Engineer__c FROM Account WHERE Id IN :acctIdSet]);
            List<Group> groupList = [SELECT Id, DeveloperName
                                     FROM Group 
                                     WHERE Type='Queue' 
                                     AND (DeveloperName   = :QUEUE_DEV_NAME_JTP_L2 
                                          OR DeveloperName = :QUEUE_DEV_NAME_NCR_L2 
                                          OR DeveloperName = :QUEUE_DEV_NAME_L3
                                          OR DeveloperName = :QUEUE_DEV_NANE_BCS
                                          //OR DeveloperName = :QUEUE_DEV_NAME_TAM
                                         )];
            Group qNCRL2;
            Group qJTPL2;
            Group qL3;
            Group qBCS;
            //Group qTAM;
            for(Group g : groupList){
                if(g.DeveloperName == QUEUE_DEV_NAME_JTP_L2){
                    qJTPL2 = g;
                }else if(g.DeveloperName == QUEUE_DEV_NAME_NCR_L2){
                    qNCRL2 = g;
                }else if(g.DeveloperName == QUEUE_DEV_NAME_L3){
                    qL3 = g;
                } else if(g.DeveloperName == QUEUE_DEV_NANE_BCS){
                    qBCS = g;
                } //else if(g.DeveloperName == QUEUE_DEV_NAME_TAM){
                //    qTAM = g;
                //}
            }
            
            for(Case c : caseToL2List){
                if(acctMap.get(c.AccountId) != null
                   && acctMap.get(c.AccountId).Billing_Region__c == 'JAPAN'
                   && qJTPL2 != null){
                       system.debug('1232019 4 updateStatus:'+ c);
                       c.OwnerId = qJTPL2.Id;
                   }else if(acctMap.get(c.AccountId) != null
                            && acctMap.get(c.AccountId).Billing_Region__c != 'JAPAN'
                            && qNCRL2 != null){
                                system.debug('1232019 5 updateStatus:'+ c);
                                c.OwnerId = qNCRL2.Id;
                            }
            }
            if(qL3 != null){
                for(Case c : caseToL3List){
                    system.debug('1232019 6 updateStatus:'+ c);
                    if(acctMap.get(c.AccountId) != null) {
                        Account acc = acctMap.get(c.AccountId);
                        system.debug('1232019 7 updateStatus:'+ acc);
                        if(acc.Support_Level__c != ESP_Utility.ESPConstants.SLA_24X7SUPPORT){
                            system.debug('1232019 8 updateStatus:');
                            
                            //Old Logic based on Frozen flag
                            //if(!c.Ownership_frozen__c) 
                            //    c.OwnerId = qL3.Id;
                            
                            //Check role of previous Owner before assigning it to ESP L3.   
                            User currentUser;
                            String currentUserID = c.OwnerId;
                            if(currentUserID.startsWith('005')){
                                currentUser = userMap.get(c.OwnerId);
                            }
                            User oldOwner;
                            if(mapTriggerOld != null) {
                                String oldOwnerId = mapTriggerOld.get(c.Id).OwnerId;
                                if(oldOwnerId.startsWith('005')){
                                    oldOwner = userMap.get(oldOwnerId);
                                }
                            }
                            
                            if(currentUser.UserRole.Name != 'NV Agent' 
                               //&& (oldOwner == NULL || oldOwner.UserRole.Name != 'NV Agent') 
                              ) {
                                //Removed the logic to assign DE after 1 hour when trigger action is set to "Escalate Case" by Time based Workflow rule.
                                  if(acc.Designated_Engineer__c != null) {// && c.Trigger_Action__c != 'Escalate Case') { //SDS-2066
                                      system.debug('1232019 9 updateStatus:');
                                      String TAMQueueName = ESP_Utility.ESPConstants.ServiceCloudSettings.TAM_Queue__c;
                                      c.OwnerId = NV_Utility.getPublicGroupsOrQueueIdByDevName(TAMQueueName);//qTAM.Id;
                                      //c.OwnerId = acc.Designated_Engineer__c;
                                      c.Designated_Engineer_Assigned__c = true;
                                      c.Last_Current_Owner_Date_Time__c = DateTime.now();
                                      //c.Milestone_Status__c = 'Assigned to BCS';
                                  } //else if(acc.Designated_Engineer__c != null && c.Trigger_Action__c == 'Escalate Case') { //SDS-2066
                                    //  c.OwnerId = qL3.Id;
                                    //  c.Trigger_Action__c = '';
                                  //} 
                                  else {
                                      if(c.Account_Manager__c == NULL && c.Regional_TAM__c == NULL)
                                          c.OwnerId = qL3.Id;
                                      else {
                                          String TAMQueueName = ESP_Utility.ESPConstants.ServiceCloudSettings.TAM_Queue__c;
                                          c.OwnerId = NV_Utility.getPublicGroupsOrQueueIdByDevName(TAMQueueName);//qTAM.Id;
                                      }
                                      //c.Trigger_Action__c = ''; //SDS-2066
                                  }
                              }
                        } else {
                            if(acc.Designated_Engineer__c != null) {
                                system.debug('1232019 9 updateStatus:');
                                c.OwnerId = acc.Designated_Engineer__c;
                                c.Designated_Engineer_Assigned__c = true;
                                //c.Milestone_Status__c = 'Assigned to BCS';
                            } else {
                                system.debug('1232019 10 updateStatus:');
                                c.OwnerId = qBCS.Id;
                                c.Assigned_to_Business_Critical_Queue__c = true;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void updatesOnOwnerChange(){
        Set<Id> cRTIdSet = getCaseRTIdSet();
        List<Case> caseToUpdateList = new List<Case>();
        for(Case c : triggerNewList){
            if(c.OwnerId != null 
               && cRTIdSet.contains(c.RecordTypeId)
               && (mapTriggerOld == null || (mapTriggerOld.get(c.Id) != null && c.OwnerId != mapTriggerOld.get(c.Id).OwnerId))
              ){
                  system.debug('1232019 1 updatesOnOwnerChange:'+ c);
                  caseToUpdateList.add(c);
              }
        }
        
        if(!caseToUpdateList.isEmpty()){
            //queryOwnerDetails(triggerNewList, mapTriggerOld, false);
            if(!userMap.isEmpty())
                queryAccountDetails();
            system.debug('1232019 2 updatesOnOwnerChange:'+ userMap);
            system.debug('1232019 3 updatesOnOwnerChange:'+ groupMap);
            for(Case c : caseToUpdateList){
                if(groupMap.get(c.OwnerId) != null) { //When Case Owner is Queue
                    Group ownerQueue = groupMap.get(c.OwnerId);
                    system.debug('1232019 3 updatesOnOwnerChange:'+ c);
                    //Set Milestone Flags
                    if(ownerQueue.DeveloperName == QUEUE_DEV_NANE_BCS) {
                        system.debug('1232019 4 updatesOnOwnerChange:'+ c.OwnerId);
                        c.Assigned_to_Business_Critical_Queue__c = true;
                    }
                    //Set Custom Owner Field and Lock.
                    //SDS-1523: Do not change Case_Owner when Case.Owner is queue 
                    /*if(ownerQueue.DeveloperName == 'ESP_L3') { 
system.debug('1232019 5 updatesOnOwnerChange:'+ c.OwnerId);
c.Ownership_frozen__c = true;
} else if(!c.Ownership_frozen__c) {
system.debug('1232019 6 updatesOnOwnerChange:'+ c.OwnerId);
c.Case_Owner__c = ownerQueue.Name;
}*/
                } else if (userMap.get(c.OwnerId) != null) { //When Case Owner is User
                    User ownerUser = userMap.get(c.OwnerId);
                    //Set Milestone Flags
                    system.debug('1232019 7 updatesOnOwnerChange:'+ c.OwnerId);
                    if(c.Accountid != null) {
                        system.debug('1232019 8 updatesOnOwnerChange:'+ c.OwnerId);
                        Account acc = accountByCaseIdMap.get(c.AccountId);
                        if(trigger.isUpdate && acc.Designated_Engineer__c == c.OwnerId && c.Status != STATUS_AAA) {
                            c.Designated_Engineer_Assigned__c = true;
                        }
                    }
                    //Set Custom Owner Field and Lock.
                    //SDS-1523: Set Case_Owner if Owner roles in JTP/NCR team
                    /*if(ownerUser.UserRole.Name == 'NV Agent') {
system.debug('1232019 9 updatesOnOwnerChange:'+ ownerUser.UserRole.Name);
c.Ownership_frozen__c = true;
} else if(!c.Ownership_frozen__c) {
system.debug('1232019 10 updatesOnOwnerChange:'+ c);
c.Case_Owner__c = (ownerUser.FirstName != null && ownerUser.FirstName != '') 
? ownerUser.FirstName + ' ' + ownerUser.LastName 
: ownerUser.LastName;
c.L1_L2_Owner__c = ownerUser.Id;
}*/
                    set<string> L1UserRoles = ESP_Utility.getL1L2OwnerRoles();
                    if(L1UserRoles.contains(ownerUser.UserRole.Name)) {
                        c.Case_Owner__c = (ownerUser.FirstName != null && ownerUser.FirstName != '') 
                            ? ownerUser.FirstName + ' ' + ownerUser.LastName 
                            : ownerUser.LastName;
                        c.L1_L2_Owner__c = ownerUser.Id;
                    }
                }
            }
        }
    }
    
    /*
*   This method operates on
*   - Community User Record Type
*   - Case Origin is Phone
*   - Case status is 'New'
*   Purpose of this method is to tun on flags so as to have the Case
*   - use the default assignment rule
*   - trigger an e-mail to the Users on updates
*   Note: This was added to execute the case assignment rule as Napilli Template and case creation doesn't trigger assignment rules.
*   Whenever it starts supporting this can be removed.
*/
    public static void executeCaseAssignment(){
        system.debug('1232019 1 executeCaseAssignment:');
        Set<Id> cRTIdSet = getCaseRTIdSet();
        List<Id> caseIds = new List<Id>{};
            for(Case theCase:triggerNewList){ 
                system.debug('1232019 2 executeCaseAssignment:'+ theCase.RecordTypeId + theCase.Origin + theCase.Status == 'New'); 
                //if(thecase.origin = 'Web')
                if(cRTIdSet.contains(theCase.RecordTypeId) && theCase.Origin != 'Phone' && theCase.Status == 'New'){
                    system.debug('1232019 3 executeCaseAssignment:');
                    caseIds.add(theCase.Id);
                }
            }
        
        List<Case> cases = new List<Case>{}; 
            for(Case c : [Select Id from Case where Id in :caseIds]) {
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;
                //dmo.EmailHeader.triggerAutoResponseEmail = true;
                //dmo.EmailHeader.triggerOtherEmail = true;
                dmo.EmailHeader.triggerUserEmail = true;
                c.setOptions(dmo);
                cases.add(c);
            }
        if(!cases.isEmpty()){
            Database.upsert(cases);
        }
    }
    
    /* This function is responsible to Update Case SLA Text from Milestone Violation updates. */
    public static void milestoneUpdates(){
        set<Id> caseIdsToUpdate = new set<Id>();
        set<Id> closedCaseIds = new set<Id>();
        system.debug('201812181: New Value: '+triggerNewList[0].Milestone_Status__c);
        system.debug('201812182: Old Value: '+mapTriggerOld.get(triggerNewList[0].Id).Milestone_Status__c);
        //caseIds.add(triggerNewList[0].Id);
        
        for(Case c : triggerNewList){
            if(c.Milestone_Status__c != null 
               && c.Milestone_Status__c != mapTriggerOld.get(c.Id).Milestone_Status__c)
            {
                caseIdsToUpdate.add(c.Id);
            }
            
            if(c.isClosed && !mapTriggerOld.get(c.Id).isClosed)
                closedCaseIds.add(c.Id);
        }
        
        closeAllMilestones(closedCaseIds);
        
        if(recuringCall == True)
            return;
        recuringCall= True;
        
        Id jobId = System.enqueueJob(new UpdateSLADetails_Queueable(caseIdsToUpdate));
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
        
        //if(System.IsFuture())// || system.isBatch())
          //  return;
        
        //updateSLADetails(caseIdsToUpdate);
    }
    
    public static Boolean recuringCall = False;
    //Queueable
    public class UpdateSLADetails_Queueable implements Queueable {
        private Set<Id> caseIdsToUpdate;
        
        public UpdateSLADetails_Queueable(Set<Id> caseIdsSet) {
            caseIdsToUpdate = caseIdsSet;
        }
        
        public void execute(QueueableContext context) {
            CaseTriggerHelper.updateSLADetails(caseIdsToUpdate);
            
        }
  }
    
    //public static boolean milestoneTest = False;
    @future
    public static void updateSLADetails(set<Id> caseIds) {
        //Query all Cases
        List<case> caseList = [select ID,Milestone_Status__c, SLA_Text__c from case where id in : caseIds];
        //Get SLA Text from Custom Metadata for each Milestone Status
        
        //Update SLA Text for each Case
        for(case c : caseList) {
            if(c.Milestone_Status__c != null && c.Milestone_Status__c != '') {
                Milestone_Alert_Setting__mdt milestoneAlertSetting = ESP_Utility.getMilestoneAlertSetting(c.Milestone_Status__c);
                c.SLA_Text__c = (milestoneAlertSetting != null) ? milestoneAlertSetting.SLA_Text__c : '';
            }
        }
        
        //Update Cases
        if(!caseList.isEmpty())
            update caseList;
        //Reset Static variable.
    }
    
    public static void closeAllMilestones(set<Id> caseIds) {
        
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone
                                           where caseId in :caseIds and completionDate = null];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = DateTime.now();
            }
            update cmsToUpdate;
        }
    }
    
    /*Funtions to get Accounts for all Details for Cases in Trigger Context */
    static Map<Id, Account> accountByCaseIdMap = null;
    public static map<Id, Account> queryAccountDetails(){
        if(accountByCaseIdMap != null)
            return accountByCaseIdMap;
        
        system.debug('inside queryAccountDetails: ');
        Set<Id> acctIdSet = new Set<Id>();        
        for(Case c : triggerNewList) {
            if(c.AccountId != null) {
                acctIdSet.add(c.AccountId);
            }
        }
        
        system.debug('acctIdSet: '+ acctIdSet);
        if(!acctIdSet.isEmpty()){ //Updated query for SDS-1530, 1408, 
            accountByCaseIdMap = new Map<Id, Account>(
                [SELECT Billing_Region__c,Designated_Engineer__c, Technical_Account_Manager_TAM__c, Regional_TAM__c, Support_Level__c, ParentId,
                 (select Id from Entitlements 
                  where Name =: ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c
                 )
                 FROM Account WHERE Id IN :acctIdSet]);
        }
        system.debug('accountByCaseIdMap: '+ accountByCaseIdMap);
        return accountByCaseIdMap;
    }
    
    /* Akhilesh: Need to fix this Methods sometime.
*   Get and Set the Case 'Community User Record Type' record type on the local variable caseRTIdSet
*/
    public static Set<Id> caseRTIdSet = null;
    public static Set<Id> getCaseRTIdSet(){
        if(caseRTIdSet == null){
            caseRTIdSet = new Set<Id>();
            for(RecordType rt : [SELECT Id FROM RecordType WHERE SObjectType='Case' 
                                 AND DeveloperName IN :CASE_RT_DEV_NAME_SET]){
                                     caseRTIdSet.add(rt.Id);
                                 }
        }
        return caseRTIdSet;
    }
    
    /* Common Function to get Onwer Details for all Cases in Trigger Context */
    static Map<Id, User> userMap = null;
    static Map<Id, Group> groupMap = null;
    public static void queryOwnerDetails(boolean queryAll, boolean queryOld){
        //if(userMap != null || groupMap != null )
        //    return; 
        system.debug('1232019 3 queryOwnerDetails: userMap '+ userMap);
        system.debug('1232019 3 queryOwnerDetails: groupMap '+ groupMap);
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        for(Case c : triggerNewList){
            if(mapTriggerOld == null 
               || (mapTriggerOld.get(c.Id) != null && c.OwnerId != mapTriggerOld.get(c.Id).OwnerId) 
               || queryAll
              ) {
                  String sOwnerId = c.OwnerId;
                  if(sOwnerId.startsWith('005')){
                      userIdSet.add(c.OwnerId);
                  }else{
                      groupIdSet.add(c.OwnerId);
                  }
                  
                  /* Query old Owners: Code to query records based on old Map as well
if(queryOld && mapTriggerOld != null) {
String oldOwnerId = mapTriggerOld.get(c.Id).OwnerId;
if(oldOwnerId.startsWith('005')){
userIdSet.add(oldOwnerId);
}else{
groupIdSet.add(oldOwnerId);
}
}*/
              }
        }
        
        userMap = new Map<Id,User>();
        if(!userIdSet.isEmpty()){
            userMap = new Map<Id,User>([SELECT Name, FirstName, LastName, UserRole.Name, Service_Queue_Type__c FROM User WHERE Id IN :userIdSet]);
        }
        groupMap = new Map<Id,Group>();
        if(!groupIdSet.isEmpty()){
            groupMap = new Map<Id,Group>([SELECT Name, DeveloperName FROM Group WHERE Id IN :groupIdSet]);
        }
    }
    
    /* Old public static void syncAccountTeamWithCaseTeam(){

List<CaseTeamMember> caseTeamMembersList = new List<CaseTeamMember>();
Map<String, id> caseTeamRoleMap = new Map<String, Id>();
for(CaseTeamRole ctr : [SELECT Name, Id FROM CaseTeamRole]){
caseTeamRoleMap.put(ctr.Name, ctr.Id);
}

Map< Id , Id > caseIdToAccountId = new Map< Id , Id >();
for(Case c : triggerNewList)  {
caseIdToAccountId.put(c.Id,  c.AccountId );
}

Map<id, List<AccountTeamMember > > accountIdToAccountTeamMembers = new    Map<id,  List<AccountTeamMember > > ();
for(AccountTeamMember accountTeamMember : [SELECT a.UserId,a.TeamMemberRole, a.Id, a.AccountId
FROM AccountTeamMember a
WHERE a.AccountId in :caseIdToAccountId.values() ]){

List<AccountTeamMember > accountTeamMembers = (accountIdToAccountTeamMembers.get(accountTeamMember.Accountid) == null) ?
new  List<AccountTeamMember >() :
accountIdToAccountTeamMembers.get(accountTeamMember.Accountid);

accountTeamMembers.add(accountTeamMember);
accountIdToAccountTeamMembers.put(accountTeamMember.Accountid, accountTeamMembers);
}

for(Case o : triggerNewList) {
Id accountId  = caseIdToAccountId.get(o.Id);
for ( AccountTeamMember accountTeamMember : accountIdToAccountTeamMembers.get(accountId) )  {
CaseTeamMember caseTeamMember  = new CaseTeamMember();
caseTeamMember.MemberId = accountTeamMember.UserId;
caseTeamMember.TeamRoleId = caseTeamRoleMap.get(accountTeamMember.TeamMemberRole);
caseTeamMember.ParentId = o.ID;
caseTeamMembersList.add(caseTeamMember);
}
}
insert caseTeamMembersList;
}
} */
    
    public static void syncAccountTeamWithCaseTeam(){
        Set<Id> caseIdSet = new Set<Id>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Design Win Support Request').getRecordTypeId();
        Map<Id, Id> caseIdToAccountId = new Map<Id, Id>();
        
        for(Case c: triggerNewList){
            if(c.RecordTypeId == caseRecordTypeId){
                caseIdSet.add(c.Id);
                caseIdToAccountId.put(c.Id,  c.AccountId );
            }
        }
        
        Map<id, List<AccountTeamMember > > accountIdToAccountTeamMembers = new    Map<id,  List<AccountTeamMember > > ();
        for(AccountTeamMember accTeamMember : [SELECT a.UserId,a.TeamMemberRole, a.Id, a.AccountId
                                               FROM AccountTeamMember a
                                               WHERE a.AccountId in :caseIdToAccountId.values() ])   {
                                                   if(accTeamMember != Null){
                                                       System.debug('accTeamMember !!!!!!!= NuLL' + accTeamMember);
                                                       List<AccountTeamMember > accountTeamMembers = ( accountIdToAccountTeamMembers.get(accTeamMember.Accountid) == null) ?
                                                           new  List<AccountTeamMember >() :
                                                       accountIdToAccountTeamMembers.get(accTeamMember.Accountid);
                                                       accountTeamMembers.add(accTeamMember);
                                                       accountIdToAccountTeamMembers.put(accTeamMember.Accountid, accountTeamMembers);
                                                   }
                                               }
        
        if(accountIdToAccountTeamMembers.isEmpty())
            return;
        
        System.debug('caseIdSet 5152020 1' + caseIdSet);
        System.debug('In side of the triger 5152020 2');
        
        List<CaseTeamMember> caseTeamMemberListToUpdate = [SELECT Id, MemberId, TeamRoleId, ParentId FROM CaseTeamMember where ParentId in : caseIdSet];
        Map<id, List<CaseTeamMember>> caseIdtoCaseTeamMemberMap = new Map<id, List<CaseTeamMember>>();
        
        System.debug('caseTeamMemberListToUpdate 5152020 3' + caseTeamMemberListToUpdate);
        for(CaseTeamMember ctm: caseTeamMemberListToUpdate){
            if(ctm != null){
                if(caseIdtoCaseTeamMemberMap.containsKey(ctm.ParentId)){
                    caseIdtoCaseTeamMemberMap.get(ctm.ParentId).add(ctm);
                } 
                else {
                    list<CaseTeamMember> tempCTMList = new list<CaseTeamMember>();
                    tempCTMList.add(ctm);
                    caseIdtoCaseTeamMemberMap.put(ctm.ParentId, tempCTMList);
                }
            }
        }
        
        System.debug('caseIdtoCaseTeamMemberMap =====' + caseIdtoCaseTeamMemberMap);
        List<CaseTeamMember> caseTeamMembersListForUpsert = new List<CaseTeamMember>();
        Map<String, id> caseTeamRoleMap = new Map<String, Id>();
        //Use ESP_Constant Class
        Set<String> CaseRolesForDesignWin = ESP_Utility.ESPConstants.DESIGN_WIN_CASE_TEAM_ROLES;
        for(CaseTeamRole ctr : [SELECT Name, Id FROM CaseTeamRole where Name in : CaseRolesForDesignWin ]){
            caseTeamRoleMap.put(ctr.Name, ctr.Id);
        }
        if(caseTeamRoleMap.isEmpty())
            return;
        
        
        for(Case o : triggerNewList) {
            System.debug('Test Point 0000000');
            list<caseTeamMember> existingcaseTeamMembersList = caseIdtoCaseTeamMemberMap.get(o.Id);
            Map<Id, caseTeamMember> userIdToCaseTeamMember = new Map<Id, caseTeamMember>();
            
            if(caseIdtoCaseTeamMemberMap.containsKey(o.Id)){
                System.debug('Test Point 11111111');
                for(caseTeamMember ctm : existingcaseTeamMembersList){
                    userIdToCaseTeamMember.put(ctm.MemberId, ctm);
                }
            }
            System.debug('Test Point 2222222');
            Id accountId  = caseIdToAccountId.get(o.Id);
            if(accountIdToAccountTeamMembers != null && accountIdToAccountTeamMembers.containsKey(accountId)) {
                for ( AccountTeamMember accountTeamMember : accountIdToAccountTeamMembers.get(accountId) )  {
                    System.debug('Test Point 3333333');
                    if(userIdToCaseTeamMember != null && userIdToCaseTeamMember.containsKey(accountTeamMember.UserId) && caseTeamRoleMap.containsKey(accountTeamMember.TeamMemberRole)){
                        /* // This Section for update on existing records
                        CaseTeamMember caseTeamMember  = new CaseTeamMember();
                        CaseTeamMember.Id = userIdToCaseTeamMember.get(accountTeamMember.UserId).Id;
                        caseTeamMember.TeamRoleId = caseTeamRoleMap.get(accountTeamMember.TeamMemberRole);
                        caseTeamMembersListForUpsert.add(caseTeamMember); */
                    }else{
                        if(caseTeamRoleMap.containsKey(accountTeamMember.TeamMemberRole)){
                            System.debug('Test Point 444444444444');
                            CaseTeamMember caseTeamMember  = new CaseTeamMember();
                            //CaseTeamMember.Id = userIdToCaseTeamMember.get(accountTeamMember.UserId).Id;
                            caseTeamMember.MemberId = accountTeamMember.UserId;
                            caseTeamMember.TeamRoleId = caseTeamRoleMap.get(accountTeamMember.TeamMemberRole);
                            caseTeamMember.ParentId = o.ID;
                            caseTeamMembersListForUpsert.add(caseTeamMember);    
                        }
                    }
                }
                
                if(caseTeamMembersListForUpsert != Null)
                    upsert caseTeamMembersListForUpsert;
            }
        }
        
    }    
// SDS-2868 - Start
public static void addCaseTeamMember(List<Case> lstNewCase){
    Set<Id> setAccIds = new Set<Id>();
    
    // Get Accounts from cases
    for(Case tmpCase : lstNewCase){
        setAccIds.add(tmpCase.AccountId);
    }
    // Get Account roles and Account Team members 
    Map<Id,Account> mapAccount = new Map<Id,Account>([select id , (select UserId,TeamMemberRole from AccountTeamMembers where Include_in_case_team__c=true) from Account where id in :setAccIds]);
    
    // Get Case Team role names and create map for role name and its id
    List<CaseTeamRole> lstCaseRole = [SELECT AccessLevel,Id,Name FROM CaseTeamRole];
    CaseTeamMember caseTeam;
    Map<String,Id> mapRoleId = new Map<String,Id>();
    for(CaseTeamRole tmpCaseRole : lstCaseRole){
        mapRoleId.put(tmpCaseRole.Name,tmpCaseRole.Id);
    }
    // Prepare list of case team members to be added
    List<CaseTeamMember> lstCaseTeam = new List<CaseTeamMember>();
    for(Case tmpCase : lstNewCase){
        if(mapAccount!=null && !mapAccount.isEmpty() && mapAccount.containsKey(tmpCase.AccountId)){

            List<AccountTeamMember> lstAccountTeamMember = mapAccount.get(tmpCase.AccountId).AccountTeamMembers;
            if(lstAccountTeamMember!=null && !lstAccountTeamMember.isEmpty()){
                for(AccountTeamMember tmpAccountTeam : lstAccountTeamMember){                    
                    caseTeam = new CaseTeamMember();
                    caseTeam.MemberId = tmpAccountTeam.UserId;
                    caseTeam.ParentId = tmpCase.id;
                    caseTeam.TeamRoleId = mapRoleId.get(tmpAccountTeam.TeamMemberRole);
                    lstCaseTeam.add(caseTeam);
                } 
            }    
        }
    }
    if(lstCaseTeam!=null && !lstCaseTeam.isEmpty())
        Database.insert(lstCaseTeam,false);
}        
// SDS-2868 - End 
}