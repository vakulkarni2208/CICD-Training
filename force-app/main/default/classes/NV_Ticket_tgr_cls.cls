public class NV_Ticket_tgr_cls extends NV_TriggerHandler {

    public list<NV_Ticket__c> oldRecords;
    private static list<NV_Ticket__c> triggerNewList;
    private static map<Id, NV_Ticket__c> mapTriggerOld;
    
    public override void init() { 
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, NV_Ticket__c>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
    }
    
    public override void afterInsert() {
        NV_Ticket__c NVTicket= (NV_Ticket__c)Trigger.new[0];
        system.debug('**' + NVTicket.NVBug_Number_Formula__c);
        if(NVTicket.Type__c=='NVBug' && ((NVTicket.Bug_no_in_NVBug_Not_in_SFDC__c!=null) || (NVTicket.NVbug__c!=null && NVTicket.NVBug_Number_Formula__c.isnumeric())) && NVTicket.IsApplicationIntegrationEntryCreated__c==false){
            string strNVTicket= JSON.serialize(NVTicket);
            NVBugOperations.LinkBug(strNVTicket);
        }
    }

}