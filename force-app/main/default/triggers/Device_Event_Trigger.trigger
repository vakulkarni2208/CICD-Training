/*----------------------------------------------------------------------------------------------------------------------------------------------------
Trigger Name : Device_Event_Trigger. Related to object Device_Event__c
Description : This is a Trigger for Device Event object.

Date        Version    Modified by        Change details
-------     -------    -------------      --------------------------------------------------------
06-09-2019    1.0      Gagan Brar        SDS-1096: NV System Call Home (Phase 1) 
  
------------------------------------------------------------------------------------------------------------------------------------------------------
*/
trigger Device_Event_Trigger on Device_Event__c (before insert, before update, after insert, after update) {
    Device_Event_Helper helper = new Device_Event_Helper();
    helper.execute();
}