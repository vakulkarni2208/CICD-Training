public class Opp_NPNOEMODMDISTI_Event_Tracker_Bat implements Database.Batchable<SObject>, System.Schedulable, Database.Stateful{
        
    private static final string EVENTNAME = 'NPNOEMODMDISTI';
    private static final integer iBatchSize = 20;
    list<Id> lstProcessedRecordIds = new list<Id>(); //Use it to update the records in the finish method
    set<Id> setUniqueRecordIds = new set<Id> ();
    List<Platform_Event_Tracker_Processor__c> lstEvents = new list<Platform_Event_Tracker_Processor__c>();

    //Constructor
    public Opp_NPNOEMODMDISTI_Event_Tracker_Bat() {}

    //Schedulable interface method implementation.
    public void execute(SchedulableContext sc){
        system.debug('------------------Start: Schedule Batch Job Opp_NPNOEMODMDISTI_Event_Tracker_Bat ---------------------------');
        Opp_NPNOEMODMDISTI_Event_Tracker_Bat oJob = new Opp_NPNOEMODMDISTI_Event_Tracker_Bat();
        database.executeBatch(oJob, iBatchSize);

        /*
        DateTime nextScheduleTime = system.now().addMinutes(2);
	    string minute = string.valueof(nextScheduleTime.minute());
	    string second = string.valueof(nextScheduleTime.second ());
	    string cronValue = second + ' ' + minute + ' * * * ?' ;
	    string jobName = 'Opp_NPNOEMODMDISTI_Event_Tracker_Bat - ' + nextScheduleTime.format('hh:mm');
	    Opp_NPNOEMODMDISTI_Event_Tracker_Bat oSchCls = new Opp_NPNOEMODMDISTI_Event_Tracker_Bat();
	    system.schedule(jobName, cronValue , oSchCls);
        system.debug('------------------End: Schedule Batch Job Opp_NPNOEMODMDISTI_Event_Tracker_Bat ---------------------------');
        */

        system.debug('------------------End: Schedule Batch Job Opp_NPNOEMODMDISTI_Event_Tracker_Bat ---------------------------');
    }


    //*************************************************************************************************************************
    //  BATCH METHODs
    //*************************************************************************************************************************
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('*******Enters Batch Start Method');
        return Database.getQueryLocator([   SELECT Id, EventName__c, ObjectName__c, ProcessedDate__c, Processed__c, RecordId__c 
                                            FROM Platform_Event_Tracker_Processor__c
                                            WHERE Processed__c = false
                                                AND EventName__c = :EVENTNAME
                                            Order By LastModifiedDate
                                        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('---------Entering Batch Job Opp_NPNOEMODMDISTI_Event_Tracker_Bat execute method-------------------');
        if (scope != null && !scope.isEmpty()){
            lstEvents = (List<Platform_Event_Tracker_Processor__c>) scope;
            for (Platform_Event_Tracker_Processor__c event : lstEvents){
                setUniqueRecordIds.add(event.RecordId__c);
            }

            //Update the Opportunities
            list<Opportunity> lstOpps = [Select Id, 
                                            NPN_Solution_Provider_VAR__r.name, NPN_Solution_Provider_VAR_Text__c, 
                                            Primary_NPN_OEM_ODM_Disti__r.name, Primary_NPN_OEM_ODM_Disti_Text__c, 
                                            Preliminary_OEM_ODM_Disti__c, Preliminary_OEM_ODM_Disti_List_Text__c 
                                        From Opportunity 
                                        Where Id = :setUniqueRecordIds];
            for (Opportunity opp : lstOpps ){
                opp.NPN_Solution_Provider_VAR_Text__c = string.isNotBlank(opp.NPN_Solution_Provider_VAR__c) ? opp.NPN_Solution_Provider_VAR__r.name.toLowercase() : '';
                opp.Primary_NPN_OEM_ODM_Disti_Text__c = string.isNotBlank(opp.Primary_NPN_OEM_ODM_Disti__c) ? opp.Primary_NPN_OEM_ODM_Disti__r.name.toLowercase() : '';
                opp.Preliminary_OEM_ODM_Disti_List_Text__c = string.isNotBlank(opp.Preliminary_OEM_ODM_Disti__c) ? opp.Preliminary_OEM_ODM_Disti__c.toLowercase() : '';
            }

            system.debug('***lstOpps > ' + lstOpps);
            system.debug('***Begin: Update the Opportunities');
            Database.SaveResult[] lstSR = Database.update(lstOpps, false);
            system.debug('***End: Update the Opportunities');

			for (Database.SaveResult sr : lstSR) {
				if (sr.isSuccess()) {
				    // Operation was successful, so get the ID of the record that was processed
				     system.debug('Successfully Updated Opportunity: ' + sr.getId());
                     lstProcessedRecordIds.add(sr.getId());
				}else {
                    system.debug('***Opportunuty Update failed> ' + sr.getErrors());  
                    /*
				    // Operation failed, so get all errors
                    system.debug('Begin: Logging Errors in NV_Log__c');            
				    for(Database.Error err : sr.getErrors()) {
                        NV_Log__c nvlog = new NV_Log__c(Component_Name__c   = 'NPNOEMODMDISTI',
                            Functionality_Name__c   = 'Opp_NPNOEMODMDISTI_Event_Tracker_Bat',
                            Method_Name__c          = 'execute',
                            Error_Message__c = '' + err.getMessage(),
                            Error_Description__c    = '' + err.getStatusCode() + '-' + err.getFields(),
                            Log_Type__c         = 'Error: Batch',
                            Record_ID__c        = '' + sr.getId(),     
                            Status__c               = 'Error'
                        );
                        insert nvlog;
				    }
                    system.debug('End: Logging Errors in NV_Log__c');
                    */
				}
			}
        }
        system.debug('---------Exiting Batch Job Opp_NPNOEMODMDISTI_Event_Tracker_Bat execute method-------------------');
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('---------Entering Batch Job finish method-------------------');
        system.debug('****lstProcessedRecordIds: ' + lstProcessedRecordIds);
        if (lstProcessedRecordIds.size() > 0){
            List<Platform_Event_Tracker_Processor__c> lstEventsUpd =  [SELECT Id
                                                                        FROM Platform_Event_Tracker_Processor__c
                                                                        WHERE Processed__c = false
                                                                            AND EventName__c = :EVENTNAME
                                                                            AND RecordId__c = :lstProcessedRecordIds
                                                                        ];
            for (Platform_Event_Tracker_Processor__c event :lstEventsUpd){
                event.Processed__c = true;
                event.ProcessedDate__c = datetime.now();
            }

            database.update(lstEventsUpd, false);
        }
        system.debug('---------Exiting Batch Job finish method-------------------');
    }
    
}