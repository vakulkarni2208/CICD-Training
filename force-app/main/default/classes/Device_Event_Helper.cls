/*----------------------------------------------------------------------------------------------------------------------------------------------------
Class Name : Device_Event_Helper. Related to object Device_Event__c
Description : This is a Trigger handler class for Device Event object.

Date        Version    Modified by        Change details
-------     -------    -------------      --------------------------------------------------------
06-09-2019    1.0      Gagan Brar        SDS-1096: NV System Call Home (Phase 1) 
  
------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public class Device_Event_Helper extends NV_TriggerHandler{

    private List<Device_Event__c> lstNew;
    private Map<Id,Device_Event__c> oldMap;
    private Map<Id,Device_Event__c> newMap;
    private List<Device_Event__c> lstOld;

    public override void init() {
        lstNew = new List<Device_Event__c>();
        lstOld = new List<Device_Event__c>();
         
        lstNew = Trigger.new;
        lstOld = Trigger.old;
        if(!Trigger.isInsert && !Trigger.isBefore)
            newMap = new Map<Id,Device_Event__c>(lstNew);
        if(!Trigger.isInsert)
            oldMap = new Map<Id,Device_Event__c>(lstOld);
    }
    
    public override void beforeInsert(){
        Device_Event_Helper.NewdeviceEvent(lstNew);
    }
    
    public override void beforeUpdate(){
        //Device_Event_Helper.TBD(lstNewReg);
    }
    
    public override void afterInsert(){}
    
    public override void afterUpdate(){}
    
    public static void NewdeviceEvent(List<Device_Event__c> lstNew){
        List<Device_Event__c> deviceEventsToUpdate;
            
        for(Device_Event__c evnt : lstNew){
            List<Asset> ast = [SELECT id, AccountId, Serial_Number__c, Product2.Product_Line__c, Product2.Family, (Select Id from Entitlements where Status = 'Active') FROM Asset WHERE id =: evnt.Asset__c];
            if (evnt.Severity__c == 'Cleared'){
                if (evnt.Batch_Id__c == null){
                        evnt.Case__c = CreateCaseForDeviceEvent(evnt, ast[0]).Id;
                        evnt.Case_Flow_Outcome__c ='Cleared Device Event, with no batch Id';
                    } else {
                        List<Device_Event__c> prdevlist = [SELECT id, Case__c FROM Device_Event__c WHERE Batch_Id__c =: evnt.Batch_Id__c AND Case__c != Null ORDER BY Name DESC];
                        if (prdevlist.size() > 0){
                            evnt.Case__c = prdevlist[0].Case__c;
                            evnt.Case_Flow_Outcome__c = 'Cleared Device Event, Linked to an existing case';
                        } else {
                            evnt.Case_Flow_Outcome__c = 'Cleared Device Event, No action taken';                   
                        }
                    }
            } else {
                if (evnt.Asset__c != null){
                    if (evnt.Batch_Id__c == null){
                        evnt.Case__c = CreateCaseForDeviceEvent(evnt, ast[0]).Id;
                        evnt.Case_Flow_Outcome__c ='New Cases Created';
                    } else {
                        List<Device_Event__c> prdevlist = [SELECT id, Case__c FROM Device_Event__c WHERE Batch_Id__c =: evnt.Batch_Id__c AND Case__c != Null ORDER BY Name DESC];
                        if (prdevlist.size() > 0){
                            evnt.Case__c = prdevlist[0].Case__c;
                            evnt.Case_Flow_Outcome__c ='Linked to an existing case';
                        } else {
                            evnt.Case__c = CreateCaseForDeviceEvent(evnt, ast[0]).Id;
                            evnt.Case_Flow_Outcome__c ='New Cases Created';
                        }
                    }
                } else {
                        evnt.Case_Flow_Outcome__c ='Asset not availabe, No action taken';
                }      
            }
        }
    }
    
    public static Case CreateCaseForDeviceEvent(Device_Event__c evnt, Asset asst){
        Id acctId = asst.AccountId;
        String rtName = CaseTriggerHelper.COMM_CASE_RT_DEV_NAME;
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:rtName];
        
        Case c = new Case();
        c.RecordTypeId = rt.Id;
        c.AccountId = acctId;
        c.Severity__c = 'S3:_Moderate';
        c.Status = 'New';
        c.Origin = 'System';
        c.Incident_Status__c = 'Awaiting Agent Assignment';
        c.Priority = 'P3';
        c.Product_Category__c = (asst.Product2.Product_Line__c == 'Automotive Datacenter' && asst.Product2.Family == 'DRIVE Constellation') ? 'DRIVE Constellation' : asst.Product2.Product_Line__c;
        c.Product_Family__c = asst.Product2.Family;
        c.AssetId = evnt.Asset__c; //3. Query Asset and get Product Category evnt.Asset__r.Product.Product_Category__c
        c.Subject = 'NVSM CALL HOME | ' + evnt.Message__c; 
        c.Description = evnt.Message_Details__c + '\n' + evnt.Presigned_URL__c;
        c.BusinessHoursId = '01m40000000CdpN';
        System.debug('asst = ' + asst);
        System.debug('asst.Entitlements = ' + asst.Entitlements);
        
        if(asst != Null && asst.Entitlements != Null && asst.Entitlements.size() == 1){
            c.EntitlementId = asst.Entitlements[0].id;
        }
        
        if (evnt.Contact_Email__c != NULL){
            c.SuppliedEmail = evnt.Contact_Email__c;
            List<Contact> cntlst = [SELECT id, email FROM Contact WHERE email =: evnt.Contact_Email__c AND accountid =: acctId ORDER BY Community_User_Type__c DESC NULLS LAST];
            if (cntlst.size() > 0){
                c.ContactId = cntlst[0].id;
            }
        }
        
        try {
            insert c;
        } 
        catch(DmlException ex) {
            System.debug('The following exception has occurred: ' + ex.getMessage());
            NV_Log__c nvlog = new NV_Log__c(Component_Name__c 	= 'Device_Event_Helper',		Error_Description__c	= ''+ex.getStackTraceString(),
                                    		Error_Message__c	= ''+ex.getMessage(),			Functionality_Name__c   = 'Device_Event_Helper',
                                    		Log_Type__c         = 'Error: Trigger',				Method_Name__c          = 'CreateCaseForDeviceEvent',
                                    		Record_ID__c        = ''+evnt.Id,					Status__c           	= 'Exception'
                                );
            insert nvlog;
        }
        return c;
    }
}