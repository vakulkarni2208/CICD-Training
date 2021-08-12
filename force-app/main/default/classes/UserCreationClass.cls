global class UserCreationClass {
    
    public UserCreationClass() {
        //logic to pull portal permission sets in a map
        /*map<String, String> mapPermissionSetNameID = new map<String, String>();
        map<String, list<String>> mapPortalGroupListPermissionSet = new map<String, list<String>>();
        list<Portal_Permission_Sets__c> lstPortalPermissionSets = [select id,name,Portal_Groups__c from Portal_Permission_Sets__c];
        for(Portal_Permission_Sets__c objPortalPermissionSets : lstPortalPermissionSets) {
            list<String> lstPortalGroup = new list<string>();
            if(objPortalPermissionSets.Portal_Groups__c != null) {
                lstPortalGroup.addAll(objPortalPermissionSets.Portal_Groups__c.split(';'));
                for(String strPermissionGroup : lstPortalGroup) {
                    if(!mapPortalGroupListPermissionSet.containsKey(strPermissionGroup)) {
                        mapPortalGroupListPermissionSet.put(strPermissionGroup,new list<String>{objPortalPermissionSets.name});                        
                    } else {
                        mapPortalGroupListPermissionSet.get(strPermissionGroup).add(objPortalPermissionSets.name);                        
                    }
                }
            }
        }
        list<PermissionSet> lstPermissionSet = [select id,name from PermissionSet];
        for(PermissionSet objPermissionSet : lstPermissionSet) {
            mapPermissionSetNameID.put(objPermissionSet.name, objPermissionSet.id);
        }
        system.debug('mapPortalGroupListPermissionSet = '+mapPortalGroupListPermissionSet);*/
       // List<AsyncApexJob> existingJob = [SELECT Id,JobType,Status FROM AsyncApexJob WHERE ApexClass.Name ='UserCreationScheduler' AND JobType ='ScheduledApex'];
        List<CronTrigger> lstCronTrigger = [Select Id, CronJobDetail.Name, State, NextFireTime From CronTrigger where CronJobDetail.Name like '%UserCreationScheduler%'];
        ContactToUserCreationBatch objCUCB = new ContactToUserCreationBatch('select id, Email, title, Portal_Groups__c, account.name, FirstName, LastName, MailingCountry, create_user__c, create_full_portal_user__c from Contact where create_user__c = True or create_full_portal_user__c = True');
        Database.executeBatch(objCUCB,200);
        
          DateTime nextScheduleTime = system.now().addMinutes(15);
          string minute = string.valueof(nextScheduleTime.minute());
          string second = string.valueof(nextScheduleTime.second ());
          string cronValue = second + ' ' + minute + ' * * * ?' ;
          string jobName = 'UserCreationScheduler - ' + nextScheduleTime.format('hh:mm');
   
        UserCreationScheduler oSchCls = new UserCreationScheduler();
        system.schedule(jobName, cronValue , oSchCls);
   
       system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
       
        // this section of code will abort the current schedule job
        if(!lstCronTrigger.isempty()){
            system.debug('lstCronTrigger' + lstCronTrigger);
            system.abortJob(lstCronTrigger[0].id);
        }
        //------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------

        
        
    }

}