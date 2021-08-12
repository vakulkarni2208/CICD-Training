public with sharing class BatchApexErrorEvent_tgr_cls extends NV_TriggerHandler {
    private static list<BatchApexErrorEvent> newRecords;
    
    public override void init() { 
        OBJECT_NAME = 'BatchApexErrorEvent';
        newRecords 	= trigger.New;
        //System.debug('New Records' + newRecords + '1'); 
    }
    public override void afterInsert() {
    	system.debug('20191213 1');
    	BatchApexErrorEvent_tgr_cls.logErrors();
    }
    
    private static void logErrors() {
    	try {
	    	List<NV_Log__c> logs = new List<NV_Log__c>();
	    	system.debug('20191213 2');
	    	set<Id> jobIds = new set<Id>();
	    	for(BatchApexErrorEvent event : newRecords) {
	    		jobIds.add(event.AsyncApexJobId);
	    	}
	    	
	    	map<Id, AsyncApexJob> asyncJobMap = new map<Id, AsyncApexJob>([SELECT Id, ApexClass.Name,CreatedDate,ExtendedStatus,JobItemsProcessed,JobType,LastProcessed,LastProcessedOffset,MethodName,NumberOfErrors,ParentJobId,Status,TotalJobItems 
	    											FROM AsyncApexJob where id in: jobIds]);
	    	
		    for(BatchApexErrorEvent event : newRecords) {
		    	NV_Log__c nvlog 			= new NV_Log__c();
		        nvlog.Job_ID__c				= event.AsyncApexJobId;
		    	nvlog.Record_ID__c			= event.JobScope;
			    nvlog.Error_Description__c	= event.StackTrace;
		        nvlog.Error_Message__c		= event.Message;
		        
		        AsyncApexJob asyncJob		= asyncJobMap.get(event.AsyncApexJobId);
		        nvlog.Log_Type__c			= asyncJob.JobType;//'Error: Batch';
		    	nvlog.Component_Name__c		= asyncJob.ApexClass.Name;
	            nvlog.Functionality_Name__c	= asyncJob.ApexClass.Name;
	            nvlog.Method_Name__c		= asyncJob.methodname;
	            nvlog.Error_Message__c	   += ', [Extended Status]: ' + asyncJob.ExtendedStatus + ', [Exception Type]: '+ event.ExceptionType;
	            nvlog.Status__c				= 'Exception';
	            
	            logs.add(nvlog);
		    }
		    
		    if (!logs.isEmpty()) {
			    insert logs;
		    }
	    } catch (Exception ex) {
            system.debug('20191213 6');
            //for(BatchApexErrorEvent ent : (list<BatchApexErrorEvent>)scope) {
            map<Id, BatchApexErrorEvent> recordsMap = new map<Id, BatchApexErrorEvent>();
            recordsMap.putAll((list<BatchApexErrorEvent>)newRecords);
            NV_Log__c nvlog = new NV_Log__c(Component_Name__c 	= 'BatchApexErrorEvent_tgr_cls',Error_Description__c	= ''+ex.getStackTraceString(),
                                    		Error_Message__c	= ''+ex.getMessage(),			Functionality_Name__c   = 'BatchApexErrorEvent_tgr_cls',
                                    		Log_Type__c         = 'Error: Batch',				Method_Name__c          = 'afterInsert',
                                    		Record_ID__c        = ''+recordsMap.keySet(),		Status__c           	= 'Exception'
                                );
            insert nvlog;
            //}
        }
    }
}