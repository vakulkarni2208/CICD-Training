public virtual class NV_TriggerHandler implements NV_TriggerHandlerInterface {
    
    public static boolean skipTriggerActions = ESP_Utility.ESPConstants.ServiceCloudSettings.Disable_Trigger_Actions__c;
    public String OBJECT_NAME;
    
    //public set<String> restrictedAction = new set<String>();
    public virtual void init(){
        //System.debug('Init Parent');
    }
    public virtual void beforeInsert(){
        //System.debug('before Insert Parent');
    }
    public virtual void beforeUpdate(){
        //System.debug('before Update Parent');
    }
    public virtual void beforeDelete(){
        //System.debug('before Delete Parent');
    }
    public virtual void afterInsert(){
        //System.debug('after Insert Parent');
    }
    public virtual void afterUpdate(){
        //System.debug('after Update Parent');
    }
    public virtual void afterDelete(){
        //System.debug('after Delete Parent');
    }
    public virtual void afterUndelete(){
        //System.debug('after Delete Parent');
    }
	
    public virtual void execute(){
        System.debug(' Execute Parent: '+ OBJECT_NAME);
        if(skipTriggerActions)
            return;
        
        this.init();
        
        //if(OBJECT_NAME != null) {
        //  setRestrictedPermission(OBJECT_NAME);
        //}
        
        if (Trigger.isBefore) {
            System.debug('Execute Before Parent: '+ OBJECT_NAME);
            if (Trigger.isInsert) {
                System.debug('Execute Before Insert Parent: '+ OBJECT_NAME);
                this.beforeInsert();
            }
            if (Trigger.isUpdate) {
                System.debug('Execute Before Update Parent: '+ OBJECT_NAME);
                this.beforeUpdate();
            }
            if (Trigger.isDelete) {
                System.debug('Execute Before Delete Parent: '+ OBJECT_NAME);
                //if(restrictedAction.contains('Delete'))
                    //throw new TriggerHandlerException('Delete is not allowed for this record.');
                this.beforeDelete();
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                System.debug('Execute After Insert Parent: '+ OBJECT_NAME);
                this.afterInsert();
            }
            if (Trigger.isUpdate) {
                System.debug('Execute After update Parent: '+ OBJECT_NAME);
                this.afterUpdate();
            }
            if (Trigger.isDelete) {
                System.debug('Execute After Delete Parent: '+ OBJECT_NAME);
                this.afterDelete();
            }
        }
    }
    /*
    public void setRestrictedPermission(String OBJECT_NAME) {
        
        //Find Custom Setting for "Object"
        //list<NV_TriggerSettings__mdt> NVTriggerSettingsList = null;//[Select ID,  Object_Name__c, Permission_Restricted__c,Profile_Allowed__c from NV_TriggerSettings__mdt];
        NV_TriggerSettings__mdt NVTriggerSettingsList = null;
        for (NV_TriggerSettings__mdt NVTriSett : [Select ID, Object_Name__c, Permission_Restricted__c,Profile_Allowed__c from NV_TriggerSettings__mdt]){
            if(NVTriSett.Object_Name__c == OBJECT_NAME){
                NVTriggerSettingsList.Object_Name__c = NVTriSett.Object_Name__c;
                NVTriggerSettingsList.Permission_Restricted__c = NVTriSett.Permission_Restricted__c;
                NVTriggerSettingsList.Profile_Allowed__c = NVTriSett.Profile_Allowed__c;
            }
        }
        //Check loggedin User profile
        //Userinfo.getUserid()
        Profile PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        //String MyProflieName = PROFILE.Name;
        
        //Set Action from Custom Setting
        if(NVTriggerSettingsList != null && NVTriggerSettingsList.Profile_Allowed__c != PROFILE.Name )
        restrictedAction.add(NVTriggerSettingsList.Permission_Restricted__c);
    }
    
    public class TriggerHandlerException extends Exception{}
    */
}