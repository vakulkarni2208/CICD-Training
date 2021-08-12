/**
 * A Utility Class to add all code common for all teams.
 * Created: 10/20/2019 - Akhilesh Gupta | 
 * Update:  10/20/2019 - Akhilesh Gupta | Added Functions for Public Group/Queues.
  
 */

public with sharing class NV_Utility {
	
	/*Start: Functions to get Public Group and Queue Details. */
	private static map<string, Id> allPublicGroupsByDevName = new map<string, Id>();
	private static map<string, Id> allPublicGroupsByName = new map<string, Id>();
	//Find Group/Queue by Developer Name
	public static Id getPublicGroupsOrQueueIdByDevName(String name){
		getPublicGroupAndQueuesByName();
		return allPublicGroupsByDevName.get(name);
	}
	//Find Group/Queue by Name
	public static Id getPublicGroupOrQueueIdByName(String name){
		getPublicGroupAndQueuesByName();
		return allPublicGroupsByName.get(name);
	}
	//Query all Public Groups and Queue
	private static void getPublicGroupAndQueuesByName(){
		if (allPublicGroupsByName == null || allPublicGroupsByName.isEmpty()){
			list<Group> lstPGs = [Select Name, DeveloperName From Group 
									where Type in ('Regular', 'Queue')];
	    	
			for (Group grp : lstPGs){
				allPublicGroupsByName.put(grp.Name, grp.Id);
				allPublicGroupsByDevName.put(grp.DeveloperName, grp.Id);
			}
		}
	}
	/*End: Functions for Public Group and Queue */
	
	/*Funtion to get Batch Job settings*/
    public static map<String, NV_Batch_Job_Setting__mdt> batchJobSettingMap = null;
    public static map<String, NV_Batch_Job_Setting__mdt> getbatchJobSettings(){
        if(batchJobSettingMap == null){
            batchJobSettingMap = new map<String, NV_Batch_Job_Setting__mdt>();
            for(NV_Batch_Job_Setting__mdt setting : [SELECT Id, MasterLabel, DeveloperName, Batch_Size__c
            											, Disable_Job__c, Frequency__c, Lookback_Time__c 
                                                	FROM NV_Batch_Job_Setting__mdt]){
                batchJobSettingMap.put(setting.MasterLabel, setting);
            }
        }
        return batchJobSettingMap;
    }
    
    public static NV_Batch_Job_Setting__mdt getbatchJobSetting(String Name){
        if(batchJobSettingMap == null)
            getbatchJobSettings();
        
        return batchJobSettingMap.get(Name);
    }
}