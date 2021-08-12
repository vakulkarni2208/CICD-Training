/**************************************************************************************************
* Name       : TriggerUser
* Purpose    : Trigger for User object
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/12/2017      | Initial Draft
**************************************************************************************************/
trigger TriggerUser on User (after insert, after update) {
    
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            TriggerUserHelper.AfterCreate(Trigger.New , Trigger.newMap);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            TriggerUserHelper.AfterUpdate(Trigger.Old, Trigger.oldMap, Trigger.New, Trigger.newMap);
        }
    }
    
    //Venkat G-calling a future method to send partner user details to EMS system-start

    if(Trigger.isInsert || Trigger.isUpdate){
        if(Trigger.isAfter){
            List<Id> userIdsList =new List<Id>();
            for(user userObj:Trigger.new){
                if(userObj.contactId!=null)
                    userIdsList.add(userObj.id);
            }
            System.enqueueJob(new QueableClassForEMSService(userIdsList,'User'));
        }
    }
    //Venkat G-calling a future method to send partner user details to EMS system-end
        
    
}