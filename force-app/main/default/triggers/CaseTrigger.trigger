trigger CaseTrigger on Case (before insert,before update,after insert, after update) {
    CaseTriggerHelper helper = new CaseTriggerHelper(); 
    helper.execute();
 /* Old Code 
    -- CaseTriggerHelper.updateProductFamily(trigger.oldMap,trigger.new);
    --if(trigger.isinsert && trigger.isAfter && !CaseTriggerHelper.EXECUTE_ASSIGNMENT){
    --    CaseTriggerHelper.EXECUTE_ASSIGNMENT = true;
    --    CaseTriggerHelper.executeCaseAssignment(trigger.New); 
    --}
    --if((trigger.isInsert || trigger.isUpdate) && trigger.isBefore){
       -- if(trigger.isUpdate){
       --     CaseTriggerHelper.escalateCase(trigger.New, trigger.oldMap);
       -- }
       -- CaseTriggerHelper.updatesOnOwnerChange(trigger.New, trigger.oldMap); 
       -- CaseTriggerHelper.updateStatus(trigger.New, trigger.oldMap);
       -- CaseTriggerHelper.updateAccountRegion(trigger.New, trigger.oldMap);
    --}
    --if(trigger.isUpdate && trigger.isAfter) {
    --    CaseTriggerHelper.milestoneUpdates(trigger.New, trigger.oldMap);
    --} 
*/
    //if(trigger.isUpdate && trigger.isAfter) {
    //    CaseTriggerHelper.caseOwnerQueueUpdate(trigger.New, trigger.oldMap);
    //}
}