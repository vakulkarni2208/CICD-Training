/*----------------------------------------------------------------------------------------------------------------------------------------------------
Class Name : NGC_Registry_Trigger_Handler. Related to object DGX_Registry_Container__c
Description : This is a Trigger handler class for NGC_Registry (DGX_Registry_Container__c) object.

Date        Version    Modified by        Change details
-------     -------    -------------      --------------------------------------------------------
23-5-2019     1.0      Nilesh Adkar        SDS-1415 : Trigger methods added.
  
------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public class NGC_Registry_Trigger_Handler extends NV_TriggerHandler {

private List<DGX_Registry_Container__c> lstNewReg;
private Map<Id,DGX_Registry_Container__c> oldMap;
private Map<Id,DGX_Registry_Container__c> newMap;
private List<DGX_Registry_Container__c> lstOldReg;

public override void init() {
     lstNewReg = new List<DGX_Registry_Container__c>();
     lstOldReg = new List<DGX_Registry_Container__c>();
     
     lstNewReg = Trigger.new;
     lstOldReg = Trigger.old;
     if(!Trigger.isInsert && !Trigger.isBefore)
         newMap = new Map<Id,DGX_Registry_Container__c>(lstNewReg);
     if(!Trigger.isInsert)
         oldMap = new Map<Id,DGX_Registry_Container__c>(lstOldReg);    
}

public override void beforeInsert(){
    NGC_Registry_Helper.associateContactAndAccountWithNGC_Registry(lstNewReg);
}

public override void beforeUpdate(){
    NGC_Registry_Helper.associateContactAndAccountWithNGC_Registry(lstNewReg);
}

public override void afterInsert(){

}

public override void afterUpdate(){

}

}